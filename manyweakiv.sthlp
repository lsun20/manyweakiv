{smcl}
{* *! version 0.0  2may2020}{...}
{viewerjumpto "Syntax" "manyweakiv##syntax"}{...}
{viewerjumpto "Description" "manyweakiv##description"}{...}
{viewerjumpto "Options" "manyweakiv##options"}{...}
{viewerjumpto "Examples" "manyweakiv##examples"}{...}
{viewerjumpto "Saved results" "manyweakiv##saved_results"}{...}
{viewerjumpto "Author" "manyweakiv##author"}{...}
{viewerjumpto "Acknowledgements" "manyweakiv##acknowledgements"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:manyweakiv} {hline 2}}
implements the weak-identification robust jackknife AR test from Mikusheva and Sun (2021).  
The companying command {helpb manyweaktest} implements a new pre-test that is 
analogous to analogous to that of Stock and Yogo (2005) first stage F test,
 but robust to many instruments and heteroscedasticity.
{p_end}
{p2colreset}{...}
 
{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:manyweakiv}
{y} {x} {ifin}
{weight} {cmd:,} {opth i:nstr(manyweakiv##instr:variable)}
            {opt n:oconstant} 
 [{it:options} {opth c:ovariates(manyweakiv##covariates:varlist)}]
 
{p 8 15 2}
{cmd:manyweaktest}
{x} {ifin}
{weight} {cmd:,} {opth i:nstr(manyweakiv##instr:variable)}
            {opt n:oconstant} 
 [{it:options} {opth c:ovariates(manyweakiv##covariates:varlist)}]

{pstd}
where {it:x} is a scalar endogeneous variable.
{p_end} 
{synoptset 26 tabbed}{...}

{pstd}

{synopthdr :options}
{synoptline}
{syntab :Must specify}
{marker instr}{...}
{synopt :{opth inst(varname)}}specifies the list of (excluded) instruments.{p_end}

{syntab :Optional}
{synopt :{opt noconstant}}specifies whether an intercept is included (default includes an intercept).{p_end}
{synopt :{opth covariate:s(varlist)}}specifies the list of controls, i.e., included instruments. {p_end}

{syntab :Saved Output}
{pstd}
{opt manyweakiv} reports the jackknife AR confidence interval via analytical test inversion.  
{opt manyweaktest} reports the many-instruments F test.  
In addition, it stores the following in {cmd:e()}:

{synoptset 24 tabbed}{...}

{syntab:Scalar}
{synopt:{cmd:r(F)}}the many-instruments F statistic{p_end}

 
{marker description}{...}
{title:Description}

{pstd}
In empirical applications using instrumental variables, the current consensus 
practice is to report the first stage F statistic and as long as it is above 10, 
researchers are allowed to rely on standard t-statistics inferences. 
This practice has foundations in Stock and Yogo (2005) which showed that the 
concentration parameter fully characterizes the size distortion of the TSLS-Wald test, 
and empirically the concentration parameter can be judged based on the first stage F statistics. 
This result has been obtained under the assumptions of homoscedasticity and 
for a fixed number of instruments.

{pstd}
{opt manyweaktest} implements a new F test that is valid under heteroscedasticity and many instruments.
Based on the result of this new many-instruments F test (cut-off at 4.14), applied researchers can switch between
the 5% JIVE t-statistic (to be implemented) or 5% jackknife AR test (implemented in {opt manyweakiv})
with the caveats analogous to Stock and Yogo (2005): 
Namely, the size of the two-step procedure are bounded within 15%.


{marker examples}{...}
{title:Examples}

{pstd}Simulate group instruments.{p_end}
{phang2}. {stata clear all}{p_end}
{phang2}. {stata set obs 100}{p_end}
{phang2}. {stata gen random  = uniform()}{p_end}
{phang2}. {stata gen group = 0}{p_end}
{phang2}. {stata local k = 10}{p_end}
	{cmd:forval j = 1/`k' {c -(}}
	{cmd:	replace group = `j' if random > (`j'-1)/`k' & random < (`j')/`k' }
	{cmd:{c )-}}
{phang2}. {stata tab group, gen(g_)}{p_end}
{phang2}. {stata gen v = rnormal()}{p_end}
{phang2}. {stata gen w = rnormal()}{p_end}
{phang2}. {stata gen x = 1 + w + v}{p_end}
	
	
{pstd} We use many-instrument F test to assess instruments' strength.  As expected we have weak instruments.{p_end}
{phang2}. {stata manyweaktest x, instr(g_*) covariates(w)}

{pstd} Simulate the outcome for illustrating the jackknife AR test, which as expected return unbounded confidence interval.{p_end}
{phang2}. {stata gen y = 1*x + w + 0.5*v}{p_end}
{phang2}. {stata manyweakiv y x, instr(g_*) covariates(w)}{p_end}

{marker acknowledgements}{...}
{title:Acknowledgements}
  
{pstd}Thank you to the users of early versions of the program who devoted time to reporting
the bugs that they encountered.
 
{marker references}{...}
{title:References}
 

{marker MS2022}{...}
{phang}
Mikusheva, A. and Sun, L. 2021.
Inference with Many Weak Instruments
{p_end}


{marker citation}{...}
{title:Citation and Installation of manyweakiv}

{pstd}{opt manyweakiv} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Poi, B. and Sun, L., 2021.
manyweakiv: weak-instruments robust test for linear IV regressions with many instruments.
{browse "https://github.com/lsun20/manyweakiv":https://github.com/lsun20/manyweakiv}.

{pstd}{opt manyweakiv} can be installed easily via the {helpb github} package, which is available on 
{browse "https://github.com/haghish/github":https://github.com/haghish/github}. {p_end}

{phang2}. {stata github install lsun20/manyweakiv }{p_end}
{phang2}. {stata github update manyweakiv }{p_end}

{marker author}{...}
{title:Author}

{pstd}Liyang Sun{p_end}
{pstd}lsun20@mit.edu{p_end}
