* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - PAPER TABLES/PLOTS - Distance/Proximity
  ** LAST UPDATE    07 22 2024 
  ** CONTENTS
  
	* Develop a dataset which only include 
			- hhid, 
			- some key demographic var, 
			- main outcomes variables
		
	And, all two different dataset HH + School enviroment and Home to School Route dataset
	were appended into one combined dataset.
	The final output dataset will be in long format with dataset level (outcome per enviroment per HH)
	
	
  ** ref dofile: Ghana's dofile 
  IFPRI Dropbox\Data-GH-Urban Ghana adolescent nutrition\Confidential\Banku Data Management\Dofiles\Paper_FE
	
*/ 

********************************************************************************

	
	****************************************************************************
	** Prepare A Combined LONG Dataset for analysis **
	****************************************************************************
	
	* use HH/School Enviroment dataset - 100 meters		
	use "$foodenv_prep\FE_GPS_static_prepared_combined_HH_School_100m_H2S_10m.dta", clear 

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
	
