* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - PAPER TABLES/PLOTS - Density
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
	
	use "$foodenv_prep\FE_GPS_static_density_prepared_combined_HH_School_100m_H2S_10m.dta", clear  
	
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
	global outcomes	any_outlet_d ///
					nova4_d ssb_d fruit_d vegetable_d fruitveg_d ///
					gdqs_yes_d gdqs_healthy_d gdqs_unhealthy_d gdqs_neutral_d ///
					gdqs_healthy_n_d gdqs_unhealthy_n_d gdqs_score_p_d gdqs_score_m_d ///
					gdqs_1_d gdqs_2_d gdqs_3_d gdqs_4_d gdqs_5_d gdqs_6_d gdqs_7_d gdqs_8_d gdqs_9_d gdqs_10_d ///
					gdqs_11_d gdqs_12_d gdqs_13_d gdqs_14_d gdqs_15_d gdqs_16_d gdqs_17_d gdqs_18_d gdqs_19_d ///
					gdqs_20_d gdqs_21_d gdqs_22_d gdqs_23_d gdqs_24_d gdqs_25_d ///
					nova4_d100 ssb_d100 fruit_d100 vegetable_d100 fruitveg_d100 ///
					gdqs_yes_d100 gdqs_healthy_d100 gdqs_unhealthy_d100 gdqs_neutral_d100 ///
					gdqs_1_d100 gdqs_2_d100 gdqs_3_d100 gdqs_4_d100 gdqs_5_d100 gdqs_6_d100 gdqs_7_d100 gdqs_8_d100 ///
					gdqs_9_d100 gdqs_10_d100 gdqs_11_d100 gdqs_12_d100 gdqs_13_d100 gdqs_14_d100 gdqs_15_d100 ///
					gdqs_16_d100 gdqs_17_d100 gdqs_18_d100 gdqs_19_d100 gdqs_20_d100 gdqs_21_d100 gdqs_22_d100 ///
					gdqs_23_d100 gdqs_24_d100 gdqs_25_d100
	
	global outcomes_1 yes_outlet expo_tot

	
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
				using "$foodenv_out\For paper\Tables_distance\Compare_density_HH_School_Rural_Adolevel.xls", /// 
				report_N(any_outlet_d) excelrow(5)

			xi:StatsByNeighborhood ///
				$outcomes_1 ///
				using "$foodenv_out\For paper\Tables_distance\Compare_density_HH_School_Rural_allsample_Adolevel.xls", ///
				report_N(yes_outlet) excelrow(5)
			
	restore 
	
	** (2): HH Vs School Eenviroment: Peri-Urban 
	preserve 
		
		keep if rural_urban == 2
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Compare_density_HH_School_PeriUrban_Adolevel.xls", ///
			report_N(any_outlet_d) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Compare_density_HH_School_PeriUrban_allsample_Adolevel.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
	restore 	
	
	** (3): HH Vs School Enviroment: Urban 
	preserve 
		
		keep if rural_urban == 3
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Compare_density_HH_School_Urban_Adolevel.xls", ///
			report_N(any_outlet_d) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_distance\Compare_density_HH_School_Urban_allsample_Adolevel.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
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
	global outcomes	any_outlet_d ///
					nova4_d ssb_d fruit_d vegetable_d fruitveg_d ///
					gdqs_yes_d gdqs_healthy_d gdqs_unhealthy_d gdqs_neutral_d ///
					gdqs_healthy_n_d gdqs_unhealthy_n_d gdqs_score_p_d gdqs_score_m_d ///
					gdqs_1_d gdqs_2_d gdqs_3_d gdqs_4_d gdqs_5_d gdqs_6_d gdqs_7_d gdqs_8_d gdqs_9_d gdqs_10_d ///
					gdqs_11_d gdqs_12_d gdqs_13_d gdqs_14_d gdqs_15_d gdqs_16_d gdqs_17_d gdqs_18_d gdqs_19_d ///
					gdqs_20_d gdqs_21_d gdqs_22_d gdqs_23_d gdqs_24_d gdqs_25_d ///
					nova4_d100 ssb_d100 fruit_d100 vegetable_d100 fruitveg_d100 ///
					gdqs_yes_d100 gdqs_healthy_d100 gdqs_unhealthy_d100 gdqs_neutral_d100 ///
					gdqs_1_d100 gdqs_2_d100 gdqs_3_d100 gdqs_4_d100 gdqs_5_d100 gdqs_6_d100 gdqs_7_d100 gdqs_8_d100 ///
					gdqs_9_d100 gdqs_10_d100 gdqs_11_d100 gdqs_12_d100 gdqs_13_d100 gdqs_14_d100 gdqs_15_d100 ///
					gdqs_16_d100 gdqs_17_d100 gdqs_18_d100 gdqs_19_d100 gdqs_20_d100 gdqs_21_d100 gdqs_22_d100 ///
					gdqs_23_d100 gdqs_24_d100 gdqs_25_d100
	
	global outcomes_1 yes_outlet expo_tot
	
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
	
	bysort school_id: keep if _n == 1 // keep at school level 
	
	* Make sumstat table for HH Enviroment **
	
	preserve 
	
		keep	com_name_scho school_id ///
				any_outlet_d_* ///
				nova4_d_* ssb_d_* fruit_d_* vegetable_d_* fruitveg_d_* ///
				gdqs_healthy_d_* gdqs_unhealthy_d_* gdqs_neutral_d_* ///
				gdqs_1_d_* gdqs_2_d_* gdqs_3_d_* gdqs_4_d_* gdqs_5_d_* ///
				gdqs_6_d_* gdqs_7_d_* gdqs_8_d_* gdqs_9_d_* gdqs_10_d_* ///
				gdqs_11_d_* gdqs_12_d_* gdqs_13_d_* gdqs_14_d_* gdqs_15_d_* ///
				gdqs_16_d_* gdqs_17_d_* gdqs_18_d_* gdqs_19_d_* gdqs_20_d_* ///
				gdqs_21_d_* gdqs_22_d_* gdqs_23_d_* gdqs_24_d_* gdqs_25_d_* ///
				nova4_d100_* ssb_d100_* fruit_d100_* vegetable_d100_* fruitveg_d100_* ///
				gdqs_healthy_d100_* gdqs_unhealthy_d100_* gdqs_neutral_d100_* ///
				gdqs_1_d100_* gdqs_2_d100_* gdqs_3_d100_* gdqs_4_d100_* gdqs_5_d100_* ///
				gdqs_6_d100_* gdqs_7_d100_* gdqs_8_d100_* gdqs_9_d100_* gdqs_10_d100_* ///
				gdqs_11_d100_* gdqs_12_d100_* gdqs_13_d100_* gdqs_14_d100_* gdqs_15_d100_* ///
				gdqs_16_d100_* gdqs_17_d100_* gdqs_18_d100_* gdqs_19_d100_* gdqs_20_d100_* ///
				gdqs_21_d100_* gdqs_22_d100_* gdqs_23_d100_* gdqs_24_d100_* gdqs_25_d100_*
		
		order	com_name_scho school_id ///
				any_outlet_d_* ///
				nova4_d_* ssb_d_* fruit_d_* vegetable_d_* fruitveg_d_* ///
				gdqs_healthy_d_* gdqs_unhealthy_d_* gdqs_neutral_d_* ///
				gdqs_1_d_* gdqs_2_d_* gdqs_3_d_* gdqs_4_d_* gdqs_5_d_* ///
				gdqs_6_d_* gdqs_7_d_* gdqs_8_d_* gdqs_9_d_* gdqs_10_d_* ///
				gdqs_11_d_* gdqs_12_d_* gdqs_13_d_* gdqs_14_d_* gdqs_15_d_* ///
				gdqs_16_d_* gdqs_17_d_* gdqs_18_d_* gdqs_19_d_* gdqs_20_d_* ///
				gdqs_21_d_* gdqs_22_d_* gdqs_23_d_* gdqs_24_d_* gdqs_25_d_* ///
				nova4_d100_* ssb_d100_* fruit_d100_* vegetable_d100_* fruitveg_d100_* ///
				gdqs_healthy_d100_* gdqs_unhealthy_d100_* gdqs_neutral_d100_* ///
				gdqs_1_d100_* gdqs_2_d100_* gdqs_3_d100_* gdqs_4_d100_* gdqs_5_d100_* ///
				gdqs_6_d100_* gdqs_7_d100_* gdqs_8_d100_* gdqs_9_d100_* gdqs_10_d100_* ///
				gdqs_11_d100_* gdqs_12_d100_* gdqs_13_d100_* gdqs_14_d100_* gdqs_15_d100_* ///
				gdqs_16_d100_* gdqs_17_d100_* gdqs_18_d100_* gdqs_19_d100_* gdqs_20_d100_* ///
				gdqs_21_d100_* gdqs_22_d100_* gdqs_23_d100_* gdqs_24_d100_* gdqs_25_d100_*
				
		export excel using "$foodenv_out\For paper\Tables_density\Sumstat_density_HH_FE_at_School_Level_Geo_Compare.xlsx",  /// 
										sheet("rural_urban") firstrow(variables) keepcellfmt sheetreplace
	
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
	gen neighborhood = com_name_scho 
	
	tempfile FE_HH_MEAN_SCHOOL
	save `FE_HH_MEAN_SCHOOL', replace 
	
	* HH FE Median DATASET * 
	use `school_fe', clear 

	append using `hh_fe_median'
	
	tab enviroment, m 
	distinct school_id enviroment, joint 
	
	lab drop yesno 
	
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
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Rural_MEAN.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Rural_allsample_MEAN.xls", ///
			report_N(yes_outlet) excelrow(5)
			
	restore 
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 1
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Rural_MEDIAN.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Rural_allsample_MEDIAN.xls", ///
			report_N(yes_outlet) excelrow(5)
			
	restore 	
	
	** (2): HH Vs School Enviroment: Peri-Urban 
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 2
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_PeriUrban_MEAN.xls", ///
			report_N(any_outlet_d) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_PeriUrban_allsample_MEAN.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
	restore 	
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 2
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_PeriUrban_MEDIAN.xls", ///
			report_N(any_outlet_d) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_PeriUrban_allsample_MEDIAN.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
	restore 
	
	** (3): HH Vs School Enviroment: Urban 
	** HH MEAN **
	use `FE_HH_MEAN_SCHOOL', clear 
	
	preserve 
		
		keep if rural_urban == 3
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Urban_MEAN.xls", ///
			report_N(any_outlet_d) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Urban_allsample_MEAN.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
	restore 	
	
	** HH MEDIAN **
	use `FE_HH_MEDIAN_SCHOOL', clear  
	
	preserve 
		
		keep if rural_urban == 3
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Urban_MEDIAN.xls", ///
			report_N(any_outlet_d) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_School_Urban_allsample_MEDIAN.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
	restore 
	
	** end of dofile 
	
