    *____________________________________________________________________________________________________________________________________*

                                                      *PROGRAM IMPLEMENTATION*

                                               *Financial Literacy Pilot in Brazil*
    *____________________________________________________________________________________________________________________________________*
	
	
	*Percentage of classes with a teacher assigned to it
	*------------------------------------------------------------------------------------------------------------------------------------*
		use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
			keep    cd_turma cd_escola d $estrato teacher1_key teacher2_key teacher3_key
			duplicates drop
			isid    cd_turma                                    //uma linha por turma do estudo
			gen 	no_teacher = 100*(missing(teacher1_key) & missing(teacher2_key) & missing(teacher3_key))
			tab d no_teacher, row
			reg no_teacher d $estrato, cluster(cd_escola)
			
	
	*Percentage of treated classes with 1, 2 or 3 teachers in charge of the financial literacy pilot 
	*------------------------------------------------------------------------------------------------------------------------------------*
		use "$dtinter/Teacher's data_long.dta", clear
		merge m:1 cd_escola using "$dtinter/Treatment and Control Groups.dta", keep(match master) nogen

			*One row per teacher-class slot -> teachers in charge of the content per class = rows per cd_turma
			bys  cd_turma: gen n_teachers = _N
			egen class_tag = tag(cd_turma)

			di as red "Distribution of treated classes by number of teachers in charge of the content:"
			tab n_teachers if class_tag == 1 & resultado == 1

			*Grade composition of the treated classes with more than one teacher (codes checked in the tab below)
			di as red "Grade of multi-teacher treated classes:"
			tab cd_etapa_aplicacao_turma if class_tag == 1 & resultado == 1 & n_teachers > 1, missing

			count if class_tag == 1 & resultado == 1 & n_teachers > 1
			local n = r(N)
			count if class_tag == 1 & resultado == 1 & n_teachers > 1 & (cd_etapa_aplicacao_turma == 7 | cd_etapa_aplicacao_turma == 9)
			local k = r(N)
			di as red "Share of multi-teacher treated classes in the 7th or 9th grade: " ///
			   as res %4.1f 100*`k'/`n' "%  (`k'/`n')"			   
		
	*Subject of the teachers in charge of the financial literacy content -- shares over TEACHERS, not classes.
	*   The data do not rank the teachers of a class, so any "leading teacher" rule would be arbitrary in the
	*   classes with two or three of them; stacking the teachers avoids the choice altogether.
	*   The long file has one row per teacher-class slot and every slot reports a subject.
	*------------------------------------------------------------------------------------------------------------------------------------*
		use "$dtinter/Teacher's data_long.dta", clear
		merge m:1 cd_escola using "$dtinter/Treatment and Control Groups.dta", keep(match master) nogen

			assert 	!missing(cd_disciplina_prof_)

			*One row per teacher, so the tabulations below count teachers and not teacher-class slots
			isid 	teacher_key_

			di as red "Teachers in charge of the content in treated classes, by grade:"
			tab cd_etapa_aplicacao_turma if resultado == 1

			foreach g in 3 5 {
				di as red "Grade `g', treated classes: subject of the teachers in charge"
				tab cd_disciplina_prof_ if resultado == 1 & cd_etapa_aplicacao_turma == `g'
			}

			di as red "Middle school (grades 7 and 9), treated classes: subject of the teachers in charge"
			tab cd_disciplina_prof_ if resultado == 1 & (cd_etapa_aplicacao_turma == 7 | cd_etapa_aplicacao_turma == 9)


	*Treated schools with at least one teacher who reports not having been trained to use the textbook (T20)
	*   The denominator is the 101 treated schools of the design, not the ones with a questionnaire, so the merge
	*   below keeps the treated schools where no teacher answered as well
	*------------------------------------------------------------------------------------------------------------------------------------*
		use "$dtinter/Teacher's data_long.dta", clear
			gen 	 byte no_training = prof_rp_20_ == 2
			collapse (max) no_training, by(cd_escola)

			merge 1:1 cd_escola using "$dtinter/Treatment and Control Groups.dta", keepusing(resultado) nogen
			keep if  resultado == 1

			di as red "Treated schools:"
			count
			di as red "of which have no teacher answering the questionnaire:"
			count if missing(no_training)
			di as red "of which have at least one teacher reporting no training:"
			count if no_training == 1


	*Behavioural outcomes: control mean and the ITT effect as a share of it, the percentages quoted in Section 5
	*   Same specification and samples as Table 4 (grades 5, 7 and 9; column 2 is the fifth grade alone), so the
	*   coefficients printed here must match the ones in Output/Tables/Table4.tex
	*------------------------------------------------------------------------------------------------------------------------------------*
		use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

			foreach var of varlist talk_parents talk_friends pigg finan_serv allowance2 {
				forvalues c = 1/3 {
					local cond   "if serie > 3"
					local sample "Pooled"
					if `c' == 2 {
						local cond   "if serie == 5"
						local sample "Elementary (5th grade)"
					}
					if `c' == 3 {
						local cond   "if serie > 5"
						local sample "Middle school"
					}

					quietly reg `var' d $estrato `cond', cluster(cd_escola)
					local b  = _b[d]
					local p  = 2*ttail(e(df_r), abs(_b[d]/_se[d]))

					quietly su `var' `cond' & d == 0
					local cm = r(mean)

					di as red %-14s "`var'" as txt %-24s "`sample'" ///
					   as txt " control mean " as res %5.3f `cm' ///
					   as txt "  ITT " as res %6.3f `b' ///
					   as txt " ("  as res %5.3f `p' as txt ")" ///
					   as txt "  = " as res %5.1f 100*`b'/`cm' as txt "% of the control mean"
				}
			}


	*Do the classes whose teachers report delivering the content overlap with the classes whose students report
	*having had it? Restricted to grades 5, 7 and 9, the ones that answered the socioeconomic questionnaire (SE60)
	*------------------------------------------------------------------------------------------------------------------------------------*
		use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
			keep if serie > 3

			*Teacher side: the class has teacher information, and at least one of its teachers reports having taught
			*at least one class (T38 is only answered by teachers who taught the content)
			egen 	 t38            = rowmax(prof1_rp_38 prof2_rp_38 prof3_rp_38)
			gen byte teacher_info   = !missing(teacher1_key) | !missing(teacher2_key) | !missing(teacher3_key)
			gen byte teacher_taught = !missing(t38)

			*Student side: SE60 is missing for the students who left it blank, so (count) below counts respondents
			*and the share is computed among them; a class where nobody answered ends with p missing, not zero
			gen byte student_yes    = socio_rp_60 == 2 if inlist(socio_rp_60, 1, 2)
			gen byte one            = 1

			**
			*Student level: the two reports side by side, in the units of the implementation table
			foreach arm in 1 0 {
				local group = cond(`arm' == 1, "treated", "control")
				di as red "`group' students who report having had classes, by what their teacher reports:"
				tab teacher_taught student_yes if d == `arm' & teacher_info == 1, row
			}

			**
			*Class level
			collapse (sum)   yes      = student_yes  ///
					 (count) answered = student_yes  ///
					 (sum)   students = one, by(cd_turma d teacher_info teacher_taught)

			gen  p = 100*yes/answered                                          //share of the class that reports having had classes

			di as red "Control classes with teacher information:"
			count if d == 0 & teacher_info == 1
			di as red "of which have a teacher reporting the content:"
			count if d == 0 & teacher_info == 1 & teacher_taught == 1
			di as red "of which have half or more of their students reporting it:"
			count if d == 0 & teacher_info == 1 & p >= 50 & !missing(p)
			di as red "of which have both:"
			count if d == 0 & teacher_info == 1 & teacher_taught == 1 & p >= 50 & !missing(p)
			
			
			
			
			
			
			
			
			
			
			