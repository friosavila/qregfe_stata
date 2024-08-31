{smcl}
{* *! version 1.0.0  2024-03-02}{...}
{vieweralsosee "[R] qreg" "help qreg"}{...}
{vieweralsosee "[R] reghdfe" "help reghdfe"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "qregfe##syntax"}{...}
{viewerjumpto "Description" "qregfe##description"}{...}
{viewerjumpto "Options" "qregfe##options"}{...}
{viewerjumpto "Examples" "qregfe##examples"}{...}
{viewerjumpto "Stored results" "qregfe##results"}{...}
{viewerjumpto "References" "qregfe##references"}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:qregfe} {hline 2}}Quantile regression with multiple fixed effects{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:qregfe}
{depvar} [{indepvars}] {ifin} {weight}
{cmd:,} {opt q:uantile(#)} {opt abs(varlist)} [{it:options}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:QRFE Methods}
{synopt :{opt cre}}use Correlated Random Effects estimator{p_end}
{synopt :{opt canay}}use Canay (2011) estimator{p_end}
{synopt :{opt canay(modified)}}use modified Canay estimator{p_end}
{synopt :{opt mmqreg}}use Method of Moments Quantile Regression estimator{p_end}

{syntab:QR Specification}
{synopt :{opt q:uantile(#)}}estimate # quantile; default is q(50). It should follow the requirements of {it:qmethod}. For example {cmd:qrprocess} only accepts numbers between 0-1. {p_end}
{synopt :{opt abs(varlist)}}absorb fixed effects specified in varlist. This is required for all methods except {cmd:mmqreg}{p_end}

{syntab:Other}
{synopt :{opt qmethod(qmethod[, options])}}specify quantile regression method to be used. Default is {cmd: qreg}{p_end}
{synopt :{opt seed(#)}}set random-number seed for replication purposes{p_end}

{syntab:SE/Robust}
{synopt :{opt boot}[(bootstrap_options)]}computes bootstrap standard errors, using {it:bootstrap_options}. Bootstrap options follow Stata's syntax. The default is to produce standard errors that {it:qmethod()} defaults into. If using {cmd:mmqreg}, Default standard errors are GLS-SE{p_end}
{synopt :{opt parallel}}use parallel processing for bootstrap. Requires {cmd:parallel} {p_end}
{synopt :{opt parallel_cluster(#)}}specify number of parallel clusters; default is 2{p_end}

{syntab:mmqreg Specific options}
{synopt :{opt robust}}robust standard errors for mmqreg{p_end}
{synopt :{opt cluster(varname)}}clustered standard errors for mmqreg{p_end}
{synopt :{opt dfadj}}use small-sample degrees-of-freedom adjustment{p_end}
{synopt :{opt denopt(denmethod)}}specify density estimation method for mmqreg{p_end}
{synopt :{opt ls}}display location and scale coefficients for mmqreg{p_end}

{synoptline}
{p 4 6 2}
{opt pweight}s are allowed only when using {cmd: mmqreg} method; see {help weight}.{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:qregfe} estimates quantile regression models with multiple fixed effects. It implements several estimators:
Correlated Random Effects (CRE), Canay (2011), a modified version of Canay's estimator, and 
Method of Moments Quantile Regression (MMQREG). The command allows for absorbing multiple fixed effects
and provides options for bootstraping standard errors.

{pstd}
An earlier version of the {cmd:mmqreg} is also available as an independent command. see {help mmqreg} for details. 

{marker examples}{...}
{title:Examples}

{pstd}Estimate median regression with individual fixed effects using CRE:{p_end}
{phang2}{cmd:. qregfe wage educ exper, q(50) abs(id) cre}

{pstd}Estimate 75th quantile regression with individual and time fixed effects using Canay estimator:{p_end}
{phang2}{cmd:. qregfe wage educ exper, q(75) abs(id year) canay}

{pstd}Estimate 25th quantile regression using MMQREG with bootstrap standard errors:{p_end}
{phang2}{cmd:. qregfe wage educ exper, q(25) abs(id) mmqreg boot}
 

{marker references}{...}
{title:References}

{phang}
Abrevaya, J., and C. M. Dahl. 2008. The effects of birth inputs on birthweight: Evidence from quantile estimation on panel data. 
Journal of Business & Economic Statistics 26: 379-397.

{phang}
Canay, I. A. 2011. A simple approach to quantile regression for panel data. The Econometrics Journal 14: 368-386.

{phang}
Machado, J. A. F., and J. M. C. Santos Silva. 2019. Quantiles via moments. Journal of Econometrics 213: 145-173.

{phang}
Wooldridge, J. M. 2010. Econometric Analysis of Cross Section and Panel Data. MIT press.

{phang}
Wooldridge, J. M. 2019. Correlated random effects models with unbalanced panels. Journal of Econometrics 211: 137-150.


{title:Author}

{pstd}
Fernando Rios-Avila{break}
Levy Economics Institute of Bard College{break}
Annandale-on-Hudson, NY{break}
friosavi@levy.org

{pstd}
Leonardo Siles{break}
Universidad de Chile{break}
Santiago, Chile{break}
lsiles@fen.uchile.cl

{pstd}
Gustavo Canavire-Bacarreza{break}
The World Bank{break}
Washington, DC{break}
gcanavire@worldbank.org

{title:Also see}

{help mmqreg}, {help reghdfe}, {help bsqreg}, {help qrprocess} (if installed)