/////////// Metrics II PS3///////////

** housekeeping
clear all                   // remove anything old stored
set more off, permanently   // tell Stata not to pause
set linesize 255            // set line length for the log file
version                     // check the version of the command interpreter

* Set working directory to the current repo folder
cd "C:\Users\42610\OneDrive - Handelshögskolan i Stockholm\Documents\Metrics_II_PS3"
global wd "`c(pwd)'"

* Create folders if they do not exist
cap mkdir figures
cap mkdir output
cap mkdir logs

** capture
cap log close // close a log-file, if one is open
log using "metrics_ii_ps3.log", replace


** Question 1 **

cap program drop f1
program define f1, rclass

    clear
    set obs 20

    * generate variables *
    gen e = rnormal(0,3)
    gen v = rnormal()
    gen z = v
    gen mu = rnormal()

    local beta_FS = 1
    gen x = `beta_FS'*z + e + mu

    local beta_x = 1
    gen y = `beta_x'*x + e

    * IV regression *
    quietly ivregress 2sls y (x = z)
    scalar b_iv = _b[x]
    return scalar beta_iv = b_iv
	
	* bias calculations *
    scalar bias = b_iv - `beta_x'
    return scalar stage2_bias = bias
    return scalar stage2_sign = (bias > 0)
    return scalar abs_stage2_bias = abs(bias)

    * manual "2SLS" *
    gen x_tilde = `beta_FS'*z
    quietly reg y x_tilde
    scalar b_2sls = _b[x_tilde]
    return scalar beta_2sls = b_2sls

  * first stage *
	quietly reg x z

	scalar b_hat_FS = _b[z]
	return scalar beta_hat_FS = b_hat_FS

	scalar bias_FS = b_hat_FS - `beta_FS'
	return scalar bias_FS = bias_FS
	
    scalar F = e(F)
    scalar ss_res = e(rss)

    return scalar F_stat = F
    return scalar F_large = (F > 10)
    return scalar ss_resid = ss_res

    * true error *
    gen u_true = e + mu
    gen u_true_sq = u_true^2
    quietly summarize u_true_sq, meanonly
    scalar ss_e = r(sum)

    return scalar ss_e = ss_e
    return scalar ratio_errors = ss_res / ss_e

end

* Run simulation * 

simulate beta_iv=r(beta_iv) ///
         beta_2sls=r(beta_2sls) ///
		 beta_hat_FS=r(beta_hat_FS) ///
		 bias_FS = r(bias_FS) ///
         F_stat=r(F_stat) ///
         F_large=r(F_large) ///
         stage2_bias=r(stage2_bias) ///
         stage2_sign=r(stage2_sign) ///
         abs_stage2_bias=r(abs_stage2_bias) ///
         ss_resid=r(ss_resid) ///
         ss_e=r(ss_e) ///
         ratio_errors=r(ratio_errors), ///
         reps(10000) seed(260424): f1

** a ** 

twoway ///
    (kdensity beta_iv, lcolor(blue)) ///
    (kdensity beta_2sls, lcolor(red) lpattern(dash)), ///
    xline(1, lcolor(black) lpattern(shortdash)) ///
    legend(label(1 "IV (2SLS)") label(2 "True 1st stage")) 


graph export "figures/density_beta.pdf", replace 

mean beta_iv
mean beta_2sls


** b *** 
mean abs_stage2_bias if bias_FS < 0
mean abs_stage2_bias if bias_FS > 0
 

corr F_stat abs_stage2_bias if F_large == 1 


twoway scatter abs_stage2_bias F_stat if F_large == 1 ///
       || lfit abs_stage2_bias F_stat if F_large == 1

graph export "figures/F_stat_bias.pdf", replace
	   
** c **

*residuals over beta_hat_FS* 

binscatter ss_resid beta_hat_FS, n(50) ///
    name(graph1, replace) ///
    xtitle("beta_hat_FS") ///
    ytitle("SSR")
	
* true errors over over beta_hat_FS * 

binscatter ss_e beta_hat_FS, n(50) ///
	name(graph2, replace) ///
    xtitle("beta_hat_FS") ///
    ytitle("SSE") 
	
* ratio of ssr/sse over beta_hat_FS*

binscatter ratio_errors beta_hat_FS, n(50) ///
	name(graph3, replace) ///
    xtitle("beta_hat_FS") ///
    ytitle("Ratio SSR/SSE") 	   
	   
graph combine graph1 graph2 graph3 

graph export "figures/error_scatterplots.pdf", replace 

*max ratio* 
summarize ratio_errors, meanonly
display r(max)


** d ** 

*scatter abs_stage2_bias over beta_hat_FS*

binscatter abs_stage2_bias beta_hat_FS, n(50) ///
    name(graph4, replace) ///
    xtitle("beta_hat_FS") ///
    ytitle("Absolute 2SLS bias")
	
graph export "figures/stage2_bias_beta_FS_scatter.pdf", replace

	
* Find beta_hat_FS for the largest abs_stage2_bias* 

sort abs_stage2_bias
list beta_hat_FS abs_stage2_bias in -10/l

*scatter F-stat over beta_hat_FS*

binscatter F_stat beta_hat_FS, n(50) ///
    name(graph5, replace) ///
    xtitle("beta_hat_FS") ///
    ytitle("F-stat")
	
graph export "figures/F_stat_beta_hat_FS_scatter.pdf", replace


** e **

preserve 

keep if beta_hat_FS > 0.5 

*binscatter abs_stage2_bias over beta_hat_FS*

binscatter abs_stage2_bias beta_hat_FS, n(50) ///
    name(graph6, replace) ///
    xtitle("beta_hat_FS") ///
    ytitle("Absolute 2SLS bias")
	
graph export "figures/stage2_bias_beta_FS_scatter_d.pdf", replace

	
* Find beta_hat_FS for the smallest abs_stage2_bias* 

sort abs_stage2_bias
list beta_hat_FS abs_stage2_bias in 1/10

*scatter F-stat over beta_hat_FS*

binscatter F_stat beta_hat_FS, n(50) ///
    name(graph7, replace) ///
    xtitle("beta_hat_FS") ///
    ytitle("F-stat")
	
graph export "figures/F_stat_beta_hat_FS_scatter_d.pdf", replace

restore 	   
	   

		 
