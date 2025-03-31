* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - PAPER TABLES/PLOTS - Adolescence characteristics
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
	use "$foodenv_prep/FE_HH_FINAL_SAMPLE.dta", clear 
	
	destring grade, replace 
	
	* use the adolescent demographic info 
	preserve 
	
		use "$hh_prep/coverpage_prepared.dta", clear 
		
		keep district com_name hhid grade ado_age ado_sex ado_inschool ado_livemo

		merge 1:1 hhid 	using "$hh_prep/s2_hhmaster_prepared.dta", ///
						assert(3) nogen ///
						keepusing(hh_size hhh_male hhh_edu mo_edu)
						
		merge 1:1 hhid	using "$hh_prep/section4_prepared.dta", ///
						assert(3) nogen /// 
						keepusing( 	hhassest_pca_qunt_geo_1 hhassest_pca_qunt_geo_2 hhassest_pca_qunt_geo_3 ///
									livestock_pca_qunt_geo_1 ///
									ses ses_3 ses_5 ///
									NationalQuintile svy_wealth_quintile ///
									ho_own_dummy improved_cookfuel improved_water improved_toilet ///
									as_owncartruck as_owntv as_owncomputer as_ownfreezer ///
									as_ownairconditioner as_ownwashmachine as_ownwaterheater as_ownmicrowave)
						
		merge 1:1 hhid	using "$hh_prep/section6_prepared.dta", ///
						assert(3) nogen /// 
						keepusing( hfias foodinsecure hf_scale ///
									hf_worryfood hf_preferredfoods hf_limitedvariety hf_eatnotwantedfood ///
									hf_smallermeal hf_fewermeals hf_nofood hf_sleephungry hf_daywithouteating ///
									hh_hunger_scale_1 hh_hunger_scale_2 hh_hunger_scale_3)

		* create dummy variable
		// Grade 		
		tab grade, gen(grade_)
		
		gen ado_edu_school = (grade >= 10 & grade <= 12)
		replace ado_edu_school = .m if mi(grade)
		lab var ado_edu_school "Adolescence education level"
		lab def ado_edu_school 0"Lower secondary school" 1"Higher secondary school"
		lab val ado_edu_school ado_edu_school
		tab ado_edu_school, m 
		
		tab ado_edu_school, gen(ado_edu_school_)
		lab var ado_edu_school_1 "Lower secondary school"
		lab var ado_edu_school_2 "Higher secondary school"
		
		// education 
		tab hhh_edu, gen(hhh_edu_) 
		tab mo_edu, gen(mo_edu_) 
		
		// assets PCA category
		tab hhassest_pca_qunt_geo_1, gen(hhassest_pca_geo_1_qunt_)
		tab hhassest_pca_qunt_geo_2, gen(hhassest_pca_geo_2_qunt_)
		tab hhassest_pca_qunt_geo_3, gen(hhassest_pca_geo_3_qunt_)
		
		tab livestock_pca_qunt_geo_1, gen(livestock_pca_geo_1_qunt_)
		
		// hfias
		tab hf_scale, gen(hf_scale_)
		tab1 hf_scale* 
		
		// ses_3
		tab ses_3, gen(ses_3_cat_)
		
		// NationalQuintile 
		tab NationalQuintile, gen(NationalQuintile_)
		
		// svy_wealth_quintile
		tab svy_wealth_quintile, gen(svy_wealth_quintile_)
		
		tempfile ado_demo 
		save `ado_demo', replace 
	
	restore 

	merge 1:1 hhid using `ado_demo', assert(3) nogen 

	
	** KEEP ONLY SAMPLE INCLUDE IN SAMPLING - TO STANDARTIZED WITH OTHER PAPER **
	// drop obs from Quận Thanh Xuân
	
	drop if district == 3 // Quận Thanh Xuân
	
	* keep only available variables 
	keep 	hhid ///
			rural_urban school_code scho_com_name ///
			ado_age ado_sex ado_inschool grade_* ado_edu_school_* ado_livemo ///
			hh_size hhh_male hhh_edu_* mo_edu_* ///
			hhassest_pca_geo_1_qunt_* hhassest_pca_geo_2_qunt_* hhassest_pca_geo_3_qunt_* ///
			livestock_pca_geo_1_qunt_* /// 
			ses_3_cat_1 ses_3_cat_2 ses_3_cat_3 ///
			NationalQuintile_1 NationalQuintile_2 NationalQuintile_3 NationalQuintile_4 NationalQuintile_5 ///
			svy_wealth_quintile_1 svy_wealth_quintile_2 svy_wealth_quintile_3 svy_wealth_quintile_4 svy_wealth_quintile_5 ///
			ho_own_dummy improved_cookfuel improved_water improved_toilet ///
			as_owncartruck as_owntv as_owncomputer as_ownfreezer ///
			as_ownairconditioner as_ownwashmachine as_ownwaterheater as_ownmicrowave ///
			hfias foodinsecure hf_scale_1 hf_scale_2 hf_scale_3 hf_scale_4 ///
			hf_worryfood hf_preferredfoods hf_limitedvariety hf_eatnotwantedfood ///
			hf_smallermeal hf_fewermeals hf_nofood hf_sleephungry hf_daywithouteating ///
			hh_hunger_scale_1 hh_hunger_scale_2 hh_hunger_scale_3

			
	* rename and lableing work
	//iecodebook template using "$foodenv_prep/Codebook/FE_paper_ado_character_codebook.xlsx", replace 
	iecodebook apply using "$foodenv_prep/Codebook/FE_paper_ado_character_codebook.xlsx"
	
	rename scho_com_name com_name_scho 
	
	* additional labeling adjustment 
	// ado_sex 
	recode ado_sex (1 = 1) (2 = 0)
	lab def sex 1"Male" 0"Female"
	lab val ado_sex sex
	tab ado_sex, m 
	
	lab val grade_1 grade_2 grade_3 grade_4 grade_5 grade_6 grade_7	///
			ado_edu_school_1 ado_edu_school_2 ///
			hhh_edu_1 hhh_edu_2 hhh_edu_3 ///
			mo_edu_1 mo_edu_2 mo_edu_3 ///
			ses_3_cat_1 ses_3_cat_2 ses_3_cat_3 ///
			NationalQuintile_1 NationalQuintile_2 NationalQuintile_3 NationalQuintile_4 NationalQuintile_5 ///
			svy_wealth_quintile_1 svy_wealth_quintile_2 svy_wealth_quintile_3 svy_wealth_quintile_4 svy_wealth_quintile_5 ///
			improved_cookfuel improved_water improved_toilet ///
			foodinsecure hf_scale_1 hf_scale_2 hf_scale_3 hf_scale_4 ///
			yesno 
	
	** SAVE As final analysis tabe dataset ***
	save "$foodenv_prep/P6. FE characteristics paper/01_FE_Adolescence_Characteristics.dta", replace 
	
	****************************************************************************
	* Set Function 
	qui do "$foodenv_analysis/analysis_function_do/StatsByNeighborhood.do"    

	* define the parameter to apply in function 
	* neighborhood : means the cluster varaible
	* SES : means the variable for category of sample (for comparision)
	
	rename school_code neighborhood 
	// in vietname, use school as cluster

	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 

	* Set reporting variables 
	global outcomes	ado_age	ado_sex ado_livemo ado_inschool grade_1 grade_2 grade_3 grade_4 grade_5 grade_6 grade_7	///
					hh_size	hhh_male ///
					hhh_edu_1 hhh_edu_2 hhh_edu_3 ///
					mo_edu_1 mo_edu_2 mo_edu_3 ///
					hhassest_pca_geo_1_qunt_1 hhassest_pca_geo_1_qunt_2 hhassest_pca_geo_1_qunt_3 hhassest_pca_geo_1_qunt_4 hhassest_pca_geo_1_qunt_5 ///
					hhassest_pca_geo_2_qunt_1 hhassest_pca_geo_2_qunt_2 hhassest_pca_geo_2_qunt_3 hhassest_pca_geo_2_qunt_4 hhassest_pca_geo_2_qunt_5 ///
					hhassest_pca_geo_3_qunt_1 hhassest_pca_geo_3_qunt_2 hhassest_pca_geo_3_qunt_3 hhassest_pca_geo_3_qunt_4 hhassest_pca_geo_3_qunt_5 ///
					ses_3_cat_1 ses_3_cat_2 ses_3_cat_3 ///
					NationalQuintile_1 NationalQuintile_2 NationalQuintile_3 NationalQuintile_4 NationalQuintile_5 ///
					svy_wealth_quintile_1 svy_wealth_quintile_2 svy_wealth_quintile_3 svy_wealth_quintile_4 svy_wealth_quintile_5 ///
					ho_own_dummy improved_cookfuel improved_water improved_toilet ///
					as_owncartruck as_owntv as_owncomputer as_ownfreezer ///
					as_ownairconditioner as_ownwashmachine as_ownwaterheater as_ownmicrowave ///
					livestock_pca_geo_1_qunt_1 livestock_pca_geo_1_qunt_3 livestock_pca_geo_1_qunt_4 livestock_pca_geo_1_qunt_5 ///
					hfias foodinsecure hf_scale_1 hf_scale_2 hf_scale_3 hf_scale_4 ///
					hf_worryfood hf_preferredfoods hf_limitedvariety hf_eatnotwantedfood ///
					hf_smallermeal hf_fewermeals hf_nofood hf_sleephungry hf_daywithouteating ///
					hh_hunger_scale_1 hh_hunger_scale_2 hh_hunger_scale_3


	** Export Analysis Tables **	
	** (1) Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_Rural_Vs_PeriUrban.xls", ///
			report_N(ado_age) excelrow(5)
		
	restore 
	
	** (2): Geo comparision - Rural Vs Urban 
	preserve 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_Rural_Vs_Urban.xls", ///
			report_N(ado_age) excelrow(5)
		
	restore 	
	
	** (3): Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_PeriUrban_Vs_Urban.xls", ///
			report_N(ado_age) excelrow(5)
		
	restore 	
	
	****************************************************************************
	** Ado FE Exposure - all Sample sumstat **
	****************************************************************************
	
	use "$foodenv_prep\FE_GPS_static_prepared_adolescent_level_all_outlets.dta", clear 
	
	rename scho_com_name com_name_scho 
	
	merge 1:1 hhid using "$hh_prep/coverpage_prepared.dta", assert(3) keepusing(district) nogen
	
	** KEEP ONLY SAMPLE INCLUDE IN SAMPLING - TO STANDARTIZED WITH OTHER PAPER **
	// drop obs from Quận Thanh Xuân
	
	drop if district == 3 // Quận Thanh Xuân
	
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
			hh_near_outlet_1 hh_near_outlet_2 hh_near_outlet_3 hh_near_outlet_4 hh_near_outlet_5 ///
			hh_near_outlet_6 hh_near_outlet_7 hh_near_outlet_8 hh_near_outlet_9 hh_near_outlet_10 ///
			hh_near_outlet_11 hh_near_outlet_12 hh_near_outlet_13 hh_near_outlet_14 hh_near_outlet_15 hh_near_outlet_97 ///
			ado_scho_dist_cat_1	ado_scho_dist_cat_2	ado_scho_dist_cat_3	///
			scho_near_outlet_1 scho_near_outlet_2 scho_near_outlet_3 scho_near_outlet_4 scho_near_outlet_5 ///
			scho_near_outlet_6 scho_near_outlet_7 scho_near_outlet_8 scho_near_outlet_9 scho_near_outlet_10	///
			scho_near_outlet_11 scho_near_outlet_12 scho_near_outlet_13 scho_near_outlet_14 scho_near_outlet_15 ///
			scho_near_outlet_97 ///
			yesno 
			
			
	** SAVE As final analysis tabe dataset ***
	save "$foodenv_prep/P6. FE characteristics paper/02_FE_Adolescence_Food_Enviroment.dta", replace 

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

	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	** for HH variables **
	* Set reporting variables 
	global outcomes	ado_hh_dist_cat_1 ado_hh_dist_cat_2 ado_hh_dist_cat_3 ///
					hh_near_outlet_1 hh_near_outlet_2 hh_near_outlet_3 hh_near_outlet_4 hh_near_outlet_5 ///
					hh_near_outlet_6 hh_near_outlet_7 hh_near_outlet_8 hh_near_outlet_9 hh_near_outlet_10 ///
					hh_near_outlet_11 hh_near_outlet_12 hh_near_outlet_13 hh_near_outlet_14 hh_near_outlet_15 ///
					hh_near_outlet_97 

 

	** Export Analysis Tables **	
	** (1) Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_Rural_Vs_PeriUrban_FE_Expo.xls", ///
			report_N(ado_hh_dist_cat_1) excelrow(5)
		
	restore 
	
	** (2): Geo comparision - Rural Vs Urban 
	preserve 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_Rural_Vs_Urban_FE_Expo.xls", ///
			report_N(ado_hh_dist_cat_1) excelrow(5)
		
	restore 	
	
	** (3): Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_PeriUrban_Vs_Urban_FE_Expo.xls", ///
			report_N(ado_hh_dist_cat_1) excelrow(5)
		
	restore 
	
	
	** For school varaibles **
	* Set reporting variables 
	global outcomes	ado_scho_dist_cat_1 ado_scho_dist_cat_2 ado_scho_dist_cat_3 ///
					scho_near_outlet_1 scho_near_outlet_2 scho_near_outlet_3 scho_near_outlet_4 scho_near_outlet_5 ///
					scho_near_outlet_6 scho_near_outlet_7 scho_near_outlet_8 scho_near_outlet_9 scho_near_outlet_10 ///
					scho_near_outlet_11 scho_near_outlet_12 scho_near_outlet_13 scho_near_outlet_14 scho_near_outlet_15 ///
					scho_near_outlet_97

 

	** Export Analysis Tables **	
	** (1) Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)

	* neighborhood correction - avoid divergence issue - treat goe locaton as cluster instead of school or commune 
	drop neighborhood 
	rename com_name_scho neighborhood 
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_Rural_Vs_PeriUrban_School_FE_Expo.xls", ///
			report_N(ado_hh_dist_cat_1) excelrow(5)
		
	restore 
	
	** (2): Geo comparision - Rural Vs Urban 
	preserve 
		
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)

	* neighborhood correction - avoid divergence issue - treat goe locaton as cluster instead of school or commune 
	drop neighborhood 
	rename com_name_scho neighborhood 

		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_Rural_Vs_Urban_School_FE_Expo.xls", ///
			report_N(ado_hh_dist_cat_1) excelrow(5)
		
	restore 	
	
	** (3): Geo comparision - Urban Vs Peri-Urban 
	preserve 
		
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)

	* neighborhood correction - avoid divergence issue - treat goe locaton as cluster instead of school or commune 
	drop neighborhood 
	rename com_name_scho neighborhood 
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Compare_Ado_PeriUrban_Vs_Urban_School_FE_Expo.xls", ///
			report_N(ado_hh_dist_cat_1) excelrow(5)
		
	restore 
	
	
	** end of dofile 
	
