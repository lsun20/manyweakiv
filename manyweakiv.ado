*! version 0.0  25apr2021  Liyang Sun, lsun20@mit.edu

capture program drop manyweakiv
program define manyweakiv, eclass sortpreserve
	version 13 
	syntax varlist(min=1 numeric) [if] [in] [aweight fweight], instr(varlist numeric ts fv) ///
	[NOConstant COVARIATEs(varlist numeric ts fv)]
	set more off
//
// 	* Mark sample (reflects the if/in conditions, and includes only nonmissing observations)
// 	marksample touse
// 	markout `touse' `by' `xq' `covariates', strok
	* Parse the dependent variable
	dis "`varlist'"
	local depvar: word 1 of `varlist'
	local endog: list varlist - depvar
	tempname h y yhat x xhat
	
		dis "`covariates'"
	qui regress `depvar' `covariates', `noconstant' // partial out controls from Y (if empty, then partial out the constant term)
	predict double `y', residual

	qui regress `endog' `covariates', `noconstant' // partial out controls from X (if empty, then partial out the constant term)
	predict double `x', residual
	
	local instr_partialed ""
// 	dis "`instr'"
	local k = 1
	foreach z of varlist `instr' {
		tempvar z`k'
// 			dis "`z'"
		qui regress `z' `covariates', `noconstant' // partial out controls from Z
		predict double `z`k'', residual
		local instr_partialed "`instr_partialed' `z`k''"
	local k = `k' + 1

	}

	
	
	** now the dep, endogenous varibale and instruments have controls partialled out

	** first-stage regression
	qui regress `x' `instr_partialed', nocons // the constant term is already partialled out 
	predict double `h', hat // leverage Z_i'(Z'Z)^-1 Z_i
	predict double `xhat', // predicted value Z\hat{\pi}
	
	** reduced-form regression
	qui regress `y' `instr_partialed', nocons // the constant term is already partialled out 
	predict double `yhat', // predicted value Z\hat{\delta}
	
	** move to mata for matrix calculation
	mata: Sigma_fun("`instr_partialed'","`yhat'","`y'","`xhat'","`x'","`h'")

	dis "The analytical solution to the jackknife AR test inversion are:"
// 	tempname roots Sigma1
	matrix list r(roots)
	matrix list r(Sigma1)
// 	ereturn clear
// 	ereturn matrix r r(roots)'
// 	ereturn matrix S r(Sigma1)'

end


mata:
void Sigma_fun(
        string scalar Z_name,			///
		string scalar Yhat_name,		///
		string scalar Y_name,			///
		string scalar Xhat_name,		///
		string scalar X_name,			///
		string scalar H_name			///
)
{
			Z = st_data(.,Z_name)
			Yhat = st_data(.,Yhat_name)
			Y = st_data(.,Y_name)
			Xhat = st_data(.,Xhat_name)
			X = st_data(.,X_name)
			H = st_data(.,H_name)
			N = rows(Z)
			K = cols(Z)
			H_diag = diag(H)
			M_diag = J(N,1,1)-H
			ZZ_inv = qrinv(Z'*Z)
			ZZZ_inv = Z*ZZ_inv

			XMX = X:*X - X:*Xhat
			YMY = Y:*Y - Y:*Yhat
			YMX = Y:*X - Y:*Xhat
			XMY = X:*Y - X:*Yhat
			XMYYMX = -YMX-XMY
			Sigma1_hh = 0
			Sigma1_gg_0 = 0
			Sigma1_gg_1 = 0
			Sigma1_gg_2 = 0
			Sigma1_gg_3 = 0
			Sigma1_gg_4 = 0
			for (i=1; i<=N; i++) {
				if (mod(i,10000) == 0) {
					printf("Finished %g observations\n",i)

				}
				Zi = Z[i,]
				Pi = ZZZ_inv * Zi'
				PP = Pi:^2
				PP_off = (PP):/((1-H[i])*M_diag + PP)
				PP_off[i]=0
				Sigma1_hh = Sigma1_hh + XMX[i]*PP_off'*XMX
				
				Sigma1_gg_0 = Sigma1_gg_0 + YMY[i]*PP_off'*YMY; 
				Sigma1_gg_1 = Sigma1_gg_1 + 2 * YMY[i]*PP_off'*XMYYMX; 
				Sigma1_gg_2 = Sigma1_gg_2 + 2 * XMX[i]*PP_off'*YMY + XMYYMX[i]*PP_off'*XMYYMX; 
				Sigma1_gg_3 = Sigma1_gg_3 + 2 * XMX[i]*PP_off'*XMYYMX; 
				Sigma1_gg_4 = Sigma1_gg_4 + XMX[i]*PP_off'*XMX;
				
			}
			
			Sigma1 = (Sigma1_gg_0, Sigma1_gg_1, Sigma1_gg_2, Sigma1_gg_3, Sigma1_gg_4)
			Sigma1
			XPX = X'*Xhat - X'*H_diag*X
			YPY = Y'*Yhat - Y'*H_diag*Y
			YPX = Y'*Xhat - Y'*H_diag*X
// 			printf("Ybar' P Ybar=%g, %g, %g\n",YPY, YPX, XPX) 

			crit2 = 1.64^2 // TODO: add in user-specified critical value
			c0 = 2*crit2*Sigma1_gg_0-YPY^2
			c1 = 2*crit2*Sigma1_gg_1+4*YPY*YPX
			c2 = 2*crit2*Sigma1_gg_2-2*YPY*XPX-4*YPX^2
			c3 = 2*crit2*Sigma1_gg_3+4*YPX*XPX
			c4 = 2*crit2*Sigma1_gg_4-XPX^2
			c = polyroots((c0, c1, c2, c3, c4)/K) // normalized by K
			creal = J(1,0,.)
			printf("Coefficients are %g, %g, %g, %g, %g\n",c0, c1, c2, c3, c4) 
			c
			if ( c0>0) { 
				st_matrix("r(roots)", creal) // unbounded CI
				printf("Unbounded confidence interval\n")
			} 
			else {
				for (i=1; i<=4; i++) {
					if (isrealvalues(c[i]) == 1) { 
						creal = (creal, Re(c[i]))
// 						creal
					}
				st_matrix("r(roots)", creal)

				}
			}
			st_matrix("r(Sigma1)", Sigma1)
}
end


