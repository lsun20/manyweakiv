*! version 0.1  23aug2023  Liyang Sun, lsun20@cemfi.es
*! version 0.0  25apr2021  Liyang Sun, lsun20@mit.edu


capture program drop manyweaktest
program define manyweaktest, eclass sortpreserve
	version 13 
	syntax varlist(min=1 numeric) [if] [in] [aweight fweight], instr(varlist numeric ts fv) ///
	[NOConstant COVARIATEs(varlist numeric ts fv)]
	set more off
//
// 	* Mark sample (reflects the if/in conditions, and includes only nonmissing observations)
// 	marksample touse
// 	markout `touse' `by' `xq' `covariates', strok
	* Parse the dependent variable
	local endog: word 1 of `varlist'
// 	local instr: list varlist - endog
	tempname x h xtilde
	
// 		dis "`covariates'"
dis "`noconstant'"
	qui regress `endog' `covariates', `noconstant' // partial out controls from X (if empty, then partial out the constant term)
	predict double `x', residual
	
	local instr_partialed ""
// 	dis "`instr'"
	qui mvreg `instr' = `covariates', `noconstant' // partial out controls from Z
	local k = 1
	foreach z of varlist `instr' {
		tempvar z`k'
// 			dis "`z'"
		predict double `z`k'', residual equation(#`k') // partial out controls from Z
		local instr_partialed "`instr_partialed' `z`k''"
	local k = `k' + 1

	}
	
	** now the endogenous varibale and instruments have controls partialled out

	** first-stage regression
	qui regress `x' `instr_partialed', nocons // the constant term is already partialled out 
	predict double `h', hat // leverage Z_i'(Z'Z)^-1 Z_i
	predict double `xtilde', // predicted value Z\hat{pi}
	** move to mata for matrix calculation
	mata: Fhat_fun("`instr_partialed'","`xtilde'","`x'","`h'")

	dis "The many-instruments F test (5%) rejects if following statistic is greater than 4.14:"
	dis `r(F)' 
	
	ereturn clear
	ereturn scalar Fhat = `r(F)'
	ereturn scalar Sigma_hh = `r(Sigma1_hh)'

end


mata:
void Fhat_fun(
        string scalar Z_name,			///
		string scalar Zhat_name,		///
		string scalar X_name,			///
		string scalar H_name			///
)
{
			Z = st_data(.,Z_name)
			Zhat = st_data(.,Zhat_name)
			X = st_data(.,X_name)
			H = st_data(.,H_name)
			N = rows(Z)
			K = cols(Z)
			M_diag = J(N,1,1)-H
			ZZ_inv = qrinv(Z'*Z)
			ZZZ_inv = Z*ZZ_inv

			XMX = X:*X - X:*Zhat

			Sigma1_hh = 0
			for (i=1; i<=N; i++) {
				if (mod(i,10000) == 0) {
					printf("Finished %g observations\n",i)
					printf("Sigma1_hh=%g\n",Sigma1_hh)

				}
				Zi = Z[i,]
				Pi = ZZZ_inv * Zi'
				PP = Pi:^2
				PP_off = (PP):/((1-H[i])*M_diag + PP)
				PP_off[i]=0
				Sigma1_hh = Sigma1_hh + XMX[i]*PP_off'*XMX
			}
			Fhat = (X'*Zhat - sum(X:*X:*H))/sqrt(K)/sqrt(2*Sigma1_hh/K)
// 			Fhat
			st_numscalar("r(F)", Fhat)
			st_numscalar("r(Sigma1_hh)", Sigma1_hh)
}
end


