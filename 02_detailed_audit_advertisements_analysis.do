* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	Analysis - For Micronutrient Forum
  ** LAST UPDATE    Oct 09, 2023
  ** CONTENTS
		
	** Advertisements Types
*/ 

********************************************************************************

	****************************************************************************
	** Outlet Coverage **
	****************************************************************************
	
	* Import data 
	use "$foodenv_prep/2023_food_vendor_detailed_advertisements_tidy_analysisprep.dta", clear 

	* Unique variable 
	isid outlet_code	
	
	
	* Keep only 7 Commune - matched with HH survey 
	/*
	Below is a summary of the districts/communes we originally included:

	Moc Chau (rural): Chieng Son (ok in map), Tan Lap (ok in map) and Moc Chau Farm Town (is this NT Moc Chau in map?)
	Dong Anh (peri-urban): Co Loa (ok in map) and Van Noi (ok in map)
	Dong Da (urban): Hang Bot (ok in map) and Thinh Quang (ok in map).
	
	*/
	
	keep if com_name_eng != "Lang Ha" & ///
			com_name_eng != "Khuong Thuong" & ///
			com_name_eng != "O Cho Dua" 
	
	
	** Number of Outet by Type
	preserve 
	
	* Change into outet leve dataset 
	bysort outlet_code: keep if _n == 1 

	* Output indicators assignment 
	tab outlet_type, m 
	
	local outlet_type	outlet_type_* 
	
	* Loop over categories					
	foreach category in outlet_type {
		
		
		putexcel set 	"$foodenv_out/Long_Audit_SumStat_Advertisements_Type.xlsx", ///
						modify sheet(`category') 
						
						
		local row = 1	
				
		local category `category'
		putexcel A`row' = "Category: `category'", bold		

		local row = `row' + 2	
		
		putexcel A`row' = "Variable label", bold
		putexcel B`row' = "Variable name", bold
		putexcel C`row' = "Count", bold
		putexcel D`row' = "Min", bold
		putexcel E`row' = "Median", bold
		putexcel F`row' = "Mean", bold
		putexcel G`row' = "Max", bold
		putexcel H`row' = "SD", bold
				
		local row = `row' + 1	
	
		foreach var of local `category' {
									
			foreach var of varlist `var' {
				
				* Var label
				describe `var'
				local varlabel : var label `var'
				putexcel A`row' = ("`varlabel'")
				
				*Desc stat
				tabstat `var', stat(N min p50 mean max sd) columns(statistics) save 
				mat T = r(StatTotal)' // the prime is for transposing the matrix
				
				* Round min, max, P50, mean and sd
				forval i = 2/6{
					matrix T[1,`i'] = round(T[1,`i'], 0.01)
				}
				
				putexcel B`row' = matrix(T), rownames
				local ++row					
			}
		local ++row					
	
		}
	local ++row		
	}

	restore 
	
	
	****************************************************************************
	** Advertisements Type **
	****************************************************************************
	
	local outlet_type	unhealthy_adv_* ///
						adv_target_kids_* ///
						unhealthy_target_kids_*
	
	* Loop over categories					
	foreach category in outlet_type {
		
		
		putexcel set 	"$foodenv_out/Long_Audit_SumStat_Advertisements_Type.xlsx", ///
						modify sheet("Advertisements_Type") 
						
						
		local row = 1	
				
		local category `category'
		putexcel A`row' = "Category: Advertisements Types", bold		

		local row = `row' + 2	
		
		putexcel A`row' = "Variable label", bold
		putexcel B`row' = "Variable name", bold
		putexcel C`row' = "Count", bold
		putexcel D`row' = "Min", bold
		putexcel E`row' = "Median", bold
		putexcel F`row' = "Mean", bold
		putexcel G`row' = "Max", bold
		putexcel H`row' = "SD", bold
				
		local row = `row' + 1	
	
		foreach var of local `category' {
									
			foreach var of varlist `var' {
				
				* Var label
				describe `var'
				local varlabel : var label `var'
				putexcel A`row' = ("`varlabel'")
				
				*Desc stat
				tabstat `var', stat(N min p50 mean max sd) columns(statistics) save 
				mat T = r(StatTotal)' // the prime is for transposing the matrix
				
				* Round min, max, P50, mean and sd
				forval i = 2/6{
					matrix T[1,`i'] = round(T[1,`i'], 0.01)
				}
				
				putexcel B`row' = matrix(T), rownames
				local ++row					
			}
		local ++row					
	
		}
	local ++row		
	}


	// By province 
	levelsof pro_name, local(geounit)

	foreach geo in `geounit' {
		
		preserve 
		
		keep if pro_name == "`geo'"

		* Loop over categories					
		foreach category in outlet_type {
			
			
			putexcel set 	"$foodenv_out/Long_Audit_SumStat_Advertisements_Type.xlsx", ///
							modify sheet("`geo'") 
							
							
			local row = 1	
					
			local category `category'
			putexcel A`row' = "Province: `geo'", bold		

			local row = `row' + 2	
			
			putexcel A`row' = "Variable label", bold
			putexcel B`row' = "Variable name", bold
			putexcel C`row' = "Count", bold
			putexcel D`row' = "Min", bold
			putexcel E`row' = "Median", bold
			putexcel F`row' = "Mean", bold
			putexcel G`row' = "Max", bold
			putexcel H`row' = "SD", bold
					
			local row = `row' + 1	
		
			foreach var of local `category' {
										
				foreach var of varlist `var' {
					
					* Var label
					describe `var'
					local varlabel : var label `var'
					putexcel A`row' = ("`varlabel'")
					
					*Desc stat
					tabstat `var', stat(N min p50 mean max sd) columns(statistics) save 
					mat T = r(StatTotal)' // the prime is for transposing the matrix
					
					* Round min, max, P50, mean and sd
					forval i = 2/6{
						matrix T[1,`i'] = round(T[1,`i'], 0.01)
					}
					
					putexcel B`row' = matrix(T), rownames
					local ++row					
				}
			local ++row					
		
			}
		local ++row		
		}
			
		restore 
		
	}
	
	
	// by district  
	levelsof dist_name, local(geounit)
	 
	foreach geo in `geounit' {
		
		preserve 
		
		keep if dist_name == "`geo'"

		if _N > 0 {
			
			* Loop over categories					
			foreach category in outlet_type {
				
				
				putexcel set 	"$foodenv_out/Long_Audit_SumStat_Advertisements_Type.xlsx", ///
								modify sheet("`geo'") 
								
								
				local row = 1	
						
				local category `category'
				putexcel A`row' = "District: `geo'", bold		

				local row = `row' + 2	
				
				putexcel A`row' = "Variable label", bold
				putexcel B`row' = "Variable name", bold
				putexcel C`row' = "Count", bold
				putexcel D`row' = "Min", bold
				putexcel E`row' = "Median", bold
				putexcel F`row' = "Mean", bold
				putexcel G`row' = "Max", bold
				putexcel H`row' = "SD", bold
						
				local row = `row' + 1	
			
				foreach var of local `category' {
											
					foreach var of varlist `var' {
						
						* Var label
						describe `var'
						local varlabel : var label `var'
						putexcel A`row' = ("`varlabel'")
						
						*Desc stat
						tabstat `var', stat(N min p50 mean max sd) columns(statistics) save 
						mat T = r(StatTotal)' // the prime is for transposing the matrix
						
						* Round min, max, P50, mean and sd
						forval i = 2/6{
							matrix T[1,`i'] = round(T[1,`i'], 0.01)
						}
						
						putexcel B`row' = matrix(T), rownames
						local ++row					
					}
				local ++row					
			
				}
			local ++row		
			}

			}
		
		restore 
		
	}	
	
	
	// by commune name 
	levelsof com_name, local(geounit)
	 
	foreach geo in `geounit' {
		
		preserve 
		
		keep if com_name == "`geo'"

		if _N > 0  {

			* Loop over categories					
			foreach category in outlet_type {
				
				
				putexcel set 	"$foodenv_out/Long_Audit_SumStat_Advertisements_Type.xlsx", ///
								modify sheet("`geo'") 
								
								
				local row = 1	
						
				local category `category'
				putexcel A`row' = "Commune: `geo'", bold		

				local row = `row' + 2	
				
				putexcel A`row' = "Variable label", bold
				putexcel B`row' = "Variable name", bold
				putexcel C`row' = "Count", bold
				putexcel D`row' = "Min", bold
				putexcel E`row' = "Median", bold
				putexcel F`row' = "Mean", bold
				putexcel G`row' = "Max", bold
				putexcel H`row' = "SD", bold
						
				local row = `row' + 1	
			
				foreach var of local `category' {
											
					foreach var of varlist `var' {
						
						* Var label
						describe `var'
						local varlabel : var label `var'
						putexcel A`row' = ("`varlabel'")
						
						*Desc stat
						tabstat `var', stat(N min p50 mean max sd) columns(statistics) save 
						mat T = r(StatTotal)' // the prime is for transposing the matrix
						
						* Round min, max, P50, mean and sd
						forval i = 2/6{
							matrix T[1,`i'] = round(T[1,`i'], 0.01)
						}
						
						putexcel B`row' = matrix(T), rownames
						local ++row					
					}
				local ++row					
			
				}
			local ++row		
			}

		}
		
		restore 
		
	}	
	

	****************************************************************************
	** Availability by Outlet Type
	****************************************************************************
	
	// by outlet name 
	local outlets `""Supermarket" "Convenience store (part of a chain)" "Convenience store (not part of a chain)" "Store primarily selling non-food items/services" "Food stall/stand/tabletop inside toad market" "Food, beverage stall/stand/tablet" "Mobile vendor" "Bakery/pastry shop" "Fast food restaurant: Western style" "Non-fast food restaurant" "Coffee/fresh juice shop" "Dairy shop" "Bar, pub" "Bubble tea store" "Non-convenience food store" "Other""'
		
	levelsof outlet_type, local(geounit)
	
	local x = 1
	
	foreach geo in `geounit' {
		
		local lab : word `x' of `outlets'
		
		preserve 
		
		keep if outlet_type == `geo'

		if _N > 0  {

			* Loop over categories					
			foreach category in outlet_type {
				
				
				putexcel set 	"$foodenv_out/Long_Audit_SumStat_Advertisements_Type_by_Outlet_Type.xlsx", ///
								modify sheet("outlet_`geo'") 
								
								
				local row = 1	
						
				local category `category'
				putexcel A`row' = "Outlet: `lab'", bold		

				local row = `row' + 2	
				
				putexcel A`row' = "Variable label", bold
				putexcel B`row' = "Variable name", bold
				putexcel C`row' = "Count", bold
				putexcel D`row' = "Min", bold
				putexcel E`row' = "Median", bold
				putexcel F`row' = "Mean", bold
				putexcel G`row' = "Max", bold
				putexcel H`row' = "SD", bold
						
				local row = `row' + 1	
			
				foreach var of local `category' {
											
					foreach var of varlist `var' {
						
						* Var label
						describe `var'
						local varlabel : var label `var'
						putexcel A`row' = ("`varlabel'")
						
						*Desc stat
						tabstat `var', stat(N min p50 mean max sd) columns(statistics) save 
						mat T = r(StatTotal)' // the prime is for transposing the matrix
						
						* Round min, max, P50, mean and sd
						forval i = 2/6{
							matrix T[1,`i'] = round(T[1,`i'], 0.01)
						}
						
						putexcel B`row' = matrix(T), rownames
						local ++row					
					}
				local ++row					
			
				}
			local ++row		
			}

		}
		
		restore 
		
		local x = `x' + 1

	}	
	

	
	** end of dofile 
	
