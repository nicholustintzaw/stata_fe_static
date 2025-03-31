* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static density sensitivity analysis 
					HH and School enviroment 50/100/200/400 m radius 
					
  ** LAST UPDATE    10 25 2024 
  ** CONTENTS
		
	
*/ 

********************************************************************************

	
	****************************************************************************
	** Adolescent level data **
	****************************************************************************

	** ANALYSIS BY DIFFERENT RADIUS ** SENSITIVITY ANALYSIS **
	
	* loop setting 
	local radius  0.05 0.1 0.2 0.4
	
	foreach i in `radius' {
		
	local j = `i' * 1000
	
	* Import data 
	use "$foodenv_prep\FE_GPS_static_density_prepared_`j'm_adolescent_level.dta", clear 
	

	* Unique variable 
	distinct hhid school_code outlet_code // dataset level: hh id 


	gen white_space = 0 // for indicator brekdown in sum-stat table
			
	** Note: put white_space for section break

	* (A) HH Enviroment Exposure 
	* outcome varaible global definition 
	global outcomes	any_outlet_d_hh ///
					white_space /// 
					hh_nova4_d hh_ssb_d	hh_fruit_d hh_vegetable_d hh_fruitveg_d ///
					white_space ///  
					hh_gdqs_healthy_d hh_gdqs_unhealthy_d hh_gdqs_neutral_d ///
					white_space ///  
					hh_gdqs_1_d hh_gdqs_2_d hh_gdqs_3_d hh_gdqs_4_d hh_gdqs_5_d hh_gdqs_6_d hh_gdqs_7_d ///
					hh_gdqs_8_d hh_gdqs_9_d hh_gdqs_10_d hh_gdqs_11_d hh_gdqs_12_d hh_gdqs_13_d hh_gdqs_14_d ///
					hh_gdqs_15_d hh_gdqs_16_d hh_gdqs_17_d hh_gdqs_18_d hh_gdqs_19_d hh_gdqs_20_d hh_gdqs_21_d ///
					hh_gdqs_22_d hh_gdqs_23_d hh_gdqs_24_d hh_gdqs_25_d ///
					white_space ///  
					nova4_d100_hh ssb_d100_hh fruit_d100_hh vegetable_d100_hh fruitveg_d100_hh ///
					white_space ///  
					gdqs_healthy_d100_hh gdqs_unhealthy_d100_hh gdqs_neutral_d100_hh ///
					white_space ///  
					gdqs_1_d100_hh gdqs_2_d100_hh gdqs_3_d100_hh gdqs_4_d100_hh gdqs_5_d100_hh ///
					gdqs_6_d100_hh gdqs_7_d100_hh gdqs_8_d100_hh gdqs_9_d100_hh gdqs_10_d100_hh	///
					gdqs_11_d100_hh gdqs_12_d100_hh gdqs_13_d100_hh gdqs_14_d100_hh gdqs_15_d100_hh ///
					gdqs_16_d100_hh gdqs_17_d100_hh gdqs_18_d100_hh gdqs_19_d100_hh gdqs_20_d100_hh ///
					gdqs_21_d100_hh gdqs_22_d100_hh gdqs_23_d100_hh gdqs_24_d100_hh gdqs_25_d100_hh


	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
					
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("FE_density_hh_`j'm_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	
	* (B) School Enviroment Exposure 
	
	* keep dataset at school unique level 
	bysort school_id: keep if _n == 1
	
	
	* to solve the sumstat output number issues
	preserve 
	
		clear 
		set obs 100
		gen school_id = .m 
		
		
		tempfile extra_df 
		save `extra_df', replace 
	
	
	restore 
	
	append using `extra_df'
	
	

	* outcome varaible global definition 	
	global outcomes	any_outlet_d_scho ///
					white_space /// 
					scho_nova4_d scho_ssb_d	scho_fruit_d scho_vegetable_d scho_fruitveg_d ///
					white_space ///
					scho_gdqs_healthy_d scho_gdqs_unhealthy_d scho_gdqs_neutral_d ///
					white_space ///
					scho_gdqs_1_d scho_gdqs_2_d scho_gdqs_3_d scho_gdqs_4_d scho_gdqs_5_d ///
					scho_gdqs_6_d scho_gdqs_7_d	scho_gdqs_8_d scho_gdqs_9_d scho_gdqs_10_d ///
					scho_gdqs_11_d scho_gdqs_12_d scho_gdqs_13_d scho_gdqs_14_d scho_gdqs_15_d ///
					scho_gdqs_16_d scho_gdqs_17_d scho_gdqs_18_d scho_gdqs_19_d scho_gdqs_20_d ///
					scho_gdqs_21_d scho_gdqs_22_d scho_gdqs_23_d scho_gdqs_24_d scho_gdqs_25_d ///
					white_space ///
					nova4_d100_scho	ssb_d100_scho	fruit_d100_scho	vegetable_d100_scho	fruitveg_d100_scho	///
					white_space ///
					gdqs_healthy_d100_scho	gdqs_unhealthy_d100_scho	gdqs_neutral_d100_scho	///
					white_space ///
					gdqs_1_d100_scho	gdqs_2_d100_scho	gdqs_3_d100_scho	gdqs_4_d100_scho	gdqs_5_d100_scho	///
					gdqs_6_d100_scho	gdqs_7_d100_scho	gdqs_8_d100_scho	gdqs_9_d100_scho	gdqs_10_d100_scho	///
					gdqs_11_d100_scho	gdqs_12_d100_scho	gdqs_13_d100_scho	gdqs_14_d100_scho	gdqs_15_d100_scho	///
					gdqs_16_d100_scho	gdqs_17_d100_scho	gdqs_18_d100_scho	gdqs_19_d100_scho	gdqs_20_d100_scho	///
					gdqs_21_d100_scho	gdqs_22_d100_scho	gdqs_23_d100_scho	gdqs_24_d100_scho	gdqs_25_d100_scho 

	
	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
					
			replace rural_urban = `x' if mi(rural_urban)
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"

			//if _N > 0 {
				
				export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("FE_density_scho_`j'm_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
			//}
			
		
		restore 
		
	}

		
	}
			
	

	** end of dofile 
	
