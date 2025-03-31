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
	
	* use HH/School Enviroment dataset - 100 meters
	use "$foodenv_prep/KDE/02_QGIS_Outputs/corr_KDE_hh_100m.dta", clear 
	
	gen enviroment = 1
	
	append using "$foodenv_prep/KDE/02_QGIS_Outputs/corr_KDE_sch_100m.dta"
	
	replace enviroment = 2 if mi(enviroment)
	
	lab def enviroment 1"Home" 2"School"
	lab var enviroment "Type of FE enviroment"
	lab val enviroment enviroment
	tab enviroment, m 
	
	rename scho_com_name com_name_scho 
	lab var com_name_scho "School Commune Name"
	
	drop com_name_id
	encode com_name, gen(com_name_id)
	order com_name_id, after(com_name)
	
	rename school_code school_id 
	
	* keep only final sample - to standartized with other paper
	merge m:1 hhid using 	"$foodenv_prep/FE_HH_FINAL_SAMPLE.dta",  ///
							keepusing(final_sample_hh final_sample_scho final_h2s_sample) ///
							keep(match) nogen assert(1 3)
	distinct hhid
	
	* save as analysis preparation combined dataset * 
	save "$foodenv_prep\FE_GPS_static_KDE_prepared_combined_HH_School_100m.dta", replace 

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
	** Home Enviroment ** 
	****************************************************************************
	** (1): HH enviroment: Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 1 // home
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_Rural_Vs_PeriUrban.xls", ///
			report_N(kde_all_outlets) excelrow(5) 
	
	restore 
	
	** (2): HH enviroment: Geo comparision - Rural Vs Urban 
	preserve 
	
	keep if enviroment == 1 // home
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_Rural_Vs_Urban.xls", ///
			report_N(kde_all_outlets) excelrow(5)		
		
	restore 	
	
	** (3): HH enviroment: Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 1 
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_HH_PeriUrban_Vs_Urban.xls", ///
			report_N(kde_all_outlets) excelrow(5)	
		
	restore 	
	
	* By Geo Breakdown - sumstat 
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			keep if enviroment == 1
			
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out\For paper\Tables_density\Sumstat_density_HH_geo_compare.xls",  /// 
										sheet("k rural_urban `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}

	
	****************************************************************************
	** School enviroment **
	****************************************************************************
	use "$foodenv_prep\FE_GPS_static_KDE_prepared_combined_HH_School_100m.dta", clear 

	* define the parameter to apply in function 
	* neighborhood : means the cluster varaible
	* SES : means the variable for category of sample (for comparision)
	
	/*
	Jef agreed to adjust for commune:

	When we conduct comparisons of FEs by geographical region
	When we conduct comparisons between home and school FEs within each geographical region (waiting to hear back from Ed Frongillo on how to do this)
	*/
	
	gen neighborhood = com_name_scho 
	// replace with commune instead of school_id in vietname, use school as cluster
	
	* keep dataset at school unique level 
	keep if enviroment == 2
	
	
	** (4): School enviroment: Geo comparision - Rural Vs Peri-Urban
	preserve 
		
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)

	* neighborhood correction - avoid divergence issue - treat goe locaton as cluster instead of school or commune 
	//rename neighborhood school_id
	drop neighborhood
	rename com_name_scho neighborhood 

		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_School_Rural_Vs_PeriUrban.xls", ///
			report_N(kde_all_outlets) excelrow(5)
			
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
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_School_Rural_Vs_Urban.xls", ///
			report_N(kde_all_outlets) excelrow(5)
			
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
			using "$foodenv_out\For paper\Tables_density\Compare_KDE_School_PeriUrban_Vs_Urban.xls", ///
			report_N(kde_all_outlets) excelrow(5)
			
	restore 	
	

	
	* By Geo Breakdown - sumstat 
	* to solve the sumstat output number issues
	preserve 
	
		clear 
		set obs 300
		gen school_id = .m 
		
		
		tempfile extra_df 
		save `extra_df', replace 
	
	
	restore 
	
	append using `extra_df'
	
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			replace rural_urban = `x' if mi(rural_urban)
						
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out\For paper\Tables_density\Sumstat_density_School_geo_compare.xls",  /// 
										sheet("k rural_urban `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	** end of dofile 
	
