* Change to working directory and load data *
*cd "..."
use  "Kreps_etal_vax_replication_data.dta", clear

* Need to install some packages if they are not already installed
* ssc install outreg2
* ssc install coefplot 
* ssc install estsimp
* ssc install eclplot
* ssc install parmest
* ssc install smileplot
* net install st0035_1

* To install the "clarify" package
* net from https://gking.harvard.edu/clarify
* net install clarify

* ANALYSES IN THE MAIN TEXT *

* Discrete choice DV is: vaxbin *
* Individual vaccine evaluations were measured on a 7-point likert scale: vaxord *
* Creating our second dependent variable coded 1 for those who report being "slightly", "moderately", or "extremely" likely to vaccinate; 0 otherwise *
gen accept_slightlyplus = 0
replace accept_slightlyplus = 1 if vaxord == 7
replace accept_slightlyplus = 1 if vaxord == 6
replace accept_slightlyplus = 1 if vaxord == 5
* label var accept_slightlyplus "Slightly, moderately, or extremely willing to take vaccine profile *

* Table 2 *

* Survey data has been reformatted such that there are ten observations for each subject in the survey, as each subject evaluated 10 hypothetical vaccines as part of five choice sets *
* Sample demographics in Table 2 and eTable 1 computed from raw data.  To replicate them here with just one observation per subject, limit commands to choice_set == 11, which is just the first vaccine evaluated *

* Create age group variable
gen age_group = "Less than 30"
replace age_group = "30 to 44" if age >=30 & age <45
replace age_group = "45 to 59" if age >=45 & age < 60
replace age_group = "60 or greater" if age >= 60

* Age group
tab age_group if choice_set == 11

* Gender
tab female if choice_set == 11

* Race
tab race_1 if choice_set == 11
tab race_2 if choice_set == 11
tab race_3 if choice_set == 11
tab race_4 if choice_set == 11
tab race_5 if choice_set == 11
tab race_6 if choice_set == 11

tab education if choice_set == 11
tab income if choice_set == 11

tab dem5 if choice_set == 11
tab gop5 if choice_set == 11
tab ideology if choice_set == 11

* Table 3 *
reg vaxbin i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, robust cluster(respondent)
outreg2 using vaxtable1, word sideway pvalue dec(2) replace
outreg2 using vaxtable1, word sideway stats(ci) dec(2) append
reg vaxbin i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n dem5 gop5 female age education flu_vaccine no_insurance  pharma_favor knowcovid  worst_to_come not_evangelical evangelical2 not_religious black latino, robust cluster(respondent)
test dem5=gop5
outreg2 using vaxtable1, word sideway pvalue dec(2) append
outreg2 using vaxtable1, word sideway stats(ci) dec(2) append
reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, robust cluster(respondent)
outreg2 using vaxtable1, word sideway pvalue dec(2) append
outreg2 using vaxtable1, word sideway stats(ci) dec(2) append
reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n dem5 gop5 female age education flu_vaccine no_insurance  pharma_favor knowcovid  worst_to_come not_evangelical evangelical2 not_religious black latino, robust cluster(respondent)
test dem5=gop5
outreg2 using vaxtable1, word sideway pvalue dec(2) append
outreg2 using vaxtable1, word sideway stats(ci) dec(2) append

* Note: additional tests of p-values with Holm correction for multiple comparisons appear at the end of this .do file *


* Figure 1 *
reg vaxbin i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, robust cluster(respondent)
coefplot, drop(_cons) omitted baselevels xline(0) ///
headings(1.efficacy_n = "{bf:Efficacy}" ///  
1.duration_n = "{bf:Protection Duration}" ///            
1.majorside_n = "{bf:Major Side Effects}" ///
1.minorside_n = "{bf:Minor Side Effects}" ///
1.fda_n = "{bf:FDA Approval}" ///
1.origin_n = "{bf:Origin}" ///
1.endorsed_n = "{bf:Endorsement}" , labsize(vsmall)) graphregion(color(white)) ylab(, labs(vsmall)) ///
xti(" " "Change in Probability of Choosing Vaccine", size(small)) ti("Discrete Choice (AMCEs)", size(small)) level(95) mlcolor(black) mcolor(black) saving(fig2top.gph, replace)

reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, robust cluster(respondent)
margins efficacy_n duration_n majorside_n minorside_n  fda_n origin_n endorsed_n, post
coefplot, drop(_cons) omitted baselevels xline(0) ///
headings(1.efficacy_n = "{bf:Efficacy}" ///  
1.duration_n = "{bf:Protection Duration}" ///            
1.majorside_n = "{bf:Major Side Effects}" ///
1.minorside_n = "{bf:Minor Side Effects}" ///
1.fda_n = "{bf:FDA Approval}" ///
1.origin_n = "{bf:Origin}" ///
1.endorsed_n = "{bf:Endorsement}" , labsize(vsmall)) graphregion(color(white)) ylab(, labs(vsmall)) ///
xti(" " "Likely to Get Vaccine", size(small)) ti("Individual Vaccine Evaluation (Marginal Means)", size(small)) level(95) mlcolor(black) mcolor(black) xlabel(.45 .5 .55 .6 .65 .7) saving(fig2bottom.gph, replace)

graph combine "fig2top.gph" "fig2bottom.gph", rows(2) cols(1) graphregion(color(white))  xsize(8.5) ysize(11)

* The code for Figure 2 involves simulations and is long.  It is reported at the end of the .do file. *

* ANALYSES IN THE ONLINE SUPPLEMENT *

* eTable 1 *
* A reminder: summary statistics if choice_set == 11 simply uses only one observation per respondent (all demos are same for each observation) *
sum black latino female  if choice_set == 11
tab education if choice_set == 11
sum age if choice_set == 11, detail 
sum gop3 if choice_set == 11
sum dem3 if choice_set == 11
tab ideology if choice_set == 11

* eTable 2 *
reg vaxbin i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, vce(cluster respondent)
margins i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, post
reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, robust cluster(respondent)
margins i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, post

* eTable 3 *
gen accept_modorextremely = 0
replace accept_modorextremely = 1 if vaxord == 7
replace accept_modorextremely = 1 if vaxord == 6
gen accept_unlikely = 0
replace accept_unlikely = 1 if vaxord == 1
replace accept_unlikely = 1 if vaxord == 2
replace accept_unlikely = 1 if vaxord == 3
reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
outreg2 using etable3, word sideway pvalue dec(2) replace
outreg2 using etable3, word sideway stats(ci) dec(2) append
reg accept_modorextremely i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
outreg2 using etable3, word sideway pvalue dec(2) append
outreg2 using etable3, word sideway stats(ci) dec(2) append
reg accept_unlikely i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
outreg2 using etable3, word sideway pvalue dec(2) append
outreg2 using etable3, word sideway stats(ci) dec(2) append
reg vaxord i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
outreg2 using etable3, word sideway pvalue dec(2) append
outreg2 using etable3, word sideway stats(ci) dec(2) append

* eFigure 2 *
reg vaxbin i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
margins efficacy_n duration_n majorside_n minorside_n  fda_n origin_n endorsed_n, post
coefplot,  ///
headings(1.efficacy_n = "{bf:Efficacy}" ///  
1.duration_n = "{bf:Protection Duration}" ///            
1.majorside_n = "{bf:Major Side Effects}" ///
1.minorside_n = "{bf:Minor Side Effects}" ///
1.fda_n = "{bf:FDA Approval}" ///
1.origin_n = "{bf:Origin}" ///
1.endorsed_n = "{bf:Endorsement}" , labsize(vsmall)) graphregion(color(white)) ylab(, labs(vsmall)) ///
xti(" " "Choosing Vaccine", size(small)) level(95) xlabel(.2 .3 .4 .5 .6) mcolor(black) mlcolor(black) ti("Discrete Choice (Marginal Means)", size(small)) saving(efig1top.gph, replace)

reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
coefplot, drop(_cons) omitted baselevels xline(0) ///
headings(1.efficacy_n = "{bf:Efficacy}" ///  
1.duration_n = "{bf:Protection Duration}" ///            
1.majorside_n = "{bf:Major Side Effects}" ///
1.minorside_n = "{bf:Minor Side Effects}" ///
1.fda_n = "{bf:FDA Approval}" ///
1.origin_n = "{bf:Origin}" ///
1.endorsed_n = "{bf:Endorsement}" , labsize(vsmall)) graphregion(color(white)) ylab(, labs(vsmall)) ///
xti(" " "Change in Probability of Taking Vaccine", size(small)) level(95) mlcolor(black) mcolor(black) xlabel(-.1 -.05 0 .05 .1) ti("Individual Vaccine Evaluations (AMCEs)", size(small)) saving(efig1bottom.gph, replace)

graph combine "efig1top.gph" "efig1bottom.gph", rows(2) cols(1) graphregion(color(white))  xsize(8.5) ysize(11)

* Figure 2 *
* Identify vax profiles at different percentiles *
reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
predict prob_vax
sort prob_vax
gen rank = _n
gen fig1mean = .
gen fig1upper = .
gen fig1lower = .
gen fig1label = _n
label var fig1label ""
gen fig2label = .
replace fig2label = 1 if rank == 1
replace fig2label = 2.5 if rank == 2
replace fig2label = 4 if rank == 3
replace fig2label = 5.5 if rank == 4
replace fig2label = 7 if rank == 5
label var fig2label ""

list efficacy_n duration_n majorside_n minorside_n fda_n origin_n endorsed_n if rank == 197
list efficacy_n duration_n majorside_n minorside_n fda_n origin_n endorsed_n if rank == 4928
list efficacy_n duration_n majorside_n minorside_n fda_n origin_n endorsed_n if rank == 9855
list efficacy_n duration_n majorside_n minorside_n fda_n origin_n endorsed_n if rank == 14783
list efficacy_n duration_n majorside_n minorside_n fda_n origin_n endorsed_n if rank == 19513

reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, cluster(respondent)
estsimp reg accept_slightlyplus efficacy2 efficacy3 duration2 majorside2 minorside2 fda2 origin2 origin3 endorsed2 endorsed3 endorsed4, cluster(respondent)
* 1st Percentile *
list  efficacy2 efficacy3 duration2 majorside2 minorside2 fda2 origin2 origin3 endorsed2 endorsed3 endorsed4 prob_vax if rank == 197
setx efficacy2 0 efficacy3 0 duration2 0 majorside2 1 minorside2 0 fda2 1 origin2 0 origin3 0 endorsed2 0 endorsed3 1 endorsed4 0
simqi, genev(preds1)
_pctile preds1, p(2.5,97.5)
replace fig1upper = r(r1) if fig2label == 1
replace fig1lower = r(r2) if fig2label == 1 
egen x = mean(preds1)
replace fig1mean = x if fig2label == 1
drop x preds1
* Mean simulated point estimate will be close to point estimate from model prediction, but obviously not exactly the same *

* 25th Percentile *
list  efficacy2 efficacy3 duration2 majorside2 minorside2 fda2 origin2 origin3 endorsed2 endorsed3 endorsed4 prob_vax if rank == 4928
setx efficacy2 0 efficacy3 0 duration2 0 majorside2 1 minorside2 0 fda2 1 origin2 1 origin3 0 endorsed2 0 endorsed3 0 endorsed4 1
simqi, genev(preds1)
_pctile preds1, p(2.5,97.5)
replace fig1upper = r(r1) if fig2label == 2.5
replace fig1lower = r(r2) if fig2label == 2.5
egen x = mean(preds1)
replace fig1mean = x if fig2label == 2.5
drop x preds1

* 50th Percentile *
list  efficacy2 efficacy3 duration2 majorside2 minorside2 fda2 origin2 origin3 endorsed2 endorsed3 endorsed4 prob_vax if rank == 9855
setx efficacy2 0 efficacy3 1 duration2 0 majorside2 0 minorside2 0 fda2 1 origin2 0 origin3 0 endorsed2 1 endorsed3 0 endorsed4 0
simqi, genev(preds1)
_pctile preds1, p(2.5,97.5)
replace fig1upper = r(r1) if fig2label == 4
replace fig1lower = r(r2) if fig2label == 4 
egen x = mean(preds1)
replace fig1mean = x if fig2label == 4
drop x preds1

* 75th Percentile *
list  efficacy2 efficacy3 duration2 majorside2 minorside2 fda2 origin2 origin3 endorsed2 endorsed3 endorsed4 prob_vax if rank == 14783
setx efficacy2 1 efficacy3 0 duration2 1 majorside2 1 minorside2 1 fda2 1 origin2 0 origin3 1 endorsed2 0 endorsed3 0 endorsed4 1
simqi, genev(preds1)
_pctile preds1, p(2.5,97.5)
replace fig1upper = r(r1) if fig2label == 5.5
replace fig1lower = r(r2) if fig2label == 5.5
egen x = mean(preds1)
replace fig1mean = x if fig2label == 5.5
drop x preds1

* 99th Percentile *
list  efficacy2 efficacy3 duration2 majorside2 minorside2 fda2 origin2 origin3 endorsed2 endorsed3 endorsed4 prob_vax if rank == 19513
setx efficacy2 0 efficacy3 1 duration2 1 majorside2 0 minorside2 1 fda2 0 origin2 1 origin3 0 endorsed2 1 endorsed3 0 endorsed4 0
simqi, genev(preds1)
_pctile preds1, p(2.5,97.5)
replace fig1upper = r(r1) if fig2label == 7
replace fig1lower = r(r2) if fig2label == 7 
egen x = mean(preds1)
replace fig1mean = x if fig2label == 7
drop x preds1

eclplot fig1mean fig1lower fig1upper fig2label, xlabel(.3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%" .9 "90%" 1 "100%", labsize(small)) yscale(range(.55 1 2 3 4 5 5.5)) xtitle("Willingness to Receive Vaccine", size(small)) ytitle("")  horizontal graphregion(color(white)) ciopts(blcolor(black)) estopts1(color(black)) ///
ylabel(.55 "Efficacy: 50%" .7 "Duration: 1 year" .85 "Major side: 1 in 10,000" 1 "Minor side: 1 in 10" 1.15 "FDA: EUA" 1.3 "Origin: China" 1.45 "Endorsed: Biden" ///
2.05 "Efficacy: 50%" 2.2 "Duration: 1 year"  2.35 "Major side: 1 in 10,000" 2.5 "Minor side: 1 in 10" 2.65 "FDA: EUA" 2.8 "Origin: UK" 2.95 "Endorsed: WHO" ///
3.55 "Efficacy: 90%" 3.7 "Duration: 1 year" 3.85 "Major side: 1 in 1,000,000" 4 "Minor side: 1 in 10" 4.15 "FDA: EUA" 4.3 "Origin: China" 4.45 "Endorsed: CDC"  ///
5.05 "Efficacy: 70%" 5.2 "Duration: 5 years" 5.35 "Major side: 1 in 10,000" 5.5 "Minor side: 1 in 30" 5.65 "FDA: EUA" 5.8 "Origin: USA" 5.95 "Endorsed: WHO"  ///
6.55 "Efficacy: 90%" 6.7 "Duration: 5 years" 6.85 "Major side: 1 in 1,000,000" 7 "Minor side: 1 in 30" 7.15 "FDA: Full approval" 7.3 "Origin: UK" 7.45 "Endorsed: CDC", labsize(vsmall) nogrid notick) ytick(1 2.5 4 5.5 7, tposition(inside)) ///
text(1 .9 "1st percentile" 2.5 .9 "25th percentile" 4 .9 "50th percentile" 5.5 .9 "75th percentile" 7 .9 "99th percentile", place(e) size(vsmall)) 
gr_edit plotregion1.plot2.style.editstyle marker(fillcolor(black)) editcopy
gr_edit plotregion1.plot2.style.editstyle marker(linestyle(color(black))) editcopy

drop b1-b12 b13

* Holm correction for multiple comparisons *
* This will create a separate data set after each model, so we must reload the data each time *
* In each case we use the Banjamani-Hochberg (1995) for the False Discovert Rate (FDR) *
* See help for multproc -- method options for more information *

* Model 1 of Table 3 *
use  "Kreps_etal_vax_replication_data.dta", clear
gen accept_slightlyplus = 0
replace accept_slightlyplus = 1 if vaxord == 7
replace accept_slightlyplus = 1 if vaxord == 6
replace accept_slightlyplus = 1 if vaxord == 5
parmby "reg vaxbin i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, robust cluster(respondent)", label norestore
multproc if parm!="_cons" ,method(simes) puncor(.05)

* Model 2 of Table 3 *
use  "Kreps_etal_vax_replication_data.dta", clear
gen accept_slightlyplus = 0
replace accept_slightlyplus = 1 if vaxord == 7
replace accept_slightlyplus = 1 if vaxord == 6
replace accept_slightlyplus = 1 if vaxord == 5
parmby "reg vaxbin i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n dem5 gop5 female age education flu_vaccine no_insurance  pharma_favor knowcovid  worst_to_come not_evangelical evangelical2 not_religious black latino, robust cluster(respondent)", label norestore
multproc if parm!="_cons" ,method(simes) puncor(.05)

* Model 3 of Table 3 *
use  "Kreps_etal_vax_replication_data.dta", clear
gen accept_slightlyplus = 0
replace accept_slightlyplus = 1 if vaxord == 7
replace accept_slightlyplus = 1 if vaxord == 6
replace accept_slightlyplus = 1 if vaxord == 5
parmby "reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n, robust cluster(respondent)", label norestore
multproc if parm!="_cons" ,method(simes) puncor(.05)

* Model 4 of Table 3 *
use  "Kreps_etal_vax_replication_data.dta", clear
gen accept_slightlyplus = 0
replace accept_slightlyplus = 1 if vaxord == 7
replace accept_slightlyplus = 1 if vaxord == 6
replace accept_slightlyplus = 1 if vaxord == 5
parmby "reg accept_slightlyplus i.efficacy_n i.duration_n i.majorside_n i.minorside_n i.fda_n i.origin_n i.endorsed_n dem5 gop5 female age education flu_vaccine no_insurance  pharma_favor knowcovid  worst_to_come not_evangelical evangelical2 not_religious black latino, robust cluster(respondent)", label norestore
multproc if parm!="_cons" ,method(simes) puncor(.05)
