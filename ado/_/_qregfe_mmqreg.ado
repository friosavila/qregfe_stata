** mmqreg for bstrap

program define mynlist,rclass
	syntax anything, 
	numlist `anything',  range(>0 <100) sort
	mata:tk = tokens("`r(numlist)'")'
	mata:tk = invtokens(uniqrows(tk)')
	mata:st_local("num",tk)
	mata:mata drop tk
	numlist "`num'",  range(>0 <100) sort
	return local numlist `r(numlist)'
end

program _qregfe_mmqreg, eclass
    syntax varlist(fv ts) [if] [in] [pw iw], ///
                        [Quantile(str asis) ///
                        ls ABSorb(varlist) *] 
    marksample touse
    markout `touse' `absorb'
    gettoken y x:varlist
    // ls show?
    if "`ls'"!="" local ls 1
    else local ls 0
    // Quantile: Should be done at an earlier point
    if missing("`quantile'") local qlist = 50
    else {
        capture: mynlist "`quantile'"
        local qlist `r(numlist)'
    }    
    // Step 1: Location 
    if "`absorb'"!="" qui: reghdfe `y' `x' if `touse' [`weight'`exp'], abs(`absorb') resid keepsingletons verbose(-1)  
    else           qui: reghdfe `y' `x' if `touse' [`weight'`exp'], noabs         resid  keepsingletons verbose(-1)
    tempname b1
    matrix `b1'=e(b)
    
    // get residuals
    tempvar r1 ar1
    ren _reghdfe_resid `r1'
    qui:gen double `ar1' = abs(`r1')
    // Step 2: Scale
    if "`absorb'"!="" qui: reghdfe `ar1' `x' if `touse' [`weight'`exp'], abs(`absorb') resid keepsingletons verbose(-1)
    else           qui: reghdfe `ar1' `x' if `touse' [`weight'`exp'], noabs         resid  keepsingletons verbose(-1)
    // predict hat_ar1
    tempname b2
    matrix `b2'=e(b)
    
    
    tempvar hat_ar1
    qui:gen double `hat_ar1'=`ar1'-_reghdfe_resid
    // Generate Standard Residuals
    tempvar sr1
    qui:gen double `sr1' = `r1'/`hat_ar1'
    // Step 3: Quantile
    _pctile2 `sr1' if `touse' [`weight'`exp'], p(`qlist') 
   
    tempname qval qnum
    matrix `qval' = r(qval)
  
    matrix `qnum' = r(qnum)
    
    // Step 4: All together
    mata: get_qcoeff("`b1'","`b2'","`qval'","`qnum'",`ls')
    
    // What is left
    ereturn post _qqcoef, esample(`touse') buildfvinfo findomitted
    ereturn local depvar `y'
    ereturn local idepvar `x'    
    ereturn local  cmd 		"mmqreg"
    ereturn local  cmd2     "mmqreg_boot"

	ereturn local  cmdline 	"mmqreg `0'"
    ereturn scalar boot = 1
	ereturn matrix qth =`qnum'
	ereturn matrix qval =`qval'
	ereturn local  fevlist `absorb'
	ereturn local  absorb `absorb'

    _mmqreg_boot_display, `options' 
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

program _mmqreg_boot_display
    syntax [anything(everything)], [*]
    display_parser, `options'
    if "`e(cmd2)'"=="mmqreg_boot" {
        display "Quantile Regression with Fixed Effects"
        ereturn display, `display_opt'
        display "Dependent Variable: `e(depvar)'"
        display "Quantile(s): `e(quantile)'"
        display "Fixed Effects: `e(absorb)'"
    }
    else {
        display in red "last estimates not found"
        error 301
    }
end 

program _pctile2, rclass
    syntax anything [if] [aw pw fw], [*] p(numlist)
    
    _pctile `anything' `if' [`weight'`exp'], `options' p(`p')
    
    tempname qval qnum
    forvalues i = 1/`:word count `p'' {
        matrix `qval' = nullmat(`qval'), `r(r`i')'
        matrix `qnum' = nullmat(`qnum'), `:word `i' of `p''
 
     }
    return matrix qval= `qval'
    return matrix qnum= `qnum'
end

mata:
    void get_qcoeff(string scalar b1  , string scalar b2  , 
                    string scalar qval, string scalar qnum, 
                    real scalar ls){
        real matrix bb1, bb2, qqval, qqnum
        real scalar i
        string matrix lb, qlab, lbqtile, lbloc, lbscl
        bb1 = st_matrix(b1)
        lb  = st_matrixcolstripe(b1)
        bb2 = st_matrix(b2)
        
        qqval = st_matrix(qval)
        qqnum = st_matrix(qnum)
        
        real matrix qqcoef
        // Direct formula
        qqcoef = vec(bb1':+bb2'*qqval)
        
        // names for Q
        if (cols(qqval)==1) qlab = "qtile"
        else {
            qlab = J(0,1,"")
            for(i=1;i<=cols(qqval);i++){
               qlab = qlab\ sprintf("q%02.0f",qqnum[i])
            }
        }
        
        lbqtile  = vec(J(1,cols(bb1),qlab)'), J(cols(qqval),1,lb[,2])
        
        // if Scale Loc Requested
        if (ls==1) { 
            qqcoef=bb1'\bb2'\qqcoef
            lbloc = lb
            lbscl = lb
            lbloc[,1]=J(rows(lb),1,"Location")
            lbscl[,1]=J(rows(lb),1,"Scale")
            lbqtile = lbloc\lbscl \lbqtile
        }
        st_matrix("_qqcoef",qqcoef')
        st_matrixcolstripe("_qqcoef",lbqtile)
    }
end


