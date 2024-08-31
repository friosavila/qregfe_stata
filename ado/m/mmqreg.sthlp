{smcl}
{* *! version 2.0 June 2022}{...}
{cmd:help mmqreg} 

{hline}

{title:Title}

{p2colset 8 18 19 2}{...}
{p2col :{cmd: mmqreg} {hline 2}} MM-Quantile regression {p_end}
{p2colreset}{...}


{title:Syntax}

{phang}

{p 8 13 2}
{cmd:mmqreg} {depvar} {indepvars} {ifin} [aw] [{cmd:,} {it:options}]


{synoptset 25 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}

{synopt :{opt q:uantile(#[#[# ...]])}}estimate {it:#} quantile(s), where 0<#<100; default is {cmd:quantile(50)}. Multiple quantiles can be specified.{p_end}

{synopt:{opt abs:orb(varlist)}}specifies the variable(s) to be absorbed in the estimation. Default is to absorb no variables.{p_end}

{synopt :{opt denopt(denmethod bwidth)}}specifies the method for density and bandwidth estimation. See {it:{help qreg##qreg_method:denmethod}} 
and {it:{help qreg##qreg_bwidth:bwidth}}. Defaults are {cmd:bwmethod}="hsheather" and {cmd:denmethod}="fitted".{p_end}

{synopt :{opt dfadj}}requests degrees of freedom adjustment equal to k+absc, where k is the number of variables (including constant) in the model, and 
absc is the number of absorbed coefficients.{p_end}

{synopt :{opt nowarning}}suppresses warnings when the scale function predicts negative values.{p_end}

{synopt :{opt ls}}displays the location or scale coefficients. Default is not to show them.{p_end}

{synopt :{opt robust}}reports heteroskedasticity-robust standard errors based on the White-Huber estimator. The default assumes a correctly specified Scale model.{p_end}

{synopt :{opt cluster(cvar)}}reports clustered standard errors. Only accepts one-way clustering.{p_end}

{synopt :{opt boot}[(bootstrap_options)]}computes bootstrap standard errors using {it:bootstrap_options}. Default is to produce standard errors based on {it:qmethod()}. For {cmd:mmqreg}, default standard errors are GLS-SE.{p_end}

{synopt :{opt parallel}}uses parallel processing for bootstrap. Requires {cmd:parallel}.{p_end}

{synopt :{opt parallel_cluster(#)}}specifies number of parallel clusters; default is 2.{p_end}

{synoptline}
{p2colreset}{...}
{phang} {it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{phang}{cmd:mmqreg} allows for {cmd:aweight}.{p_end}


{title:Description}

{pstd}
{cmd:mmqreg} estimates quantile regressions using the method of moments as described in Machado and Santos Silva (2019), extending the methodology to allow for multiple fixed effects. Compared to {help xtqreg}, {cmd:mmqreg} offers three additional features:{p_end}

{pstd}1. Estimation of Location-Scale quantile regressions without fixed effects.{p_end}
{pstd}2. Estimation of LS quantile regression absorbing multiple fixed effects using the {cmd:hdfe} command.{p_end}
{pstd}3. Joint estimation of various quantiles, facilitating coefficient testing across quantiles using resampling methods like bootstrap or analytical standard errors.{p_end}

{pstd}Unlike {help xtqreg}, standard errors for quantiles, location, and scale effects can be estimated with degrees of freedom adjustment.{p_end}

{pstd}As a GMM estimator, {cmd:mmqreg} provides three options for standard errors: default (same as {cmd:xtqreg}), robust, and clustered.{p_end}

{title:Remarks}

{pstd}
{cmd:mmqreg} provides asymptotic approximations for coefficient correlations across quantiles and offers different standard error options. However, consider using resampling methods for additional robustness.{p_end}

{pstd}The author thanks J.M.C. Santos Silva for clarifying details of the estimation methodology. All errors are the author's own.{p_end}

{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{stata webuse nlswork, clear}{p_end}

{pstd}Required additional commands:{p_end}
{phang2}{stata ssc install xtqreg}{p_end}
{phang2}{stata ssc install ftools}{p_end}
{phang2}{stata ssc install hdfe}{p_end}

{pstd}Median regression with fixed effects for idcode using {cmd:xtqreg}{p_end}
{phang2}{stata xtqreg ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure not_smsa south, i(idcode) ls}{p_end}

{pstd}Median regression with fixed effects for idcode using {cmd:mmqreg}{p_end}
{phang2}{stata mmqreg ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure not_smsa south, abs(idcode)}{p_end}

{pstd}25th and 75th quantile regression with fixed effects for idcode using {cmd:mmqreg}{p_end}
{phang2}{stata mmqreg ln_w age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure not_smsa south, abs(idcode) q(25 75)}{p_end}

{pstd}Comparing {cmd:mmqreg} with and without fixed effects{p_end}
{phang2}{stata "use http://fmwww.bc.edu/RePEc/bocode/o/oaxaca.dta, clear"}{p_end}

{phang2}{stata mmqreg lnwage i.female educ exper tenure i.isco, q(25 75)}{p_end}
{phang2}{stata mmqreg lnwage i.female educ exper tenure, q(25 75) abs(isco)}{p_end}
{phang2}{stata mmqreg lnwage educ exper tenure, q(25 75) abs(isco female)}{p_end}

    {hline}
 
{title:References}

{phang}Machado, J.A.F. and Santos Silva, J.M.C. (2019), 
{browse "https://doi.org/10.1016/j.jeconom.2019.04.009":Quantiles via Moments}, 
{it:Journal of Econometrics}, 213(1), pp. 145-173.{p_end} 

{phang}Rios-Avila, Fernando, Siles, Leonardo and Canavire-Bacarreza, Gustavo (2024), 
Extending Quantile Regressions via Method of Moments Using Multiple Fixed Effects. IZA Working Paper.
{p_end} 

{title:Also see}

{help xtqreg}, {help hdfe}, {help ftools}