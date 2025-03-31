* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - Distance/Proximity HH Vs School Comparision
  ** LAST UPDATE    03 19 2025 
  ** CONTENTS
  

  * ref model: Professor Edward's recommendation 
  A generalization that fits the data structure is a multi-level model:

	Hij = B0 + B1 Sj + Uj + Eij

	where Uj is the random effect for schools and Eij is the random effect for home. Hij = Sj if B0=0 and B1=1, of course, but on average H could equal S for combinations of B0 and B1 that are not 0 and 1, respectively.  I am thinking that one could then test using a linear contrast, for example, H = B0 +B1 S where H and S are at their means. 
	
*/ 

********************************************************************************

	************************************************************************************
	** DISTANCE data HH/School to Outlet - with all outlets available in FE dataset 
	************************************************************************************
	use "$foodenv_prep\FE_GPS_static_prepared_adolescent_level_all_outlets_final.dta", clear 
	
	* Diff FE outcome var
	local outcome_var near near_nova4 near_fruit 
	
	foreach var in `outcome_var' {
		
		local var_label : var label hh_`var'
		local var_label = subinstr("`var_label'", "Home", "Home - School", 1)
		
		gen diff_`var' 		= (hh_`var' - scho_`var')
		replace diff_`var'	= .m if mi(hh_`var') | mi(scho_`var')
		
		lab var diff_`var' "`var_label'"
		
	}
	
	* Keep only HH sample obs - 2620 
	keep if final_sample_hh == 1
	
	// diff_near diff_near_nova4 diff_near_fruit
	tab rural_urban, m 
	
	* (1) Rural 
	sum hh_near if rural_urban == 1
	sum scho_near if rural_urban == 1
	
	reg diff_near if rural_urban == 1
	reg diff_near if rural_urban == 1, vce(cluster school_id)
	mixed diff_near || school_id: if rural_urban ==1, mle 
	
	* (2) Peri-Urban 
	
	
	* (3) Urban
	
	
	&&&
	
	** Huber-White sandwich estimator (e.g., vce(cluster schools) in Stata regress) **
	* (1) Rural Vs Peri-Urban 
	reg diff_near rural_urban if rural_urban != 3, vce(cluster school_id)

	* (2) Rural Vs Urban 
	reg diff_near rural_urban if rural_urban != 2, vce(cluster school_id)

	* (3) Peri-Urban Vs Urban 
	reg diff_near rural_urban if rural_urban != 1, vce(cluster school_id)

	* (4) Use district as comparision 
	reg diff_near i.district, vce(cluster school_id)
	
	reg diff_near ib2.district, vce(cluster school_id)

	
	** Multi-level model **
	mixed diff_near rural_urban || school_id:, mle 
 
	* (1) Rural Vs Peri-Urban 
	mixed diff_near rural_urban || school_id: if rural_urban != 3, mle 
	
	* (2) Rural Vs Urban 
	mixed diff_near rural_urban || school_id: if rural_urban != 2, mle 
	
	* (3) Peri-Urban Vs Urban 
	mixed diff_near rural_urban || school_id: if rural_urban != 1, mle 
			
			
	****************************************************************************
	****************************************************************************
	
	** (a) Distance to nearest outlet (meter): hh_near vs scho_near
	
	** (1)  Multi-level model: Hij = B0 + B1 Sj + Uj + Eij
	// If the household ID (hhid) is applied as a random effect for the home, the model cannot be implemented due to endless 'Not concave' iterations.
	mixed hh_near scho_near || school_id: || com_name_id: if rural_urban == 1
	estat icc 
	
	lincom _b[scho_near] - 1
	
	mixed hh_near scho_near || school_id: || com_name_id: if rural_urban == 3

	
	mixed hh_near_95p scho_near_95p || school_id: || com_name_id:
	estat icc 
	
	lincom _b[scho_near_95p] - 1

	** (2) Huber-White Sandwich Estimator
	reg hh_near scho_near, vce(cluster school_id)

	reg hh_near_95p scho_near_95p, vce(cluster school_id)
	
	
	** (b) Distance to nearest NOVA-4 food group (meter): hh_near_nova4 vs scho_near_nova4

	** (1)  Multi-level model: Hij = B0 + B1 Sj + Uj + Eij
	mixed hh_near_nova4 scho_near_nova4 || school_id: || com_name_id:
	estat icc 
	
	lincom _b[scho_near_nova4] - 1
	
	mixed hh_near_nova4_95p scho_near_nova4_95p || school_id: || com_name_id:
	estat icc 
	
	lincom _b[scho_near_nova4_95p] - 1
	
	** (2) Huber-White Sandwich Estimator
	reg hh_near_nova4 scho_near_nova4, vce(cluster school_id)
	
	reg hh_near_nova4_95p scho_near_nova4_95p, vce(cluster school_id)
	
	** (c) Distance to nearest Fruit food group (meter): hh_near_fruit vs scho_near_fruit

	** (1)  Multi-level model: Hij = B0 + B1 Sj + Uj + Eij
	mixed hh_near_fruit scho_near_fruit || school_id: || com_name_id:
	estat icc 
	
	lincom _b[scho_near_fruit] - 1
	
	mixed hh_near_fruit_95p scho_near_fruit_95p || school_id: || com_name_id:
	estat icc 
	
	lincom _b[scho_near_fruit_95p] - 1
	
	** (2) Huber-White Sandwich Estimator
	reg hh_near_fruit scho_near_fruit, vce(cluster school_id)
	
	reg hh_near_fruit_95p scho_near_fruit_95p, vce(cluster school_id)
	
	
	****************************************************************************
	** Prepare A Combined LONG Dataset for different model analysis **
	****************************************************************************
	
	keep 	hhid school_id com_name_id ///
			hh_near scho_near hh_near_95p scho_near_95p ///
			hh_near_nova4 scho_near_nova4 hh_near_nova4_95p scho_near_nova4_95p ///
			hh_near_fruit scho_near_fruit hh_near_fruit_95p scho_near_fruit_95p
			
	rename hh_near* near*_hh
	rename scho_near* near*_scho
	
	reshape long near_ near_nova4_ near_fruit_ near_95p_ near_nova4_95p_ near_fruit_95p_ , i(hhid) j(enviroment_str) string 
	
	rename *_ * 
	
	distinct hhid 
	
	encode enviroment_str, gen(enviroment)
	
	** (3)  Multi-level model: Yijk = B0 + B1 Xijk + Uj + Vk 
	** (a) Distance to nearest outlet (meter): hh_near vs scho_near
	
	mixed near enviroment || school_id: || com_name_id:
	mixed near_95p enviroment || school_id: || com_name_id:

	** (b) Distance to nearest NOVA-4 food group (meter): hh_near_nova4 vs scho_near_nova4
	
	mixed near_nova4 enviroment || school_id: || com_name_id:
	mixed near_nova4_95p enviroment || school_id: || com_name_id:
	
	** (c) Distance to nearest Fruit food group (meter): hh_near_fruit vs scho_near_fruit
	
	mixed near_fruit enviroment || school_id: || com_name_id:
	mixed near_fruit_95p enviroment || school_id: || com_name_id:
	
	****************************************************************************
	** Sensitivity Analysis **
	****************************************************************************

	** (a) Distance to nearest outlet (meter): hh_near vs scho_near
	gen ln_near = ln(near)
	gen ln_near_95p = ln(near_95p)
	
	mixed ln_near enviroment || school_id: || com_name_id:
	mixed ln_near_95p enviroment || school_id: || com_name_id:
	
	// enviroment = 1 (school) , enviroment = 0 (home).
	// non-winsorized model: (e^0.1648 - 1) × 100 = 17.9% increase
	// winsorized model: (e^0.1848 - 1) × 100 = 20.3% increase 

	
	** (b) Distance to nearest NOVA-4 food group (meter): hh_near_nova4 vs scho_near_nova4
	gen ln_near_nova4 = ln(near_nova4)
	gen ln_near_nova4_95p = ln(near_nova4_95p)
	
	mixed ln_near_nova4 enviroment || school_id: || com_name_id:
	mixed ln_near_nova4_95p enviroment || school_id: || com_name_id:

	// enviroment = 1 (school) , enviroment = 0 (home).
	// non-winsorized model: (e^0.0494518  - 1) × 100 = 5.07% increase
	// winsorized model: (e^0.0681567 - 1) × 100 = 7.05% increase

	
	** (c) Distance to nearest Fruit food group (meter): hh_near_fruit vs scho_near_fruit
	gen ln_near_fruit = ln(near_fruit)
	gen ln_near_fruit_95p = ln(near_fruit_95p)
	
	mixed ln_near_fruit enviroment || school_id: || com_name_id:
	mixed ln_near_fruit_95p enviroment || school_id: || com_name_id:

	// enviroment = 1 (school) , enviroment = 0 (home).
	// non-winsorized model: (e^-0.062482 - 1) × 100 = 6.06% decrease 
	// winsorized model: (e^-0.0408407 - 1) × 100 = 4.00% decrease

	** end of dofile 
	
