*! v0.2 CRE Estimator

program _qregfe_cre, eclass		 

syntax varlist(fv ts) [if] [in] [pw], ABSorb(varlist)    /// variables to absorb
		[Quantile(numlist >0 <100) /// quantile to estimate <- Lets use numbers between 0-100
		 qmethod(str asis) ///	<- Default its qreg. may include options
		 BOOT BOOT1(str asis) * CRE CRE1(str asis) ///
		 seed(str asis) parallel parallel_cluster(int 2) ]  


    // Set Sample (touse) and Absorb Variables (absorb)	 
    marksample touse
    markout `touse' `absorb'

    // Getting Quantile: Default is 50. Allowing for multiple Qs depend on Command option
    if "`quantile'"=="" local quantile = 50

    // qmethod, and options
    if "`qmethod'"!="" {
        cmd_parser `qmethod'
        local qmethod   `r(rcmd)'
        local qoptions  `r(ropt)'
    }    

    if      "`qmethod'"==""          local qmethod      qreg            // Default is qreg
    
    // Setup Y and X
	gettoken yvar xvar : varlist
	
    
    if "`weight'`exp'"!="" local weightexp [`weight'`exp'] 
    qui: cre, abs(`absorb') keepsingletons keep : ///
        `qmethod' `yvar' `xvar' `if' `in' `weightexp', `qoptions' `options'  q(`quantile')

	*if "`bs'"=="" display in white "Std Errors are not valid for Inference. Try bscanayreg"
	ereturn local depvar "`yvar'"
    ereturn local quantile `quantile'
    ereturn local absorb "`absorb'"
    ereturn local cmd "qregfe"
    ereturn local wcmd `qmethod'
    ereturn local cmdline qregfe `0'
    ereturn local method "CRE"
    ereturn local qmethod "`qmethod'"
    
    display_results, `options'

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
    if "`e(cmd)'"=="qregfe" {
        display "Quantile Regression with Fixed Effects"
        adde local cmd `e(wcmd)'
        `e(cmd)', `display_opt'
        adde local cmd qregfe
        display "Dependent Variable: `e(depvar)'"
        display "Quantile(s): `e(quantile)'"
        display "Fixed Effects: `e(absorb)'"
    }
    else {
        display in red "last estimates not found"
        error 301
    }
end 

program cmd_parser, rclass
	syntax [anything] [aw fw pw iw ] [if] [in], [* Quantile(passthru) ] 
	if "`anything'"=="" exit
	else {
		qui:capture which `anything'
		if _rc!=0 {
		    display as error "There is no `anything' command" _n "Search if it can be installed from SSC"
			error 111
		}
	}
	if  !missing("`quantile'") {
	    display as error "You cannot Specify 'quantile' as part of qmethod"
		error 112
	}
	local wgt=subinstr("`exp'","=","",1)
	return local  rcmd  `anything'
	return local  ropt  `options' 
	return local  rwgt  `wgt'
	return local  rif  `if'
	return local  rin  `in'
	return local  rewgt [`weight'`exp']

end


program define cre, properties(prefix)
	set prefix cre
	gettoken first second : 0, parse(":")
	if "`first'"==":" {
		`second' 
	}
	else {
		cre_opt `first'
		local felist `r(felist)'
		local prefix `r(prefix)'
		local keep   `r(keep)'
		local replace `r(replace)'
		local keepsingletons `r(keepsingletons)'
		
		local compact  `r(compact)'
		
		gettoken other cmd0 : second, parse(" :")

		** Improvement for ANY comd
		gettoken cmd 0: cmd0
		
		local nx 1
		while `nx' {
			syntax anything [if] [in] [aw iw fw pw], [*]
			capture _iv_parse `0'
			if _rc!=0 {
				gettoken cmd2 0: 0	
				local cmd `cmd' `cmd2'
			}
			else local nx 0
		}
		 
		local x `s(exog)'   `s(inst)'
		local y `s(lhs)' 
		marksample touse
		markout `touse' `felist' `x'  `y'
 		***
  
		myhdmean `x' if `touse' [`weight'`exp'], abs(`felist') prefix(`prefix') `compact' `keepsingletons' `replace'
		local vlist `r(vlist)'
		`cmd' `anything' `vlist'  `if' `in' [`weight'`exp'], `options'
		if "`keep'"==""{
			drop `vlist'
		}
		
	}
end

program cre_opt, rclass
	syntax , abs(varlist) [keep prefix(name) compact keepsingletons replace]
	if "`prefix'"=="" local prefix m
	return local felist `abs'
	return local prefix `prefix'
	return local keep   `keep'
	return local keepsingletons   `keepsingletons'
	return local compact   `compact'
	return local replace `replace'
end 

program myhdmean, rclass
	syntax anything [if] [aw iw pw fw], abs(varlist) prefix(name) [compact  keepsingletons replace]
	
	ms_fvstrip `anything' `if', expand dropomit
	local vvlist `r(varlist)'
	** First check and create
	foreach i in `vvlist' {
		local icnt = `icnt'+1
		capture confirm variable `i'
		if _rc!=0 {
			 local vn = strtoname("`i'")
			if length("`vn'")>30 	local vn _v`icnt'
            capture drop `vn'
			gen double `vn'=`i'
			label var `vn' "`i'"
			local dropvlist `dropvlist' `vn'
		
		}
		else local vn `i'
		
		local vflist `vflist' `vn'
	}
	***
	
	if "`compact'"=="" {
		foreach i in `vflist' {
			local vplist
			local cnt
			local fex
			foreach j of varlist `abs' {
				local cnt=`cnt'+1
				capture drop `prefix'`cnt'_`i'
				local fex    `fex'    `prefix'`cnt'_`i'=`j'
				local vplist `vplist' `prefix'`cnt'_`i'
			}
			qui:reghdfe `i' `if'  [`weight'`exp'], abs(`fex')  `keepsingletons' resid verbose(-1)
			label var `prefix'`cnt'_`i' "`:variable label `i''"
			qui:sum _reghdfe_resid, meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `vplist'
			else  local dropvlist `dropvlist' `vplist'
		}
		
		local vflist `vlist'
		local vlist
		foreach i in `vflist' {
			sum `i', meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `i'
			else local dropvlist `dropvlist' `i'
		}
		
		return local vlist  `vlist'
	}
	else {
		foreach i in  `vflist' {
			local cnt
			local fex
			local vplist
			capture drop `prefix'`cnt'_`i'
			qui:reghdfe `i' `if'  [`weight'`exp'], abs(`abs') resid `keepsingletons' verbose(-1)
			qui:sum _reghdfe_resid, meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() {
				qui:gen double `prefix'`cnt'_`i'=`i'-_reghdfe_resid-_cons
				local vlist `vlist' `prefix'`cnt'_`i'
			}
 			qui:drop _reghdfe_resid			
		}
		
		/*local vflist `vlist'
		local vlist
		foreach i in `vflist' {
			sum `i', meanonly
			if abs(`r(max)'-`r(min)')>epsfloat() local vlist `vlist' `i'
			else local dropvlist `dropvlist' `i'
		}*/
		return local vlist   `vlist'
	}
	*display in w "`dropvlist'"
	if "`dropvlist'"!="" drop `dropvlist'
	
end

program adde, eclass
    ereturn `0'
end
