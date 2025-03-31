
	* bring in advertisement-level data
	use "$foodenv_prep/2023_food_vendor_detailed_prep_sect4_adlevel.dta", clear 
	
		*** create tables ***
			
		*** Advertisement setting and characteristics, by rural/urban ***
		gen temp=rural_urban
		
			* having trouble exporting out variables with long labels - modifying label *
			label list gdqs_foodcat
			label def gdqs_foodcat 5 "Citrus fruits" 8 "Dark green leafy vegetables", modify
			
			* creating numeric vars for string variables to run table loops
			ds ad*, has(type string)
			for var `r(varlist)': encode X, gen(X_n) \ ren X X_s\ ren X_n X \ order X, after(X_s) \ drop X_s
			
			* partitioning brands that have been verified vs not
			gen ad_brandverifyes=ad_brand if ad_brandverified==1
			label var ad_brandverifyes "List of brands, verified"
			
			gen ad_brandverifno=ad_brand if ad_brandverified==0
			label var ad_brandverifno "List of brands, not verified"
			
			label val ad_brandverifyes ad_brandverifno ad_brand_n
			
			preserve
				collapse (count) ad_brand, by(ad_brandverifyes ad_brandverifno)
				ren ad_brand n
				egen total=total(n)
				gen share=round(n/total*100,.01)
				label var ad_brandverifyes "List of brands, verified"
				label var ad_brandverifno "List of brands, not verified"
 
				tab ad_brandverifyes
				loc row=`r(r)'+3
				
				putexcel set "$foodenv_tables/foodenv_detailed_audit.xlsx", sheet(brands) modify
				putexcel A2="List of brands, verified"
				export excel ad_brandverifyes n share if ad_brandverifyes<. using "$foodenv_tables/foodenv_detailed_audit.xlsx", sheet(brands) cell(A2) firstrow(varl) sheetmodify
				
				putexcel A`row'="List of brands, not verified"
				loc row=`row'+1
				export excel ad_brandverifno n share if ad_brandverifno<. using "$foodenv_tables/foodenv_detailed_audit.xlsx", sheet(brands) cell(A`row') sheetmodify
			restore	
			
			
			*** user input ***
			scalar numberoftables=2 /*PUT THE TOTAL NUMBER OF TABLES HERE */
			global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

			global matrixname1 "adsetting_byregion" /* PUT THE TABLE NAME HERE */
			global ${matrixname1}tablevars "ad_where ad_setting ad_size-ad_appearance"  /*LIST VARS HERE*/
			global ${matrixname1}tablecatvars "ad_where ad_setting ad_size ad_type ad_visibility ad_appearance" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname1}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
					
			
			global matrixname2 "addesc_byregion" /* PUT THE TABLE NAME HERE */
			global ${matrixname2}tablevars "ad_combo ad_chartype-ad_claim97 ad_company ad_companysource"  /*LIST VARS HERE*/
			global ${matrixname2}tablecatvars "ad_chartype ad_gdqs ad_gdqsnegdet ad_gdqsposdet ad_company ad_companysource" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname2}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname2}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
			
			*** baseline table generation ***
			do "${foodenv_ado}00_desc_table_loop.do"	
			
			
			drop temp
		
		*** stratifying inside/outside by outlet type ***
			gen temp=ad_where
			
			*** user input ***
			scalar numberoftables=1 /*PUT THE TOTAL NUMBER OF TABLES HERE */
			global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

			global matrixname1 "adsetting_byadloc" /* PUT THE TABLE NAME HERE */
			global ${matrixname1}tablevars "rural_urban outlet_typecat outlet_type "  /*LIST VARS HERE*/
			global ${matrixname1}tablecatvars "rural_urban outlet_typecat outlet_type" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname1}tablecondition "if s4q2>0" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
			
			*** baseline table generation ***
			do "${foodenv_ado}00_desc_table_loop_2c.do"	
			
			
		*** comparing advertisement settings and characteristics by outlet type (categories)
			drop temp
			gen temp=outlet_typecat
			
			*** user input ***
			scalar numberoftables=2 /*PUT THE TOTAL NUMBER OF TABLES HERE */
			global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

			global matrixname1 "adsetting_byvdtype" /* PUT THE TABLE NAME HERE */
			global ${matrixname1}tablevars "ad_where ad_setting ad_size-ad_appearance"  /*LIST VARS HERE*/
			global ${matrixname1}tablecatvars "ad_where ad_setting ad_size ad_type ad_visibility ad_appearance" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname1}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
					
			
			global matrixname2 "addesc_byvdtype" /* PUT THE TABLE NAME HERE */
			global ${matrixname2}tablevars "ad_combo ad_chartype-ad_claim97 ad_company ad_companysource"  /*LIST VARS HERE*/
			global ${matrixname2}tablecatvars "ad_chartype ad_gdqs ad_gdqsnegdet ad_gdqsposdet ad_company ad_companysource" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname2}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname2}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
			
			*** baseline table generation ***
			do "${foodenv_ado}00_desc_table_loop.do"	


	
	* bring in outlet-level data
	use "$foodenv_prep/2023_food_vendor_detailed_prep_sect4_outletlevel.dta", clear 
	
		*** create tables ***
		gen temp=rural_urban
			
			*** user input ***
			scalar numberoftables=2 /*PUT THE TOTAL NUMBER OF TABLES HERE */
			global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

			global matrixname1 "vddesc_byregion" /* PUT THE TABLE NAME HERE */
			global ${matrixname1}tablevars "outlet_wetmarket outlet_typecat outlet_type outlet_adyn outlet_catadyn* outlet_typeadyn* outletad_char-outletad_gdqsnegkids_pct"  /*LIST VARS HERE*/
			global ${matrixname1}tablecatvars "outlet_typecat outlet_type outlet_wetmarket" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname1}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
			
			global matrixname2 "vdadsdesc_byregion" /* PUT THE TABLE NAME HERE */
			global ${matrixname2}tablevars "outletad_char-outletad_gdqsnegkids_pct"  /*LIST VARS HERE*/
			global ${matrixname2}tablecatvars "" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname2}tablecondition "if outlet_adyn==1" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname2}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
			
			*** baseline table generation ***
			do "${foodenv_ado}00_desc_table_loop.do"			
		
	
		*** Questions ***
			
			* create variables on outlets selling GDQS healthy? GDQS unhealthy? Nova 4 foods?
			