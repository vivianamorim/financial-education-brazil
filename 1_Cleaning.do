                     
														*CLEANING*
														
										   *Financial Literacy Pilot in Brazil*
	*-------------------------------------------------------------------------------------------------------------------------*	
	*Creating variables needed for descriptives and regressions
	
	
	*Preparing dataset for analysis
	*-------------------------------------------------------------------------------------------------------------------------*	
	use  "$dtinter\Fin_Lit_pooled_data.dta", replace 

		**
		*5th to 9th grade, socioeconomic questionnarie answered by the students
		*----------------------------------------------------------------------------------------------------------------------*	
		{
			*Age
			 gen     age=8  if socio_rp_01 == 1  &  fl_socio_blank == 0
			 replace age=9  if socio_rp_01 == 2  &  fl_socio_blank == 0
			 replace age=10 if socio_rp_01 == 3  &  fl_socio_blank == 0
			 replace age=11 if socio_rp_01 == 4  &  fl_socio_blank == 0
			 replace age=12 if socio_rp_01 == 5  &  fl_socio_blank == 0
			 replace age=13 if socio_rp_01 == 6  &  fl_socio_blank == 0
			 replace age=14 if socio_rp_01 == 7  &  fl_socio_blank == 0
			 replace age=15 if socio_rp_01 == 8  &  fl_socio_blank == 0
			 replace age=16 if socio_rp_01 == 9  &  fl_socio_blank == 0
			 replace age=17 if socio_rp_01 == 10 &  fl_socio_blank == 0

			*Adequate age
			gen     adequate_age	=    (socio_rp_01  < cd_etapa_aplicacao_turma )  													if fl_socio_blank == 0 
			replace adequate_age	=. if socio_rp_01  == .a | socio_rp_01  == .b | socio_rp_01  == .

			
			*Gender
			gen     gender			=	 (socio_rp_03 == 1)     																		if fl_socio_blank == 0         
			replace gender			=. if socio_rp_03 == .a | socio_rp_03 == .b | socio_rp_03 == .

			*Student's color
			gen     color_white		=	 (socio_rp_04 == 1  | socio_rp_04 == 4)  														if fl_socio_blank == 0
			replace color_white		=. if socio_rp_04 == .a | socio_rp_04 == .b | socio_rp_04 == .

			*Mother education
			gen     mother_educ_1	=	 (socio_rp_05 == 1  | socio_rp_05 == 2) 														if fl_socio_blank == 0
			replace mother_educ_1	=. if socio_rp_05 == 6  | socio_rp_05 == .b | socio_rp_05 == . | socio_rp_05 == .a

			gen     mother_educ_2	=	 (socio_rp_05 == 3) 																			if fl_socio_blank == 0
			replace mother_educ_2	=. if socio_rp_05 == 6  | socio_rp_05 == .b | socio_rp_05 == . | socio_rp_05 == .a

			gen     mother_educ_3	=	 (socio_rp_05 == 4  | socio_rp_05 == 5) 														if fl_socio_blank == 0
			replace mother_educ_3	=. if socio_rp_05 == 6  | socio_rp_05 == .b | socio_rp_05 == . | socio_rp_05 == .a

			*Paved street
			gen     hh_paved_street	=    (socio_rp_07 == 1) 																			if fl_socio_blank == 0
			replace hh_paved_street	=. if socio_rp_07 == .a | socio_rp_07 == .b | socio_rp_07 == .

			*Electricity
			gen     hh_electri 		=	 (socio_rp_08 == 1) 																			if fl_socio_blank == 0
			replace hh_electri 		=. if socio_rp_08 == .a | socio_rp_08 == .b | socio_rp_08 == .

			*Piped water
			gen     hh_piped_water 	=    (socio_rp_09 == 1) 																			if fl_socio_blank == 0
			replace hh_piped_water 	=. if socio_rp_09 == .a | socio_rp_09 == .b | socio_rp_09 == . 

			*Garbage collection
			gen     hh_garb_col 	=	 (socio_rp_10 == 1) 																			if fl_socio_blank == 0
			replace hh_garb_col 	=. if socio_rp_10 == .a | socio_rp_10 == .b | socio_rp_10 == .

			*Bolsa familia
			gen     bolsa_fam 		=	 (socio_rp_11 == 1) 																			if fl_socio_blank == 0
			replace bolsa_fam 		=. if socio_rp_11 == .a | socio_rp_11 == .b  | socio_rp_11 == . 
		}
		
		
		**
		*3rd grade, socioeconomic questionnaire answered by legal guardians
		*----------------------------------------------------------------------------------------------------------------------*	
		{
			*Idade do reponsavel pela crianca
			gen 	resp_age_1		=    (resp_rp_04 == 1) 																				if fl_blank_parent == 0
			replace resp_age_1		=. if resp_rp_04 == .a | resp_rp_04 == .b | resp_rp_04 == .

			gen     resp_age_2		=    (resp_rp_04 == 2  | resp_rp_04 == 3  | resp_rp_04 == 4) 										if fl_blank_parent == 0
			replace resp_age_2		=. if resp_rp_04 == .a | resp_rp_04 == .b | resp_rp_04 == .

			gen 	resp_age_3		=    (resp_rp_04 == 5) 																				if fl_blank_parent == 0
			replace resp_age_3		=. if resp_rp_04 == .a | resp_rp_04 == .b | resp_rp_04 == .

			*Age
			replace age				=7  if resp_rp_26 == 1 & fl_blank_parent == 0
			replace age				=8  if resp_rp_26 == 2 & fl_blank_parent == 0
			replace age				=9  if resp_rp_26 == 3 & fl_blank_parent == 0
			replace age				=10 if resp_rp_26 == 4 & fl_blank_parent == 0
			replace age				=11 if resp_rp_26 == 5 & fl_blank_parent == 0
			replace age				=12 if resp_rp_26 == 6 & fl_blank_parent == 0
			 
			*Adequate age
			replace adequate_age	=     (resp_rp_26 <= cd_etapa_aplicacao_turma )  		    										if fl_blank_parent == 0
			replace adequate_age	=. if (resp_rp_26 == .a | resp_rp_26 == .b | resp_rp_26 == .)  										 & fl_blank_parent == 0
			
			*Resp Gender
			gen     resp_gender		=    (resp_rp_03 == 1) 																				if fl_blank_parent == 0
			replace resp_gender		=. if resp_rp_03 == .a | resp_rp_03 == .b | resp_rp_03 == .

			*Resp Educ
			gen     resp_educ_1		=    (resp_rp_06 == 1  	| resp_rp_06 == 2) 															if fl_blank_parent == 0
			replace resp_educ_1		=. if resp_rp_06 == .a 	| resp_rp_06 == .b | resp_rp_06 == .
			
			gen     resp_educ_2		=    (resp_rp_06 == 3)																				if fl_blank_parent == 0
			replace resp_educ_2		=. if resp_rp_06 == .a 	| resp_rp_06 == .b | resp_rp_06 == .
			
			gen     resp_educ_3		=    (resp_rp_06 == 4  	| resp_rp_06 == 5  | resp_rp_06 == 6) 										if fl_blank_parent == 0
			replace resp_educ_3		=. if resp_rp_06 == .a 	| resp_rp_06 == .b | resp_rp_06 == .
			
			*Occupation
			gen     resp_occup_1	=	 (resp_rp_07 == 1) 																				if fl_blank_parent == 0
			replace resp_occup_1	=. if resp_rp_07 == .a 	| resp_rp_07 == .b | resp_rp_07 == .	

			gen     resp_occup_2	=	 (resp_rp_07 == 2  	| resp_rp_07 == 3| resp_rp_07 == 4 ) 										if fl_blank_parent == 0
			replace resp_occup_2	=. if resp_rp_07 == .a 	| resp_rp_07 == .b | resp_rp_07 == .
			
			gen     resp_occup_3	=	 (resp_rp_07 == 7) 																				if fl_blank_parent == 0
			replace resp_occup_3	=. if resp_rp_07 == .a 	| resp_rp_07 == .b | resp_rp_07 == .

			*Paved street
			replace hh_paved_street	=	  (resp_rp_08 == 1) 																			if fl_blank_parent == 0
			replace hh_paved_street	=. if (resp_rp_08 == .a	| resp_rp_08 == .b | resp_rp_08 == .) 										 & fl_blank_parent == 0

			*Electricity
			replace hh_electri		=	  (resp_rp_09 == 1)      																		if fl_blank_parent == 0
			replace hh_electri 		=. if (resp_rp_09 == .a | resp_rp_09 == .b | resp_rp_09 == .)  										 & fl_blank_parent == 0
			
			*Piped water
			replace hh_piped_water	=	  (resp_rp_10 == 1)  																			if fl_blank_parent == 0
			replace hh_piped_water 	=. if (resp_rp_10 == .a | resp_rp_10 == .b | resp_rp_10 == .) 										 & fl_blank_parent == 0
			
			*Garbage collection
			replace hh_garb_col		=	  (resp_rp_11 == 1)     																		if fl_blank_parent == 0
			replace hh_garb_col 	=. if (resp_rp_11 == .a | resp_rp_11 == .b | resp_rp_11 == .)  	 									 & fl_blank_parent == 0

			*Bolsa familia
			replace bolsa_fam		=	  (resp_rp_12 == 1)     																		if fl_blank_parent == 0
			replace bolsa_fam 		=. if (resp_rp_12 == .a | resp_rp_12 == .b | resp_rp_12 == .)   									 & fl_blank_parent == 0
	}
		
		
		**
		*Other variables
		*----------------------------------------------------------------------------------------------------------------------*	
		{	
			**
			*Treatment status
			clonevar d     = resultado 
			
			**
			*Grade
			clonevar serie = cd_etapa_aplicacao_turma

			**
			*Financial Proficiency, in standard deviation
			/*
			egen sd 	 	= sd(vl_proficiencia)
			egen mean	 	= mean(vl_proficiencia)
			gen sm 			= (vl_proficiencia-mean)/sd
			*/
			
			foreach cd_etapa_aplicacao_turma in 3 5 7 9 {
				su vl_proficiencia if cd_etapa_aplicacao_turma == `cd_etapa_aplicacao_turma', detail
					if `cd_etapa_aplicacao_turma' == 3 gen     sm = (vl_proficiencia - r(mean))/r(sd) if cd_etapa_aplicacao_turma == `cd_etapa_aplicacao_turma'
					if `cd_etapa_aplicacao_turma' != 3 replace sm = (vl_proficiencia - r(mean))/r(sd) if cd_etapa_aplicacao_turma == `cd_etapa_aplicacao_turma'
			}  
			
			egen 	covered_textbook = rowmax (prof1_rp_40 prof2_rp_40  prof3_rp_40)
			sort d   cd_escola cd_turma 
			br      cd_escola cd_turma d prof1_rp_40  prof2_rp_40  prof3_rp_40 covered_textbook

			
			**
			*Implementação
			gen 	t1 = 1 			if  covered_textbook < 3 & d == 1  								// até 60% do conteúdo coberto 
			replace t1 = 0 			if  d  ==  0

			gen 	t2 = 1 			if  covered_textbook > 2 & d == 1 & !missing(covered_textbook) 			// mais de 60% do conteúdo coberto
			replace t2 = 0 			if  d  ==  0
			
			replace t1 = 0 if t2 == 1 & d == 1
			replace t2 = 0 if t1 == 1 & d == 1

			**
			*Mesada
			gen     allowance	=1 	if socio_rp_25 == 1
			replace allowance	=0 	if socio_rp_25 == 2 | socio_rp_25 == 3 | socio_rp_25 == 4 
			gen     allowance2	=1 	if socio_rp_25 == 1 | socio_rp_25 == 2
			replace allowance2	=0 	if socio_rp_25 == 3 | socio_rp_25 == 4 

			**
			*Earns
			gen     earns		=1 	if socio_rp_26 == 1 | socio_rp_26 == 2 
			replace earns		=0 	if socio_rp_26 == 3 | socio_rp_26 == 4 

			**
			*Money_gift
			gen     money_gift	=1 	if socio_rp_27 == 1 | socio_rp_27 == 2 
			replace money_gift	=0 	if socio_rp_27 == 3 | socio_rp_27 == 4 

			**
			*Talk with parents
			gen     talk_parents=1 	if socio_rp_28 == 1 | socio_rp_30 == 1
			replace talk_parents=0 	if socio_rp_28 == 2 & socio_rp_30 == 2

			**
			*Talk with friends
			gen     talk_friends=1 	if socio_rp_31 == 1 
			replace talk_friends=0 	if socio_rp_31 == 2

			*Pigg
			gen     pigg		=1	if  socio_rp_32 == 1 |  resp_rp_59 == 1
			replace pigg		=0 	if (socio_rp_32 == 2 | socio_rp_32 == 3 | resp_rp_59 == 2 | resp_rp_59 == 3)

			*Financial services
			gen     bank_acount	=1 	if  socio_rp_33 == 1 |  resp_rp_55 == 1
			replace bank_acount	=0 	if (socio_rp_33 == 2 | socio_rp_33 == 3 | resp_rp_55 == 2 | resp_rp_55 == 3)

			gen     credit_card	=1 	if  socio_rp_34 == 1 |  resp_rp_57 == 1
			replace credit_card	=0 	if (socio_rp_34 == 2 | socio_rp_34 == 3 | resp_rp_57 == 2 | resp_rp_57 == 3)

			gen     debit_card	=1  if  socio_rp_35 == 1 |  resp_rp_58 == 1
			replace debit_card	=0  if (socio_rp_35 == 2 | socio_rp_35 == 3 | resp_rp_58 == 2 | resp_rp_58 == 3)

			gen	    finan_serv	=1  if  bank_acount == 1 | credit_card == 1 | debit_card == 1
			replace finan_serv	=0  if  bank_acount == 0 & credit_card == 0 & debit_card == 0
	}
	
		
		**
		*Consumption index
		*----------------------------------------------------------------------------------------------------------------------*	
		{
			putexcel set "$descriptives/PCA.xlsx", sheet(pca_consumption) replace
			gen     index_q42=socio_rp_42
			gen     index_q43=socio_rp_43
			gen     index_q44=socio_rp_44
			gen     index_q45=socio_rp_45
			foreach i in 46 {
				gen     index_q`i'=.
				replace index_q`i'=1 			if socio_rp_`i' == 4
				replace index_q`i'=2 			if socio_rp_`i' == 3
				replace index_q`i'=3 			if socio_rp_`i' == 2
				replace index_q`i'=4 			if socio_rp_`i' == 1
			}
			gen    	 	index_q47			=socio_rp_47
			gen     	index_q48			=socio_rp_48
			egen    	consump_sum		 	= rowtotal(index_q42 index_q43 index_q44 index_q45 index_q46 index_q47 index_q48)
			gen     	consump_index	 	= consump_sum/7
			replace 	consump_index	 	=. if consump_sum == 0
			recode  	consump_sum 0	 	=.
			sum 		consump_index
			gen 		consump_index_sm 	= (consump_index-`r(mean)')/`r(sd)'
			pca 		index_q42 index_q43 index_q44 index_q45 index_q46 index_q47 index_q48 //principal component analysis
			predict 	pca_consump
			matrix  	pca_consump_valor 	= e(L)
			matrix list pca_consump_valor
			putexcel  	B2				  	= matrix(pca_consump_valor)
			sum 		pca_consump
			gen 		pca_consump_sm	  	= (pca_consump-`r(mean)')/`r(sd)'
		}	

	
		**
		*Savings index
		*----------------------------------------------------------------------------------------------------------------------*	
		{
			putexcel set "$descriptives/PCA.xlsx", sheet(pca_savings) modify 
			foreach i in 52 53 54 56 57 58 {
				gen     index_q`i'=.
				replace index_q`i'=1 				if socio_rp_`i' == 4
				replace index_q`i'=2 				if socio_rp_`i' == 3
				replace index_q`i'=3 				if socio_rp_`i' == 2
				replace index_q`i'=4 				if socio_rp_`i' == 1
			}
			gen     	index_q55=socio_rp_55
			gen     	index_q59=socio_rp_59
			egen    	save_sum   		= rowtotal(index_q52 index_q53 index_q54 index_q55 index_q56 index_q57 index_q58 index_q59)
			gen     	save_index 		= save_sum/7
			replace 	save_index 		=. 			if save_sum == 0
			recode  	save_sum 0 		=.
			sum 		save_index
			gen 		save_index_sm 	= (save_index-`r(mean)')/`r(sd)'	
			pca 		index_q52 index_q53 index_q54 index_q55 index_q56 index_q57 index_q58 index_q59
			predict 	pca_save
			matrix 		pca_save_valor	= e(L)
			matrix list pca_save_valor
			putexcel  	B2				= matrix(pca_save_valor)
			sum 		pca_save
			gen 		pca_save_sm		= (pca_save-`r(mean)')/`r(sd)'
		}
		
	
		**
		*Risk aversion and self-control
		*----------------------------------------------------------------------------------------------------------------------*	
		{
		foreach question in 42 44 45 46 47 52 53 55 59 {
			if `question' != 52 & `question' != 53 gen 		selfcontrol_`question' 	=			socio_rp_`question' == 1 | socio_rp_`question' == 2  //totally agree
			if `question' != 52 & `question' != 53 replace  selfcontrol_`question' 	= . 	 if socio_rp_`question' == .
			
			if `question' == 52 | `question' == 53 gen 		riskaversion_`question' = 			socio_rp_`question' == 1 | socio_rp_`question' == 2 //totally agree
			if `question' == 52 | `question' == 53 replace  riskaversion_`question'	= . 	 if socio_rp_`question' == .  //totally agree
		}
		
		foreach cd_etapa_avaliada_turma in  5 7 9 				{
			foreach question in 42 43 45 46 47 55 59 52 53 	   54 56 58	{
				su socio_rp_`question'											if cd_etapa_avaliada_turma == `cd_etapa_avaliada_turma', detail
				if `cd_etapa_avaliada_turma' == 5  gen  	 z_`question' = (socio_rp_`question'- r(mean))/r(sd)	if cd_etapa_avaliada_turma == `cd_etapa_avaliada_turma'
				if `cd_etapa_avaliada_turma' != 5  replace 	 z_`question' = (socio_rp_`question'- r(mean))/r(sd)	if cd_etapa_avaliada_turma == `cd_etapa_avaliada_turma'
			} 
		}
				
		egen self_control 		= rowmean(socio_rp_42 socio_rp_43 socio_rp_45 socio_rp_46 socio_rp_47 socio_rp_55 socio_rp_59)
		egen risk_aversion2   	= rowmean(socio_rp_52 socio_rp_53 socio_rp_54 socio_rp_56 socio_rp_58 )
		
		egen z_self_control   	= rowmean(z_42 	z_43 z_45 z_46 z_47 z_55 z_59) 
		egen z_risk_aversion1 	= rowmean(z_52 z_53           			  ) 
		egen z_risk_aversion2 	= rowmean(z_52 z_53           z_54 z_56 z_58) 
		}
		
		
		**
		*IV
		*----------------------------------------------------------------------------------------------------------------------*	
		{
		tab socio_rp_61 d, mis
		tab prof1_rp_40 d, mis		
		gen treated   = d == 1  				 											 //grupo de tratamento original  

			
		**
		*Treated student regardless of the treatment status
		
		gen teacher_covered_textbook 	= 1 if !missing(covered_textbook)

		
		**
		*Students without a teacher assigned to its class (error or because the teacher did not answer the questionnarie)
		count 								if missing(teacher1_key) & missing(teacher2_key) & missing(teacher3_key)	
		gen student_no_assigned_teacher =  	   missing(teacher1_key) & missing(teacher2_key) & missing(teacher3_key)
		

		**
		*Student without a teacher assigned but that say he/she received the textbooks
		*Lets consider treated if at least 50% of the students in that class said they received the textbook
		gen student_textbook 			= 1 if student_no_assigned_teacher == 1 & socio_rp_61 < 4 
		
		bys cd_escola cd_turma: egen n_students_book = sum(student_textbook)					//number of students in that class with a book
		gen id = 1
		
		bys cd_escola cd_turma: egen alunos_turma    = sum(id)
		
		gen 	turma_treated = 1 if (n_students_book/alunos_turma) > 0.5 & (n_students_book/alunos_turma)!= .  
		
		replace turma_treated = 1 if teacher_covered_textbook == 1
		
		sort  d cd_escola cd_turma 
		br      cd_escola cd_turma  d student_no_assigned_teacher teacher_covered_textbook ///
		student_textbook n_students_book alunos_turma turma_treated		if d == 1 & turma_treated == 1 & student_no_assigned_teacher == 1
			
		*egen test = rsum(teacher_covered_textbook student_textbook )
		*tab   test //it needs to be equal to 1 or  0
			
		//control student that was treated
		replace treated = 1 if d == 0 & turma_treated == 1
		replace treated = 0 if d == 1 & turma_treated == .
		
		tab treated d
		}
		
		
		**
		*Organizing
		*----------------------------------------------------------------------------------------------------------------------*	
		{	
			order cd_estado-cd_etapa_avaliada_turma sm pca_consump_sm pca_save_sm allowance2 earns talk_parents talk_friends pigg bank_acount credit_card debit_card finan_serv

			**
			*Identificação do estrato
			egen   	estrato = group(strata*)
			
			**
			*Labels
			label var sm 			 	"Financial proficiency score"
			label var pca_consump_sm 	"Consumption score"
			label var pca_save_sm    	"Saving score"
			label var allowance2    	"1 if has mesada and 0 otherwise"
			label var earns			 	"1 if works and 0 otherwise"
			label var adequate_age 		"Adequate age for their grade"
			label var hh_paved_street 	"Access to paved street"
			label var hh_electri 		"Access to etrecticity"
			label var hh_piped_water 	"Access to piped water"
			label var hh_garb_col 		"Access to garbage collection"
			label var bolsa_fam 		"Beneficiary of Bolsa Família"
			label var resp_age_1 		"Age: less than 20 years"
			label var resp_age_2 		"Age: 21 to 59 years"
			label var resp_age_3 		"Age: more than 60 years"
			label var resp_educ_1 		"Mother education/Legal guardian: incomplete elementary school"
			label var resp_educ_2 		"Mother education/Legal guardian: incomplete high school"
			label var resp_educ_3 		"Mother education/Legal guardian: at least high school degreee"
			label var resp_occup_1 		"Occupation: formal labor market"
			label var resp_occup_2 		"Occupation: informal labor market"
			label var resp_occup_3 		"Occupation: unemployed"
			label var gender 		    "Gender: male"
			label var color_white 		"Color: white"
			label var mother_educ_1 	"Mother education/Legal guardian: incomplete elementary school"
			label var mother_educ_2 	"Mother education/Legal guardian: incomplete high school"
			label var mother_educ_3 	"Mother education/Legal guardian: at least high school degreee"
			label var d 				"Treatment"
			label def cd_etapa_avaliada_turma 3 "3{sup:rd}grade" 5 "5{sup:th} grade" 7 "7{sup:th} grade" 9 "9{sup:th} grade" ,replace
			lab   val cd_etapa_avaliada_turma  cd_etapa_avaliada_turma 
		}
		
		
		*Final data
		*----------------------------------------------------------------------------------------------------------------------*	
		compress
		erase "$descriptives/PCA.xlsx"
		save  "$dtfinal/Fin_Lit_pooled_data_clean.dta", replace 
		
		/*
		*IDEB
		*----------------------------------------------------------------------------------------------------------------------*	
		use       "$dtinter/Treatment and Control Groups.dta", clear
		
		estimates clear
		
		*Disaggregating the schools according to their IDEB
		su 	      IDEB_F09_2013, detail
		local     mediana_ef2 = r(p50)
		su	      IDEB_F05_2013, detail
		local     mediana_ef1 = r(p50)
		gen       bottom50 = (IDEB_F09_2013 < `mediana_ef2' | IDEB_F05_2013 < `mediana_ef1')
		replace   bottom50 = . if IDEB_F09_2013 == . & IDEB_F05_2013 == .
		
		gen 	  bottom50_ef1 = (IDEB_F05_2013 < `mediana_ef1')
		replace   bottom50_ef1 = . if IDEB_F05_2013 == .
		
		gen 	  bottom50_ef2 = (IDEB_F09_2013 < `mediana_ef2')
		replace   bottom50_ef2 = . if IDEB_F09_2013 == .
		
		tempfile  bottom
		save 	 `bottom'
		*Program & quality of the school
		use 	"$dtfinal/Fin_Lit_pooled_data_clean.dta",replace 
		merge 	m:1 cd_escola using `bottom', nogen keepusing(bottom50* IDEB*) 
		
		save 	"$dtfinal/Fin_Lit_pooled_data_clean.dta", replace 
	
		
		
		
		
		
		
		
		
		
		
		
		
