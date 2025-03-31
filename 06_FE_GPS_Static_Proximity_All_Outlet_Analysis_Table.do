* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - HH and School enviroment with all available outlet 
  ** LAST UPDATE    10 25 2024 
  ** CONTENTS
		
	
*/ 

********************************************************************************
		
	************************************************************************************
	** DISTANCE data HH/School to Outlet - with all outlets available in FE dataset 
	************************************************************************************
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
	
	
	* GDQS Unhealthy Score - absolute value correction
	foreach var of varlist hh_gdqs_unhealthy_score scho_gdqs_unhealthy_score {
		
		replace `var' = abs(`var') if !mi(`var') 
		
	}
	
	
	* Winsoring at 99 and 95 percentile 
	local outcomes	hh_near ///
					hh_near_nova4 hh_near_ssb hh_near_fruit hh_near_vegetable hh_near_fruitveg ///
					hh_near_gdqs_yes hh_near_gdqs_healthy hh_near_gdqs_unhealthy hh_near_gdqs_neutral ///
					hh_near_gdqs_1 hh_near_gdqs_2 hh_near_gdqs_3 hh_near_gdqs_4 hh_near_gdqs_5 hh_near_gdqs_6 ///
					hh_near_gdqs_7 hh_near_gdqs_8 hh_near_gdqs_9 hh_near_gdqs_10 hh_near_gdqs_11 hh_near_gdqs_12 ///
					hh_near_gdqs_13	hh_near_gdqs_14	hh_near_gdqs_15	hh_near_gdqs_16	hh_near_gdqs_17	///
					hh_near_gdqs_18	hh_near_gdqs_19	hh_near_gdqs_20	hh_near_gdqs_21	hh_near_gdqs_22	///
					hh_near_gdqs_23	hh_near_gdqs_24	hh_near_gdqs_25 ///
					hh_gdqs_healthy_score hh_gdqs_unhealthy_score ///
					hh_gdqs_healthy_num hh_gdqs_unhealthy_num hh_gdqs_neutral_num ///
					scho_near ///
					scho_near_nova4 scho_near_ssb scho_near_fruit scho_near_vegetable scho_near_fruitveg ///
					scho_near_gdqs_yes scho_near_gdqs_healthy scho_near_gdqs_unhealthy scho_near_gdqs_neutral ///
					scho_near_gdqs_1 scho_near_gdqs_2 scho_near_gdqs_3 scho_near_gdqs_4 scho_near_gdqs_5 scho_near_gdqs_6 ///
					scho_near_gdqs_7 scho_near_gdqs_8 scho_near_gdqs_9 scho_near_gdqs_10 scho_near_gdqs_11 scho_near_gdqs_12 ///
					scho_near_gdqs_13 scho_near_gdqs_14 scho_near_gdqs_15 scho_near_gdqs_16 scho_near_gdqs_17 scho_near_gdqs_18 ///
					scho_near_gdqs_19 scho_near_gdqs_20 scho_near_gdqs_21 scho_near_gdqs_22 scho_near_gdqs_23 scho_near_gdqs_24 scho_near_gdqs_25 ///
					scho_gdqs_healthy_score scho_gdqs_unhealthy_score ///					
					scho_gdqs_healthy_num scho_gdqs_unhealthy_num scho_gdqs_neutral_num 
					
		
	* to record winsorized
	preserve 
		
		clear 
		
		tempfile pct_dt
		save `pct_dt', emptyok 
		
	restore 
	
	local i = 1
					
	foreach var in `outcomes' {
		
		local lab: variable label  `var'
		
		
		gen `var'_99p = `var'
		gen `var'_95p = `var'
		
		quietly sum `var', d 
		
		local p99 = r(p99)
		local p95 = r(p95)
		
		replace `var'_99p = `p99' if `var' > `p99' & !mi(`var')
		replace `var'_95p = `p95' if `var' > `p95' & !mi(`var')
		
		lab var `var'_99p "`lab' - winsorized 99p"
		lab var `var'_95p "`lab' - winsorized 95p"
		
		
		count if `var' > `p95' & !mi(`var')
		local n_p95 = `r(N)'
		
		count if `var' > `p95' & !mi(`var') & rural_urban == 1
		local n_p95_1 = `r(N)'
		
		count if `var' > `p95' & !mi(`var') & rural_urban == 2
		local n_p95_2 = `r(N)'
		
		count if `var' > `p95' & !mi(`var') & rural_urban == 3
		local n_p95_3 = `r(N)'
		
		
		
		count if `var' > `p99' & !mi(`var')
		local n_p99 = `r(N)'
		
		count if `var' > `p99' & !mi(`var') & rural_urban == 1
		local n_p99_1 = `r(N)'
		
		count if `var' > `p99' & !mi(`var') & rural_urban == 2
		local n_p99_2 = `r(N)'
		
		count if `var' > `p99' & !mi(`var') & rural_urban == 3
		local n_p99_3 = `r(N)'
		
		preserve 
		
			clear 
			set obs 1
			
			gen index = `i' 
			gen var = "`var'"
			
			gen greater_than_95p 		= `n_p95'
			gen greater_than_95p_rural 	= `n_p95_1'
			gen greater_than_95p_purban	= `n_p95_2'
			gen greater_than_95p_urban	= `n_p95_3'
			
			gen greater_than_99p 		= `n_p99'
			gen greater_than_99p_rural	= `n_p99_1'
			gen greater_than_99p_purban = `n_p99_2'
			gen greater_than_99p_urban	= `n_p99_3'
		
			append using `pct_dt'
			save `pct_dt', replace 
			
			 
		
		restore 
		
		local i = `i' + 1

	}
	
	preserve 
	
		use `pct_dt', clear 
	
		export excel using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("winsorized_obs_proximity") firstrow(varlabels) keepcellfmt sheetreplace 
										
	restore 
	
	
	* Outlet exposure proportion by proximity category 
	* (re -organized into 3 category)
	* 50m, 50-199m and 200+ m
	
	tab1 ado_hh_dist_cat_1 ado_hh_dist_cat_2 ado_hh_dist_cat_3 ado_hh_dist_cat_4 ado_hh_dist_cat_5 
	tab1 ado_scho_dist_cat_1 ado_scho_dist_cat_2 ado_scho_dist_cat_3 ado_scho_dist_cat_4 ado_scho_dist_cat_5
	
	local grp hh scho 
	
	foreach g in `grp' {
		
		// ado_hh_dist_cat_2 
		tab1 ado_`g'_dist_cat_2 ado_`g'_dist_cat_3 , m 
		replace ado_`g'_dist_cat_2 = 1 if ado_`g'_dist_cat_3 == 1 & ado_`g'_dist_cat_2 == 0
		tab ado_`g'_dist_cat_2, m 
		
		drop ado_`g'_dist_cat_3
		
		// ado_hh_dist_cat_4
		tab ado_`g'_dist_cat_4, m 
		replace ado_`g'_dist_cat_4 = 1 if ado_`g'_dist_cat_5 == 1 & ado_`g'_dist_cat_4 == 0 
		tab ado_`g'_dist_cat_4, m 
		
		rename ado_`g'_dist_cat_4 ado_`g'_dist_cat_3
		
		drop ado_`g'_dist_cat_5
		
		lab var ado_`g'_dist_cat_2 	"Adolescent with nearest outlet 50-199 meter"
		lab var ado_`g'_dist_cat_3 	"Adolescent with nearest outlet 200+ meter"
		
	}

	
	lab def yesno 0"No" 1"Yes"
	lab val ado_hh_dist_cat_1 ado_hh_dist_cat_2 ado_hh_dist_cat_3 ///
			ado_scho_dist_cat_1 ado_scho_dist_cat_2 ado_scho_dist_cat_3 ///
			yesno 
	
	* Save dataset 
	save "$foodenv_prep\FE_GPS_static_prepared_adolescent_level_all_outlets_final.dta", replace 

	
	****************************************************************************
	* (A) HH Enviroment Exposure 
	****************************************************************************
	* outcome varaible global definition 
	global outcomes	hh_near hh_near_95p hh_near_99p ///
					white_space /// 
					ado_hh_dist_cat_1 ado_hh_dist_cat_2 ado_hh_dist_cat_3 ///
					white_space /// 
					hh_near_nova4 hh_near_ssb hh_near_fruit hh_near_vegetable hh_near_fruitveg ///
					white_space /// 
					hh_near_nova4_95p hh_near_ssb_95p hh_near_fruit_95p hh_near_vegetable_95p hh_near_fruitveg_95p ///
					white_space /// 
					hh_near_nova4_99p hh_near_ssb_99p hh_near_fruit_99p hh_near_vegetable_99p hh_near_fruitveg_99p ///
					white_space ///
					/*hh_near_gdqs_yes*/ hh_near_gdqs_healthy hh_near_gdqs_unhealthy hh_near_gdqs_neutral ///
					white_space ///
					/*hh_near_gdqs_yes_95p*/ hh_near_gdqs_healthy_95p hh_near_gdqs_unhealthy_95p hh_near_gdqs_neutral_95p ///
					white_space ///
					/*hh_near_gdqs_yes_99p*/ hh_near_gdqs_healthy_99p hh_near_gdqs_unhealthy_99p hh_near_gdqs_neutral_99p ///
					white_space /// 
					hh_near_gdqs_1 hh_near_gdqs_2 hh_near_gdqs_3 hh_near_gdqs_4 hh_near_gdqs_5 hh_near_gdqs_6 ///
					hh_near_gdqs_7 hh_near_gdqs_8 hh_near_gdqs_9 hh_near_gdqs_10 hh_near_gdqs_11 hh_near_gdqs_12 ///
					hh_near_gdqs_13	hh_near_gdqs_14	hh_near_gdqs_15	hh_near_gdqs_16	hh_near_gdqs_17	///
					hh_near_gdqs_18	hh_near_gdqs_19	hh_near_gdqs_20	hh_near_gdqs_21	hh_near_gdqs_22	///
					hh_near_gdqs_23	hh_near_gdqs_24	hh_near_gdqs_25 ///
					white_space /// 
					hh_near_gdqs_1_95p hh_near_gdqs_2_95p hh_near_gdqs_3_95p hh_near_gdqs_4_95p hh_near_gdqs_5_95p ///
					hh_near_gdqs_6_95p hh_near_gdqs_7_95p hh_near_gdqs_8_95p hh_near_gdqs_9_95p hh_near_gdqs_10_95p ///
					hh_near_gdqs_11_95p hh_near_gdqs_12_95p hh_near_gdqs_13_95p	hh_near_gdqs_14_95p	hh_near_gdqs_15_95p	///
					hh_near_gdqs_16_95p	hh_near_gdqs_17_95p	hh_near_gdqs_18_95p	hh_near_gdqs_19_95p	hh_near_gdqs_20_95p	///
					hh_near_gdqs_21_95p	hh_near_gdqs_22_95p	hh_near_gdqs_23_95p	hh_near_gdqs_24_95p	hh_near_gdqs_25_95p ///
					white_space /// 
					hh_near_gdqs_1_99p hh_near_gdqs_2_99p hh_near_gdqs_3_99p hh_near_gdqs_4_99p hh_near_gdqs_5_99p ///
					hh_near_gdqs_6_99p hh_near_gdqs_7_99p hh_near_gdqs_8_99p hh_near_gdqs_9_99p hh_near_gdqs_10_99p ///
					hh_near_gdqs_11_99p hh_near_gdqs_12_99p hh_near_gdqs_13_99p	hh_near_gdqs_14_99p	hh_near_gdqs_15_99p	///
					hh_near_gdqs_16_99p	hh_near_gdqs_17_99p	hh_near_gdqs_18_99p	hh_near_gdqs_19_99p	hh_near_gdqs_20_99p	///
					hh_near_gdqs_21_99p	hh_near_gdqs_22_99p	hh_near_gdqs_23_99p	hh_near_gdqs_24_99p	hh_near_gdqs_25_99p ///
					white_space /// 
					hh_gdqs_healthy_score hh_gdqs_unhealthy_score ///
					white_space /// 
					hh_gdqs_healthy_score_95p hh_gdqs_unhealthy_score_95p ///
					white_space /// 
					hh_gdqs_healthy_score_99p hh_gdqs_unhealthy_score_99p ///
					white_space ///
					hh_gdqs_healthy_num hh_gdqs_unhealthy_num hh_gdqs_neutral_num ///
					white_space ///
					hh_gdqs_healthy_num_95p hh_gdqs_unhealthy_num_95p hh_gdqs_neutral_num_95p ///				
					white_space ///
					hh_gdqs_healthy_num_99p hh_gdqs_unhealthy_num_99p hh_gdqs_neutral_num_99p
			
	
	
	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
					
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("FE_Static_alloutlets_hh_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}	
	
	
	
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
	// replace with commune instead of school_id in vietname, use school as cluster

	** Export Analysis Tables **
	** (1): HH enviroment: Geo comparision - Rural Vs Peri-Urban 
	preserve 
		
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_HH_AllOutlets_Rural_Vs_PeriUrban.xls", ///
			report_N(hh_near) excelrow(5)
			
	restore 
	
	** (2): HH enviroment: Geo comparision - Rural Vs Urban 
	preserve 
			
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_HH_AllOutlets_Rural_Vs_Urban.xls", ///
			report_N(hh_near) excelrow(5)	
		
	restore 	
	
	** (3): HH enviroment: Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_HH_AllOutlets_PeriUrban_Vs_Urban.xls", ///
			report_N(hh_near) excelrow(5)	
		
	restore 	
	
	
	****************************************************************************
	* (B) School Enviroment Exposure 
	****************************************************************************
	* keep dataset at school unique level 
	bysort  school_id: keep if _n == 1
		
	* to solve the sumstat output number issues
	preserve 
	
		clear 
		set obs 300
		gen school_id = .m 
		
		
		tempfile extra_df 
		save `extra_df', replace 
	
	
	restore 
	
	append using `extra_df'
	
	* outcome varaible global definition 
	global outcomes	scho_near scho_near_95p scho_near_99p ///
					white_space ///
					ado_scho_dist_cat_1 ado_scho_dist_cat_2 ado_scho_dist_cat_3 ///
					white_space ///
					scho_near_nova4 scho_near_ssb scho_near_fruit scho_near_vegetable scho_near_fruitveg ///
					white_space ///
					scho_near_nova4_95p scho_near_ssb_95p scho_near_fruit_95p scho_near_vegetable_95p scho_near_fruitveg_95p ///
					white_space ///
					scho_near_nova4_99p scho_near_ssb_99p scho_near_fruit_99p scho_near_vegetable_99p scho_near_fruitveg_99p ///
					white_space /// 
					/*scho_near_gdqs_yes*/ scho_near_gdqs_healthy scho_near_gdqs_unhealthy scho_near_gdqs_neutral ///
					white_space /// 
					/*scho_near_gdqs_yes_95p*/ scho_near_gdqs_healthy_95p scho_near_gdqs_unhealthy_95p scho_near_gdqs_neutral_95p ///
					white_space /// 
					/*scho_near_gdqs_yes_99p*/ scho_near_gdqs_healthy_99p scho_near_gdqs_unhealthy_99p scho_near_gdqs_neutral_99p ///
					white_space /// 
					scho_near_gdqs_1 scho_near_gdqs_2 scho_near_gdqs_3 scho_near_gdqs_4 scho_near_gdqs_5 ///
					scho_near_gdqs_6 scho_near_gdqs_7 scho_near_gdqs_8 scho_near_gdqs_9 scho_near_gdqs_10 ///
					scho_near_gdqs_11 scho_near_gdqs_12 scho_near_gdqs_13 scho_near_gdqs_14 scho_near_gdqs_15 ///
					scho_near_gdqs_16 scho_near_gdqs_17 scho_near_gdqs_18 scho_near_gdqs_19 scho_near_gdqs_20 ///
					scho_near_gdqs_21 scho_near_gdqs_22 scho_near_gdqs_23 scho_near_gdqs_24 scho_near_gdqs_25 ///
					white_space /// 
					scho_near_gdqs_1_95p scho_near_gdqs_2_95p scho_near_gdqs_3_95p scho_near_gdqs_4_95p scho_near_gdqs_5_95p ///
					scho_near_gdqs_6_95p scho_near_gdqs_7_95p scho_near_gdqs_8_95p scho_near_gdqs_9_95p scho_near_gdqs_10_95p ///
					scho_near_gdqs_11_95p scho_near_gdqs_12_95p scho_near_gdqs_13_95p scho_near_gdqs_14_95p scho_near_gdqs_15_95p ///
					scho_near_gdqs_16_95p scho_near_gdqs_17_95p scho_near_gdqs_18_95p scho_near_gdqs_19_95p scho_near_gdqs_20_95p ///
					scho_near_gdqs_21_95p scho_near_gdqs_22_95p scho_near_gdqs_23_95p scho_near_gdqs_24_95p scho_near_gdqs_25_95p ///
					white_space /// 
					scho_near_gdqs_1_99p scho_near_gdqs_2_99p scho_near_gdqs_3_99p scho_near_gdqs_4_99p scho_near_gdqs_5_99p ///
					scho_near_gdqs_6_99p scho_near_gdqs_7_99p scho_near_gdqs_8_99p scho_near_gdqs_9_99p scho_near_gdqs_10_99p ///
					scho_near_gdqs_11_99p scho_near_gdqs_12_99p scho_near_gdqs_13_99p scho_near_gdqs_14_99p scho_near_gdqs_15_99p ///
					scho_near_gdqs_16_99p scho_near_gdqs_17_99p scho_near_gdqs_18_99p scho_near_gdqs_19_99p scho_near_gdqs_20_99p ///
					scho_near_gdqs_21_99p scho_near_gdqs_22_99p scho_near_gdqs_23_99p scho_near_gdqs_24_99p scho_near_gdqs_25_99p ///
					white_space ///	
					scho_gdqs_healthy_score scho_gdqs_unhealthy_score ///
					white_space ///	
					scho_gdqs_healthy_score_95p scho_gdqs_unhealthy_score_95p ///
					white_space ///	
					scho_gdqs_healthy_score_99p scho_gdqs_unhealthy_score_99p ///					
					white_space ///
					scho_gdqs_healthy_num scho_gdqs_unhealthy_num scho_gdqs_healthy_num ///
					white_space ///
					scho_gdqs_healthy_num_95p scho_gdqs_unhealthy_num_95p scho_gdqs_neutral_num_95p ///
					white_space ///
					scho_gdqs_healthy_num_99p scho_gdqs_unhealthy_num_99p scho_gdqs_neutral_num_99p 
	
	
	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			replace rural_urban = `x' if mi(rural_urban)
					
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"

			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("FE_Static_alloutlets_scho_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}	
	
	
	
	
	** (4): School enviroment: Geo comparision - Rural Vs Peri-Urban
	preserve 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
	* neighborhood correction - avoid divergence issue - treat goe locaton as cluster instead of school or commune 
	// rename neighborhood school_id
	drop neighborhood
	rename com_name_scho neighborhood 
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_School_AllOutlet_Rural_Vs_PeriUrban.xls", ///
			report_N(scho_near) excelrow(5)
		
	restore 	
	
	** (5): School enviroment: Geo comparision - Rural Vs Urban 
	preserve 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)

	* neighborhood correction - avoid divergence issue - treat goe locaton as cluster instead of school or commune 
	//rename neighborhood school_id
	drop neighborhood
	rename com_name_scho neighborhood 

		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_School_AllOutlet_Rural_Vs_Urban.xls", ///
			report_N(scho_near) excelrow(5)		
		
	restore 	
	
	** (6): School enviroment: Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)

	* neighborhood correction - avoid divergence issue - treat goe locaton as cluster instead of school or commune 
	//rename neighborhood school_id
	drop neighborhood
	rename com_name_scho neighborhood 

		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_School_AllOutlet_PeriUrban_Vs_Urban.xls", ///
			report_N(scho_near) excelrow(5)	
		
	restore 	
	
	
	
					
	** end of dofile 
	
