*! v0.1 Very Basic!
/*******************************************
This Program Implements basic and Modified 
Canay QREG estimator.

Option 1:
1st: Estimate OLS model with FE -> y = xb + fe + e
2nd: Modify Y  and run QREG:  q_t(y-fe|x) =  x b(t) 

Option 2:
2nd: run QREG:  q_t(y|x, fe) =  x b(t) + fe g(t)

*******************************************/

/*
Author:  Fernando Rios-Avila, Leonardo Siles, Gustavo Canavire 
Structure: QREGFE - Main Program
           CMD_PARSER - Parse qreg Command. Useful for passing options
           ESTIMATOR_CANAY - Canay Estimator
           ESTIMATOR_CRE   - Correlated Random Effects Estimator
           DISPLAY_PARSER  - Parse Display
           DISPLAY_RESULTS - Display Results
*/
program define qregfe , eclass
    syntax [anything(everything)], [* BOOT BOOT1(str asis) /// Options for Bootstrap
                                    parallel parallel_cluster(int 2) /// Parallel for more power
                                    CANAY CANAY1(str asis) /// Options for Canay: Normal or Modified
                                    CRE   CRE1(str asis) /// Options for CRE: Normal or Compact
                                    MMQREG /// <- Plain Simple. But only accepts Boot
                                    seed(str asis) ] // Seed for Reproducibility

	if replay() {
		display_results, `options'
        exit
    }
	else {

        if "`seed'"!="" set seed `seed'
        ** Required Program
        qui:capture which reghdfe
        if _rc!=0 {
            display as error "reghdfe is not installed. Please install it from SSC"
            error 101
        }
        ** Checking for Canay and CRE
        if ("`canay'`canay1'"!="")+("`cre'`cre1'"!="")+("`mmqreg'"!="")>1 {
            display as error "You cannot Specify more than one method"
            error 110
        }

        if "`parallel'"!="" {
            capture which parallel
            if _rc!=0 {
                display as error "parallel is not installed. Please install it from GitHub"
                display as error `"{stata "net install parallel, from(https://raw.github.com/gvegayon/parallel/stable/) replace"}"'
                error 102
            }
        }

/*        if "`cre'`cre1'"!="" {
            capture which cre
            if _rc!=0 {
                display as error "cre is not installed. Please install it from GitHub"
                display as error `"{stata "net install cre, from(https://friosavila.github.io/stpackages) replace"}"'
                display as error "Or from SSC"
                display as error `"{stata "ssc install cre, replace"}"'
                error 102
            }

        }*/
        
        /*** IF CANAY ***/
        if "`canay'`canay1'"!="" {
                if "`boot'`boot1'"!="" & "`parallel'"=="" {
                    ** Simple Bootstrap
                    capture : bootstrap, `boot1': _qregfe_canay `0'    
                    syntax varlist(fv ts) [if] [in] ,  [*] Quantile(numlist) ABSorb(varlist)
                        gettoken yvar aux: varlist
                    	ereturn local depvar "`yvar'"
                        ereturn local quantile `quantile'
                        ereturn local absorb "`absorb'"
                        ereturn local cmd "qregfe"
                        ereturn local cmdline qregfe `0'
                    if _rc==0 display_results    
                }
            else if "`boot'`boot1'"!="" & "`parallel'"!="" {
                    ** Parallel Bootstrap
                    parallel initialize `parallel_cluster'
                    capture : parallel bs, `boot1': _qregfe_canay `0' 
                    ** Recover for display
                    syntax varlist(fv ts) [if] [in] ,  [*] Quantile(numlist) ABSorb(varlist)
                        gettoken yvar aux: varlist
                    	ereturn local depvar "`yvar'"
                        ereturn local quantile `quantile'
                        ereturn local absorb "`absorb'"
                        ereturn local cmd "qregfe"
                        ereturn local cmdline qregfe `0'
                    
                    if _rc==0 display_results
            }
            else {
                ** NO Bootstrap
                _qregfe_canay `0'             
            }
        }
        /*** IF CRE ***/
        else if "`cre'`cre1'"!="" {
                if "`boot'`boot1'"!="" & "`parallel'"=="" {
                    ** Simple Bootstrap
                    qui: bootstrap, `boot1': _qregfe_cre `0'    
                    syntax varlist(fv ts) [if] [in] ,  [*] Quantile(numlist) ABSorb(varlist)
                        gettoken yvar aux: varlist
                    	ereturn local depvar "`yvar'"
                        ereturn local quantile `quantile'
                        ereturn local absorb "`absorb'"
                        ereturn local cmd "qregfe"
                        ereturn local cmdline qregfe `0'
                    if _rc==0 display_results    
                }
            else if "`boot'`boot1'"!="" & "`parallel'"!="" {
                    ** Parallel Bootstrap
                    parallel initialize `parallel_cluster'
                    qui: parallel bs, `boot1': _qregfe_cre `0' 
                    ** Recover for display
                    syntax varlist(fv ts) [if] [in] ,  [*] Quantile(numlist) ABSorb(varlist)
                        gettoken yvar aux: varlist
                    	ereturn local depvar "`yvar'"
                        ereturn local quantile `quantile'
                        ereturn local absorb "`absorb'"
                        ereturn local cmd "qregfe"
                        ereturn local cmdline qregfe `0'
                    
                    if _rc==0 display_results
            }
            else {
                ** NO Bootstrap
                _qregfe_cre `0'             
            }
        }
        else if "`mmqreg'"!="" {
                    mmqreg `0'
                    ereturn local cmd "qregfe"
                    ereturn local wcmd "mmqreg"
                    ereturn local cmdline qregfe `0'
        }            
        else {
            display as error "Need to provide a method. CRE, Canay, or mmqreg"
            error 111
        }
    }      
end
 
program display_parser, rclass
	syntax  ,  [ level(passthru) * ///
									 noci               ///
									 nopvalues          ///
									 noomitted          ///
									 vsquish            ///
									 noemptycells       ///
									 baselevels         ///
									 allbaselevels      ///
									 nofvlabel          ///
									 fvwrap(passthru)   ///
									 fvwrapon(passthru) ///
									 cformat(passthru)  ///
									 pformat(passthru)  ///
									 sformat(passthru)  ///
									 nolstretch ]
	return local display_opt `level' `noci' `nopvalues' `noomitted' `vsquish' `noemptycells' `baselevels' `allbaselevels' `nofvlabel' `fvwrap' `fvwrapon' `cformat' `pformat' `sformat' `nolstretch'
    return local other_opt `options'
end

program display_results
    syntax [anything(everything)], [*]
    display_parser, `options'
    if "`e(wcmd)'"=="qregfe" {
        display "Quantile Regression with Fixed Effects"
        `e(cmd)', `display_opt'
        display "Dependent Variable: `e(depvar)'"
        display "Quantile(s): `e(quantile)'"
        display "Fixed Effects: `e(absorb)'"
    }
    else {
        display in red "last estimates not found"
        error 301
    }
end 