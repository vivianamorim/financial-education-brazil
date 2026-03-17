

												*DESCRIPTIVE STATISTICS*
														
										   *Financial Literacy Pilot in Brazil*
	*-------------------------------------------------------------------------------------------------------------------------*	


	**
	*Figures B1a B1b ok
	*---------------------------------------------------------------------------------------------------------------------*
	{	//correlation between financial proficiency and the IDEB (Education Development Index. )
		use 	"$dtfinal/Fin_Lit_pooled_data_clean.dta",replace 
			merge 	m:1 cd_escola using  "$dtinter/Treatment and control groups.dta", nogen  

			collapse (mean)vl_proficiencia IDEB_F05_2015 IDEB_F09_2015 if serie == 5 | serie == 9, by(serie cd_escola)
			
					twoway ///
					(lfit   vl_proficiencia IDEB_F05_2015 if serie == 5, lp(shortdash) lcolor(cranberry) lw(thick)) 	///
				|| (scatter vl_proficiencia IDEB_F05_2015 if serie == 5, symbol(O) color(emidblue*0.8)  msize(medsmall) mlabcolor(black) mlabposition(9) mlabsize(2)	 ///   
					ylabel(,nogrid) 																					///
					title("", size(medium) color(black)) 																///
					ytitle("Financial Proficiency Score, 2015", size(medium) color(black)) 								///
					xtitle("IDEB of fifth graders, 2015", size(medium)) ///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	///
					plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
					ysize(5) xsize(7)							 														///
					legend(off) ///
					note("", span color(black) fcolor(background) pos(7) size(small)))
					graph export "$figures/FigureB1a.pdf", as(pdf) replace	

						twoway ///
					(lfit   vl_proficiencia IDEB_F09_2015 if serie == 9, lp(shortdash) lcolor(cranberry) lw(thick)) 	///
				|| (scatter vl_proficiencia IDEB_F09_2015 if serie == 9, symbol(O) color(emidblue*0.8)  msize(medsmall) mlabcolor(black) mlabposition(9) mlabsize(2)	 ///   
					ylabel(,nogrid) 																					///
					title("", size(medium) color(black)) 																///
					ytitle("Financial Proficiency Score, 2015", size(medium) color(black)) 								///
					xtitle("IDEB of ninth graders, 2015", size(medium)) ///
					graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white))	///
					plotregion( color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) 	///
					ysize(5) xsize(7)							 														///
					legend(off) ///
					note("", span color(black) fcolor(background) pos(7) size(small)))
					graph export "$figures/FigureB1b.pdf", as(pdf) replace	
	}
	
		
	**
	*Table A2
	*---------------------------------------------------------------------------------------------------------------------*
	{	//sample selected
		use 	"$dtinter/Treatment and Control Groups.dta", clear
			label 	 define			 tipo 1 "Only initial grades" 2 "Only final grades" 3 "Initial and final grades"
			label 	 val  	 tipo_escola tipo 
			gen 	 id = 1
			collapse (sum)id, by(resultado tipo_escola munic)
			expand 	 2, gen(REP)
			decode 	 munic, gen(mun)
			replace  mun = "Total" if REP == 1
			collapse (sum) id, by(resultado tipo_escola mun)
			reshape  wide id, i(resultado tipo_escola) j(mun) string
			reshape  wide id*, i(tipo_escola) j(resultado)
			foreach city in Joinville Manaus Total {
				egen id`city' = rowtotal(id`city'*)
			}
			gen 	idManaus_censo = .
			replace idManaus_censo = 202 if tipo_escola == 1 		//numero de escolas de acordo com o Censo Escolar 
			replace idManaus_censo = 35  if tipo_escola == 2
			replace idManaus_censo = 65  if tipo_escola == 3
			order    tipo_escola idJoinville idJoinville1 idJoinville0 idManaus_censo  idManaus idManaus1 idManaus0 idTotal1
			expand 2, gen(REP)
			replace tipo_escola = 0 if REP == 1
			collapse (sum)id*, by(tipo_escola)
			tostring*, replace force
			replace tipo_escola = "1st-5th grades" in 2
			replace tipo_escola = "6th-9th grades" in 3
			replace tipo_escola = "1st-9th grades" in 4 
			replace tipo_escola = "Total" in 1
			gen coladd = "All"
			gen coladd2 = ""
			gen coladd3 = ""
			order tipo_escola idJoinville coladd idJoinville1 idJoinville0 coladd2 idManaus* coladd3
			replace idManaus = "36 sampled based on 2013 IDEB 1st-5th grades" in 2
			replace idManaus = "28 sampled based on 2013 IDEB 6th-9th grades" in 3
			replace idManaus = "All" in 4
			set obs 8
			drop idTotal
			replace tipo_escola 		= "Schools offering" in 5
			replace idJoinville 		= "Joinville" in 6
			replace idManaus_censo 		= "Manaus" in 6
			replace idTotal1 			= "Manaus and Joinville" in 6
			replace idJoinville 		= "Number of schools" in 7
			replace coladd 				= "Randomization sample" in 7
			replace idJoinville1 		= "Randomization Groups" in 7
			replace idJoinville1 		= "Treatment" in 8
			replace idJoinville0 		= "Control" in 8 
			replace idManaus_censo 		= "Number of schools" in 7
			replace idManaus			= "Randomization sample" in 7
			replace idManaus1 			= "Randomization Groups" in 7
			replace idManaus1			= "Treatment" in 8
			replace idManaus0 			= "Control" in 8 
			replace idTotal1 			= "Number of randomized schools" in 7
			replace idTotal1 			= "Treatment" in 8
			replace idTotal0 			= "Control" in 8
			gen 	order = 1 in 6
			replace order = 2 in 7
			replace order = 3 in 8
			replace order = 4 in 5
			replace order = 5 in 2
			replace order = 6 in 3
			replace order = 7 in 4
			replace order = 8 in 1		
		
			sort order
			drop order
			export excel "$descriptives/Table A2.xlsx", firstrow(variables) replace
	}
	
	
	**
	**Table A4
	*---------------------------------------------------------------------------------------------------------------------*
	{
		clear
		set obs 30
		gen 	col1 = "Statement"  															in 1
		gen 	col2 = "Answers' scale" 														in 1
		replace col2 = "Totally agree" 															in 2
		gen 	col3 = "Agree" 																	in 2
		gen 	col4 = "Disagree" 																in 2
		gen 	col5 = "Totally disagree" 														in 2
		gen 	col6 = "Weight in index" 														in 1
		
		
		replace col1 = "Consumption questions" 													in 3
		
		replace col1 = "I buy what I want, then I see how I can pay" 							in 4
		replace col6 = "0.45" in 4
		
		replace col1 = "I see no problem in owing money"										in 5
		replace col6 = "0.44" in 5
		
		replace col1 = "If the brand is famous the product is of high quality" 					in 6
		replace col6 = "0.32" in 6

		replace col1 = "The best product is always the most expensive" 							in 7
		replace col6 = "0.33" in 7

		replace col1 = "I plan before spending my money" 										in 8
		replace col6 = "0.1" in 8

		replace col1 = "It is worthless to plan because the money comes from luck" 				in 9
		replace col6 = "0.43" in 9	

		replace col1 = "Buy what I want is more important than have planning" 					in 10
		replace col6 = "0.45" in 10

		replace col1 = "Saving questions"														in 12
		
		replace col1 = "I think that saving money is important to avoid problems in the future"	in 13
		replace col6 = "0.41" in 13

		replace col1 = "I feel safer when I can save some money"								in 14
		replace col6 = "0.39" in 14
		
		replace col1 = "Saving some money is important to avoid debt"							in 15
		replace col6 = "0.42" in 15

		replace col1 = "Buying everything I want is more important than putting the money together"	in 16
		replace col6 = "0.24" in 16

		replace col1 = "Avoiding waste is also a way to save money"								in 17
		replace col6 = "0.38" in 17

		replace col1 = "I try to use the products for longer"									in 18
		replace col6 = "0.35" in 18

		replace col1 = "Whenever I can, I save money"											in 19
		replace col6 = "0.37" in 19
		
		replace col1 = "I would rather spend the change on something I want than save the money for later"	in 20
		replace col6 = "0.19" in 20

		foreach row in 4 5 6 7 9 10 16 20 {
			replace col2 = "1" in `row'
			replace col3 = "2" in `row'
			replace col4 = "3" in `row'
			replace col5 = "4" in `row'
		}
		
		foreach row in 8 13 14 15 17 18 19 {
			replace col2 = "4" in `row'
			replace col3 = "3" in `row'
			replace col4 = "2" in `row'
			replace col5 = "1" in `row'
		}	
		export excel "$descriptives/Table A4.xlsx", replace	
	}

	
	**
	**Table A5 ok
	*---------------------------------------------------------------------------------------------------------------------*
	{
		**
		*block 1
		*-----------------------------------------------------------------------------------------------------------------*
		{	
		
			*Students' participation rate
			*-----------------------------------------------------------------------------------------------------------------*
				use  "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
				
				recode    fl_blank_score (0 = 100) (1 = 0)		//100 if student answered the financial literacy questionnaire, 0 if the student did not answer
				label var fl_blank_score  "Students' participation rate"
			

			*Response rate of socieconomic and attitudinal questionnaires
			*-----------------------------------------------------------------------------------------------------------------*
				recode    fl_blank_parent (0 = 100) (1 = 0)
				recode    fl_socio_blank  (0 = 100) (1 = 0)
				replace   fl_blank_parent = . if fl_blank_score == 0 
				replace   fl_socio_blank  = . if fl_blank_score == 0 
				label var fl_blank_parent "Response rate of socioeconomic and attitudinal questionnaires"
				label var fl_socio_blank  "Response rate of socioeconomic and attitudinal questionnaires"	  
			
			*Balance test
			*-----------------------------------------------------------------------------------------------------------------*
			
				/*
				This code requires version 6.4 of the command iebaltab to run as expected.
				The next line of code loads that version of the command. A command loaded this way 
				is used instead of whatever version of iebaltab the user has installed on thier computer.
				The file used beloe was retrieved from https://github.com/worldbank/ietoolkit/releases,
				and is commited to this repository
				*/
				do "$dofiles/ado/iebaltab.ado"
			
			
				* Run balance tests
				iebaltab fl_blank_score  fl_blank_parent if cd_etapa_aplicacao_turma == 3, format(%12.1f)  cov(estrato) rowvarlabels grpvar(resultado) save("$descriptives/Table_block1_3grade.xlsx") replace
				iebaltab fl_blank_score  fl_socio_blank  if cd_etapa_aplicacao_turma == 5, format(%12.1f)  cov(estrato) rowvarlabels grpvar(resultado) save("$descriptives/Table_block1_5grade.xlsx") replace
				iebaltab fl_blank_score  fl_socio_blank  if cd_etapa_aplicacao_turma == 7, format(%12.1f)  cov(estrato) rowvarlabels grpvar(resultado) save("$descriptives/Table_block1_7grade.xlsx") replace
				iebaltab fl_blank_score  fl_socio_blank  if cd_etapa_aplicacao_turma == 9, format(%12.1f)  cov(estrato) rowvarlabels grpvar(resultado) save("$descriptives/Table_block1_9grade.xlsx") replace
			
			
			
			*Organizing
			*-----------------------------------------------------------------------------------------------------------------*
				foreach grade in 3 5 7 9 {
					import 		excel "$descriptives\Table_block1_`grade'grade.xlsx", allstring clear
						foreach var of varlist * {
							replace `var' ="" if inlist(`var', "Variable", "N", "Mean/SE", "(1)-(2)")
						}
						if `grade' == 3 replace C = "Third-grade"   in 1
						if `grade' == 5 replace C = "Fifth-grade"   in 1
						if `grade' == 7 replace C = "Seventh-grade" in 1
						if `grade' == 9 replace C = "Ninth-grade"   in 1
						replace 	C = "C" in 2
						replace 	E = "T" in 2
						replace 	F = "T-C" in 2
						replace 	A = A[_n-1] if A == ""
						gen 		obs = _n
						egen 		group = group(A)
						gen 		obs_group = 1 		if					 		!missing(group)
						replace 	obs_group = 2 		if group[_n] == group[_n-1] & !missing(group)
						expand 		3 					if obs_group == 2, gen(REP)
						sort 		obs A REP 
						replace 	C = B[_n-2] 		if REP == 1
						replace 	E = D[_n-2] 		if REP == 1
						replace 	E = "" in 1 
						replace 	F = "" in 1
						drop in 12/14
						gen 	    variable = "Mean" 	if obs_group == 1 												& !missing(group)	
						replace	    variable = "SE"	  	if obs_group == 2 & obs_group[_n-1] == 1							& !missing(group)
						replace	    variable = "OBS"  	if obs_group == 2 & obs_group[_n-1] == 2 & obs_group[_n+1] == 2	& !missing(group)
						order   	A variable
						drop 		B D obs group obs_group REP
						replace 	A = "" 				if A[_n] == A[_n-1] | A[_n] == A[_n-2]
						replace 	A = "" 				if A[_n] == A[_n-1] | A[_n] == A[_n-3]
						replace 	variable = A[_n+1] 	if A[_n+1] != ""
						drop 		A
						if 		`grade' > 3 drop variable			
						if 		`grade' == 3		export	 excel using "$descriptives\Table A5.xls",  replace
						if 		`grade' == 5 		export	 excel using "$descriptives\Table A5.xls",  sheetmodify cell(E1)	
						if 		`grade' == 7 		export	 excel using "$descriptives\Table A5.xls",  sheetmodify cell(H1)	
						if 		`grade' == 9 		export	 excel using "$descriptives\Table A5.xls",  sheetmodify cell(K1)	
						erase 	"$descriptives\Table_block1_`grade'grade.xlsx"
				}
		}
		
		
		**
		*block 2
		*-----------------------------------------------------------------------------------------------------------------*
		{	
			
			*When the textbook was received
			*-----------------------------------------------------------------------------------------------------------------*
				use  "$dtfinal/Fin_Lit_pooled_data_clean.dta",clear 
				
				bys d: tab socio_rp_61 cd_etapa_aplicacao_turma, mis
				
				tab 	socio_rp_61, gen (d_when_receive)
				tab 	cd_etapa_aplicacao_turma if resultado == 1 & fl_blank_score == 0 //numero de estudantes tratados em cada serie e que participaram da prova

				foreach var of varlist d_when*{
					replace `var' = 100 if `var' == 1
				}

				keep if resultado == 1
				*-----------------------------------------------------------------------------------------------------------------*
				sumstats (d_when_receive1 d_when_receive2 d_when_receive3 d_when_receive4 if resultado == 1 & cd_etapa_aplicacao_turma == 5) ///
						 (d_when_receive1 d_when_receive2 d_when_receive3 d_when_receive4 if resultado == 1 & cd_etapa_aplicacao_turma == 7) ///
						 (d_when_receive1 d_when_receive2 d_when_receive3 d_when_receive4 if resultado == 1 & cd_etapa_aplicacao_turma == 9) ///
				using "$descriptives/Table_block2.xlsx", replace stats(N mean sd)

			*Organizing
			*-----------------------------------------------------------------------------------------------------------------*
				import 		excel "$descriptives\Table_block2.xlsx", allstring clear
				drop 		in 1
				destring, 	replace
				gen 		obs = _n
				mkmat 		B C D if inrange(obs,2,5  ), matrix(A1)
				mkmat 		B C D if inrange(obs,8,11 ), matrix(A2)
				mkmat 		B C D if inrange(obs,14,17), matrix(A3)
				matrix 		T = (A1 , A2,  A3)
				clear 
				svmat 		T
				gen 		des	=  "Beginning of the year" 		in 1
				replace 	des	= "By the middle of the year" 	in 2
				replace 	des	= "In the end of the year" 		in 3
				replace 	des	= "Haven’t received" 			in 4
				order des
				tostring *, replace force
				replace 	T1 = ""
				replace 	T4 = ""
				replace 	T7 = ""
				set 		obs 6
				gen 		obs = _n
				gsort 	   -obs
				replace  des = "Deliver of the financial literacy textbooks according to students, in %" in 1
				foreach var in T2 T5 T8 {
					replace `var' = "Mean" in 2
					replace `var' = substr(`var',1, 4) if `var' != "Mean"
				}
				foreach var in T3 T6 T9 {
					replace `var' = "SD" in 2
					replace `var' = substr(`var',1, 4) if `var' != "Mean"& `var' != "SD"
				}
				gen 		T10 =.
				gen 		T11=.
				order 	des T10 T11
				drop 	obs
				
				export	 excel using "$descriptives\Table A5.xls",  sheetmodify cell(A12)
				erase 	"$descriptives\Table_block2.xlsx"
		}
			

		**
		**block 3
		*-----------------------------------------------------------------------------------------------------------------*
		{
			*Semester in which teachers used the teaching material, % of the textbook covered
			*-----------------------------------------------------------------------------------------------------------------*
				
				**
				*Teacher Data
				*-------------------------------------------------------------------------------------------------------------*
				use 	"$dtinter/Teacher's data.dta", clear				//Teacher's dataset to have one teacher observation per row
				rename (prof1_rp_* prof2_rp_* prof3_rp_*) (prof_rp_*_1 prof_rp_*_2 prof_rp_*_3)
				rename (teacher*_key cd_disciplina_prof*) (teacher_key_* cd_disciplina_prof_*)  
				keep 	prof_* teacher_* cd_disciplina* cd_turma
				reshape long teacher_key_ cd_disciplina_prof_  prof_rp_01_ prof_rp_02_ prof_rp_03_ prof_rp_04_ ///
						 prof_rp_05_ prof_rp_06_ prof_rp_07_ prof_rp_08_ prof_rp_09_ prof_rp_10_ prof_rp_11_ prof_rp_12_ prof_rp_13_ prof_rp_14_ prof_rp_15_ ///
						 prof_rp_16_ prof_rp_17_ prof_rp_18_ prof_rp_19_ prof_rp_20_ prof_rp_21_ prof_rp_22_ prof_rp_23_ prof_rp_24_ prof_rp_25_ prof_rp_26_ ///
						 prof_rp_27_ prof_rp_28_ prof_rp_29_ prof_rp_30_ prof_rp_31_ prof_rp_32_ prof_rp_33_ prof_rp_34_ prof_rp_35_ prof_rp_36_ prof_rp_37_  ///
						 prof_rp_38_ prof_rp_39_ prof_rp_40_ prof_rp_41_ prof_rp_42_ prof_rp_43_ prof_rp_44_ prof_rp_45_ prof_rp_46_ prof_rp_47_ prof_rp_48_  ///
						 prof_rp_49_ prof_rp_50_ prof_rp_51_ prof_rp_52_ prof_rp_53_ prof_rp_54_ prof_rp_55_ prof_rp_56_ prof_rp_57_ prof_rp_58_ prof_rp_59_  ///
						 prof_rp_60_ prof_rp_61_ prof_rp_62_ prof_rp_63_ prof_rp_64_ prof_rp_65_ ///
						 , i(cd_turma) j (prof)
						sort cd_turma prof
						drop if missing(teacher_key_)
						bys cd_turma: gen t = _N		//t is the number of teachers in that classroom
											
						*
						*Keeping only if there is only one teacher in the classroom or if there is more than one teacher but the answer to the question % of the syllabus covered is different than missing.
						keep if (t == 1 ) | (t > 1 & !missing(prof_rp_40_))  //when there is only one teacher in the class or when its more than one teacher keep the one that it is not missing. 
						drop t
						bys  cd_turma: gen t = _N
						keep if (t == 1 ) | (t > 1 & !missing(prof_rp_39_))  
						drop t
						bys     cd_turma: gen t = _N
						sort    cd_turma  prof
						br      cd_turma  prof t prof_rp_40_  prof_rp_39_ 
						gsort   cd_turma 	   - prof_rp_40_ -prof_rp_39_
						egen    cd_turmatag = tag(cd_turma)
						keep if cd_turmatag == 1 //keeping only one teacher per class
						drop t  cd_turmatag
						
				tempfile prof
				save 	`prof'

				
				**
				**Student Data
				*-------------------------------------------------------------------------------------------------------------*
				use  	"$dtfinal/Fin_Lit_pooled_data_clean.dta",clear 	//organized at classroom level
				
				**
				*Imperfect complience
				preserve
					merge 	m:1 		cd_turma 		using `prof' , keep(1 3) nogen
					bys resultado: tab socio_rp_61 prof_rp_40_ if cd_etapa_aplicacao_turma != 3, mis
				restore
				
				**
				*Merging teacher data with classroom information
				egen 	tag_turma = tag(cd_turma)
				keep if tag_turma == 1 
				keep 	cd_estado cd_municipio cd_localizacao_escola cd_escola cd_turma cd_etapa_aplicacao_turma estrato strata421 strata422 strata423 strata131 strata132 strata133 resultado 
				merge 	1:1 		cd_turma 		using `prof' , keep(1 3) nogen

				**
				*Semester in which they used the material
				gen     semester=1 if (prof_rp_39_==1 | prof_rp_39_==2 | prof_rp_39_==3) 	
				replace semester=2 if (prof_rp_39_==4 | prof_rp_39_==5 | prof_rp_39_==6) 	
				replace semester=3 if (prof_rp_39_==7) 										
				tab	 	semester, gen (d_semester)
			
				**
				*Percentage of syllabus covered
				tab prof_rp_40_, gen (d_content)
				foreach var of varlist d_semester* d_content* {
					replace `var' = 100 if `var' == 1
				}
				
				**
				**Statistics
				keep if resultado == 1
				*-----------------------------------------------------------------------------------------------------------------*
				sumstats (d_semester1  d_semester2  d_semester3 d_content1 d_content2 d_content3 d_content4 if cd_etapa_aplicacao_turma == 3) ///
						 (d_semester1  d_semester2  d_semester3 d_content1 d_content2 d_content3 d_content4 if cd_etapa_aplicacao_turma == 5) ///
						 (d_semester1  d_semester2  d_semester3 d_content1 d_content2 d_content3 d_content4 if cd_etapa_aplicacao_turma == 7) ///
						 (d_semester1  d_semester2  d_semester3 d_content1 d_content2 d_content3 d_content4 if cd_etapa_aplicacao_turma == 9) ///
				using "$descriptives/Table_block3.xlsx", stats(N mean sd) replace
				
						
				**
				**Organizing
				*-----------------------------------------------------------------------------------------------------------------*
					import 		excel "$descriptives\Table_block3.xlsx", allstring clear
					drop 		in 1
					destring, 	replace
					gen 		obs = _n
					mkmat 		B C D if inrange(obs,2,8  ), matrix(A1)
					mkmat 		B C D if inrange(obs,11,17), matrix(A2)
					mkmat 		B C D if inrange(obs,20,26), matrix(A3)
					mkmat 		B C D if inrange(obs,29,35), matrix(A4)
					matrix T = (A1 , A2,  A3, A4)
					clear 
					svmat T
					set obs 11
					tostring *, replace force
					gen 	dec = "Only in 1st semester" in 1
					replace dec = "Only in 2nd semester" in 2
					replace dec = "All year" in 3
					replace dec = "Less than 40%" in 4
					replace dec = "Between 40% and 60%" in 5
					replace dec = "Between 60% and 80%" in 6
					replace dec = "More than 80%" in 7
					order dec
					foreach var of varlist T1 T4 T7 T10 {
						replace `var' = ""
					}
					replace dec = "% of classes by the semester in which the teachers used the financial literacy textbooks" in 8
					replace dec = "% of classes by the percentage of the financial literacy textbook covered by the teachers" in 10
					gen 	order = 1 in 8
					replace order = 2 in 9
					replace order = 3 in 1
					replace order = 4 in 2
					replace order = 5 in 3
					replace order = 6 in 10
					replace order = 7 in 11
					replace order = 8 in 4
					replace order = 9  in 5
					replace order = 10 in 6
					replace order = 11 in 7
					
					
					sort order
					foreach var in T2 T5 T8 T11 {
						replace `var' = "Mean" in 2
						replace `var' = "Mean" in 7
						replace `var' = substr(`var',1, 4) if `var' != "Mean"
					}
					foreach var in T3 T6 T9 T12 {
						replace `var' = "SD" in 2
						replace `var' = "SD" in 7
						replace `var' = substr(`var',1, 4) if `var' != "Mean"& `var' != "SD"
					}
					drop order T1
					export	 excel using "$descriptives\Table A5.xls",  sheetmodify cell(A19)	
					erase 	"$descriptives\Table_block3.xlsx"
		}
	}
	

	**
	*Table A6
	*---------------------------------------------------------------------------------------------------------------------*	
	{	//teachers

			foreach grade in 3 5 7 9 {
				
			use  "$dtinter/Teacher's data_long.dta",replace 

			keep if teacher_key_!= . 

			local variables teacher_male teacher_age1 teacher_age2 teacher_age3 teacher_white d_teacher_expe1 d_teacher_expe2 d_teacher_expe3  wage_2 wage_3 wage_4 wage_5
			
			estimates clear

				foreach var of local variables {
					replace `var' = `var'*100 if cd_etapa_aplicacao_turma == `grade'
				}
				
				label var teacher_male  		"Gender: male"
				label var teacher_age1			"Age: less than 35 yers"
				label var teacher_age2  		"Age: 36 to 50 yers"
				label var teacher_age3 			"Age: older than 51 years"
				label var teacher_white 		"Color: white"
				label var d_teacher_expe1 		"Experience: up to 5 years"
				label var d_teacher_expe2 		"Experience: 6 to 15 years"
				label var d_teacher_expe3  		"Experience: more than 16 years"
				label var wage_2 				"Wage: 3 to 4 minimum wages"
				label var wage_3 				"Wage: 4 to 5 minimum wages"
				label var wage_4 				"Wage: 5 to 6 minimum wages"
				label var wage_5				"Wage: more than 6 minimum wages"
				
				**
				*Balance test I
				*-------------------------------------------------------------------------------------------------------------*
				iebaltab `variables' if cd_etapa_aplicacao_turma == `grade', cov($estrato) format(%12.1f)  grpvar(resultado) save("$descriptives/Table6_`grade' grade.xlsx") rowvarlabels replace

				/*
				**
				*Balance test II
				*Regression of the covariates on the treatment dummy adding strata as control and including % of missings in the table
				*-------------------------------------------------------------------------------------------------------------*
				foreach var in `variables' {
					
					count if `var' == . & cd_etapa_aplicacao_turma == `grade' & resultado == 1 
					local miss_trat = r(N)
					
					count if `var' == . & cd_etapa_aplicacao_turma == `grade' & resultado == 0 
					local miss_cont = r(N)
					
					count if 			  cd_etapa_aplicacao_turma == `grade' & resultado == 1 
					local n_trat = r(N)
					
					count if 			  cd_etapa_aplicacao_turma == `grade' & resultado == 0 
					local n_cont = r(N)
					
					reg `var' resultado $estrato if cd_etapa_aplicacao_turma == `grade', coefleg cluster(cd_escola) 
					est store res_`var'
					if `grade' == 3 outreg2 * using "$descriptives/Balance test II for teachers_3grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2) 
					if `grade' == 5 outreg2 * using "$descriptives/Balance test II for teachers_5grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2)
					if `grade' == 7 outreg2 * using "$descriptives/Balance test II for teachers_7grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2)  
					if `grade' == 9 outreg2 * using "$descriptives/Balance test II for teachers_9grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2)
				}
				*/
			
				**
				*Setting up the table
				*-------------------------------------------------------------------------------------------------------------*
					import 		excel "$descriptives\Table6_`grade' grade.xlsx", allstring clear
					replace 	A = A[_n-1] if A == ""
					gen 		obs = _n
					egen 		group = group(A)
					gen 		obs_group = 1
					replace 	obs_group = 2 if group[_n] == group[_n-1]
					expand 		3 if obs_group == 2, gen(REP)
					sort 		obs A REP 
					replace 	C = B[_n-2] if REP == 1
					replace 	E = D[_n-2] if REP == 1
					replace 	C = "C" in 2
					replace 	E = "T" in 2
					replace 	F = "T-C" in 2
					replace 	E = "" in 1 
					replace 	F = "" in 1
					drop 		in 3/6
					gen 	    variable = "Mean" if obs_group == 1 & obs_group[_n-1] == 1
					replace	    variable = "SE"	  if obs_group == 2 & obs_group[_n-1] == 1
					replace	    variable = "OBS"  if obs_group == 2 & obs_group[_n-1] == 2 & obs_group[_n+1] == 2
					drop 		B D obs group obs_group REP
					replace 	A = "" if A[_n] == A[_n-1] | A[_n] == A[_n-2]
					replace 	A = "" if A[_n] == A[_n-1] | A[_n] == A[_n-3]
					order A variable
					if `grade' > 3 drop A 	variable		
					if `grade' == 3 replace C = "Third-grade"   in 1
					if `grade' == 5 replace C = "Fifth-grade"   in 1
					if `grade' == 7 replace C = "Seventh-grade" in 1
					if `grade' == 9 replace C = "Ninth-grade"   in 1
					if `grade' == 3		export	 excel using "$descriptives\Table A6.xls",  replace
					if `grade' == 5 	export	 excel using "$descriptives\Table A6.xls",  sheetmodify cell(F1)	
					if `grade' == 7 	export	 excel using "$descriptives\Table A6.xls",  sheetmodify cell(I1)	
					if `grade' == 9 	export	 excel using "$descriptives\Table A6.xls",  sheetmodify cell(L1)	
					erase "$descriptives\Table6_`grade' grade.xlsx"
			}
		}	

		
	**
	*Table A7
	*---------------------------------------------------------------------------------------------------------------------*	
	{	//students

			foreach grade in 3 5 7 9 {
				
				use  "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

				estimates clear

				if `grade' == 3 local variables hh_paved_street hh_electri hh_piped_water hh_garb_col bolsa_fam adequate_age resp_educ_1   resp_educ_2   resp_educ_3  
				
				if `grade' != 3 local variables hh_paved_street hh_electri hh_piped_water hh_garb_col bolsa_fam adequate_age mother_educ_1 mother_educ_2 mother_educ_3 gender color_white
				
				foreach var of local variables {
					replace `var' = `var'*100 if cd_etapa_avaliada_turma == `grade'
				}
				
				**
				*Balance test I
				*-------------------------------------------------------------------------------------------------------------*
				iebaltab `variables' if cd_etapa_avaliada_turma == `grade',  cov(estrato)  format(%12.1f)   grpvar(resultado) save("$descriptives/Table7_`grade' grade.xlsx") rowvarlabels replace
			
				/*
				**
				*Balance test II
				*Regression of the covariates on the treatment dummy adding strata as control and including % of missings in the table
				*-------------------------------------------------------------------------------------------------------------*
				foreach var in `variables' {
					
					count if `var' == . & cd_etapa_avaliada_turma == `grade' & resultado == 1 & (fl_socio_blank==0 | fl_blank_parent==0) 
					local miss_trat = r(N) 	//missing observations among treated students

					count if `var' == . & cd_etapa_avaliada_turma == `grade' & resultado == 0 & (fl_socio_blank==0 | fl_blank_parent==0)
					local miss_cont = r(N)	//missing observations among control
					
					count if 			  cd_etapa_avaliada_turma == `grade' & resultado == 1 & (fl_socio_blank==0 | fl_blank_parent==0)   
					local n_trat = r(N)		//total oftreated observations 
					
					count if 			  cd_etapa_avaliada_turma == `grade' & resultado == 0 & (fl_socio_blank==0 | fl_blank_parent==0) 
					local n_cont = r(N)		//total of control observations
					
					reg `var' resultado $estrato if cd_etapa_avaliada_turma == `grade' & (fl_socio_blank==0 | fl_blank_parent==0), coefleg 		  cluster(cd_escola) 
					est store res_`var'
					
					if `grade' == 3 outreg2 * using "$descriptives/Balance test II for students_3grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2) 
					if `grade' == 5 outreg2 * using "$descriptives/Balance test II for students_5grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2)
					if `grade' == 7 outreg2 * using "$descriptives/Balance test II for students_7grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2)  
					if `grade' == 9 outreg2 * using "$descriptives/Balance test II for students_9grade.xls", append label addstat("Missing tratados", `miss_trat'			, "Missing controles",`miss_cont', "Number treat", `n_trat', "Number control", `n_cont') bdec(2) sdec(2)
				}
				*/

				
				**
				*Setting up the table
				*-------------------------------------------------------------------------------------------------------------*
					import 		excel "$descriptives\Table7_`grade' grade.xlsx", allstring clear
					replace 	A = A[_n-1] if A == ""
					gen 		obs = _n
					egen 		group = group(A)
					gen 		obs_group = 1
					replace 	obs_group = 2 if group[_n] == group[_n-1]
					expand 		3 if obs_group == 2, gen(REP)
					sort 		obs A REP 
					replace 	C = B[_n-2] if REP == 1
					replace 	E = D[_n-2] if REP == 1
					replace 	C = "C" in 2
					replace 	E = "T" in 2
					replace 	F = "T-C" in 2
					replace 	E = "" in 1 
					replace 	F = "" in 1
					drop 		in 3/6
					gen 	    variable = "Mean" if obs_group == 1 & obs_group[_n-1] == 1
					replace	    variable = "SE"	  if obs_group == 2 & obs_group[_n-1] == 1
					replace	    variable = "OBS"  if obs_group == 2 & obs_group[_n-1] == 2 & obs_group[_n+1] == 2
					drop 		B D obs group obs_group REP
					replace 	A = "" if A[_n] == A[_n-1] | A[_n] == A[_n-2]
					replace 	A = "" if A[_n] == A[_n-1] | A[_n] == A[_n-3]
					order A variable
					if `grade' > 3 drop A 	variable		
					if `grade' == 3 replace C = "Third-grade"   in 1
					if `grade' == 5 replace C = "Fifth-grade"   in 1
					if `grade' == 7 replace C = "Seventh-grade" in 1
					if `grade' == 9 replace C = "Ninth-grade"   in 1
					if `grade' == 3		export	 excel using "$descriptives\Table A7.xls",  replace
					if `grade' == 5 	export	 excel using "$descriptives\Table A7.xls",  sheetmodify cell(F1)	
					if `grade' == 7 	export	 excel using "$descriptives\Table A7.xls",  sheetmodify cell(I1)	
					if `grade' == 9 	export	 excel using "$descriptives\Table A7.xls",  sheetmodify cell(L1)	
					erase "$descriptives\Table7_`grade' grade.xlsx"

			}
		}
		
		
	**
	**Table A10
	*---------------------------------------------------------------------------------------------------------------------*
	{
		use "$dtinter/Treatment and Control Groups.dta", clear
		
		**
		*Schools in Joinville
		*-----------------------------------------------------------------------------------------------------------------*
		estimates clear
		foreach var in  DSU_F14 DSU_F58 TDI_F03 TDI_F05 TDI_F07 TDI_F09 			///
		TA_F07_2009 TA_F09_2009 TA_F07_2011 TA_F09_2011 TA_F07_2013 TA_F09_2013 	///
		TA_F03_2009 TA_F05_2009 TA_F03_2011 TA_F05_2011 TA_F03_2013 TA_F05_2013 	///
		MAT_F09_2009 LP_F09_2009 MAT_F09_2011 LP_F09_2011 MAT_F09_2013 LP_F09_2013  ///
		MAT_F05_2009 LP_F05_2009 MAT_F05_2011 LP_F05_2011 MAT_F05_2013 LP_F05_2013 	///
		IDEB_F09_2009 IDEB_F09_2011 IDEB_F09_2013 									///
		IDEB_F05_2009 IDEB_F05_2011 IDEB_F05_2013 {
			eststo: reg `var' resultado $estrato if  group!=. & munic == 42 ,  vce(cluster group)  
		}	
		global regressions*
		outreg2 [$regressions] using "$descriptives/Balance test for schools_Joinville.xls", nor nocons tstat  dec(2) noparen replace
		
		**
		*Schools in Manaus
		*-----------------------------------------------------------------------------------------------------------------*
		estimates clear
		foreach var in  DSU_F14 DSU_F58 TDI_F03 TDI_F05 TDI_F07 TDI_F09 			///
		TA_F07_2009 TA_F09_2009 TA_F07_2011 TA_F09_2011 TA_F07_2013 TA_F09_2013 	///
		TA_F03_2009 TA_F05_2009 TA_F03_2011 TA_F05_2011 TA_F03_2013 TA_F05_2013 	///
		MAT_F09_2009 LP_F09_2009 MAT_F09_2011 LP_F09_2011 MAT_F09_2013 LP_F09_2013 	///
		MAT_F05_2009 LP_F05_2009 MAT_F05_2011 LP_F05_2011 MAT_F05_2013 LP_F05_2013 	///
		IDEB_F09_2009 IDEB_F09_2011 IDEB_F09_2013 									///
		IDEB_F05_2009 IDEB_F05_2011 IDEB_F05_2013 {
			eststo: reg `var' resultado $estrato if  group!=. & munic == 13,   vce(cluster group)  
		}	
		global regressions*
		outreg2 [$regressions] using "$descriptives/Balance test for schools_Manaus.xls", nor nocons tstat  noparen  dec(2) replace
	
		/*
		**
		*Overall
		*-----------------------------------------------------------------------------------------------------------------*
		estimates clear
		foreach var in  DSU_F14 DSU_F58 TDI_F03 TDI_F05 TDI_F07 TDI_F09 ///
		TA_F07_2009 TA_F09_2009 TA_F07_2011 TA_F09_2011 TA_F07_2013 TA_F09_2013 ///
		TA_F03_2009 TA_F05_2009 TA_F03_2011 TA_F05_2011 TA_F03_2013 TA_F05_2013 ///
		MAT_F09_2009 LP_F09_2009 MAT_F09_2011 LP_F09_2011 MAT_F09_2013 LP_F09_2013 ///
		MAT_F05_2009 LP_F05_2009 MAT_F05_2011 LP_F05_2011 MAT_F05_2013 LP_F05_2013 ///
		IDEB_F09_2009 IDEB_F09_2011 IDEB_F09_2013 ///
		IDEB_F05_2009 IDEB_F05_2011 IDEB_F05_2013 {
			 eststo: reg `var' resultado $estrato if  group!=.,   vce(cluster group)  
		}	
		global regressions*
		outreg2  [$regressions]  using "$descriptives/Balance test for schools_Overall.xls", nor nocons tstat  noparen replace
		*/
		
		**
		*Organizing
		*-----------------------------------------------------------------------------------------------------------------*
		import  	delimited "$descriptives/Balance test for schools_Joinville.txt", clear  
		gen 		obs = _n
		keep		 if obs == 5 | obs == 26
			
		drop v1 obs
		sxpose, clear force
		
		gen 	dec = "% teachers in 1st to 5th grade with undergrad" in 1 
		replace dec = "% teachers in 6th to 9th grade with undergrad" in 2
		replace dec = "Age grade distortion 3rd grade (2013)" in 3
		replace dec = "Age grade distortion 5th grade (2013)" in 4
		replace dec = "Age grade distortion 7th grade (2013)" in 5
		replace dec = "Age grade distortion 9th grade (2013)" in 6
		replace dec = "Grade-promotion 7th grade (2009)" in 7
		replace dec = "Grade-promotion 9th grade (2009)" in 8
		replace dec = "Grade-promotion 7th grade (2011)" in 9
		replace dec = "Grade-promotion 9th grade (2011)" in 10
		replace dec = "Grade-promotion 7th grade (2013)" in 11
		replace dec = "Grade-promotion 9th grade (2013)" in 12
		replace dec = "Grade-promotion 3rd grade (2009)" in 13
		replace dec = "Grade-promotion 5th grade (2009)" in 14
		replace dec = "Grade-promotion 3rd grade (2011)" in 15
		replace dec = "Grade-promotion 5th grade (2011)" in 16
		replace dec = "Grade-promotion 3rd grade (2013)" in 17
		replace dec = "Grade-promotion 5th grade (2013)" in 18
		replace dec = "Math performance 9th grade (2009)" in 19
		replace dec = "Reading performance 9th grade (2009)" in 20
		replace dec = "Math performance 9th grade (2011)" in 21
		replace dec = "Reading performance 9th grade (2011)" in 22
		replace dec = "Math performance 9th grade (2013)" in 23
		replace dec = "Reading performance 9th grade (2013)" in 24
		replace dec = "Math performance 5th grade (2009)" in 25
		replace dec = "Reading performance 5th grade (2009)" in 26
		replace dec = "Math performance 5th grade (2011)" in 27
		replace dec = "Reading performance 5th grade (2011)" in 28
		replace dec = "Math performance 5th grade (2013)" in 29
		replace dec = "Reading performance 5th grade (2013)" in 30
		replace dec = "IDEB 9th grade (2009)" in 31
		replace dec = "IDEB 9th grade (2011)" in 32
		replace dec = "IDEB 9th grade (2013)" in 33
		replace dec = "IDEB 5th grade (2009)" in 34
		replace dec = "IDEB 5th grade (2011)" in 35
		replace dec = "IDEB 5th grade (2013)" in 36
		order 	dec
		set 	obs 38
		replace _var1 = "Joinville" in 37
		replace _var1 = "Beta" in 38
		replace _var2 = "Obs" in 38
		gen 	order = 1 in 37
		replace order = 2 in 38
		local i = 1
		forvalues order = 3(1)38 {
			replace order = `order' in `i'
			local i = `i' + 1
		}
		
		
		sort	order
		drop 	order
		export	excel using "$descriptives\Table A10.xls",  replace
		import  delimited   "$descriptives/Balance test for schools_Manaus.txt", clear  
		gen 	obs = _n
		keep 	if obs == 5 | obs == 26
		drop 	v1 obs
		sxpose, clear force
		set 	obs 38
		replace _var1 = "Manaus" in 37
		replace _var1 = "Beta" in 38
		replace _var2 = "Obs" in 38
		gen 	order = 1 in 37
		replace order = 2 in 38
		local i = 1
		forvalues order = 3(1)38 {
			replace order = `order' in `i'
			local i = `i' + 1
		}
		
		sort 	order
		drop 	order
		export	 excel using "$descriptives\Table A10.xls",  sheetmodify cell(D1)
		erase "$descriptives/Balance test for schools_Joinville.txt"
		erase "$descriptives/Balance test for schools_Manaus.txt"
		erase "$descriptives/Balance test for schools_Manaus.xls"
		erase "$descriptives/Balance test for schools_Joinville.xls"
	}
		
			
	**
	**Table A11
	*---------------------------------------------------------------------------------------------------------------------*
	{
		set seed 1257866
		foreach grade in 3 5 7 9 {
			use  "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
				estimates clear
				if `grade' == 3 local variables hh_paved_street hh_electri hh_piped_water hh_garb_col bolsa_fam adequate_age resp_educ_1   resp_educ_2   resp_educ_3  
				if `grade' != 3 local variables hh_paved_street hh_electri hh_piped_water hh_garb_col bolsa_fam adequate_age mother_educ_1 mother_educ_2 mother_educ_3 gender color_white
				
				foreach var of local variables {
					replace `var' = `var'*100 if cd_etapa_avaliada_turma == `grade'
				}

				*Regression of the percentage of missings 
				*-------------------------------------------------------------------------------------------------------------*
				foreach var in `variables' {
					gen 	miss_`var' = 1 if  missing(`var') & cd_etapa_avaliada_turma == `grade' 
					replace miss_`var' = 0 if !missing(`var') & cd_etapa_avaliada_turma == `grade'
					eststo:  reg  miss_`var' resultado $estrato if cd_etapa_avaliada_turma == `grade', cluster(cd_escola) 
				}
				global regressions*
				outreg2  [$regressions]  using "$descriptives/missing`grade'.xls", nor nocons tstat  noparen  dec(2) replace	
		}
				

		**
		*Organizing
		*-----------------------------------------------------------------------------------------------------------------*
		import  	delimited "$descriptives/missing3.txt", clear  
		gen 		obs = _n
		keep		 if obs == 5 | obs == 20
			
		drop v1 obs
		sxpose, clear force
		set obs 13
		
		
		
		gen 	dec = "Access to paved street" in 1 
		replace dec = "Access to electricity" in 2
		replace dec = "Access to piped water" in 3
		replace dec = "Access to garbage collection" in 4
		replace dec = "Beneficiary of Bolsa Família" in 5
		replace dec = "Adequate age for their grade " in 6
		replace dec = "Mother education: incomplete elementary school" in 7
		replace dec = "Mother education: incomplete high school" in 8
		replace dec = "Mother education: at least high school degree" in 9

		//
		replace _var1 = "Third-grade" in 10
		replace _var1 = "Beta" in 11
		replace _var2 = "Obs" in 11
		gen 	order = 1 in 10
		replace order = 2 in 11
		local i = 1
		forvalues order = 3(1)11 {
			replace order = `order' in `i'
			local i = `i' + 1
		}
		
		sort	order
		drop 	order
		order dec 
		set obs 13
		replace dec = "Gender: male"  in 12
		replace dec = "Color:  white" in 13
		export	excel using "$descriptives\Table A11.xls",  replace
		
		//
		import  delimited    "$descriptives/missing5.txt", clear  
		gen 	obs = _n
		keep		 if obs == 5 | obs == 20
		drop 	v1 obs
		sxpose, clear force
		set obs 13
		replace _var1 = "Fifth-grade" in 12
		replace _var1 = "Beta" in 13
		replace _var2 = "Obs" in 13
		gen 	order = 1 in 12
		replace order = 2 in 13
		local i = 1
		forvalues order = 3(1)13 {
			replace order = `order' in `i'
			local i = `i' + 1
		}
		sort order
		drop order
		export	 excel using "$descriptives\Table A11.xls",  sheetmodify cell(D1)
		
		//
		import  delimited    "$descriptives/missing7.txt", clear  
		gen 	obs = _n
		keep		 if obs == 5 | obs == 20
		drop 	v1 obs
		sxpose, clear force
		set obs 13
		replace _var1 = "Seventh-grade" in 12
		replace _var1 = "Beta" in 13
		replace _var2 = "Obs" in 13
		gen 	order = 1 in 12
		replace order = 2 in 13
		local i = 1
		forvalues order = 3(1)13 {
			replace order = `order' in `i'
			local i = `i' + 1
		}
		sort order	
		drop order
		export	 excel using "$descriptives\Table A11.xls",  sheetmodify cell(F1)
		
		//
		import  delimited    "$descriptives/missing9.txt", clear  
		gen 	obs = _n
		keep		 if obs == 5 | obs == 20
		drop 	v1 obs
		sxpose, clear force
		set obs 13
		replace _var1 = "Ninth-grade" in 12
		replace _var1 = "Beta" in 13
		replace _var2 = "Obs" in 13
		gen 	order = 1 in 12
		replace order = 2 in 13
		local i = 1
		forvalues order = 3(1)13 {
			replace order = `order' in `i'
			local i = `i' + 1
		}
		sort order	
		drop order
		export	 excel using "$descriptives\Table A11.xls",  sheetmodify cell(H1)

		foreach grade in 3  5 7 9 {
			erase "$descriptives/missing`grade'.txt"
			erase "$descriptives/missing`grade'.xls"		
		}
	}
	
	
	**
	**Table A12 ok
	*---------------------------------------------------------------------------------------------------------------------*
	//testando conjuntamente se as medias entre os grupos de T e C sao iguais. no iebaltab, testamos uma variavel de cada vez
	{
		use  "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
				
			mvtest means	 hh_paved_street hh_electri hh_piped_water hh_garb_col bolsa_fam adequate_age resp_educ_1   resp_educ_2    					  if  cd_etapa_avaliada_turma == 3		, by(resultado)
			matrix a3 		= r(stat_m)
				
			foreach grade in 5 7 9 {
			mvtest means 	 hh_paved_street hh_electri hh_piped_water hh_garb_col bolsa_fam adequate_age mother_educ_1 mother_educ_2  gender color_white if  cd_etapa_avaliada_turma == `grade', by(resultado)
			matrix a`grade' = r(stat_m)
			}
			clear
				
			matrix  B = a3\a5\a7\a9
			svmat   B
			replace B6 = 3 in 1/4
			replace B6 = 5 in 5/8
			replace B6 = 7 in 9/12
			replace B6 = 9 in 13/16
			
			gen teste = ""
			foreach row in 1 5 9 13{
			replace teste = "Wilks" in `row'
			}
				
			foreach row in 2 6 10 14{
			replace teste = "Pillai" in `row'
			}	
				
			foreach row in 3 7 11 15{
			replace teste = "Lawley" in `row'
			}	
				
			foreach row in 4 8 12 16{
			replace teste = "Roy" in `row'
			}		
				
			tostring *, replace force

			foreach var of varlist B1 B2 B5 {
				replace `var' = substr(`var',1,4)
			}
	
			set obs 17
			replace teste = "Test" in 17
			replace B1 = "Statistic" in 17
			replace B2 = "F" in 17
			replace B3 = "df1" in 17
			replace B4 = "df2" in 17
			replace B5 = "pvalue" in 17
			gen order = 1 in 17
			sort order B6 teste
			replace B6 = "Third-grade" in 2/5
			replace B6 = "Fifth-grade" in 6/9
			replace B6 = "Seventh-grade" in 10/13
			replace B6 = "Ninth-grade" in 14/17
			order B6 teste
			drop order
			export	 excel using "$descriptives\Table A12.xls",  replace
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
	/*
	**
	*Imperfect complience
	*---------------------------------------------------------------------------------------------------------------------*


























































/*
*Other descriptives
*-------------------------------------------------------------------------------------------------------------------------

*Contaminação*
*-------------------------------------------------------------------------------------------------------------------------
/* 
Turmas das escolas de controle que acabaram recebendo tratamento e as turmas das escolas de tratamento que aparentemente não receberam*/

use 	"$dtfinal/Teacher's data.dta", clear								//32 turmas que estão com missing no código da escola
keep 	 cd_turma cd_escola prof1_rp_38 prof1_rp_39 prof1_rp_40 			//respostas do professor 1 
destring cd_escola, replace
merge 	 m:1 cd_escola using "$dtfinal/Treatment and Comparison Groups.dta", keep(match master) nogen

*Perguntas que não deveriam ter sido respondidas por professores das escolas do grupo de controle
codebook cd_escola if prof1_rp_39 >= 1 & prof1_rp_39 <= 8 & resultado == 0
codebook cd_escola if prof1_rp_38 >= 1 & prof1_rp_38 <= 8 & resultado == 0
codebook cd_escola if prof1_rp_40 >= 1 & prof1_rp_40 <= 8 & resultado == 0

*Professores que responderam todas as questões de aplicação do programa e são das escolas do grupo de controle
gen 	a = 1 					if (prof1_rp_39 >= 1 & prof1_rp_39 <= 8) &  (prof1_rp_38 >= 1 & prof1_rp_38 <= 8) & (prof1_rp_40 >= 1 & prof1_rp_40 <= 8)  & resultado == 0

*Estatísticas para a == 1
codebook cd_turma 	      		if a == 1 												//29 turmas das escolas de controle acabaram participando do programa
gen 	controle_tratado = 1 	if a == 1 				 & resultado == 0				//vamos considerar midada se o professor tiver respondido as três questões acima 
replace controle_tratado = 0 	if controle_tratado != 1 & resultado == 0				//controle_tratado: controle que foi tratado

*Professores que não respondeam as questões de aplicação do programa e são das escolas do grupo de tratamento
gen 	b = 1 					if (prof1_rp_39 == .a ) &  (prof1_rp_38== .a ) & (prof1_rp_40 == .a )  & resultado == 1

*Estatísticas para b = 1
codebook cd_turma 	      		if b == 1 												//9 turmas das escolas tratadas que aparentemente não receberam o tratamento
gen 	trat_sem_trat = 1 		if b == 1 				& resultado == 1				//vamos considerar contamidada se o professor não tiver respondido as três questões acima 
replace trat_sem_trat = 0 		if trat_sem_trat != 1   & resultado == 1				//trat_sem_trat: tratado sem tratamento

*Relação de alunos contaminados
keep 	cd_turma cd_escola controle_tratado trat_sem_trat resultado
save	"$dtinter/Control classes with treatment.dta", replace

*Se a escola de controle tem uma turma que foi tratada, vamos considerá-la como contaminada
sort 	 cd_escola cd_turma
collapse (mean)controle_tratado trat_sem_trat resultado, by (cd_escola)			
replace  controle_tratado = 1 if controle_tratado > 0 & controle_tratado != . 
replace  trat_sem_trat    = 1 if trat_sem_trat    > 0 & trat_sem_trat    != . 

*Relação de escolas contaminadas
save 	"$dtinter/Control schools with treatment.dta", replace

*1*
*Estatísticas descritivas das escolas do grupo de controle contaminado versus do grupo de controle não contaminado
*-------------------------------------------------------------------------------------------------------------------------
use 	"$dtinter/Control schools with treatment.dta", clear
merge 	 1:1 cd_escola using "$dtinter/School characteristics.dta", keep(match master) nogen

*Labels
label var  WaterAccess   	"Access to piped water"
label var  EnergyAccess 	"Access to electricity"
label var  SewerAccess  	"Access do basic sanitation"
label var  Computer  		"School with computer"
label var  SportCourt  		"School with sport court"
label var  FilteredWater  	"School with filtered water"
label var  WasteCollection  "School with garbage collection"
label var  WasteRecycling   "School with recycling"
label var  ComputerLab   	"School with computer lab"
label var  ScienceLab   	"School with science lab"
label var  Library   		"School with library"
label var  ReadingRoom 		"School with reading room"

tabform  $infraestrutura using "$descriptives/Descriptive of control schools versus control treated.xls", by(controle_tratado) vertical nototal mtest bdec(3) level(95)

*2*
*Estatísticas descritivas das crianças de escolas contamidas com relação às crianças do grupo de controle que não foram contaminadas
*-------------------------------------------------------------------------------------------------------------------------
use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

merge m:1 cd_turma using "$dtinter/Control classes with treatment.dta", nogen //vamos assumir que as turmas que estão listadas em Fin_Lit_pooled_data_clean.dta, mas que não aparecem na base de professores não foram contaminadas

label var sm 				"Proficiency"
label var pca_consump_sm	"Consumption index"
label var pca_save_sm 		"Saving index"
label var adequate_age 		"Adequate age for their grade"
label var hh_paved_street 	"Access to paved street"
label var hh_electri 		"Access to etrecticity"
label var hh_piped_water 	"Access to piped water"
label var hh_garb_col 		"Access to garbage collection"
label var bolsa_fam 		"Beneficiary of Bolsa Família"
label var resp_age_1 		"Age: less than 20 years"
label var resp_age_2 		"Age: 21 to 59 years"
label var resp_age_3 		"Age: more than 60 years"
label var resp_educ_1 		"Education: incomplete elementary school"
label var resp_educ_2 		"Education: incomplete high school"
label var resp_educ_3 		"Education: at least high school degreee"
label var resp_occup_1 		"Occupation: formal labor market"
label var resp_occup_2 		"Occupation: informal labor market"
label var resp_occup_3 		"Occupation: unemployed"
label var gender 		    "Gender: male"
label var color_white 		"Color: white"
label var mother_educ_1 	"Mother education: incomplete elementary school"
label var mother_educ_2 	"Mother education: incomplete high school"
label var mother_educ_3 	"Mother education: at least high school degreee"

tabform  $student using "$descriptives/Descriptive of control students versus control students treated.xls", by(controle_tratado) vertical nototal mtest bdec (3) level(95)

tab socio_rp_61 if controle_tratado == 1  
tab socio_rp_61 if trat_sem_trat == 1
*_________________________________________________________________________________________________________________________*



*Proficiency in Math and Portuguese - before and after treatment*
*-------------------------------------------------------------------------------------------------------------------------
use 	"$dtfinal/Treatment and Comparison Groups.dta", clear
keep  	cd_escola munic resultado LP_* MAT_* IDEB_* strata*
order 	cd_escola munic resultado LP_* MAT_* IDEB_* strata*
reshape long LP_F05_ LP_F09_ MAT_F05_ MAT_F09_ IDEB_F05_ IDEB_F09_, i(cd_escola munic resultado) j(ano)
merge 1:1 cd_escola ano using "$dtinter/Enrollment by school_2007-2017.dta", keep(match master)

*Performance by grade
foreach grade in 5 9 { 
	preserve
		collapse (mean)IDEB_F0`grade '_  LP_F0`grade '_ MAT_F0`grade '_ [pw = Enrollment`grade 'Grade], by(resultado ano)
		tempfile a`grade '
		save `a`grade ''
	restore
}

*Merging
use `a5', clear
merge 1:1 resultado ano using `a9', nogen
 
foreach subject in IDEB LP MAT {
	foreach grade in 5 9 {
		if "`subject'" == "IDEB" local title  = "IDEB"
		if "`subject'" == "LP"   local title  = "Desempenho em Português"
		if "`subject'" == "MAT"  local title  = "Desempenho em Matemática"
		if `grade' 	   == 5 	   local stitle = "5o ano do EF"
		if `grade'     == 9	   local stitle = "9o ano do EF"

		tw 	///
		(line `subject'_F0`grade'_ ano if resultado == 0, xline(2015) lwidth(0.5) lp(shortdash) ///  
		///
		connect(direct) recast(connected) ml(`subject'_F0`grade'_) mlabcolor(gs2) ///
		///
		msize(1.5) ms(o) mlabposition(12) color(gs12) mlabsize(2.5)) ///
		///
		(line `subject'_F0`grade'_ ano if resultado == 1, lwidth(0.5) lp(shortdash) saving(`subject'_F0`grade', replace) ///  
		///
		connect(direct) recast(connected) ml(`subject'_F0`grade'_) mlabcolor(gs2) ///
		///
		msize(1.5) ms(o) mlabposition(12) color(ebblue) mlabsize(2.5) ///
		///
		ylabel(, labsize(small) gmax angle(horizontal) format(%12.0fc)) ///
		///
		ytitle("", size(medsmall)) ///
		///
		xtitle("",) ///
		///
		xlabel(2007(2)2017, labsize(small)) ///
		///
		title("`title'", pos(12) size(medsmall) color(black)) ///
		///
		subtitle("`stitle'", pos(12) size(medsmall) color(black)) ///
		///
		graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
		///
		plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
		///
		legend(order(1 "Controle" 2 "Tratamento") region(lwidth(none)) cols(2) size(medsmall) position(6)) ///
		///
		ysize(5) xsize(7) ///
		///
		note("", color(black) fcolor(background) pos(7) size(small)))
	}
}

graph combine LP_F05.gph MAT_F05.gph IDEB_F05.gph, holes(4) imargin(0 0 0 0)
graph export  "$figures/Trends for treatment and comparison groups_5th grade.emf", replace
graph combine LP_F09.gph MAT_F09.gph IDEB_F09.gph, holes(4) imargin(0 0 0 0)
graph export  "$figures/Trends for treatment and comparison groups_9th grade.emf", replace
erase IDEB_F05.gph 
erase LP_F05.gph 
erase MAT_F05.gph
erase IDEB_F09.gph 
erase LP_F09.gph 
erase MAT_F09.gph 
*_________________________________________________________________________________________________________________________*



*The number of classrooms in teacher's dataset is different from the number of student's dataset
*----------------------------------------------------------------------------------------------------------------------------
*Classrooms in teacher's dataset
use 	"$dtfinal/Teacher's data.dta", clear								//32 turmas que estão com missing no código da escola
keep 	 cd_turma 
tempfile a
save 	`a'

*Classrooms in student's dataset
use 	"$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
keep 	cd_turma
duplicates drop
merge 	1:1 cd_turma using `a' 												//tem 34 turmas aqui que não estão na base de professores e essas turmas representam cerca de 900 alunos
*____________________________________________________________________________________________________________________________




*% of school classrooms included in treatment and comparison groups -> a school can have 10 classrooms, but only 5 in the program
*----------------------------------------------------------------------------------------------------------------------------

*Número de turmas das escolas de Joinville e Manaus
use 	"$dtinter/Classrooms in Manaus and Joinville_2015.dta", clear
collapse (sum) TClass3Grade TClass5Grade TClass7Grade TClass9Grade, by (cd_escola)
tempfile turmas
save    `turmas'

*Turmas das escolas dos grupos de tratamento e comparação
use 		"$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
keep 	 	cd_turma cd_etapa_aplicacao_turma cd_escola
duplicates  drop
gen 		id = 1

*Number of classrooms per school
collapse 	(sum) id, by (cd_etapa_aplicacao_turma cd_escola)
reshape 	wide id, i(cd_escola) j(cd_etapa_aplicacao_turma) 
merge 		1:1 cd_escola using `turmas', nogen keep(match master)

foreach i in 3 5 7 9{
	gen p_`i' =id`i'/TClass`i'Grade 
}

drop 		if cd_escola == .
merge 		1:1 cd_escola using "$dtfinal/Treatment and Comparison Groups.dta", keepusing(resultado) keep(match master) nogen
collapse 	(mean)p_*, by(resultado)
reshape 	long p_, i(resultado) j(etapa)
reshape 	wide p_, i(etapa) j(resultado)

graph bar (asis)p_0 p_1, graphregion(color(white)) bar(1, color(gs12))  bar(2, color(ebblue))   ///
///
over(etapa, sort(etapa) label(labsize(small))) ///
///
legend(order(1 "Controle" 2 "Tratamento") cols(2) size(medsmall)  region(lwidth(none))) ///
///
graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
///
plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
///
blabel(bar, position(inside) orientation(horizontal) size(vsmall)  color(black) format (%12.2fc))   ///
///
title("Proporção de turmas nos grupos de tratamento e compararação por escola", pos(12) size(medsmall) color(black)) ///
///
subtitle(, pos(12) size(medsmall) color(black)) ///
///
ylabel(, labsize(small) gmax angle(horizontal) format (%12.2fc) ) ///
///
ytitle ("%", size(medsmall)) /// 
///
ysize(5) xsize(7) ///
///
note("" , color(black) fcolor(background) pos(7) size(small))
graph export "$figures/% of treated classrooms by school.emf", as(emf) replace		
*____________________________________________________________________________________________________________________________


erase "$dtinter/Control classes with treatment.dta"
erase "$dtinter/Control schools with treatment.dta"
