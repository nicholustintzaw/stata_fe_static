* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static proximity sensitivity analysis 
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
	use "$foodenv_prep\FE_GPS_static_prepared_`j'm_adolescent_level.dta", clear 

	* Unique variable 
	distinct hhid school_code outlet_code 
	
	tab hhid_fe_merge, m 
	distinct hhid outlet_code hhid_fe_merge, joint // dataset level: hh id by outlet 

	* GDQS Unhealthy Score - absolute value correction
	foreach var of varlist hh_gdqs_unhealthy_score scho_gdqs_unhealthy_score {
		
		replace `var' = abs(`var') if !mi(`var') 
		
	}
	
	gen white_space = 0 // for indicator brekdown in sum-stat table
	tab exposure_enviroment, gen(exposure_enviroment_)		
			
	** Note: put white_space for section break
	
	
	****************************************************************************
	** (1) Type of outlets 
	****************************************************************************
	
	* (A) HH Enviroment Exposure 
	* outcome varaible global definition 
	global outcomes	ado_expo_hh_yes ado_expo_hh ///
					white_space /// 
					hh_near ///
					white_space /// 
					hh_near_nova4 hh_near_ssb hh_near_fruit hh_near_vegetable hh_near_fruitveg ///
					white_space ///
					hh_near_gdqs_yes hh_near_gdqs_healthy hh_near_gdqs_unhealthy hh_near_gdqs_neutral ///
					white_space /// 
					hh_near_gdqs_1 hh_near_gdqs_2 hh_near_gdqs_3 hh_near_gdqs_4 hh_near_gdqs_5 hh_near_gdqs_6 ///
					hh_near_gdqs_7 hh_near_gdqs_8 hh_near_gdqs_9 hh_near_gdqs_10 hh_near_gdqs_11 hh_near_gdqs_12 ///
					hh_near_gdqs_13	hh_near_gdqs_14	hh_near_gdqs_15	hh_near_gdqs_16	hh_near_gdqs_17	///
					hh_near_gdqs_18	hh_near_gdqs_19	hh_near_gdqs_20	hh_near_gdqs_21	hh_near_gdqs_22	///
					hh_near_gdqs_23	hh_near_gdqs_24	hh_near_gdqs_25 ///
					white_space /// 
					hh_gdqs_healthy_score hh_gdqs_unhealthy_score ///
					white_space ///
					hh_gdqs_healthy_num hh_gdqs_unhealthy_num hh_gdqs_neutral_num ///
					white_space ///
					hh_gdqs_healthy_no hh_gdqs_healthy_all hh_gdqs_unhealthy_no hh_gdqs_unhealthy_all 
	

	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
					
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("FE_Static_hh_`j'm_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
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
	global outcomes	ado_expo_scho_yes ado_expo_scho ///
					white_space ///
					scho_near ///
					white_space ///
					scho_near_nova4 scho_near_ssb scho_near_fruit scho_near_vegetable scho_near_fruitveg ///
					white_space /// 
					scho_near_gdqs_yes scho_near_gdqs_healthy scho_near_gdqs_unhealthy scho_near_gdqs_neutral ///
					white_space /// 
					scho_near_gdqs_1 scho_near_gdqs_2 scho_near_gdqs_3 scho_near_gdqs_4 scho_near_gdqs_5 scho_near_gdqs_6 ///
					scho_near_gdqs_7 scho_near_gdqs_8 scho_near_gdqs_9 scho_near_gdqs_10 scho_near_gdqs_11 scho_near_gdqs_12 ///
					scho_near_gdqs_13 scho_near_gdqs_14 scho_near_gdqs_15 scho_near_gdqs_16 scho_near_gdqs_17 scho_near_gdqs_18 ///
					scho_near_gdqs_19 scho_near_gdqs_20 scho_near_gdqs_21 scho_near_gdqs_22 scho_near_gdqs_23 scho_near_gdqs_24 scho_near_gdqs_25 ///
					white_space ///
					scho_gdqs_healthy_score scho_gdqs_unhealthy_score ///
					white_space ///
					scho_gdqs_healthy_num scho_gdqs_unhealthy_num scho_gdqs_neutral_num 
	
	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
					
			replace rural_urban = `x' if mi(rural_urban)
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("FE_Static_scho_`j'm_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}

		
	}
			
	

	** end of dofile 
	
