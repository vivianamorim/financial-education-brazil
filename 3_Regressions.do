
                     
														*RESULTS*
														
										    *Financial Literacy Pilot in Brazil*
	*-------------------------------------------------------------------------------------------------------------------------*	
	
	**
	*1*
	*PROGRAMS
	*_________________________________________________________________________________________________________________________*

	{
		**
		*PROGRAM TO SAVE NUMBER OF CLUSTERS
		*---------------------------------------------------------------------------------------------------------------------*
		{
			cap program drop clusters	//para salvar os resultados de RI
			program define   clusters
			syntax, results(string)
				
				unique cd_escola if e(sample) == 1 & d == 1							//number of schools in the treatment group
				scalar unique_treat  = r(unique)
				unique cd_escola if e(sample) == 1 & d == 0							//number of schools in the control group
				scalar unique_control= r(unique)
				scalar clusters = unique_treat + unique_control
			   *estadd scalar unique_control = unique_control  : test`results'
			   *estadd scalar unique_treat	 = unique_treat    : test`results'
				estadd scalar clusters	     = clusters        : test`results'
			end
		}

		
		**
		*PROGRAM DO SAVE RANDOMIZATION INFERENCE RESULTS
		*---------------------------------------------------------------------------------------------------------------------*
		{
			cap program drop add 	//para salvar os resultados de RI
			program define   add
			syntax, results(string)
			
				scalar standde 			= el(r(se),1,1)
				scalar pvalue  			= el(r(p) ,1,1)
				scalar lbound  			= el(r(ci),1,1)  //lower bound p value
				scalar ubound          	= el(r(ci),2,1)	 //upper bound p value
			   *estadd scalar standde 	= standde  : test`results'
				estadd scalar pvalue   	= pvalue   : test`results'
			   *estadd scalar lbound    = lbound   : test`results'
			   *estadd scalar ubound  	= ubound   : test`results'
				
			end	
		}
		
		
		**
		*PROGRAM TO CALCULATE THE AVERAGE SIZE OF THE CLUSTER (average number of students per school)
		*---------------------------------------------------------------------------------------------------------------------*
		{
			cap program drop cluster_size	
			program define   cluster_size
			syntax, results(string)
			preserve
				gen 	id = 1 if e(sample) == 1
				collapse (sum)id, by (cd_escola)
				su 		id, detail
				scalar 	cluster_size = r(mean)
				estadd 	scalar cluster_size = cluster_size   : test`results'
			restore
			end
		}	
			
			
		**
		*PROGRAM FOR SENSITIVITY ANALYSIS CHARTS
		*---------------------------------------------------------------------------------------------------------------------*
		{	
			cap program drop chart
			program define chart
			syntax, ciclo(string) var(string)
			
				if "`var'"   == "pca_consump_sm" local title  "Consumption index"
				if "`var'"   == "pca_save_sm"    local title  "Saving index"
				if "`var'"   == "talk_parents"   local title  "Talk to parents"
				if "`var'"   == "talk_friends"   local title  "Talk to friends"
				if "`var'"   == "pigg"   		 local title  "Piggy's bank use"
				if "`var'"   == "finan_serv"     local title  "Use of finantial services"
				if "`var'"   == "allowance2"     local title  "Allowance"
				if "`ciclo'" == "pooled" 		 local title2 "pooled"
				if "`ciclo'" == "1st" 			 local title2 "Primary education"
				if "`ciclo'" == "2nd" 			 local title2 "Middle school"
				twoway rarea _med_updelta0 _med_lodelta0 _med_rho, bcolor(gs14) || line _med_delta0 _med_rho, lcolor(black) saving("A`ciclo'`var'.gph", replace) ///
				ytitle("ACME({&rho})",size(medium)) title("`title', `title2'", size(medium)) xtitle("Sensitivity parameter: {&rho}", size(medium)) legend(off) scheme(sj) ///
				ylabel(, nogrid) ///
				graphregion(fcolor(white) lcolor(white)) 
				*graph export "$figures/`ciclo'_`var'.emf", as(emf) replace
			end
		}

		
		**
		*PROGRAM TO CREATE THE CHARTS OF THE QUANTILE REGRESSIONS
		*---------------------------------------------------------------------------------------------------------------------*
		{
		cap program drop charts
		program define	 charts 
			syntax, model(string)

			matrix results = r(table)' 
			matrix A = (0, 0, 0, 0) 
			local  i = 1
			forvalues f = 5(5)95 {
				matrix A = A \ (`f', results[`i',1], results[`i',5], results[`i',6])		//quantile of analysis, coefficient, lower and upper bound
				local i = `i' + 2 
			}
			matrix list A
			clear
			svmat 	A 
			drop 	in 1
			rename (A1 A2 A3 A4) (quantile b lower upper)
			twoway ///
			(scatter b quantile, msymbol(O) msize(medium) color(cranberry) yline(0,lpattern(dash))) ///
			(rcap 	lower upper quantile, color(navy) ///
			graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
			plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
			ylabel(-0.15(0.05)0.30, nogrid labsize(small) format(%4.2fc)) ///
			xlabel(0(5)95, labsize(small) gmax angle(horizontal)) ///
			ytitle("Standard deviation", size(medsmall)) ///
			xtitle("Quantiles of finacial proficiency", size(medsmall)) ///
			title("", pos(12) color(black) size(medsmall)) ///
			subtitle(, pos(12) size(medsmall)) ///
			ysize(5) xsize(7) ///
			legend(off) ///
			note("$gr_note", color(black) fcolor(background) pos(7) size(small))) 
			
			if "`model'" == "Elementary education"  graph export "$figures/Figure1.pdf" 	, as(pdf) replace	
			if "`model'" == "Pooled" 				graph export "$figures/FigureB2a.pdf"	, as(pdf) replace	
			if "`model'" == "Middle school" 		graph export "$figures/FigureB2b.pdf"	, as(pdf) replace	
		end
		}
	}
	
	
	**
	*2*
	*REGRESSIONS
	*_________________________________________________________________________________________________________________________*

	
	**
	*Table 1
	*-------------------------------------------------------------------------------------------------------------------------*
	{ //ITT -> Impacts of the program on financial proficienty, and consumption and saving index
		use  	"$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
		estimates clear
		local i = 1
		
		foreach var of varlist sm pca_consump_sm pca_save_sm { //self_control risk_aversion1 risk_aversion2
			estimates clear
			if "`var'" == "sm" 				local title = "Financial proeficiency"
			if "`var'" == "pca_consump_sm" 	local title = "Consumption Index"
			if "`var'" == "pca_save_sm" 	local title = "Saving Index"		
			if "`var'" == "risk_aversion1" 	local title = "Risk-aversion - 1 & 2 questions"		
			if "`var'" == "risk_aversion2" 	local title = "Risk-aversion - 1,2,3,5,7"					
			

		*1. Pooled 
					eststo test`i', title("Pooled"):								   		 		reg `var' d $estrato, 			  		  			cluster(cd_escola)
					clusters, results(`i')
					ritest d _b[d], seed(443171 ) reps(1000) cluster(cd_escola) strata(estrato): 	reg `var' d $estrato							, 	cluster(cd_escola)
					add, results(`i')
					local i = `i' + 1

			
		*2. Primeiro Ciclo
					eststo test`i', title("Elementary"):								     		reg `var' d $estrato if serie < 7				, 	cluster(cd_escola)
					clusters, results(`i')	
					ritest d _b[d], seed(673974) reps(1000) cluster(cd_escola) strata(estrato): 	reg `var' d $estrato if serie < 7				, 	cluster(cd_escola)
					add, results(`i')
					local i = `i' + 1

		*3. Segundo Ciclo	
					eststo test`i', title("Middle school"):			      					 		reg `var' d $estrato if serie > 5				, cluster(cd_escola)
					clusters, results(`i')
					ritest d _b[d], seed(700515) reps(1000) cluster(cd_escola) strata(estrato): 	reg `var' d $estrato if serie > 5				, cluster(cd_escola)
					add, results(`i')
					local i = `i' + 1

		*4. Por série
			if "`var'" == "sm" {
				foreach serie in 3 5 7 9 {
					eststo test`i', title("`serie' grade"):								  	 		reg `var' d $estrato if serie == `serie'		, cluster(cd_escola)
					clusters, results(`i')
					ritest d _b[d], seed(647313) reps(1000) cluster(cd_escola) strata(estrato): 	reg `var' d $estrato if serie == `serie'		, cluster(cd_escola)
					add, results(`i')
					local i = `i' + 1
				}
			}
			else {
				foreach serie in 5 7 9 {
					eststo test`i', title("`serie' grade"): 										reg `var' d $estrato if serie == `serie'		, cluster(cd_escola)
					clusters, results(`i')
					ritest d _b[d], seed(861244) reps(1000) cluster(cd_escola) strata(estrato): 	reg `var' d $estrato if serie == `serie'		, cluster(cd_escola)
					add, results(`i')
					local i = `i' + 1
				}	
			}
			
			if "`var'" == "sm" estout test* using "$results/Table1.xls", title("`title'") keep(d) starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("' `")""')) p ) stats(pvalue N clusters r2, labels("RI pvalue" "N. obs" "N. clusters" "R-squared")) replace
			if "`var'" != "sm" estout test* using "$results/Table1.xls", title("`title'") keep(d) starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("' `")""')) p ) stats(pvalue N clusters r2, labels("RI pvalue" "N. obs" "N. clusters" "R-squared")) append
		}
	}
		
	
	
	**
	*Table 2
	*-------------------------------------------------------------------------------------------------------------------------*
	{ //Behavioral Outcomes talk_friends allowance allowance2  earns money_gift 
		use 		"$dtfinal/Fin_Lit_pooled_data_clean.dta",replace 
		estimates clear 
		local i = 1
		foreach var in talk_parents talk_friends pigg finan_serv allowance2 {

			if "`var'" == "pigg" 			estimates clear
			if "`var'" == "allowance2" 		estimates clear
			
			* 1. Pooled 
				eststo test`i', title("Pooled"):  											reg `var' d $estrato, 			  cluster(cd_escola)
				clusters, results(`i')
				ritest d _b[d], seed(012587) reps(1000) cluster(cd_escola) strata(estrato): reg `var' d $estrato, 			  cluster(cd_escola)
				add, results(`i')
				local i = `i' + 1


			* 2. Elementary students
				eststo test`i', title("Elementary"):  										reg `var' d $estrato if serie < 7, cluster(cd_escola)
				clusters, results(`i')
				ritest d _b[d], seed(699051) reps(1000) cluster(cd_escola) strata(estrato): reg `var' d $estrato if serie < 7, cluster(cd_escola)
				add, results(`i')
				local i = `i' + 1
				
				
			* 3. Middle school students
				eststo test`i', title("Middle school"):										reg `var' d $estrato if serie > 5, cluster(cd_escola)
				clusters, results(`i')
				ritest d _b[d], seed(767240) reps(1000) cluster(cd_escola) strata(estrato): reg `var' d $estrato if serie > 5, cluster(cd_escola)
				add, results(`i')
				local i = `i' + 1
		
			
			if "`var'" == "talk_friends" estout test* using "$results/Table2.xls", keep(d) starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("' `")""')) p ) mgroups("Talk to parents"  "Talk to friends"				,  pattern(1 0 0 1 0 0 )) stats(pvalue N clusters r2, labels("RI pvalue" "N. obs" "N. clusters" "R-squared")) replace
			if "`var'" == "finan_serv" 	 estout test* using "$results/Table2.xls", keep(d) starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("' `")""')) p ) mgroups("Piggy's bank use" "Use of financial services"	,  pattern(1 0 0 1 0 0 )) stats(pvalue N clusters r2, labels("RI pvalue" "N. obs" "N. clusters" "R-squared")) append
			if "`var'" == "allowance2" 	 estout test* using "$results/Table2.xls", keep(d) starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("' `")""')) p ) mgroups("Allowance"				   						,  pattern(1 0 0 1 0 0 )) stats(pvalue N clusters r2, labels("RI pvalue" "N. obs" "N. clusters" "R-squared")) append
		}	
	}
	
	
	
	**
	*Table 3 - LATE -> Using treatment assignment as instrument for receiving treatment
	*-------------------------------------------------------------------------------------------------------------------------*
	{
	use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

			*How many control students received treatment and how many treatment students did not receive
			tab d treated, mis
			codebook cd_escola if treated == 1 & d == 0 
			codebook cd_escola if treated == 0 & d == 1 

			foreach var of varlist sm pca_consump_sm pca_save_sm {
			estimates clear

				if "`var'" == "sm" 					local titleg = "Financial Proeficiency"
				if "`var'" == "pca_consump_sm" 	 	local titleg = "Consumption Index"
				if "`var'" == "pca_save_sm" 		local titleg = "Savings Index"
				if "`var'" == "z_self_control" 		local titleg = "Self-control"
				if "`var'" == "z_risk_aversion2" 	local titleg = "Risk-aversion"
				
				* 1. Pooled 
					eststo testA0, title("ITT"): reg    `var' d $estrato  								, cluster(cd_escola)
					eststo testA1, title("LATE"):ivreg2 `var'   $estrato (treated = d )					, cluster(cd_escola)
					
					* 2. Elementary
					eststo testB0, title("ITT") : reg    `var' d $estrato  				if serie < 7	, cluster(cd_escola)
					eststo testB2, title("LATE"): ivreg2 `var'   $estrato (treated = d) if serie < 7	, cluster(cd_escola)
				
				* 3. Middle school
					eststo testC0, title("ITT") : reg    `var' d $estrato  				if serie > 5	, cluster(cd_escola)
					eststo testC1, title("LATE"): ivreg2 `var'   $estrato (treated = d) if serie > 5	, cluster(cd_escola)
			
				if "`var'" == "sm" estout * using "$results/Table3.xls", title("`titleg'") keep(d  treated) starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("' `")""'))) mgroups("Pooled" "Elementary" "Middle school"	,  pattern(1 0 1 0 1 0)) stats(N r2, labels( "N. obs" "R-squared")) replace
				if "`var'" != "sm" estout * using "$results/Table3.xls", title("`titleg'") keep(d  treated) starlevels(* 0.1 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("' `")""'))) mgroups("Pooled" "Elementary" "Middle school"	,  pattern(1 0 1 0 1 0)) stats(N r2, labels( "N. obs" "R-squared")) append			
			}
	}
	
	
	
	**
	*Table A13, Figures 1, 2, 3 appendix
	*-------------------------------------------------------------------------------------------------------------------------*
	{  //ACME
	
		
		**
		*Sensitivity analysis
		*---------------------------------------------------------------------------------------------------------------------*
		use 		"$dtfinal/Fin_Lit_pooled_data_clean.dta",replace 
		merge 		m:1 cd_escola using "$dtinter/School characteristics.dta", keep (match master) nogen

			tab complexidade, gen (complexidade) //Fiz isso porque o comando medeff nao aceita factor variables
			//Este comando não aceita nenhum coeficiente que seja missing na regressão. Depois de rodar pela primeira vez, eu vi os eventuais missings e os excluí dos controles das regressões abaixo.

			*POOLED
			*-----------------------------------------------------------------------------------------------------------------*
			local nvar = 1
			foreach var of varlist pca_consump_sm pca_save_sm talk_parents talk_friends pigg finan_serv allowance2 {
				medeff  (regress sm d strata421 strata422 strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) 	(regress `var' d sm  strata421 strata422 strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3), treat(d) mediate(sm) seed(896749 ) 
			   	matrix pooled_`nvar' = (r(delta0), r(delta0lo), r(delta0hi) \ r(zeta1), r(zeta1lo), r(zeta1hi) \ r(tau), r(taulo), r(tauhi) \ r(navg), r(navglo), r(navghi))
				medsens (regress sm d strata421 strata422 strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) 	(regress `var' d sm  strata421 strata422 strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3), treat(d) mediate(sm) 
			    chart, ciclo(pooled) var(`var')
				local nvar = `nvar' + 1
			}
	
		
			*Primary education
			*-----------------------------------------------------------------------------------------------------------------*
			local nvar = 1
			foreach var of varlist pca_consump_sm pca_save_sm talk_parents talk_friends allowance2  {
				medeff   (regress sm d strata421 		  strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3)  (regress `var' d sm strata421 		    strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie < 7 , treat(d) mediate(sm) seed(089770) 
				matrix primary_`nvar' = (r(delta0), r(delta0lo), r(delta0hi) \ r(zeta1), r(zeta1lo), r(zeta1hi) \ r(tau), r(taulo), r(tauhi) \ r(navg), r(navglo), r(navghi))
			    medsens  (regress sm d strata421 		  strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3)  (regress `var' d sm strata421 		    strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie < 7 , treat(d) mediate(sm) 
				chart, ciclo(1st) var(`var')
			    local nvar = `nvar' + 1
			}

			foreach var of varlist	pigg finan_serv {
				medeff   (regress sm d strata421 strata422 strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3)  (regress `var' d sm strata421 strata422 strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie < 7 , treat(d) mediate(sm) seed(727484) 
				matrix primary_`nvar' = (r(delta0), r(delta0lo), r(delta0hi) \ r(zeta1), r(zeta1lo), r(zeta1hi) \ r(tau), r(taulo), r(tauhi) \ r(navg), r(navglo), r(navghi))
			    medsens  (regress sm d strata421 strata422 strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3)  (regress `var' d sm strata421 strata422 strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie < 7 , treat(d) mediate(sm) 
				chart, ciclo(1st) var(`var')
				local nvar = `nvar' + 1
			}

			*Middle school
			*-----------------------------------------------------------------------------------------------------------------*
			local nvar = 1
			foreach var of varlist pca_consump_sm  pca_save_sm  talk_parents  pigg finan_serv allowance2 {
				medeff   (regress sm d 					  strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) (regress `var' d sm   					strata423 	strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie > 5 , treat(d) mediate(sm) seed(410672) 
				matrix middle_`nvar' = (r(delta0), r(delta0lo), r(delta0hi) \ r(zeta1), r(zeta1lo), r(zeta1hi) \ r(tau), r(taulo), r(tauhi) \ r(navg), r(navglo), r(navghi))
			    medsens  (regress sm d 				      strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) (regress `var' d sm   					strata423 	strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie > 5 , treat(d) mediate(sm) 
				chart, ciclo(2nd) var(`var')
				local nvar = `nvar' + 1
			}
			
			foreach var of varlist  talk_friends {
				medeff   (regress sm d  		strata422 strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) 	(regress `var' d sm 		  strata422 strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie > 5 , treat(d) mediate(sm) seed(094495) 
				matrix middle_`nvar' = (r(delta0), r(delta0lo), r(delta0hi) \ r(zeta1), r(zeta1lo), r(zeta1hi) \ r(tau), r(taulo), r(tauhi) \ r(navg), r(navglo), r(navghi))
			    medsens  (regress sm d  		strata422 strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) 	(regress `var' d sm 		  strata422 strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie > 5 , treat(d) mediate(sm) 
				chart, ciclo(2nd) var(`var')
				local nvar = `nvar' + 1
			}	
			
			*Organizing data
			*-----------------------------------------------------------------------------------------------------------------*
			foreach level in pooled primary middle {
				matrix total = (`level'_1, `level'_2, `level'_3, `level'_4,  `level'_5, `level'_6, `level'_7)
				clear
				svmat  total 
				tostring *, replace force
				foreach var of varlist * {
					replace `var' = substr(`var',1,4)
				}
				set obs 7
				if "`level'" == "pooled" replace total1 = "Pooled" in 5
				if "`level'" == "primary" replace total1 = "Primary Education" in 5
				if "`level'" == "middle" replace total1 = "Middle school" in 5
				replace total1  = "Consumption" in 6
				replace total4  = "Savings" in 6
				replace total7  = "Talk to parents" in 6
				replace total10 = "Talk to friends" in 6
				replace total13 = "Piggy's bank use'" in 6
				replace total16 = "Use of financial services" in 6
				replace total19 = "Allowance" in 6
				forvalues p = 1(3)19 {
					replace total`p' = "Mean" in 7
					local 		 f = `p' + 1 
					replace total`f' = "95%CI" in 7
				}
				gen 	dec = "Total effect" in 1
				replace dec = "ADE" in 2
				replace dec = "ACME" in 3
				replace dec = "% of total effect mediated" in 4
				order 	dec
				gen 	order = 1 in 5
				replace order = 2 in 6
				replace order = 3 in 7
				replace order = 4 in 1
				replace order = 5 in 2
				replace order = 6 in 3
				replace order = 7 in 4
				sort order
				drop order
				if "`level'" == "pooled"  export excel using "$results\Table A13.xls", replace
				if "`level'" == "primary" export excel using "$results\Table A13.xls", sheetmodify cell(A9)
				if "`level'" == "middle"  export excel using "$results\Table A13.xls", sheetmodify cell(A17)
			}
			
			
			
			graph combine "$projectfolder/Apooledpca_consump_sm.gph" "$projectfolder/Apooledpca_save_sm.gph"    "$projectfolder/Apooledtalk_parents.gph" ///
						  "$projectfolder/Apooledtalk_friends.gph"   "$projectfolder/Apooledpigg.gph"  	   		"$projectfolder/Apooledfinan_serv.gph"   ///
						  "$projectfolder/Apooledallowance2.gph", cols(2) xsize(4) ysize(8)
						  graph export "$figures\Figure1_appendix.pdf", as(pdf) replace
						  
			graph combine "$projectfolder/A1stpca_consump_sm.gph"    "$projectfolder/A1stpca_save_sm.gph"       "$projectfolder/A1sttalk_parents.gph" 	 ///
						  "$projectfolder/A1sttalk_friends.gph"      "$projectfolder/A1stpigg.gph"  	        "$projectfolder/A1stfinan_serv.gph"   	 ///
						  "$projectfolder/A1stallowance2.gph",    cols(2) xsize(4) ysize(8)
						  graph export "$figures\Figure2_appendix.pdf", as(pdf) replace
							
			graph combine "$projectfolder/A2ndpca_consump_sm.gph"   "$projectfolder/A2ndpca_save_sm.gph"        "$projectfolder/A2ndtalk_parents.gph" 	 ///
						  "$projectfolder/A2ndtalk_friends.gph"     "$projectfolder/A2ndpigg.gph"  	            "$projectfolder/A2ndfinan_serv.gph"   	 ///
						  "$projectfolder/A2ndallowance2.gph",    cols(2) xsize(4) ysize(8)
						  graph export "$figures\Figure3_appendix.pdf"   , as(pdf) replace  
			
			foreach name in pca_consump_sm pca_save_sm  talk_parents talk_friends pigg finan_serv allowance2 {
				cap noi erase "$projectfolder\Apooled`name'.gph"
				cap noi erase "$projectfolder\A1st`name'.gph"
				cap noi erase "$projectfolder\A2nd`name'.gph"
			}
	}
		
		
	
	**
	*Figures 1, B2a, B2b
	*-------------------------------------------------------------------------------------------------------------------------*
	{ //Quantile regressions
		estimates clear
		use 	"$dtfinal/Fin_Lit_pooled_data_clean.dta",replace 
			reg 	sm $estrato
			predict resid, residuals

			set seed 551118

			*Pooled
			preserve
			cap noi eststo: sqreg resid d, 			    quantile(.05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .55 .6 .65 .7 .75 .8 .85 .9 .95) reps(1000) 
			charts, model("Pooled")
			restore

			*Primary education
			preserve
			cap noi eststo: sqreg resid d if serie < 7, quantile(.05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .55 .6 .65 .7 .75 .8 .85 .9 .95) reps(1000) 
			charts, model("Elementary education")
			restore

			*Middle school
			preserve
			cap noi eststo: sqreg resid d if serie > 5, quantile(.05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .55 .6 .65 .7 .75 .8 .85 .9 .95) reps(1000) 
			charts, model("Middle school")
			restore
			*grqreg, ols 
			
			/*
			*By grade
			foreach grade in 3 5 7 9 {
			preserve
			cap noi eststo: sqreg resid d if serie == `grade' quantile(.05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .55 .6 .65 .7 .75 .8 .85 .9 .95) reps(1000) 
			charts, model("`Grade' grade")
			restore
			*/
	}
	
