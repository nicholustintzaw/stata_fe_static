* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static KDE density sensitivity analysis 
					HH and School enviroment 100/200/400 m radius 
					
  ** LAST UPDATE    10 25 2024 
  ** CONTENTS
		
	
*/ 

********************************************************************************

	
	****************************************************************************
	** Adolescent level data **
	****************************************************************************

	** ANALYSIS BY DIFFERENT RADIUS ** SENSITIVITY ANALYSIS **
	
	* loop setting 
	local radius  0.1 0.2 0.4
	
	foreach i in `radius' {
		
	local j = `i' * 1000
	
	* Import data 
	use "$foodenv_prep/KDE/02_QGIS_Outputs/corr_KDE_hh_`j'm.dta", clear 
	
	gen enviroment = 1 
	
	append using "$foodenv_prep/KDE/02_QGIS_Outputs/corr_KDE_sch_`j'm.dta"
	
	replace enviroment = 0 if mi(enviroment)
	
	lab def enviroment 0"School" 1"Home"
	lab val enviroment enviroment
	tab enviroment, m 
	
	* Unique variable 
	distinct hhid school_code enviroment, joint // dataset level: hh id 


	gen white_space = 0 // for indicator brekdown in sum-stat table
			
	** Note: put white_space for section break

	* (A) HH Enviroment Exposure 
	* outcome varaible global definition 
	global outcomes	kde_all_outlets ///
					white_space /// 
					kde_outlet_type_1 kde_outlet_type_2 kde_outlet_type_3 kde_outlet_type_4 ///
					kde_outlet_type_5 kde_outlet_type_6 kde_outlet_type_7 kde_outlet_type_8 ///
					kde_outlet_type_9 kde_outlet_type_10 kde_outlet_type_11 kde_outlet_type_12 ///
					kde_outlet_type_13 kde_outlet_type_14 kde_outlet_type_15 kde_outlet_type_97 ///
					white_space /// 
					kde_nova4_yes kde_ssb_yes kde_fruit_grp_yes kde_vegetable_grp_yes kde_fruitveg_grp_yes ///
					white_space /// 
					kde_gdqs_grp_1_yes kde_gdqs_grp_2_yes kde_gdqs_grp_3_yes kde_gdqs_grp_4_yes ///
					kde_gdqs_grp_5_yes kde_gdqs_grp_6_yes kde_gdqs_grp_7_yes kde_gdqs_grp_8_yes ///
					kde_gdqs_grp_9_yes kde_gdqs_grp_10_yes kde_gdqs_grp_11_yes kde_gdqs_grp_12_yes ///
					kde_gdqs_grp_13_yes kde_gdqs_grp_14_yes kde_gdqs_grp_16_yes kde_gdqs_grp_17_yes ///
					kde_gdqs_grp_18_yes kde_gdqs_grp_19_yes kde_gdqs_grp_20_yes kde_gdqs_grp_21_yes ///
					kde_gdqs_grp_22_yes kde_gdqs_grp_23_yes kde_gdqs_grp_24_yes kde_gdqs_grp_25_yes ///
					white_space /// 
					kde_gdqs_healthy_yes kde_gdqs_unhealthy_yes kde_gdqs_neutral_yes


	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
					
			keep if enviroment == 1
			
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("FE_kde_hh_`j'm_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	
	* (B) School Enviroment Exposure 
	
	* keep dataset at school unique level 
	keep if enviroment == 0
	
	
	* to solve the sumstat output number issues
	preserve 
	
		clear 
		set obs 100
		gen school_id = .m 
		
		
		tempfile extra_df 
		save `extra_df', replace 
	
	
	restore 
	
	append using `extra_df'

	
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
										sheet("FE_kde_scho_`j'm_geo `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
			//}
			
		
		restore 
		
	}

		
	}
			
	

	** end of dofile 
	
