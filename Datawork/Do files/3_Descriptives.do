    *____________________________________________________________________________________________________________________________________*

															*DESCRIPTIVE STATISTICS*
														
														*Financial Literacy Pilot in Brazil*
    *____________________________________________________________________________________________________________________________________*

	*----------------------------------------------------------------------------------------------------------------------*
	*TABLES AND FIGURES FOR THE PAPER, in the order they appear in it. Each block loads its own
	*data and writes a LaTeX fragment to $textables, which the paper inputs.
	*
	*CONTENTS:
	*  Figure 1   -- Sampling flow chart (numbers as \newcommand macros; layout in Paper/02_pilot.tex)
	*  Table A.1  -- Program implementation according to students and teachers
	*  Table A.3  -- Items used to construct the consumption and savings attitude indices (PCA weights)
	*  Tables A.4 and A.5 -- Balance tests for students and teachers
	*  Table A.6  -- Pre-treatment balance test with administrative data at school level
	*
	*Legacy exploratory blocks (commented out for years) live in archive/3_Descriptives_legacy.do.
	*----------------------------------------------------------------------------------------------------------------------*

	**
	*Figure -- Sampling flow chart: from the school universe to the randomized sample
	*---------------------------------------------------------------------------------------------------------------------*
	{	//Writes every number of the sampling flow chart as a LaTeX \newcommand macro to
		//$textables/Fig_sampling_flow_numbers.tex; the tikzpicture in Paper/02_pilot.tex only reads
		//these macros, so the figure is reproducible. Three sources:
		//  (1) universe: 2015 School Census microdata (municipal schools in activity in Manaus and
		//      Joinville, cycle enrollment flags in_fund_ai/in_fund_af), computed below;
		//  (2) sampling frame by stratum: Table 1 of the pilot's implementation report (World Bank,
		//      August 2016), typed in the locals below;
		//  (3) study, draw and assignment counts: computed from Treatment and Control Groups.dta.
		//The census csv sits outside the public package; when it is missing, the block is skipped
		//and the committed fragment remains the one generated last.
		//
		//The figure replaced the old Table A.1 of the paper. For reference, the report's Table 1
		//("Amostra selecionada para o piloto"), by school type:
		//
		//                              Joinville                   Manaus                        Total
		//                          frame    T    C          frame  drawn    T    C           T     C    all
		//     Only grades 1-5         20   10   10            202     36   18   18          28    28     56
		//     Only grades 6-9          2    1    1             35     28   14   14          15    15     30
		//     Grades 1-9              50   25   25             65     65   33   32          58    57    115
		//     Total                   72   36   36            302    129   65   64         101   100    201
		capture confirm file "$dtraw/CensoEscolar_2015/DADOS/microdados_ed_basica_2015.csv"
		if _rc != 0		display as error "Census microdata not found: sampling flow chart NOT regenerated"
		if _rc == 0 {

			*(1) Universe: municipal schools in activity, by the cycles they offer
			import delimited "$dtraw/CensoEscolar_2015/DADOS/microdados_ed_basica_2015.csv", delim(";") encoding("latin1") clear
			keep 	co_entidade co_municipio tp_dependencia tp_situacao_funcionamento in_fund_ai in_fund_af
			keep if inlist(co_municipio, 1302603, 4209102)								//Manaus and Joinville
			keep if tp_dependencia == 3 & tp_situacao_funcionamento == 1				//municipal network, in activity
			gen byte manaus = co_municipio == 1302603

			foreach m in 0 1 {
				local city = cond(`m' == 1, "m", "j")
				count if manaus == `m' & in_fund_ai == 1 & in_fund_af != 1
				local `city'_ai   = r(N)
				count if manaus == `m' & in_fund_ai != 1 & in_fund_af == 1
				local `city'_af   = r(N)
				count if manaus == `m' & in_fund_ai == 1 & in_fund_af == 1
				local `city'_both = r(N)
				local `city'_uni  = ``city'_ai' + ``city'_af' + ``city'_both'
			}
			assert `j_uni' == 83 & `m_uni' == 369										//the census counts quoted in the paper

			*(2) Sampling frame by stratum, from the implementation report
			local fr_a1  20
			local fr_a2  2
			local fr_a3  50
			local fr_b1  202
			local fr_b2  35
			local fr_b3  65
			local fr_j   = `fr_a1' + `fr_a2' + `fr_a3'
			local fr_m   = `fr_b1' + `fr_b2' + `fr_b3'
			local excl_j = `j_uni' - `fr_j'
			local excl_m = `m_uni' - `fr_m'

			*(3) Study, draw and assignment counts, from the randomization file
			use "$dtinter/Treatment and Control Groups.dta", clear
			count
			local study   = r(N)
			count if munic == 42
			local study_j = r(N)
			count if munic == 13
			local study_m = r(N)
			count if resultado == 1
			local treat   = r(N)
			count if resultado == 0
			local control = r(N)
			foreach s in 421 422 423 131 132 133 {
				count if group == `s'
				local st_`s' = r(N)
			}
			forvalues q = 1/4 {															//equal allocation across the 2013 IDEB quartiles
				quietly count if group == 131 & pc_IDEB_F05_2013 == `q'
				assert r(N) == `st_131'/4
				quietly count if group == 132 & pc_IDEB_F09_2013 == `q'
				assert r(N) == `st_132'/4
			}
			local perq_b1 = `st_131'/4
			local perq_b2 = `st_132'/4
			local nd_b1   = `fr_b1' - `st_131'
			local nd_b2   = `fr_b2' - `st_132'
			local notdrawn = `nd_b1' + `nd_b2'

			*Every tier of the funnel has to close before anything is written
			assert `st_421' == `fr_a1' & `st_422' == `fr_a2' & `st_423' == `fr_a3'		//Joinville enters in full
			assert `st_133' == `fr_b3'													//so does stratum B.3
			assert `study_j' == `fr_j'
			assert `study_m' == `st_131' + `st_132' + `st_133'
			assert `study'   == `study_j' + `study_m'
			assert `treat' + `control' == `study'
			assert `excl_j' >= 0 & `excl_m' >= 0

			file open  fig using "$textables/Fig_sampling_flow_numbers.tex", write replace text
			file write fig "% Generated by Do files/3_Descriptives.do (sampling flow chart block) -- do not edit by hand." _n
			file write fig "% Universe from the 2015 School Census microdata; frame from the implementation report;" _n
			file write fig "% study, draw and assignment counts from Treatment and Control Groups.dta." _n
			file write fig "\newcommand{\FlowUniverse}{`=`j_uni'+`m_uni''}" _n
			file write fig "\newcommand{\FlowUniJ}{`j_uni'}" _n
			file write fig "\newcommand{\FlowUniM}{`m_uni'}" _n
			file write fig "\newcommand{\FlowJAi}{`j_ai'}" _n
			file write fig "\newcommand{\FlowJAf}{`j_af'}" _n
			file write fig "\newcommand{\FlowJBoth}{`j_both'}" _n
			file write fig "\newcommand{\FlowMAi}{`m_ai'}" _n
			file write fig "\newcommand{\FlowMAf}{`m_af'}" _n
			file write fig "\newcommand{\FlowMBoth}{`m_both'}" _n
			file write fig "\newcommand{\FlowExcl}{`=`excl_j'+`excl_m''}" _n
			file write fig "\newcommand{\FlowExclJ}{`excl_j'}" _n
			file write fig "\newcommand{\FlowExclM}{`excl_m'}" _n
			file write fig "\newcommand{\FlowFrameJ}{`fr_j'}" _n
			file write fig "\newcommand{\FlowFrameM}{`fr_m'}" _n
			file write fig "\newcommand{\FlowAOne}{`fr_a1'}" _n
			file write fig "\newcommand{\FlowATwo}{`fr_a2'}" _n
			file write fig "\newcommand{\FlowAThree}{`fr_a3'}" _n
			file write fig "\newcommand{\FlowBOne}{`fr_b1'}" _n
			file write fig "\newcommand{\FlowBTwo}{`fr_b2'}" _n
			file write fig "\newcommand{\FlowBThree}{`fr_b3'}" _n
			file write fig "\newcommand{\FlowDrawBOne}{`st_131'}" _n
			file write fig "\newcommand{\FlowDrawBTwo}{`st_132'}" _n
			file write fig "\newcommand{\FlowQuartBOne}{`perq_b1'}" _n
			file write fig "\newcommand{\FlowQuartBTwo}{`perq_b2'}" _n
			file write fig "\newcommand{\FlowNotDrawn}{`notdrawn'}" _n
			file write fig "\newcommand{\FlowNotDrawnBOne}{`nd_b1'}" _n
			file write fig "\newcommand{\FlowNotDrawnBTwo}{`nd_b2'}" _n
			file write fig "\newcommand{\FlowStudy}{`study'}" _n
			file write fig "\newcommand{\FlowStudyJ}{`study_j'}" _n
			file write fig "\newcommand{\FlowStudyM}{`study_m'}" _n
			file write fig "\newcommand{\FlowTreat}{`treat'}" _n
			file write fig "\newcommand{\FlowControl}{`control'}" _n
			file close fig

			display "SAMPLING_FLOW_DONE"
		}
	}

	**
	*Table A1 -- Program implementation according to students and teachers
	*---------------------------------------------------------------------------------------------------------------------*
	* Panel A: student questionnaire (SE60 fin-lit classes, Yes=2; SE61 when received the book;
	*          SE62 teacher used the book). Students in grades 5/7/9 only (no socio questionnaire
	*          in grade 3): Pooled = 5/7/9, Elementary = 5, Middle = 7/9.
	* Panel B: teacher questionnaire, stacked base, one row per teacher (Yes=1 in every item):
	*          T20 training, T17 teacher book, T18 books distributed, T38 taught >=1 class,
	*          T19 used the student book. Pooled = all, Elementary = grades 3/5, Middle = 7/9.
	* Shares are UNCONDITIONAL (missing kept in the denominator; "Did not answer" rows shown).
	* Diff = control - treatment, the raw gap between the two group means, with stars from a
	* regression on treatment and the strata dummies clustered at the school level.
	* Every cell is computed directly -- group means with summarize, and the difference with the
	* regression above -- replicating what iebaltab produced here before, cell by cell. The
	* three samples of the column groups sit in $pooled, $elementary and $middle, set at the top
	* of each panel. All the LaTeX markup lives inside three small helpers: prow and qrow write
	* the panel and question headers, trow computes and writes one data row (C, T and Diff for
	* the three samples), and orow writes the Observations row of a panel.
	*==========================================================================================*
	{
		*---------- helpers ----------
		cap program drop prow									//panel header, in bold italics
		program define prow
			args title
			local title : subinstr local title "%" "\%", all
			file write tex `"\multicolumn{10}{l}{\textit{\textbf{`title'}}} \\"' _n
		end

		cap program drop qrow									//question header, in italics
		program define qrow
			args title
			local title : subinstr local title "%" "\%", all
			file write tex `"\multicolumn{10}{l}{\textit{`title'}} \\"' _n
		end

		cap program drop trow									//one data row: C, T and Diff per sample
		program define trow
			args var lab
			local lab : subinstr local lab "%" "\%", all
			file write tex `"\quad `lab'"'
			foreach cond in "$pooled" "$elementary" "$middle" {
				qui summ `var' if `cond' & d == 0
				local mc = r(mean)
				qui summ `var' if `cond' & d == 1
				local mt = r(mean)
				qui reg `var' d $estrato if `cond', vce(cluster cd_escola)
				local p  = 2*ttail(e(df_r), abs(_b[d]/_se[d]))
				local st = cond(`p' < .01, "***", cond(`p' < .05, "**", cond(`p' < .1, "*", "")))
				file write tex " & " (strtrim(string(`mc',"%12.1f"))) " & " (strtrim(string(`mt',"%12.1f"))) ///
					" & " (strtrim(string(`mc' - `mt',"%12.1f"))) "`st'"
			}
			file write tex " \\" _n
		end

		cap program drop orow									//Observations row of a panel
		program define orow
			file write tex "\quad Observations"
			foreach cond in "$pooled" "$elementary" "$middle" {
				qui count if `cond' & d == 0
				local nc = r(N)
				qui count if `cond' & d == 1
				file write tex " & " (strtrim(string(`nc',"%9.0fc"))) " & " (strtrim(string(r(N),"%9.0fc"))) " & "
			}
			file write tex " \\" _n
		end

		file open  tex using "$textables/TableA1.tex", write replace
		file write tex "% Generated by Do files/3_Descriptives.do -- data rows only, do not edit by hand." _n
		file write tex "% The shell (caption, headers, notes, source) lives in Paper/Fin_Lit_Paper.tex." _n

		*---------- Panel A: students ----------
		use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
		keep if serie > 3
		global pooled		"serie >  3"
		global elementary	"serie == 5"
		global middle		"serie >  5"

		gen a1  = 100*(socio_rp_60 == 2)                       //had fin-lit classes: Yes (label "no": No=1, Yes=2)
		gen a2  = 100*(socio_rp_60 == 1)                       //                     No
		gen a3  = 100*missing(socio_rp_60)
		gen a4  = 100*(socio_rp_61 == 1)                       //received: beginning of the year
		gen a5  = 100*(socio_rp_61 == 2)                       //          middle of the year
		gen a6  = 100*(socio_rp_61 == 3)                       //          end of the year
		gen a7  = 100*(socio_rp_61 == 4)                       //          haven't received
		gen a8  = 100*missing(socio_rp_61)
		gen a9  = 100*(socio_rp_62 == 3)                       //teacher used the book: received and used
		gen a10 = 100*(socio_rp_62 == 2)                       //                       received but haven't used
		gen a11 = 100*(socio_rp_62 == 1)                       //                       haven't received
		gen a12 = 100*missing(socio_rp_62)

		prow "Panel A. Implementation according to students (% of students)"
		qrow "Did you have financial education classes?"
		trow a1  "Yes"
		trow a2  "No"
		trow a3  "Did not answer"
		qrow "When did you receive the financial education textbook?"
		trow a4  "Beginning of the year"
		trow a5  "By the middle of the year"
		trow a6  "In the end of the year"
		trow a7  "Haven't received"
		trow a8  "Did not answer"
		qrow "Has your teacher used the financial education textbook?"
		trow a9  "Received and used"
		trow a10 "Received but haven't used"
		trow a11 "Haven't received"
		trow a12 "Did not answer"
		orow

		file write tex "\addlinespace" _n

		*---------- Panel B: teachers (one row per teacher) ----------
		use "$dtinter/Teacher's data_long.dta", clear
		merge m:1 cd_escola using "$dtinter/Treatment and Control Groups.dta", keep(match master) nogen
		gen d = resultado
		global pooled		"inlist(cd_etapa_aplicacao_turma, 3, 5, 7, 9)"	//all four pilot grades = every teacher in
		global elementary	"cd_etapa_aplicacao_turma < 7"					//the file (683 rows, all matched in the
		global middle		"cd_etapa_aplicacao_turma > 5"					//merge above, d never missing -- checked)

		gen b1  = 100*(prof_rp_20_ == 1)                       //received training: Yes
		gen b2  = 100*(prof_rp_20_ == 2)                       //                   No
		gen b3  = 100*missing(prof_rp_20_)
		gen b4  = 100*(prof_rp_17_ == 1)                       //received the teacher book
		gen b5  = 100*(prof_rp_17_ == 2)
		gen b6  = 100*missing(prof_rp_17_)
		gen b7  = 100*(prof_rp_18_ == 1)                       //student books distributed
		gen b8  = 100*(prof_rp_18_ == 2)
		gen b9  = 100*missing(prof_rp_18_)
		gen b10 = 100*(prof_rp_19_ == 1)                       //used the student book
		gen b11 = 100*(prof_rp_19_ == 2)
		gen b12 = 100*missing(prof_rp_19_)
		forvalues k = 1/8 {                                    //number of fin-lit classes taught (T38: 8 = top category)
			gen b`=12+`k'' = 100*(prof_rp_38_ == `k')
		}
		gen b21 = 100*missing(prof_rp_38_)
		forvalues k = 1/4 {                                    //share of the textbook covered (T40: <40, 40-60, 60-80, >80)
			gen b`=21+`k'' = 100*(prof_rp_40_ == `k')
		}
		gen b26 = 100*missing(prof_rp_40_)
		gen b27 = 100*inlist(prof_rp_39_, 1, 2, 3)             //when taught (T39): codes 1-3 = beginning of the year
		gen b28 = 100*inlist(prof_rp_39_, 4, 5, 6)             //                   codes 4-6 = end of the year
		gen b29 = 100*(prof_rp_39_ == 7)                       //                   code  7   = all year
		gen b30 = 100*missing(prof_rp_39_)

		prow "Panel B. Implementation according to teachers (% of teachers)"
		qrow "Received training to use the textbook"
		trow b1  "Yes"
		trow b2  "No"
		trow b3  "Did not answer"
		qrow "Received the teacher book"
		trow b4  "Yes"
		trow b5  "No"
		trow b6  "Did not answer"
		qrow "Student books were distributed to the students"
		trow b7  "Yes"
		trow b8  "No"
		trow b9  "Did not answer"
		qrow "Used the student book"
		trow b10 "Yes"
		trow b11 "No"
		trow b12 "Did not answer"
		qrow "Number of financial education classes taught"
		forvalues k = 1/7 {
			trow b`=12+`k'' "`k'"
		}
		trow b20 "8 or more"
		trow b21 "Did not answer"
		qrow "When in the year was the subject taught?"
		trow b27 "First semester"
		trow b28 "Second semester"
		trow b29 "All year"
		trow b30 "Did not answer"
		qrow "Share of the textbook covered"
		trow b22 "Less than 40%"
		trow b23 "40%--60%"
		trow b24 "60%--80%"
		trow b25 "More than 80%"
		trow b26 "Did not answer"
		orow

		file close tex

		display "IMPLEMENTATION_TABLE_DONE"
	}

	**
	*==========================================================================================*
	* Table A.3 -- Items used to construct the consumption and savings attitude indices
	* Reproduces the weights column from the same PCA that 1_Cleaning.do uses to build the two
	* indices: same items, same reversed coding, same sample, so the loadings are identical by
	* construction (we recompute rather than read 1_Cleaning's PCA.xlsx, which OneDrive can
	* drop silently). The statements and the answer-scale coding are fixed questionnaire text
	* and live here; the fragment carries the rows, the shell keeps the headers and notes.
	*==========================================================================================*
	{
		use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

		**
		*The recoded items already live in the clean base (built by 1_Cleaning.do, positively
		*worded statements reversed there), so the same pca call reproduces the same loadings
		pca 	index_q42 index_q43 index_q44 index_q45 index_q46 index_q47 index_q48
		matrix 	L_c = e(L)

		pca 	index_q52 index_q53 index_q54 index_q55 index_q56 index_q57 index_q58 index_q59
		matrix 	L_s = e(L)

		**
		*One row per statement: text, the four scale codes as printed, and the first-component loading
		file open  tex using "$textables/TableA3.tex", write replace
		file write tex "% Generated by Do files/3_Descriptives.do -- data rows only, do not edit by hand." _n
		file write tex "% The shell (caption, headers, notes, source) lives in Paper/Fin_Lit_Paper.tex." _n

		file write tex "\textbf{Consumption questions} &       &       &       &       &  \\" _n
		local c_42 "I buy what I want, then I see how I can pay|1|2|3|4"
		local c_43 "I see no problem in owing money|1|2|3|4"
		local c_44 "If the brand is famous the product is of high quality|1|2|3|4"
		local c_45 "The best product is always the most expensive|1|2|3|4"
		local c_46 "I plan before spending my money|4|3|2|1"
		local c_47 "It is worthless to plan because the money comes from luck|1|2|3|4"
		local c_48 "Buy what I want is more important than planning|1|2|3|4"
		local r = 0
		foreach i in 42 43 44 45 46 47 48 {
			local ++r
			*Statement = text before the first pipe; scale codes = the rest, pipes turned into
			*column separators (plain string functions: gettoken's parse() shifts under version control)
			local p    = strpos("`c_`i''", "|")
			local stmt = substr("`c_`i''", 1, `p' - 1)
			local rest = subinstr(substr("`c_`i''", `p' + 1, .), "|", " & ", .)
			local w : display %4.2f L_c[`r', 1]
			file write tex "`stmt' & `rest' & `w' \\" _n
		}

		file write tex "      &       &       &       &       &  \\" _n
		file write tex "\textbf{Saving questions} &       &       &       &       &  \\" _n
		local s_52 "I think that saving money is important to avoid problems in the future|4|3|2|1"
		local s_53 "I feel safer when I can save some money|4|3|2|1"
		local s_54 "Saving some money is important to avoid debt|4|3|2|1"
		local s_55 "Buying everything I want is more important than putting the money together|1|2|3|4"
		local s_56 "Avoiding waste is also a way to save money|4|3|2|1"
		local s_57 "I try to use the products for longer|4|3|2|1"
		local s_58 "Whenever I can, I save money|4|3|2|1"
		local s_59 "I would rather spend the change on something I want than save the money for later|1|2|3|4"
		local r = 0
		foreach i in 52 53 54 55 56 57 58 59 {
			local ++r
			local p    = strpos("`s_`i''", "|")
			local stmt = substr("`s_`i''", 1, `p' - 1)
			local rest = subinstr(substr("`s_`i''", `p' + 1, .), "|", " & ", .)
			local w : display %4.2f L_s[`r', 1]
			file write tex "`stmt' & `rest' & `w' \\" _n
		}
		file close tex

		display "CSINDEX_TABLE_DONE"
	}

	**
	*==========================================================================================*
	* Tables A.5 and A.6 -- Balance tests for students and teachers
	* Same method as Table A.1, one vrow call per variable: C and T are the group means, with
	* their school-clustered SEs and Ns from a regression on a constant within each group, and
	* Diff is the raw gap C - T with stars from the p-value of a regression on treatment and
	* the strata dummies, clustered at the school level -- exactly what iebaltab reported here
	* before, checked byte by byte. Columns are the four grades ($gvar holds each table's grade
	* variable). In the students' table the third grade has its own questionnaire: vrow's third
	* argument names its variable when it differs (. = not measured in the third grade).
	*==========================================================================================*
	{
		*---------- helper: one variable = three lines (Mean, SE, Obs) x four grades ----------
		cap program drop vrow
		program define vrow
			args v lab g3
			if "`g3'" == "" local g3 `v'
			local Lm ""
			local Ls ""
			local Ln ""
			foreach g in 3 5 7 9 {
				local x = cond(`g' == 3, "`g3'", "`v'")
				if "`x'" == "." {
					local Lm "`Lm' &  &  & "
					local Ls "`Ls' &  &  & "
					local Ln "`Ln' &  &  & "
					continue
				}
				qui reg `x' if $gvar == `g' & resultado == 0, vce(cluster cd_escola)
				local mc  = _b[_cons]
				local scf = strtrim(string(_se[_cons],"%12.1f"))
				local Nc  = e(N)
				qui reg `x' if $gvar == `g' & resultado == 1, vce(cluster cd_escola)
				local mt  = _b[_cons]
				local stf = strtrim(string(_se[_cons],"%12.1f"))
				local Nt  = e(N)
				qui reg `x' resultado $estrato if $gvar == `g', vce(cluster cd_escola)
				local p   = 2*ttail(e(df_r), abs(_b[resultado]/_se[resultado]))
				local st  = cond(`p' < .01, "***", cond(`p' < .05, "**", cond(`p' < .1, "*", "")))
				local mcf = strtrim(string(`mc',"%12.1f"))
				local mtf = strtrim(string(`mt',"%12.1f"))
				local dff = strtrim(string(`mc' - `mt',"%12.1f"))
				local Lm `"`Lm' & `mcf' & `mtf' & `dff'`st'"'
				local Ls `"`Ls' & (`scf') & (`stf') & "'
				local Ln `"`Ln' & `Nc' & `Nt' & "'
			}
			file write tex `"`lab' & Mean`Lm' \\"' _n
			file write tex `" & SE`Ls' \\"' _n
			file write tex `" & Obs`Ln' \\"' _n
			file write tex "\addlinespace" _n
		end

		*---------- Table A.4: students ----------
		use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
		recode    fl_blank_score  (0 = 100) (1 = 0)				//100 = participated; response to the questionnaire
		recode    fl_blank_parent (0 = 100) (1 = 0)				//is conditional on having taken the assessment; in
		recode    fl_socio_blank  (0 = 100) (1 = 0)				//the 3rd grade it was answered by the legal
		replace   fl_blank_parent = . if fl_blank_score == 0	//guardians (fl_blank_parent)
		replace   fl_socio_blank  = . if fl_blank_score == 0
		foreach var in hh_paved_street hh_electri hh_piped_water hh_garb_col bolsa_fam adequate_age ///
			resp_educ_1 resp_educ_2 resp_educ_3 mother_educ_1 mother_educ_2 mother_educ_3 gender color_white {
			replace `var' = `var'*100
		}
		global gvar cd_etapa_avaliada_turma

		file open  tex using "$textables/TableA4.tex", write replace
		file write tex "% Generated by Do files/3_Descriptives.do -- data rows only, do not edit by hand." _n
		file write tex "% The shell (caption, headers, notes, source) lives in Paper/Fin_Lit_Paper.tex." _n
		vrow fl_blank_score  "Participation: financial literacy assessment"
		vrow fl_socio_blank  "Response: socioeconomic questionnaire"							fl_blank_parent
		vrow hh_paved_street "Access to paved street"
		vrow hh_electri      "Access to electricity"
		vrow hh_piped_water  "Access to piped water"
		vrow hh_garb_col     "Access to garbage collection"
		vrow bolsa_fam       "Beneficiary of Bolsa Família"
		vrow adequate_age    "Adequate age for their grade"
		vrow mother_educ_1   "Mother education/Legal guardian: incomplete elementary school"	resp_educ_1
		vrow mother_educ_2   "Mother education/Legal guardian: incomplete high school"			resp_educ_2
		vrow mother_educ_3   "Mother education/Legal guardian: at least high school degree"	resp_educ_3
		vrow gender          "Gender: male"														.
		vrow color_white     "Color: white"														.
		file close tex

		*---------- Table A.5: teachers ----------
		use "$dtinter/Teacher's data_long.dta", clear
		keep if teacher_key_ != .
		foreach var in teacher_male teacher_age1 teacher_age2 teacher_age3 teacher_white ///
			d_teacher_expe1 d_teacher_expe2 d_teacher_expe3 wage_2 wage_3 wage_4 wage_5 {
			replace `var' = `var'*100
		}
		global gvar cd_etapa_aplicacao_turma

		file open  tex using "$textables/TableA5.tex", write replace
		file write tex "% Generated by Do files/3_Descriptives.do -- data rows only, do not edit by hand." _n
		file write tex "% The shell (caption, headers, notes, source) lives in Paper/Fin_Lit_Paper.tex." _n
		vrow teacher_male    "Gender: male"
		vrow teacher_age1    "Age: less than 35 years"
		vrow teacher_age2    "Age: 36 to 50 years"
		vrow teacher_age3    "Age: older than 51 years"
		vrow teacher_white   "Color: white"
		vrow d_teacher_expe1 "Experience: up to 5 years"
		vrow d_teacher_expe2 "Experience: 6 to 15 years"
		vrow d_teacher_expe3 "Experience: more than 16 years"
		vrow wage_2          "Wage: 3 to 4 minimum wages"
		vrow wage_3          "Wage: 4 to 5 minimum wages"
		vrow wage_4          "Wage: 5 to 6 minimum wages"
		vrow wage_5          "Wage: more than 6 minimum wages"
		file close tex

		display "BALANCE_TABLES_DONE"
	}


	**
	*==========================================================================================*
	* Table A.6 -- Pre-treatment balance test with administrative data at school level
	* One three-line block per covariate of the public school records (Treatment and Control
	* Groups.dta, one row per study school): C and T are the group means with their standard
	* errors and Ns, and Diff is the raw gap C - T, with stars from the p-value of a regression
	* of the covariate on treatment and the strata dummies, clustered at the randomization
	* group -- the same statistic as Tables A.1, A.4 and A.5. Covariates that cannot be
	* regressed in a given sample are left without stars by the capture. The fragment carries
	* the rows; the shell keeps the headers and notes.
	*==========================================================================================*
	{
		*---------- helper: format the difference with its significance stars ----------
		cap program drop starfmt
		program define starfmt, rclass
			args b p
			local s = ""
			if `p' < 0.10 local s = "*"
			if `p' < 0.05 local s = "**"
			if `p' < 0.01 local s = "***"
			return local cell = string(`b',"%9.2f") + "`s'"
		end

		*---------- covariates (public school records) and row labels ----------
		local vars DSU_F14 DSU_F58 TDI_F03 TDI_F05 TDI_F07 TDI_F09 ///
			TA_F07_2009 TA_F09_2009 TA_F07_2011 TA_F09_2011 TA_F07_2013 TA_F09_2013 ///
			TA_F03_2009 TA_F05_2009 TA_F03_2011 TA_F05_2011 TA_F03_2013 TA_F05_2013 ///
			MAT_F09_2009 LP_F09_2009 MAT_F09_2011 LP_F09_2011 MAT_F09_2013 LP_F09_2013 ///
			MAT_F05_2009 LP_F05_2009 MAT_F05_2011 LP_F05_2011 MAT_F05_2013 LP_F05_2013 ///
			IDEB_F09_2009 IDEB_F09_2011 IDEB_F09_2013 IDEB_F05_2009 IDEB_F05_2011 IDEB_F05_2013

		local labels `" "\% teachers in 1st to fifth grade with undergrad" "\% teachers in 6th to ninth grade with undergrad" "Age grade distortion third grade (2013)" "Age grade distortion fifth grade (2013)" "Age grade distortion seventh grade (2013)" "Age grade distortion ninth grade (2013)" "Grade-promotion seventh grade (2009)" "Grade-promotion ninth grade (2009)" "Grade-promotion seventh grade (2011)" "Grade-promotion ninth grade (2011)" "Grade-promotion seventh grade (2013)" "Grade-promotion ninth grade (2013)" "Grade-promotion third grade (2009)" "Grade-promotion fifth grade (2009)" "Grade-promotion third grade (2011)" "Grade-promotion fifth grade (2011)" "Grade-promotion third grade (2013)" "Grade-promotion fifth grade (2013)" "Math performance ninth grade (2009)" "Reading performance ninth grade (2009)" "Math performance ninth grade (2011)" "Reading performance ninth grade (2011)" "Math performance ninth grade (2013)" "Reading performance ninth grade (2013)" "Math performance fifth grade (2009)" "Reading performance fifth grade (2009)" "Math performance fifth grade (2011)" "Reading performance fifth grade (2011)" "Math performance fifth grade (2013)" "Reading performance fifth grade (2013)" "IDEB ninth grade (2009)" "IDEB ninth grade (2011)" "IDEB ninth grade (2013)" "IDEB fifth grade (2009)" "IDEB fifth grade (2011)" "IDEB fifth grade (2013)" "'
		local nv : word count `vars'

		*---------- pooled control/treatment means, SEs, and strata-adjusted difference ----------
		matrix R = J(`nv',8,.)								// 1 Nc 2 mc 3 sec 4 Nt 5 mt 6 set 7 diff(C-T) 8 pdiff
		use "$dtinter/Treatment and Control Groups.dta", clear
		local i = 0
		foreach v of local vars {
			local ++i
			qui su `v' if resultado==0 & group!=.
			matrix R[`i',1]=r(N)
			matrix R[`i',2]=r(mean)
			if r(N)>0 matrix R[`i',3]=r(sd)/sqrt(r(N))
			qui su `v' if resultado==1 & group!=.
			matrix R[`i',4]=r(N)
			matrix R[`i',5]=r(mean)
			if r(N)>0 matrix R[`i',6]=r(sd)/sqrt(r(N))
			*The reported difference is the raw control-treatment gap in means; the strata dummies
			*and the clusters enter only the test behind the stars. Here the cluster is the
			*randomization group, since each school is a single observation.
			capture reg `v' resultado $estrato if group!=., vce(cluster group)
			if _rc==0 {
				matrix R[`i',7] = R[`i',2] - R[`i',5]
				matrix R[`i',8] = 2*ttail(e(df_r), abs(_b[resultado]/_se[resultado]))
			}
		}

		*---------- write the LaTeX fragment ----------
		file open  tex using "$textables/TableA6.tex", write replace
		file write tex "% Generated by Do files/3_Descriptives.do (pre-treatment balance block) -- data rows only, do not edit by hand." _n
		forvalues r = 1/`nv' {
			local lab : word `r' of `labels'
			file write tex "`lab'"
			file write tex " & " (strtrim(string(R[`r',1],"%9.0f"))) " & " (string(R[`r',2],"%9.2f"))
			file write tex " & " (strtrim(string(R[`r',4],"%9.0f"))) " & " (string(R[`r',5],"%9.2f"))
			if missing(R[`r',7]) file write tex " & \\" _n
			else {
				starfmt `=R[`r',7]' `=R[`r',8]'
				file write tex " & `r(cell)' \\" _n
			}
			file write tex " & & (" (string(R[`r',3],"%9.2f")) ")"
			file write tex " & & (" (string(R[`r',6],"%9.2f")) ") & \\" _n
		}
		file close tex

		display "PRETBALANCE_TABLE_DONE"
	}


