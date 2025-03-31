* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - PAPER TABLES/PLOTS - Outlet characteristics
  ** LAST UPDATE    07 22 2024 
  ** CONTENTS
  
	* Develop a dataset which only include 
			- hhid, 
			- some key demographic var, 
			- main outcomes variables
	
  ** ref dofile: Ghana's dofile 
  IFPRI Dropbox\Data-GH-Urban Ghana adolescent nutrition\Confidential\Banku Data Management\Dofiles\Paper_FE
	
*/ 

********************************************************************************

	
	****************************************************************************
	** Prepare A Combined LONG Dataset for analysis **
	****************************************************************************
	
	* use HH/School Enviroment dataset - 100 meters
	use "$foodenv_prep/FE_OUTLETS_FINAL_SAMPLE.dta", clear 
	
	keep if final_sample == 1 // keep final sample 
	
	distinct outlet_code 
	
	* GDQS Unhealthy Score - absolute value correction
	replace gdqs_score_minus = abs(gdqs_score_minus) if !mi(gdqs_score_minus) 

	* keep only available variables 
	keep 	outlet_code ///
			rural_urban com_name_eng com_name_id ///
			outlet_type_* ///
			nova4_yes ssb_yes fruit_grp_yes vegetable_grp_yes fruitveg_grp_yes ///
			gdqs_yes gdqs_healthy_yes gdqs_unhealthy_yes gdqs_neutral_yes ///
			gdqs_healthy_num gdqs_unhealthy_num gdqs_neutral_sum gdqs_score_plus gdqs_score_minus ///
			gdqs_grp_1_yes gdqs_grp_2_yes gdqs_grp_3_yes gdqs_grp_4_yes gdqs_grp_5_yes ///
			gdqs_grp_6_yes gdqs_grp_7_yes gdqs_grp_8_yes gdqs_grp_9_yes gdqs_grp_10_yes ///
			gdqs_grp_11_yes gdqs_grp_12_yes gdqs_grp_13_yes gdqs_grp_14_yes gdqs_grp_15_yes ///
			gdqs_grp_16_yes gdqs_grp_17_yes gdqs_grp_18_yes gdqs_grp_19_yes gdqs_grp_20_yes ///
			gdqs_grp_21_yes gdqs_grp_22_yes gdqs_grp_23_yes gdqs_grp_24_yes gdqs_grp_25_yes

	
	* Set Function 
	qui do "$foodenv_analysis/analysis_function_do/StatsByNeighborhood.do"    

	* define the parameter to apply in function 
	* neighborhood : means the cluster varaible
	* SES : means the variable for category of sample (for comparision)
	
	rename com_name_eng neighborhood 
	// in vietname, use school as cluster, but for all outlet info used commune as cluster
	// some commune has more than one school 

	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 

	lab def yesno 0"No" 1"Yes"
	lab val outlet_type_1 outlet_type_2 outlet_type_3 outlet_type_4 outlet_type_5 ///
			outlet_type_6 outlet_type_7 outlet_type_8 outlet_type_9 outlet_type_10 ///
			outlet_type_11 outlet_type_12 outlet_type_13 outlet_type_14 outlet_type_15 ///
			outlet_type_97 ///
			nova4_yes ssb_yes fruit_grp_yes vegetable_grp_yes fruitveg_grp_yes ///
			gdqs_yes gdqs_healthy_yes gdqs_unhealthy_yes gdqs_neutral_yes ///
			gdqs_grp_1_yes gdqs_grp_2_yes gdqs_grp_3_yes gdqs_grp_4_yes gdqs_grp_5_yes ///
			gdqs_grp_6_yes gdqs_grp_7_yes gdqs_grp_8_yes gdqs_grp_9_yes gdqs_grp_10_yes ///
			gdqs_grp_11_yes gdqs_grp_12_yes gdqs_grp_13_yes gdqs_grp_14_yes gdqs_grp_15_yes ///
			gdqs_grp_16_yes gdqs_grp_17_yes gdqs_grp_18_yes gdqs_grp_19_yes gdqs_grp_20_yes ///
			gdqs_grp_21_yes gdqs_grp_22_yes gdqs_grp_23_yes gdqs_grp_24_yes gdqs_grp_25_yes ///
			yesno 
	
	* Set reporting variables 
	global outcomes	outlet_type_1 outlet_type_2 outlet_type_3 outlet_type_4 outlet_type_5 ///
					outlet_type_6 outlet_type_7 outlet_type_8 outlet_type_9 outlet_type_10 ///
					outlet_type_11 outlet_type_12 outlet_type_13 outlet_type_14 outlet_type_15 ///
					outlet_type_97 ///
					nova4_yes ssb_yes fruit_grp_yes vegetable_grp_yes fruitveg_grp_yes ///
					gdqs_yes gdqs_healthy_yes gdqs_unhealthy_yes gdqs_neutral_yes ///
					gdqs_healthy_num gdqs_unhealthy_num gdqs_neutral_sum gdqs_score_plus gdqs_score_minus ///
					gdqs_grp_1_yes gdqs_grp_2_yes gdqs_grp_3_yes gdqs_grp_4_yes gdqs_grp_5_yes ///
					gdqs_grp_6_yes gdqs_grp_7_yes gdqs_grp_8_yes gdqs_grp_9_yes gdqs_grp_10_yes ///
					gdqs_grp_11_yes gdqs_grp_12_yes gdqs_grp_13_yes gdqs_grp_14_yes gdqs_grp_15_yes ///
					gdqs_grp_16_yes gdqs_grp_17_yes gdqs_grp_18_yes gdqs_grp_19_yes gdqs_grp_20_yes ///
					gdqs_grp_21_yes gdqs_grp_22_yes gdqs_grp_23_yes gdqs_grp_24_yes gdqs_grp_25_yes
	
	
	** Export Analysis Tables **	
	** (1) Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Outlet_Rural_Vs_PeriUrban.xls", ///
			report_N(outlet_type_1) excelrow(5)
		
	restore 
	
	** (2): Geo comparision - Rural Vs Urban 
	preserve 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Outlet_Rural_Vs_Urban.xls", ///
			report_N(outlet_type_1) excelrow(5)
		
	restore 	
	
	** (3): Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Outlet_PeriUrban_Vs_Urban.xls", ///
			report_N(outlet_type_1) excelrow(5)
		
	restore 	
	
	
	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out\For paper\Compare_Outlet_SumStat.xls",  /// 
										sheet("rural_urban `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	
	****************************************************************************
	* Overall Outlet Density 
	****************************************************************************
	* Calculate the Density per study unit (commune)
	bysort neighborhood: keep if _n == 1
	
	tempfile com_d 
	save `com_d', replace 
			
	import excel using "$foodenv_prep/Study_Commue_area.xlsx", sheet("Sheet 1") firstrow clear
	
	rename VARNAME_3 neighborhood
	
	distinct neighborhood com_name_id
	
	* get pop data from sampling doc 
	* ref dir: C:\Users\NTZaw\OneDrive - CGIAR\All SHiFT files\WP1\Vietnam\Quantitative survey\population and sample calculations
	* ref doc: Estimates key indicators_ranking_add school.xls
	
	gen commune_pop = .m 
	replace commune_pop = 7636.8245 if neighborhood == "Chieng Son"
	replace commune_pop = 19259.599 if neighborhood == "Co Loa"
	replace commune_pop = 20046.641 if neighborhood == "Hang Bot"
	replace commune_pop = 13808.14 if neighborhood == "Khuong Thuong"
	replace commune_pop = 28321.599 if neighborhood == "Lang Ha"
	replace commune_pop = 40560.316 if neighborhood == "O Cho Dua"
	replace commune_pop = 10613.471 if neighborhood == "Tan Lap"
	replace commune_pop = 16193.816 if neighborhood == "Thinh Quang"
	replace commune_pop = 12301.086 if neighborhood == "Van Noi"
	replace commune_pop = 31122.258 if neighborhood == "NT Moc Chau" // Moc Chau farm town?
	
	merge m:1 neighborhood using `com_d', assert(3) nogen keepusing(rural_urban) 

	bysort com_name_id: egen outlet_count = count(outlet_code)
	
	destring study_site_area, replace 
	format study_site_area %13.0g
	
	replace study_site_area = round(study_site_area, 0.1)
	lab var study_site_area "Commune Area (m^2)"
		
	* overall outlet density 
	// by hectar
	gen commune_outlet_d = round(outlet_count/(study_site_area / 10000), 0.0001)
	
	// by km^2
	gen commune_outlet_dkm2 = round(outlet_count/(study_site_area / 1000000), 0.0001)
	
	// by population 
	gen commune_outlet_d_pop = round(outlet_count/(commune_pop), 0.0001)

	lab var commune_outlet_d "Density (per hectar) of outlets (by commune)"
	lab var commune_outlet_dkm2 "Density (per km^2) of outlets (by commune)"
	lab var commune_outlet_d_pop "Density (per population) of outlets (by commune)"

	bysort com_name_id: keep if _n == 1
	
	* population density by commune - per km^2
	gen commune_pop_d = round(commune_pop/(study_site_area / 1000000), 0.0001)

	forvalues x = 1/10 {

		gen double commune_pop_d_`x' = commune_pop_d if com_name_id == `x'
		
		egen double commune_pop_d_`x'_max = max(commune_pop_d_`x') 
		drop commune_pop_d_`x'
		
		rename commune_pop_d_`x'_max commune_pop_d_`x'
	}
	
	lab var commune_pop_d "Pop Density per km^2 (by commune)"
	lab var commune_pop_d_1 "Pop Density per km^2: NT Moc Chau"
	lab var commune_pop_d_2 "Pop Density per km^2: Chieng Son"
	lab var commune_pop_d_3 "Pop Density per km^2: Tan Lap"
	lab var commune_pop_d_4 "Pop Density per km^2: Co Loa"
	lab var commune_pop_d_5 "Pop Density per km^2: Van Noi"
	lab var commune_pop_d_6 "Pop Density per km^2: Hang Bot"
	lab var commune_pop_d_7 "Pop Density per km^2: Khuong Thuong"
	lab var commune_pop_d_8 "Pop Density per km^2: Lang Ha"
	lab var commune_pop_d_9 "Pop Density per km^2: Thinh Quang"
	lab var commune_pop_d_10 "Pop Density per km^2: O Cho Dua"
	

	* Set reporting variables 
	global outcomes	commune_outlet_d commune_outlet_dkm2 commune_outlet_d_pop ///
					commune_pop_d_1 commune_pop_d_2 commune_pop_d_3 commune_pop_d_4 ///
					commune_pop_d_5 commune_pop_d_6 commune_pop_d_7 commune_pop_d_8 ///
					commune_pop_d_9 commune_pop_d_10 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	** Export Analysis Tables **	
	** (1) Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Outlet_Rural_Vs_PeriUrban_outlet_density.xls", ///
			report_N(commune_outlet_d) excelrow(5)
		
	restore 
	
	** (2): Geo comparision - Rural Vs Urban 
	preserve 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Outlet_Rural_Vs_Urban_outlet_density.xls", ///
			report_N(commune_outlet_d) excelrow(5)
		
	restore 	
	
	** (3): Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Outlet_PeriUrban_Vs_Urban_outlet_density.xls", ///
			report_N(commune_outlet_d) excelrow(5)
		
	restore 	


	* By Geo Breakdown
	global outcomes	commune_outlet_d commune_outlet_dkm2 commune_outlet_d_pop 
					
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			keep if rural_urban == `x'
			
			if _N > 0 {
				
				* number of outcome variables 
				local num_vars : word count $outcomes 
				di _N
				di `num_vars'

				if `num_vars' > _N {
					// Add new observation only if needed
					local add_row = `num_vars' - _N
					
					di `add_row'
					di _N
					
					clear 
					set obs `add_row'
					tempfile emptydf
					save `emptydf', emptyok
				
				}

			}				
			
		restore
	
	
		preserve 
		
			keep if rural_urban == `x'
			
			if _N > 0 {
				
				if `num_vars' > _N {
					
					
					di _N 
					
					append using `emptydf'
					
					di _N
					
				}
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out\For paper\Compare_Outlet_SumStat.xls",  /// 
										sheet("Outlet Density `x'") firstrow(varlabels) keepcellfmt sheetreplace 
										
			}
		
		restore 
		
		
	}
	
	
	
	****************************************************************************
	** HH/Outlet distance to Roads Network
	****************************************************************************
	import excel using "$foodenv_raw/hh_outet_distance_to_road.xlsx", firstrow sheet("HH") clear 
	
	destring nearest_road_dist nearest_road_outlet_dist, replace 
	
	sum nearest_road_dist nearest_road_outlet_dist, d 
	
	keep hhid nearest_road_dist nearest_road_outlet_dist
	tempfile disthh 
	save `disthh', replace 
	
	use "$foodenv_prep/FE_HH_FINAL_SAMPLE.dta", clear 

	merge 1:1 hhid using `disthh', assert(1 3) nogen 
	
	tab final_sample_hh, m 
	
	keep if final_sample_hh == 1
	
	lab def distcat 1"< 50 m" 2"50 - 99 m" 3"100 - 199 m" 4"200 + m" 
	
	gen hh_road_distcat = (nearest_road_dist < 50)
	replace hh_road_distcat = 2 if nearest_road_dist >= 50 & nearest_road_dist < 100 
	replace hh_road_distcat = 3 if nearest_road_dist >= 100 & nearest_road_dist < 200 
	replace hh_road_distcat = 4 if nearest_road_dist >= 200 & !mi(nearest_road_dist)
	lab val hh_road_distcat distcat
	lab var hh_road_distcat "HH: Distance to nearest road network"
	tab hh_road_distcat, m 
	
	
	gen hh_outletroad_distcat = (nearest_road_outlet_dist < 50)
	replace hh_outletroad_distcat = 2 if nearest_road_outlet_dist >= 50 & nearest_road_outlet_dist < 100 
	replace hh_outletroad_distcat = 3 if nearest_road_outlet_dist >= 100 & nearest_road_outlet_dist < 200 
	replace hh_outletroad_distcat = 4 if nearest_road_outlet_dist >= 200 & !mi(nearest_road_outlet_dist)
	lab val hh_outletroad_distcat distcat
	lab var hh_outletroad_distcat "HH: Distance to nearest road network where Outlets present"
	tab hh_outletroad_distcat, m 	
	
	tab1 hh_road_distcat hh_outletroad_distcat, m 
	
	tab hh_outletroad_distcat rural_urban, col
	
	
	** end of dofile 
	
