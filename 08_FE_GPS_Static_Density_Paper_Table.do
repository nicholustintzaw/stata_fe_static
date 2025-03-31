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
	
	* use HH/School Enviroment dataset - 100 meters
	use "$foodenv_prep\FE_GPS_static_density_prepared_100m_adolescent_level.dta", clear 
	
	* append home to school route dataset - 10 meters
	// h2s dataset had same variables names as hh enviroment indicators from hh/school dataset
	preserve 
	
		use  "$foodenv_prep\FE_GPS_static_density_H2S_prepared_10m_adolescent_level.dta", clear 
		* d100_hh
		* `ind'd100_`env'
		* keep only available variables 
		keep 	hhid final_h2s_sample ///
				rural_urban ///
				school_id scho_com_name ///
				hh_yes_outlet expo_tot_hh ///
				any_outlet_d_hh h2s_buffer_area *_nova4_* *_ssb_* *_fruit_* *_vegetable_* *_fruitveg_* *_gdqs_yes_* *_gdqs_healthy_* *_gdqs_healthy_n_* *_gdqs_unhealthy_* *_gdqs_unhealthy_n_* *_gdqs_neutral_* *_gdqs_score_p_* *_gdqs_score_m_* *_gdqs_1_* *_gdqs_2_* *_gdqs_3_* *_gdqs_4_* *_gdqs_5_* *_gdqs_6_* *_gdqs_7_* *_gdqs_8_* *_gdqs_9_* *_gdqs_10_* *_gdqs_11_* *_gdqs_12_* *_gdqs_13_* *_gdqs_14_* *_gdqs_15_* *_gdqs_16_* *_gdqs_17_* *_gdqs_18_* *_gdqs_19_* *_gdqs_20_* *_gdqs_21_* *_gdqs_22_* *_gdqs_23_* *_gdqs_24_* *_gdqs_25_* *_d100_hh
			
		rename hh_* h2s_* 
		rename *_d100_hh *_d100_h2s
		rename any_outlet_d_hh any_outlet_d_h2s
		rename expo_tot_hh expo_tot_h2s
		rename final_h2s_sample final_sample_h2s

		tempfile h2s 
		save `h2s', replace 
	
	restore 
	
	merge 1:1 hhid using `h2s', assert(3) nogen 
	
	distinct hhid 
	
	drop com_name_id
	encode com_name, gen(com_name_id)
	order com_name_id, after(com_name)
	
	
	* keep only available variables 
	keep 	hhid com_name_id final_sample_* ///
			rural_urban com_name_id ///
			school_id scho_com_name ///
			hh_yes_outlet school_yes_outlet h2s_yes_outlet expo_tot_* any_outlet_d_* ///
			school_buffer_area hh_buffer_area h2s_buffer_area *_nova4_* *_ssb_* *_fruit_* *_vegetable_* *_fruitveg_* *_gdqs_yes_* *_gdqs_healthy_* *_gdqs_healthy_n_* *_gdqs_unhealthy_* *_gdqs_unhealthy_n_* *_gdqs_neutral_* *_gdqs_score_p_* *_gdqs_score_m_* *_gdqs_1_* *_gdqs_2_* *_gdqs_3_* *_gdqs_4_* *_gdqs_5_* *_gdqs_6_* *_gdqs_7_* *_gdqs_8_* *_gdqs_9_* *_gdqs_10_* *_gdqs_11_* *_gdqs_12_* *_gdqs_13_* *_gdqs_14_* *_gdqs_15_* *_gdqs_16_* *_gdqs_17_* *_gdqs_18_* *_gdqs_19_* *_gdqs_20_* *_gdqs_21_* *_gdqs_22_* *_gdqs_23_* *_gdqs_24_* *_gdqs_25_* *_d100_* ///
			hh_latitude hh_longitude
	
	* rename for reshape dataset 
	rename hh_* *_hh
	rename scho_* *_scho
	rename school_buffer_area buffer_area_scho 
	rename school_yes_outlet yes_outlet_scho
	rename h2s_* *_h2s 
	
	* Some variable were missing the analysis preparation dta file 
	// density for any outlet 
	/*
	local envs hh scho h2s 
	
	foreach env in `envs' {
		
		* re-calculate # of outlet in buffer area 
		bysort hhid: egen expo_tot_`env' = total(yes_outlet_`env')
		replace expo_tot_`env' = .m if yes_outlet_`env' != 1 
		
		* calculate density (by per hectar)
		gen any_outlet_d_`env' = round(expo_tot_`env'/(buffer_area_`env' / 10000), 0.0001)
		replace any_outlet_d_`env' = .m if yes_outlet_`env' != 1 
		lab var any_outlet_d_`env' "Density (per hectar) of any outlet"
		
		order expo_tot_`env', after(yes_outlet_`env')
		order any_outlet_d_`env', after(buffer_area_`env')
	}
	

	
	** need to move below outcome developemdnt code to - analysis preparation phase **
	local envs hh scho h2s 
	
	local indicators	nova4_ ssb_ fruit_ vegetable_ fruitveg_ gdqs_yes_ gdqs_healthy_ /*gdqs_healthy_n_*/ ///
						gdqs_unhealthy_ /*gdqs_unhealthy_n_*/ gdqs_neutral_ /*gdqs_score_p_ gdqs_score_m_*/ ///
						gdqs_1_ gdqs_2_ gdqs_3_ gdqs_4_ gdqs_5_ gdqs_6_ gdqs_7_ gdqs_8_ gdqs_9_ ///
						gdqs_10_ gdqs_11_ gdqs_12_ gdqs_13_ gdqs_14_ gdqs_15_ gdqs_16_ gdqs_17_ ///
						gdqs_18_ gdqs_19_ gdqs_20_ gdqs_21_ gdqs_22_ gdqs_23_ gdqs_24_ gdqs_25_ 
	
	foreach env in `envs' {
		
		foreach ind in `indicators' {
			
			* calculate density (by per hectar)
			gen `ind'd100_`env' = round((`ind's_`env'/expo_tot_`env') * 100, 0.01)
			replace `ind'd100_`env' = .m if yes_outlet_`env' != 1 | expo_tot_`env' == 0
			lab var `ind'd100_`env' "Density (per 100 outlets per hectar) of `ind'"
		
		}
		
	}
	
	*/

	// drop the number of outlet var (by food group)
	drop *_s_hh *_s_scho *_s_h2s // expo_tot_*
	//drop gdqs_healthy_n_d_* gdqs_unhealthy_n_d_* gdqs_score_p_d_* gdqs_score_m_d_*
	drop gdqs_healthy_n_d100_* gdqs_unhealthy_n_d100_* gdqs_score_p_d100_* gdqs_score_m_d100_*
		
	* set local rshape variables 
	local long_var	final_sample_ yes_outlet_ expo_tot_ ///
					any_outlet_d_ ///
					nova4_d_ ssb_d_ fruit_d_ vegetable_d_ fruitveg_d_ ///
					gdqs_yes_d_ gdqs_healthy_d_ gdqs_unhealthy_d_ gdqs_neutral_d_ ///
					gdqs_healthy_n_d_ gdqs_unhealthy_n_d_ gdqs_score_p_d_ gdqs_score_m_d_ ///
					gdqs_1_d_ gdqs_2_d_ gdqs_3_d_ gdqs_4_d_ gdqs_5_d_ gdqs_6_d_ gdqs_7_d_ gdqs_8_d_ gdqs_9_d_ gdqs_10_d_ ///
					gdqs_11_d_ gdqs_12_d_ gdqs_13_d_ gdqs_14_d_ gdqs_15_d_ gdqs_16_d_ gdqs_17_d_ gdqs_18_d_ gdqs_19_d_ gdqs_20_d_ ///
					gdqs_21_d_ gdqs_22_d_ gdqs_23_d_ gdqs_24_d_ gdqs_25_d_ ///
					nova4_d100_ ssb_d100_ fruit_d100_ vegetable_d100_ fruitveg_d100_ ///
					gdqs_yes_d100_ gdqs_healthy_d100_ gdqs_unhealthy_d100_ gdqs_neutral_d100_ ///
					/*gdqs_healthy_n_d100_ gdqs_unhealthy_n_d100_ gdqs_score_p_d100_ gdqs_score_m_d100_*/ ///
					gdqs_1_d100_ gdqs_2_d100_ gdqs_3_d100_ gdqs_4_d100_ gdqs_5_d100_ gdqs_6_d100_ gdqs_7_d100_ gdqs_8_d100_ ///
					gdqs_9_d100_ gdqs_10_d100_ gdqs_11_d100_ gdqs_12_d100_ gdqs_13_d100_ gdqs_14_d100_ gdqs_15_d100_ gdqs_16_d100_ ///
					gdqs_17_d100_ gdqs_18_d100_ gdqs_19_d100_ gdqs_20_d100_ gdqs_21_d100_ gdqs_22_d100_ gdqs_23_d100_ gdqs_24_d100_ gdqs_25_d100_


	reshape long `long_var', i(hhid) j(enviroment) string
	
	// drop un-necessary obs 
	egen outcome_miss_all = rowtotal(`long_var')
	tab outcome_miss_all, m 

	rename *_ *  
	
	//drop if outcome_miss_all == 0 
	drop outcome_miss_all

	tab final_sample enviroment, m
	distinct hhid if final_sample == 0
	
	* drop the no gps data - excluded hh in exposure analysis
	drop if final_sample == 0
	
	distinct hhid enviroment, joint 
	isid hhid enviroment 
	
	* enviroment
	tab enviroment, m 
	replace enviroment = "1" if enviroment == "hh"
	replace enviroment = "2" if enviroment == "scho"
	replace enviroment = "3" if enviroment == "h2s"
	destring enviroment, replace 
	lab var enviroment "FE analysis enviroment"
	lab def enviroment 1"Home" 2"School" 3"Home to School Route"
	lab val enviroment enviroment
	tab enviroment, m 
	
	* GDQS Unhealthy Score - absolute value correction
	replace gdqs_score_m_d = abs(gdqs_score_m_d) if !mi(gdqs_score_m_d) 

	* rename and lableing work
	//iecodebook template using "$foodenv_prep/Codebook/FE_paper_analysis_density_codebook.xlsx", replace 
	iecodebook apply using "$foodenv_prep/Codebook/FE_paper_analysis_density_codebook.xlsx"

	* keep only final sample - to standartized with other paper
	merge m:1 hhid using 	"$foodenv_prep/FE_HH_FINAL_SAMPLE.dta",  ///
							keepusing(final_sample_hh final_sample_scho final_h2s_sample) ///
							keep(match) nogen assert(1 3)
	distinct hhid
	
	* get outlet number in 100 m radius
	merge m:1 hhid enviroment using "$foodenv_prep\FE_GPS_static_prepared_combined_HH_School_100m_H2S_10m.dta", keepusing(ado_expo_num) assert (2 3) keep(matched) nogen 

	* Save a combined dataset * 
	save "$foodenv_prep\FE_GPS_static_density_prepared_combined_HH_School_100m_H2S_10m.dta", replace 
	
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
	** Home Enviroment ** 
	****************************************************************************
	** (1): HH enviroment: Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 1 
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_Rural_Vs_PeriUrban.xls", ///
			report_N(any_outlet_d) excelrow(5) 
		
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_Rural_Vs_PeriUrban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)
	
	restore 
	
	** (2): HH enviroment: Geo comparision - Rural Vs Urban 
	preserve 
	
	keep if enviroment == 1 
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_Rural_Vs_Urban.xls", ///
			report_N(any_outlet_d) excelrow(5)
			
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_Rural_Vs_Urban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
		
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
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_PeriUrban_Vs_Urban.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_HH_PeriUrban_Vs_Urban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)		
		
	restore 	
	
	
	* By Geo Breakdown - sumstat 
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			global outcomes	yes_outlet expo_tot any_outlet_d ///
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
		
			keep if enviroment == 1
			
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out\For paper\Tables_density\Sumstat_density_HH_geo_compare.xls",  /// 
										sheet("rural_urban `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	
	****************************************************************************
	** School enviroment **
	****************************************************************************
	use "$foodenv_prep\FE_GPS_static_density_prepared_combined_HH_School_100m_H2S_10m.dta", clear 

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
	bysort  enviroment school_id: keep if _n == 1 // keep data at school & enviroment level 
		
	* keep dataset at school unique level 
	keep if enviroment == 2
	
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
	
	** (5): School enviroment: Geo comparision - Rural Vs Peri-Urban
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
			using "$foodenv_out\For paper\Tables_density\Compare_density_School_Rural_Vs_PeriUrban.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_School_Rural_Vs_PeriUrban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)
			
	restore 	
	
	** (6): School enviroment: Geo comparision - Rural Vs Urban 
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
			using "$foodenv_out\For paper\Tables_density\Compare_density_School_Rural_Vs_Urban.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_School_Rural_Vs_Urban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)
			
	restore 	
	
	** (7): School enviroment: Geo comparision - Urban Vs Peri-Urban 
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
			using "$foodenv_out\For paper\Tables_density\Compare_density_School_PeriUrban_Vs_Urban.xls", ///
			report_N(any_outlet_d) excelrow(5)
		
		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_School_PeriUrban_Vs_Urban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)
			
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
		
			//replace enviroment = 2 if mi(enviroment)
			replace rural_urban = `x' if mi(rural_urban)
			
			global outcomes	yes_outlet expo_tot any_outlet_d ///
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
			
			//keep if enviroment == 2
			
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out\For paper\Tables_density\Sumstat_density_School_geo_compare.xls",  /// 
										sheet("rural_urban `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	
	/* NOT APPLY IN STATIC APPROACH 
	** (8): HH to School Route: Geo comparision - Rural Vs Peri-Urban
	preserve 
	
	keep if enviroment == 3
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_H2S_Rural_Vs_PeriUrban.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_H2S_Rural_Vs_PeriUrban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)
			
	restore 		
	
	** (9): HH to School Route: Geo comparision - Rural Vs Urban 
	preserve 
	
	keep if enviroment == 3
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_H2S_Rural_Vs_Urban.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_H2S_Rural_Vs_Urban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)
			
	restore 	
	
	** (10): HH to School Route: Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 3
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_H2S_PeriUrban_Vs_Urban.xls", ///
			report_N(any_outlet_d) excelrow(5)

		xi:StatsByNeighborhood ///
			$outcomes_1 ///
			using "$foodenv_out\For paper\Tables_density\Compare_density_H2S_PeriUrban_Vs_Urban_allsample.xls", ///
			report_N(yes_outlet) excelrow(5)
			
	restore 	
	
	
	* By Geo Breakdown - sumstat 
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			global outcomes	yes_outlet expo_tot any_outlet_d ///
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
			
			keep if enviroment == 3
			
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out\For paper\Tables_density\Sumstat_density_H2S_geo_compare.xls",  /// 
										sheet("rural_urban `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	*/
	
	/*
	****************************************************************************
	** EquityTool Wealth Quintile **
	****************************************************************************
	
	merge m:1 hhid using "$hh_prep/section4_prepared.dta", assert(2 3) keep(match) keepusing(NationalQuintile svy_wealth_quintile)

	// reg near_nova4 i.svy_wealth_quintile
	
	* (1) HH Enviroment
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 1
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* Survey Distribution Quintile		
				reg `v' i.svy_wealth_quintile
				
				estimates store `v', title(`v')
			
			}
			
		restore 
		
	}
		
		
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/density/HH_density_by_wealth_quintile_SQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
   
   
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 1
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* National Quintile 				
				reg `v' i.NationalQuintile
				
				estimates store `v', title(`v')
							
			}
			
		restore 
		
	}
	
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/density/HH_density_by_wealth_quintile_NQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
		
	// by geo location 
	
	levelsof rural_urban, local(geo)
		
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* Survey Distribution Quintile				
					reg `v' i.svy_wealth_quintile
					
					estimates store `v', title(`v')
				
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/density/HH_geo_`g'_density_by_wealth_quintile_SQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	
			
			
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
									
					* National Quintile 					
					reg `v' i.NationalQuintile
					
					estimates store `v', title(`v')
									
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/density/HH_geo_`g'_density_by_wealth_quintile_NQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
			
			
	* (2) School Enviroment
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 2
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* Survey Distribution Quintile			
				reg `v' i.svy_wealth_quintile
				
				estimates store `v', title(`v')
			
			}
			
		restore 
		
	}
		
		
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/density/School_density_by_wealth_quintile_SQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
			
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 2
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* National Quintile 				
				reg `v' i.NationalQuintile
				
				estimates store `v', title(`v')
							
			}
			
		restore 
		
	}
	
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/density/School_density_by_wealth_quintile_NQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
			
			
	// by geo location 
	
	levelsof rural_urban, local(geo)
		
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* Survey Distribution Quintile				
					reg `v' i.svy_wealth_quintile
					
					estimates store `v', title(`v')
				
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/density/School_geo_`g'_density_by_wealth_quintile_SQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	
			
		
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* National Quintile 					
					reg `v' i.NationalQuintile
					
					estimates store `v', title(`v')
									
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/density/School_geo_`g'_density_by_wealth_quintile_NQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
			
			
			
	* (3) HH to School Route 
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 3
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* Survey Distribution Quintile			
				reg `v' i.svy_wealth_quintile
				
				estimates store `v', title(`v')
			
			}
			
		restore 
		
	}
		
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/density/H2S_density_by_wealth_quintile_SQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			

	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 3
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* National Quintile 				
				reg `v' i.NationalQuintile
				
				estimates store `v', title(`v')
							
			}
			
		restore 
		
	}
	
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/density/H2S_density_by_wealth_quintile_NQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
			
	// by geo location 
	
	levelsof rural_urban, local(geo)
		
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* Survey Distribution Quintile				
					reg `v' i.svy_wealth_quintile
					
					estimates store `v', title(`v')				
				
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/density/H2S_geo_`g'_density_by_wealth_quintile_SQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	
			
	
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* National Quintile 					
					reg `v' i.NationalQuintile
					
					estimates store `v', title(`v')				
				
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/density/H2S_geo_`g'_density_by_wealth_quintile_NQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	

	*/
	
	** end of dofile 
	
