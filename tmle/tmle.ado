*! version 1.0.0  15jun2025

program define tmle, rclass
	version 19 // or desired version
	
//#######################################################################################
// Adapted from https://github.com/migariane/SIM-TMLE-tutorial
// Miguel Angel Luque Fernandez, Micheal Schomaker, Bernard Rachet, Mireille Schnitzer
// Targeted Maximum Likelihood Estimation for a Binary Treatment: A tutorial
// Stata simple TMLE implementation 
//#######################################################################################

syntax varlist(min=2 max=2 numeric) [if] [in], omodel(string) tmodel(string) [opredict(string) tpredict(string) level(integer 95)]

marksample touse

local Y: word 1 of `varlist'
local A: word 2 of `varlist'
tempvar ATE QAW_0 Q0W_0 Q1W_0 logQAW logQ1W logQ0W aa H1W H0W gw eps1 eps2 Q0W_1 Q1W_1 EY0tmle EY1tmle IC d0 d1 varIC y_original

* transform Y if continuous outcome
capture assert inlist(`Y', 0, 1) if !missing(`Y')
local continuous=0
if _rc==9 {
	local continuous=1
	qui gen `y_original'=`Y'
	qui sum `Y'
	local a=r(min)
	local b=r(max)
	qui replace `Y'=(`Y'-`a')/(`b'-`a')
}

* Step 1: prediction model for the outcome Q0 (g-computation)
qui `omodel'

qui {
	predict double `QAW_0', `opredict'
	gen `aa'=`A'
	replace `A' = 0
	predict double `Q0W_0', `opredict'
	replace `A' = 1
	predict double `Q1W_0', `opredict'
	replace `A' = `aa'
	drop `aa'
}

// Q to logit scale
gen `logQAW' = logit(`QAW_0')
gen `logQ1W' = logit(`Q1W_0')
gen `logQ0W' = logit(`Q0W_0')

* Step 2: prediction model for the treatment g0 (IPTW)
qui `tmodel'
qui predict `gw', `tpredict'
gen double `H1W' = `A' / `gw'
gen double `H0W' = (1 - `A') / (1 - `gw')

* Step 3: Computing the clever covariate H(A,W) and estimating the parameter (epsilon) (MLE)
qui glm `Y' `H1W' `H0W', fam(binomial) offset(`logQAW') noconstant
gen `eps1' = _b[`H1W']
gen `eps2' = _b[`H0W']

* Step 4: update from Q0 to Q1
// These from Luque-Fernandez et al. (2018) seem incorrect
// gen double `Q1W_1' = invlogit(`eps1' / `gw' + `logQ1W')
// gen double `Q0W_1' = invlogit(`eps2' / (1 - `gw') + `logQ0W')

// formula used by Frank & Karim (2023)
gen double `Q1W_1' = invlogit(`eps1' * `H1W' + `logQ1W')
gen double `Q0W_1' = invlogit(`eps2' * `H0W' + `logQ0W')

* Step 5: Targeted estimate of the ATE 
gen `ATE' = (`Q1W_1' - `Q0W_1') if `touse'
qui summ `ATE'
local ATE=r(mean)

if `continuous'==1 {
	local ATE=(`b'-`a')*`ATE'
}
return scalar ATE=r(mean)

* Step 6: Statistical inference (efficient influence curve)
qui if `continuous'==1 {
	replace `Q1W_1'=`a'+(`b'-`a')*`Q1W_1'
	replace `Q0W_1'=`a'+(`b'-`a')*`Q0W_1'
}

qui sum(`Q1W_1') if `touse'
gen `EY1tmle' = r(mean)
qui sum(`Q0W_1') if `touse'
gen `EY0tmle' = r(mean)

gen `d1' = ((`A' * (`Y' - `Q1W_1')/`gw')) + `Q1W_1' - `EY1tmle'
gen `d0' = ((1 - `A') * (`Y' - `Q0W_1')/(1 - `gw'))  + `Q0W_1' - `EY0tmle'

gen `IC' = `d1' - `d0'
qui sum `IC'
local varIC = r(Var) / r(N)

return scalar se=sqrt(`varIC')

// critical value & p-value
local z=invnormal(1 - (1-`level'/100)/2)
local p=2*(normal(-abs(`ATE'/sqrt(`varIC'))))
return scalar p=`p'

local LCI =  `ATE' - `z'*sqrt(`varIC')
local UCI =  `ATE' + `z'*sqrt(`varIC')

if `continuous'==1 {
	qui replace `Y'=`y_original'
}

display as text "ATE: " as result %05.4f  `ATE' _skip(3) ///
  as text "p: " as result %05.4f `p' _skip(3) ///
  as text "`level'% CI: " as result "(" %05.4f  `LCI' "," %05.4f  `UCI' ")"

end