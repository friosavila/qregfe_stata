webuse nlswork, clear
bysort idcode:gen nobs=_N
drop if nobs<5
* Linear Regression model with fixed effects
reghdfe ln_wage age tenure  ttl_exp not_smsa , abs(idcode)
est sto ols
* Quantile Regression CRE
qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) cre q(50) 
est sto cre_q50
* Quantile Regression Canay
qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) canay q(50) 
est sto canay_q50
* Quantile Regression mCanay
qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) canay(modified) q(50) 
est sto mcanay_q50
* Quantile Regression MMQREG
qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) mmqreg q(50) 
est sto mmqreg_q50
esttab ols cre_q50 canay_q50 mcanay_q50 mmqreg_q50, se b(3) tex mtitle(OLS CRE Canay MCanay MMqreg)


qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) cre q(50)
qregplot, estore(cre)
qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) canay q(50)
qregplot, estore(canay)
qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) canay(modified) q(50)
qregplot, estore(mcanay)
qregfe ln_wage age tenure ttl_exp not_smsa, abs(idcode) mmqreg q(50) 
qregplot, estore(mqr)
esttab ols cre_q50 canay_q50 mcanay_q50 mmqreg_q50, se b(3) tex mtitle(OLS CRE Canay MCanay MMqreg)

foreach i in  age tenure ttl_exp not_smsa {
    qregplot `i', from(cre) name(cre_x, replace) title("CRE")
    qregplot `i', from(canay) name(canay_x, replace) title("Canay")
    qregplot `i', from(mcanay) name(mcanay_x, replace) title("Modified Canay")
    qregplot `i', from(mqr) name(mqr_x, replace) title("MMQREG")
    graph combine cre_x canay_x mcanay_x mqr_x, ycommon
    *graph export "qregplot_`i'.pdf", replace 
}