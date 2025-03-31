* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - PAPER TABLES/PLOTS - KDE Density
  ** LAST UPDATE    07 22 2024 
  ** CONTENTS
  
	* Develop a dataset which only include 
			- hhid, 
			- some key demographic var, 
			- main outcomes variables
		
	
*/ 

********************************************************************************

	
	****************************************************************************
	** Prepare A Combined LONG Dataset for analysis **
	****************************************************************************
	
	use "$foodenv_prep\FE_GPS_static_KDE_prepared_combined_HH_School_100m.dta", clear 

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
	global outcomes	kde_all_outlets ///
					kde_outlet_type_1 kde_outlet_type_2 kde_outlet_type_3 kde_outlet_type_4 ///
					kde_outlet_type_5 kde_outlet_type_6 kde_outlet_type_7 kde_outlet_type_8 ///
					kde_outlet_type_9 kde_outlet_type_10 kde_outlet_type_11 kde_outlet_type_12 ///
					kde_outlet_type_13 kde_outlet_type_14 kde_outlet_type_15 kde_outlet_type_97 ///
					kde_nova4_yes kde_ssb_yes kde_fruit_grp_yes kde_vegetable_grp_yes kde_fruitveg_grp_yes ///
					kde_gdqs_grp_1_yes kde_gdqs_grp_2_yes kde_gdqs_grp_3_yes kde_gdqs_grp_4_yes ///
					kde_gdqs_grp_5_yes kde_gdqs_grp_6_yes kde_gdqs_grp_7_yes kde_gdqs_grp_8_yes ///
					kde_gdqs_grp_9_yes kde_gdqs_grp_10_yes kde_gdqs_grp_11_yes kde_gdqs_grp_12_yes ///
					kde_gdqs_grp_13_yes kde_gdqs_grp_14_yes kde_gdqs_grp_16_yes kde_gdqs_grp_17_yes ///
					kde_gdqs_grp_18_yes kde_gdqs_grp_19_yes kde_gdqs_grp_20_yes kde_gdqs_grp_21_yes ///
					kde_gdqs_grp_22_yes kde_gdqs_grp_23_yes kde_gdqs_grp_24_yes kde_gdqs_grp_25_yes ///
					kde_gdqs_healthy_yes kde_gdqs_unhealthy_yes kde_gdqs_neutral_yes
	
	
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
				using "$foodenv_out\For paper\Tables_distance\Compare_KDE_HH_School_Rural_Adolevel.xls", /// 
				report_N(kde_all_outlets) excelrow(5)
			
	restore 
	
	** (2): HH Vs School Eenviroment: Peri-Urban 
	preserve 
		
		keep if rural_urban == 2
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Compare_KDE_HH_School_PeriUrban_Adolevel.xls", ///
			report_N(kde_all_outlets) excelrow(5)	
		
	restore 	
	
	** (3): HH Vs School Enviroment: Urban 
	preserve 
		
		keep if rural_urban == 3
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Compare_KDE_HH_School_Urban_Adolevel.xls", ///
			report_N(kde_all_outlets) excelrow(5)	
		
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
	
	bysort school_id: keep if _n == 1 // keep at school level 
	
	* Make sumstat table for HH Enviroment **
	
	preserve 
	
		keep	com_name_scho school_id ///
				kde_all_outlets_* ///
				kde_outlet_type_1_* kde_outlet_type_2_* kde_outlet_type_3_* ///
				kde_outlet_type_4_* kde_outlet_type_5_* kde_outlet_type_6_* ///
				kde_outlet_type_7_* kde_outlet_type_8_* kde_outlet_type_9_* ///
				kde_outlet_type_10_* kde_outlet_type_11_* kde_outlet_type_12_* ///
				kde_outlet_type_13_* kde_outlet_type_14_* kde_outlet_type_15_* ///
				kde_outlet_type_97_* ///
				kde_nova4_yes_* kde_ssb_yes_* kde_fruit_grp_yes_* ///
				kde_vegetable_grp_yes_* kde_fruitveg_grp_yes_* ///
				kde_gdqs_grp_1_yes_* kde_gdqs_grp_2_yes_* kde_gdqs_grp_3_yes_* ///
				kde_gdqs_grp_4_yes_* kde_gdqs_grp_5_yes_* kde_gdqs_grp_6_yes_* ///
				kde_gdqs_grp_7_yes_* kde_gdqs_grp_8_yes_* kde_gdqs_grp_9_yes_* ///
				kde_gdqs_grp_10_yes_* kde_gdqs_grp_11_yes_* kde_gdqs_grp_12_yes_* ///
				kde_gdqs_grp_13_yes_* kde_gdqs_grp_14_yes_* kde_gdqs_grp_16_yes_* ///
				kde_gdqs_grp_17_yes_* kde_gdqs_grp_18_yes_* kde_gdqs_grp_19_yes_* ///
				kde_gdqs_grp_20_yes_* kde_gdqs_grp_21_yes_* kde_gdqs_grp_22_yes_* ///
				kde_gdqs_grp_23_yes_* kde_gdqs_grp_24_yes_* kde_gdqs_grp_25_yes_* ///
				kde_gdqs_healthy_yes_* kde_gdqs_unhealthy_yes_* kde_gdqs_neutral_yes_*
				
		order	com_name_scho school_id ///
				kde_all_outlets_* ///
				kde_outlet_type_1_* kde_outlet_type_2_* kde_outlet_type_3_* ///
				kde_outlet_type_4_* kde_outlet_type_5_* kde_outlet_type_6_* ///
				kde_outlet_type_7_* kde_outlet_type_8_* kde_outlet_type_9_* ///
				kde_outlet_type_10_* kde_outlet_type_11_* kde_outlet_type_12_* ///
				kde_outlet_type_13_* kde_outlet_type_14_* kde_outlet_type_15_* ///
				kde_outlet_type_97_* ///
				kde_nova4_yes_* kde_ssb_yes_* kde_fruit_grp_yes_* ///
				kde_vegetable_grp_yes_* kde_fruitveg_grp_yes_* ///
				kde_gdqs_grp_1_yes_* kde_gdqs_grp_2_yes_* kde_gdqs_grp_3_yes_* ///
				kde_gdqs_grp_4_yes_* kde_gdqs_grp_5_yes_* kde_gdqs_grp_6_yes_* ///
				kde_gdqs_grp_7_yes_* kde_gdqs_grp_8_yes_* kde_gdqs_grp_9_yes_* ///
				kde_gdqs_grp_10_yes_* kde_gdqs_grp_11_yes_* kde_gdqs_grp_12_yes_* ///
				kde_gdqs_grp_13_yes_* kde_gdqs_grp_14_yes_* kde_gdqs_grp_16_yes_* ///
				kde_gdqs_grp_17_yes_* kde_gdqs_grp_18_yes_* kde_gdqs_grp_19_yes_* ///
				kde_gdqs_grp_20_yes_* kde_gdqs_grp_21_yes_* kde_gdqs_grp_22_yes_* ///
				kde_gdqs_grp_23_yes_* kde_gdqs_grp_24_yes_* kde_gdqs_grp_25_yes_* ///
				kde_gdqs_healthy_yes_* kde_gdqs_unhealthy_yes_* kde_gdqs_neutral_yes_*
				
		export excel using "$foodenv_out\For paper\Tables_density\Sumstat_KDE_HH_FE_at_School_Level_Geo_Compare.xlsx",  /// 
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
	
	drop neighborhood
	gen neighborhood = com_name_scho 
	
	tempfile FE_HH_MEAN_SCHOOL
	save `FE_HH_MEAN_SCHOOL', replace 
	
	* HH FE Median DATASET * 
	use `school_fe', clear 

	append using `hh_fe_median'
	
	tab enviroment, m 
	distinct school_id enviroment, joint 
	
	drop neighborhood
	gen neighborhood = com_name_scho 
	
	tempfile FE_HH_MEDIAN_SCHOOL
	save `FE_HH_MEDIAN_SCHOOL', replace 
	

	
	** (1): HH Vs School Enviroment: Rural
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 

	preserve 
	
		keep if rural_urban == 1
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_School_Rural_MEAN.xls", ///
			report_N(kde_all_outlets) excelrow(5)
			
	restore 
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 1
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_School_Rural_MEDIAN.xls", ///
			report_N(kde_all_outlets) excelrow(5)
			
	restore 	
	
	** (2): HH Vs School Enviroment: Peri-Urban 
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 2
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_School_PeriUrban_MEAN.xls", ///
			report_N(kde_all_outlets) excelrow(5)	
		
	restore 	
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 2
		
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_School_PeriUrban_MEDIAN.xls", ///
			report_N(kde_all_outlets) excelrow(5)

	restore 
	
	** (3): HH Vs School Enviroment: Urban
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 
	
	preserve 
	
		keep if rural_urban == 3 
		
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_School_Urban_MEAN.xls", ///
			report_N(kde_all_outlets) excelrow(5)
		
	restore 	
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear  
	
	preserve 

		keep if rural_urban == 3 
		
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_School_Urban_MEDIAN.xls", ///
			report_N(kde_all_outlets) excelrow(5)
		
	restore 
	
	
	** end of dofile 
	
