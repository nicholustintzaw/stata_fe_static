* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - based Prof.Ed text file example
  ** LAST UPDATE    03 24 2015 
  ** CONTENTS
  
	Perform analysis at school level or adolescent level with 
	
*/ 

********************************************************************************

	
	****************************************************************************
	****************************************************************************
	
	** USE ALL OUTLET FROM COMMUNE DATASET **
	use "$hh_prep/coverpage_prepared.dta", clear 
	
	keep 	hhid district com_name vill_name school_id classname /*grade*/ ado_age ado_agedob ado_sex ado_inschool ado_livemo ado_livemono ado_livemoother ado_livepcyear consent // take grade info from school data - MDRI provided updated data on GRADE 
	
	merge 1:1 hhid using "$hh_clean/hh_school_gps.dta"
	
	keep if _merge == 3 // keep only adolescent from the HH survey 
	drop _merge 
	
	keep hhid rural_urban
	
	tempfile rural_urban
	save `rural_urban', replace 
	
	use  "$foodenv_prep\FE_GPS_static_prepared_adolescent_level_all_outlets.dta", clear 
	
	merge 1:1 hhid using `rural_urban', keep(match) nogen assert(3)
	
	merge 1:1 hhid using 	"$foodenv_prep/FE_HH_FINAL_SAMPLE.dta",  ///
							keepusing(final_sample_hh final_sample_scho final_h2s_sample) ///
							keep(match) nogen assert(1 3)
		
	gen white_space = 0 // for indicator brekdown in sum-stat table

	rename scho_com_name com_name_scho 
	lab var com_name_scho "School Commune Name"
	
	drop com_name_id
	encode com_name, gen(com_name_id)
	order com_name_id, after(com_name)
	
	local outcomes	hh_near ///
					hh_near_nova4 hh_near_ssb hh_near_fruit hh_near_vegetable hh_near_fruitveg ///
					hh_near_gdqs_healthy hh_near_gdqs_unhealthy hh_near_gdqs_neutral ///
					hh_near_gdqs_1 hh_near_gdqs_2 hh_near_gdqs_3 hh_near_gdqs_4 hh_near_gdqs_5 hh_near_gdqs_6 ///
					hh_near_gdqs_7 hh_near_gdqs_8 hh_near_gdqs_9 hh_near_gdqs_10 hh_near_gdqs_11 hh_near_gdqs_12 ///
					hh_near_gdqs_13	hh_near_gdqs_14	hh_near_gdqs_15	hh_near_gdqs_16	hh_near_gdqs_17	///
					hh_near_gdqs_18	hh_near_gdqs_19	hh_near_gdqs_20	hh_near_gdqs_21	hh_near_gdqs_22	///
					hh_near_gdqs_23	hh_near_gdqs_24	hh_near_gdqs_25 
				
					
	keep hhid school_id rural_urban com_name_id `outcomes'

	keep if !mi(hh_near)
	
	reshape long hh_ , i(hhid) j(var) string 
	
	rename hh_ value
	
	replace var = "1" if var == "near"
	replace var = "2" if var == "near_nova4"
	replace var = "3" if var == "near_ssb"
	replace var = "4" if var == "near_fruit"
	replace var = "5" if var == "near_vegetable"
	replace var = "6" if var == "near_fruitveg"
	replace var = "7" if var == "near_gdqs_healthy"
	replace var = "8" if var == "near_gdqs_unhealthy"
	replace var = "9" if var == "near_gdqs_neutral"
	replace var = "10" if var == "near_gdqs_1"
	replace var = "11" if var == "near_gdqs_2"
	replace var = "12" if var == "near_gdqs_3"
	replace var = "13" if var == "near_gdqs_4"
	replace var = "14" if var == "near_gdqs_5"
	replace var = "15" if var == "near_gdqs_6"
	replace var = "16" if var == "near_gdqs_7"
	replace var = "17" if var == "near_gdqs_8"
	replace var = "18" if var == "near_gdqs_9"
	replace var = "19" if var == "near_gdqs_10"
	replace var = "20" if var == "near_gdqs_11"
	replace var = "21" if var == "near_gdqs_12"
	replace var = "22" if var == "near_gdqs_13"
	replace var = "23" if var == "near_gdqs_14"
	replace var = "24" if var == "near_gdqs_15"
	replace var = "25" if var == "near_gdqs_16"
	replace var = "26" if var == "near_gdqs_17"
	replace var = "27" if var == "near_gdqs_18"
	replace var = "28" if var == "near_gdqs_19"
	replace var = "29" if var == "near_gdqs_20"
	replace var = "30" if var == "near_gdqs_21"
	replace var = "31" if var == "near_gdqs_22"
	replace var = "32" if var == "near_gdqs_23"
	replace var = "33" if var == "near_gdqs_24"
	replace var = "34" if var == "near_gdqs_25"

	
	rename var variable 
	destring variable, replace 
	
	lab def val_lab 1"near_any_outlet" ///
					2"near_nova4" ///
					3"near_ssb" ///
					4"near_fruit" ///
					5"near_vegetable" ///
					6"near_fruitveg" ///
					7"near_gdqs_healthy" ///
					8"near_gdqs_unhealthy" ///
					9"near_gdqs_neutral" ///
					10"near_gdqs_1" ///
					11"near_gdqs_2" ///
					12"near_gdqs_3" ///
					13"near_gdqs_4" ///
					14"near_gdqs_5" ///
					15"near_gdqs_6" ///
					16"near_gdqs_7" ///
					17"near_gdqs_8" ///
					18"near_gdqs_9" ///
					19"near_gdqs_10" ///
					20"near_gdqs_11" ///
					21"near_gdqs_12" ///
					22"near_gdqs_13" ///
					23"near_gdqs_14" ///
					24"near_gdqs_15" ///
					25"near_gdqs_16" ///
					26"near_gdqs_17" ///
					27"near_gdqs_18" ///
					28"near_gdqs_19" ///
					29"near_gdqs_20" ///
					30"near_gdqs_21" ///
					31"near_gdqs_22" ///
					32"near_gdqs_23" ///
					33"near_gdqs_24" ///
					34"near_gdqs_25" 

	lab val variable val_lab 
	
	&&
	
	global  graph_opts1 bgcolor(white) graphregion(color(white))  ///
			legend(region(lc(none) fc(none)))                     ///
			ylab(,angle(0) nogrid) title(, justification(left) color(black) span pos(17)) subtitle(, justification(left) color(black))
		  
  graph   box value,     ///
          hor over(variable) ///
          legend(order(0 "Professional Cadre:" 1 "Medical Officer" 2 "Nurse") r(1) symxsize(small) symysize(small)  pos(6) ring(1)) ///
          asy $graph_opts1 ylab(-1 "-1 SD" 0 "SDI Mean" .553483 "Median" 1 "+1 SD" 2 "+2 SD" 3 "+3 SD", labsize(vsmall)) ytit("") note("") ///
          lintensity(.5) yline(.553483 , lc(black) lp(dash)) ///
          box(1 , fi(0) lc(maroon) lw(medthick)) box(2, fc(white) lc(navy) lw(medthick)) ///
    title ("Percentile Box Plot")
	
	
	preserve 
		
		keep if variable < 10 & rural_urban == 1
		graph box value, 	hor over(variable)	///
							box(1 , fi(0) lc(maroon) lw(medthick)) ///
							marker(1, msize(vtiny) mcolor(blue)) ///
							$graph_opts1 ///
							ylab(0 "0" 250 "250" 500 "500" 1000 "1000" 2000 "2000" 4000 "4000" 6000 "6000", labsize(vsmall)) ///
							ytit("") note("") ///
							title("Rural")
							
	restore 
	
	preserve 
		
		keep if variable < 10 & rural_urban == 2
		graph box value, 	hor over(variable)	///
							box(1 , fi(0) lc(maroon) lw(medthick)) ///
							marker(1, msize(vtiny) mcolor(blue)) ///
							$graph_opts1 ///
							ylab(, labsize(vsmall)) ///
							ytit("") note("") ///
							title("Peri-Urban")
							
	restore 
	
	
	preserve 
		
		keep if variable < 10 & rural_urban == 3
		graph box value, 	hor over(variable)	///
							box(1 , fi(0) lc(maroon) lw(medthick)) ///
							marker(1, msize(vtiny) mcolor(blue)) ///
							$graph_opts1 ///
							ylab(, labsize(vsmall)) ///
							ytit("") note("") ///
							title("Urban")
							
	restore 
	
	preserve 
		
		keep if variable < 10 & rural_urban != 1
		graph box value, 	hor over(rural_urban) over(variable) ///
							marker(1, msize(vtiny) mcolor(blue)) ///
							marker(2, msize(vtiny) mcolor(red)) ///
							legend(order(1 "Peri-Urban" 2 "Urban") r(1) symxsize(small) symysize(small)  pos(6) ring(1)) ///
							asy $graph_opts1 ///
							box(1 , fi(0) lc(maroon) lw(medthick)) ///
							box(2, fc(white) lc(navy) lw(medthick)) ///
							ylab(, labsize(vsmall)) ///
							ytit("") note("") ///
							title("Peri-Urban vs Urban")
							
	restore 
	
	
	preserve 
	
		keep if variable >= 10
		graph box value, 	hor over(variable)	///
							box(1 , fi(0) lc(maroon) lw(medthick)) ///
							$graph_opts1 
	
	restore 
	
	&&
	
	
	foreach var in `outcomes' {
		
		egen mx_`var'	= mean(`var')
		egen p50_`var'	= pctile(`var'), p(50)
		egen p95_`var'	= pctile(`var'), p(95)
		egen p99_`var'	= pctile(`var'), p(99)
		
		drop `var'
		
	} 
	
	keep if _n == 1
	
	gen obs_index = _n 
	
	reshape long mx_ p50_ p95_ p99_, i(obs_index) j(var) string
	
	
	rename *_ v_* 
	
	reshape long v_, i(var) j(value) string 
	
	rename v_ reporting_value 
	
	keep var value reporting_value
	
	
	
	
	
	
	
	&&&
	** Prepare for reshape long form ** 
	keep hhid school_id rural_urban com_name_id *_near *_near_fruit		
	
	keep if !mi(hh_near)
		
	rename hh_* *_hh 
	rename scho_* *_scho 
		
	reshape long near_ near_fruit_ , i(hhid) j(enviroment) string 
	
	replace enviroment = "1" if enviroment == "hh"
	replace enviroment = "2" if enviroment == "scho"
	destring enviroment, replace 
	
	
	rename *_ * 
	
	
	* For adolescent level 
	keep if rural_urban == 1
	
	mixed near_fruit enviroment || com_name_id:, mle 
	estat icc
	
	mixed near_fruit enviroment || school_id:, mle 
	estat icc
	
	mixed near_fruit enviroment || com_name_id: || school_id:, mle 
	estat icc
		
		
	
	bysort school_id enviroment: egen near_fruit_hh_mean = mean(near_fruit)
	sort enviroment school_id 
	
	bysort school_id enviroment: keep if _n == 1
	
	mixed near_fruit_hh_mean enviroment || school_id:, mle 
	estat icc
	
	&&&
	
	rural_urban
	
	
	&&
	
	enviroment
	
	
	** USE SCHOOL LEVEL DATASET **
	use "$foodenv_prep\FE_GPS_static_prepared_HH_vs_School_at_school_level.dta", clear 
	
	keep if rural_urban == 1 
	
	tab school_id, m // 9 schools 
	tab enviroment, m 
	
	// sample outcome var - near_any_outlet 
	keep enviroment school_id rural_urban near_vegetable
	
	sort school_id enviroment

	
	&&
	* use HH/School Enviroment dataset - 100 meters		
	use "$foodenv_prep\FE_GPS_static_prepared_combined_HH_School_100m_H2S_10m.dta", clear 

	keep if rural_urban == 1 
	drop if enviroment == 3
	

	
	&&
	
	****************************************************************************
	* Set Function 
	qui do "$foodenv_analysis/analysis_function_do/StatsByNeighborhood.do"    

	* define the parameter to apply in function 
	* neighborhood : means the cluster varaible
	* SES : means the variable for category of sample (for comparision)
	
	/*
	Jef agreed to adjust for commune:

	When we conduct comparisons of FEs by geographical region
	When we conduct comparisons between home and school FEs within each geographical region (waiting to hear back from Ed Frongillo on how to do this)
	*/
	
	gen neighborhood = com_name_id 
	// replace with adolescent commune instead of school commune at individual level analysis 

	gen SES = enviroment
	lab val SES enviroment
	tab SES, m 

	* Set reporting variables 
	global outcomes	near_any_outlet ///
					near_nova4 near_ssb near_fruit near_vegetable near_fruitveg ///
					near_gdqs_yes near_gdqs_healthy near_gdqs_unhealthy near_gdqs_neutral ///
					near_gdqs_1 near_gdqs_2 near_gdqs_3 near_gdqs_4 near_gdqs_5 near_gdqs_6 ///
					near_gdqs_7 near_gdqs_8 near_gdqs_9 near_gdqs_10 near_gdqs_11 near_gdqs_12 ///
					near_gdqs_13 near_gdqs_14 near_gdqs_15 near_gdqs_16 near_gdqs_17 near_gdqs_18 ///
					near_gdqs_19 near_gdqs_20 near_gdqs_21 near_gdqs_22 near_gdqs_23 near_gdqs_24 near_gdqs_25 ///
					gdqs_healthy_score gdqs_unhealthy_score gdqs_healthy_num gdqs_unhealthy_num gdqs_neutral_num
	

	global outcomes_1 ado_expo_yes ado_expo_num 
	
	
	****************************************************************************
	****************************************************************************
	
	** Export Analysis Tables **
	
	****************************************************************************
	****************************************************************************
	
	****************************************************************************
	** Home Vs School Enviroment Comparision: Adolescent Level **
	****************************************************************************
	tab SES, m 
	tab SES, m nolab 
	
	keep if SES < 3 // home to school route 
	
	recode SES (1 = 0) (2 = 1) // to matched with function command; home = 0 vs School = 1
	lab def edit_ses 0"Home" 1"School"
	lab val SES edit_ses
	
	
	** (1): HH Vs School Enviroment: Rural
	preserve 
	
		keep if rural_urban == 1
		
			xi:StatsByNeighborhood ///
				$outcomes ///
				using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Rural_Adolevel.xls", ///
				report_N(near_any_outlet) excelrow(5)

			xi:StatsByNeighborhood ///
				$outcomes_1 ///
				using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Rural_allsample_Adolevel.xls", ///
				report_N(ado_expo_yes) excelrow(5)
			
	restore 
	
	** (2): HH Vs School Eenviroment: Peri-Urban 
	preserve 
		
		keep if rural_urban == 2
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_PeriUrban_Adolevel.xls", ///
			report_N(near_any_outlet) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_PeriUrban_allsample_Adolevel.xls", ///
			report_N(ado_expo_yes) excelrow(5)		
		
	restore 	
	
	** (3): HH Vs School Enviroment: Urban 
	preserve 
		
		keep if rural_urban == 3
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Urban_Adolevel.xls", ///
			report_N(near_any_outlet) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Urban_allsample_Adolevel.xls", ///
			report_N(ado_expo_yes) excelrow(5)		
		
	restore 	
	
	****************************************************************************
	** Home Vs School Enviroment Comparision: School Level **
	****************************************************************************

	* Prepare temfpile for home enviroment * 
	preserve 
	
		* keep dataset at school unique level 
		bysort  enviroment school_id: keep if _n == 1 // keep data at school & enviroment level 
		
		keep if enviroment == 2
		
		tempfile school_fe 
		save `school_fe', replace 
		
	restore 
	
	
	* Calculate average/median score for HH enviroment at School Level * 
	keep if enviroment == 1
	
	* Set reporting variables 
	global outcomes	near_any_outlet ///
					near_nova4 near_ssb near_fruit near_vegetable near_fruitveg ///
					near_gdqs_yes near_gdqs_healthy near_gdqs_unhealthy near_gdqs_neutral ///
					near_gdqs_1 near_gdqs_2 near_gdqs_3 near_gdqs_4 near_gdqs_5 near_gdqs_6 ///
					near_gdqs_7 near_gdqs_8 near_gdqs_9 near_gdqs_10 near_gdqs_11 near_gdqs_12 ///
					near_gdqs_13 near_gdqs_14 near_gdqs_15 near_gdqs_16 near_gdqs_17 near_gdqs_18 ///
					near_gdqs_19 near_gdqs_20 near_gdqs_21 near_gdqs_22 near_gdqs_23 near_gdqs_24 near_gdqs_25 ///
					gdqs_healthy_score gdqs_unhealthy_score gdqs_healthy_num gdqs_unhealthy_num gdqs_neutral_num
	

	global outcomes_1 ado_expo_yes ado_expo_num 
	
	foreach var in $outcomes_1 {
		
		local n_label : var label `var'
		
		bysort school_id: egen `var'_mean = mean(`var')
		bysort school_id: egen `var'_median = median(`var')
		bysort school_id: egen `var'_sd = sd(`var')
		bysort school_id: egen `var'_iqr = iqr(`var')
		
		lab var `var'_mean "`n_label': mean"
		lab var `var'_median "`n_label': median"
		lab var `var'_sd "`n_label': SD"
		lab var `var'_iqr "`n_label': IQR"
		
		order `var'_mean `var'_median `var'_sd `var'_iqr, after(`var')
		
		drop `var'

	}
	
	foreach var in $outcomes {
		
		local n_label : var label `var'
		
		bysort school_id: egen `var'_mean = mean(`var')
		bysort school_id: egen `var'_median = median(`var')
		bysort school_id: egen `var'_sd = sd(`var')
		bysort school_id: egen `var'_iqr = iqr(`var')
		
		lab var `var'_mean "`n_label': mean"
		lab var `var'_median "`n_label': median"
		lab var `var'_sd "`n_label': SD"
		lab var `var'_iqr "`n_label': IQR"
		
		order `var'_mean `var'_median `var'_sd `var'_iqr, after(`var')
		
		drop `var'
		
	}
	
	* keep dataset at school level 
	bysort school_id: keep if _n == 1 // keep at school level 
	
	* Make sumstat table for HH Enviroment **
	
	preserve 
	
		keep	com_name_scho school_id ///
				near_any_outlet_* ///
				near_nova4_* near_ssb_* near_fruit_* near_vegetable_* near_fruitveg_* ///
				near_gdqs_healthy_* near_gdqs_unhealthy_* near_gdqs_neutral_* ///
				near_gdqs_1_* near_gdqs_2_* near_gdqs_3_* near_gdqs_4_* near_gdqs_5_* ///
				near_gdqs_6_* near_gdqs_7_* near_gdqs_8_* near_gdqs_9_* near_gdqs_10_* ///
				near_gdqs_11_* near_gdqs_12_* near_gdqs_13_* near_gdqs_14_* near_gdqs_15_* ///
				near_gdqs_16_* near_gdqs_17_* near_gdqs_18_* near_gdqs_19_* near_gdqs_20_* ///
				near_gdqs_21_* near_gdqs_22_* near_gdqs_23_* near_gdqs_24_* near_gdqs_25_* ///
				gdqs_healthy_score_* gdqs_unhealthy_score_* gdqs_healthy_num_* ///
				gdqs_unhealthy_num_* gdqs_neutral_num_*
		
		export excel using "$foodenv_out\For paper\Tables_distance\Sumstat_proximity_HH_FE_at_School_Level_Geo_Compare.xlsx",  /// 
										sheet("rural_urban") firstrow(varlabels) keepcellfmt sheetreplace
	
	restore 
	
	
	** FE - school level dataset preparation ** 
	preserve 
	
		rename *_mean *
		
		drop *_median *_sd 
		
		tempfile hh_fe_mean 
		save `hh_fe_mean'
	
	restore 
	
	preserve 
	
		rename *_median *
		
		drop *_mean *_sd 
		
		tempfile hh_fe_median 
		save `hh_fe_median'
	
	restore 
	
	* HH FE Mean DATASET * 
	use `school_fe', clear 

	append using `hh_fe_mean'
	
	tab enviroment, m 
	distinct school_id enviroment, joint 
	
	lab drop yesno
	
	drop neighborhood
	gen neighborhood = com_name_scho // treat cluster as school commune 
	
	tempfile FE_HH_MEAN_SCHOOL
	save `FE_HH_MEAN_SCHOOL', replace 
		
	save "$foodenv_prep\FE_GPS_static_prepared_HH_vs_School_at_school_level.dta", replace 

	
	* HH FE Median DATASET * 
	use `school_fe', clear 

	append using `hh_fe_median'
	
	tab enviroment, m 
	distinct school_id enviroment, joint 
	
	lab drop yesno 
	
	drop neighborhood
	gen neighborhood = com_name_scho // treat cluster as school commune 
	
	tempfile FE_HH_MEDIAN_SCHOOL
	save `FE_HH_MEDIAN_SCHOOL', replace 
	
	
	** (1): HH Vs School Enviroment: Rural
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 

	preserve 
	
		keep if rural_urban == 1
		
			xi:StatsByNeighborhood ///
				$outcomes ///
				using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Rural_MEAN.xls", ///
				report_N(near_any_outlet) excelrow(5)

			xi:StatsByNeighborhood ///
				$outcomes_1 ///
				using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Rural_allsample_MEAN.xls", ///
				report_N(ado_expo_yes) excelrow(5)
			
	restore 
	
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 1
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Rural_MEDIAN.xls", ///
			report_N(near_any_outlet) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Rural_allsample_MEDIAN.xls", ///
			report_N(ado_expo_yes) excelrow(5)
			
	restore 	
	
	** (2): HH Vs School Eenviroment: Peri-Urban 
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 2
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_PeriUrban_MEAN.xls", ///
			report_N(near_any_outlet) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_PeriUrban_allsample_MEAN.xls", ///
			report_N(ado_expo_yes) excelrow(5)		
		
	restore 	
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 2	
		
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_PeriUrban_MEDIAN.xls", ///
			report_N(near_any_outlet) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_PeriUrban_allsample_MEDIAN.xls", ///
			report_N(ado_expo_yes) excelrow(5)		
		
	restore 
	
	** (3): HH Vs School Enviroment: Urban 
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 3
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Urban_MEAN.xls", ///
			report_N(near_any_outlet) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Urban_allsample_MEAN.xls", ///
			report_N(ado_expo_yes) excelrow(5)		
		
	restore 	
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear  
	
	preserve 
		
		keep if rural_urban == 3
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Urban_MEDIAN.xls", ///
			report_N(near_any_outlet) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Reg_proximity_HH_School_Urban_allsample_MEDIAN.xls", ///
			report_N(ado_expo_yes) excelrow(5)		
		
	restore 
	

	
	** end of dofile 
	
