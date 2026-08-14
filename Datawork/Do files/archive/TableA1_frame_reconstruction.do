*ARCHIVED 2026-08-11 -- former Table A.1 block of 2_Descriptives.do.
*The published Table A.1 now starts at the sampling frame, taken from the pilot's
*implementation report (World Bank, August 2016); see the compact block at the top
*of 2_Descriptives.do. This code rebuilt the school frame from the identified census
*files and validated that the report's frame (20/2/50 Joinville, 202/35/65 Manaus)
*is consistent with the 2015 School Census and the 2013 IDEB. Kept for reference;
*needs the identified folder to run.

	**
	*==========================================================================================*
	* Table A.1 -- Sample selected for the pilot study (+ school frame reconstruction)
	* (moved from the former 4_Tables.do)
	*==========================================================================================*
																*4. Tables*

										   *Financial Literacy Pilot in Brazil*
	*-------------------------------------------------------------------------------------------------------------------------*
	/*
	Builds the paper tables that are written directly as LaTeX fragments into
	"Paper/tables/", so that recompiling the paper picks up whatever this do-file
	last produced. Nothing in the paper is typed by hand.

	Currently produces:
	    Paper/tables/tableSample.tex   Table A.1 -- Sample selected for the pilot study

	The do-file runs in two steps.

	STEP 1 rebuilds the school-level frame, one record for every municipal school in
	Manaus and Joinville that offered at least one pilot grade in 2015, and saves it
	de-identified as "Data/2. Intermediate/School frame_2015.dta". It needs

	    Data/0. DeIdentification/Identified/Classrooms in Manaus and Joinville_2015.dta
	    Data/0. DeIdentification/Identified/Enrollment by school_2007-2017.dta
	    Data/0. DeIdentification/Identified/Treatment and Control Groups.dta
	    Data/1. Raw/IDEB_2015_ANOS_INICIAIS_ESCOLAS.xlsx
	    Data/1. Raw/IDEB_2015_ANOS_FINAIS_ESCOLAS.xlsx

	The first three carry real INEP school codes and are not part of the public
	package; the two IDEB files are public downloads from INEP. Step 1 is skipped
	automatically when the identified folder is absent.

	STEP 2 builds the table from the de-identified frame alone. It is the only step
	the public package needs, and it can be re-run by anyone.

	ONE NUMBER IS NOT COMPUTED FROM DATA. The size of the Manaus frame in the two
	strata that were sampled -- 202 and 35 schools -- is taken from the August 2016
	technical report, which records the frame before sampling. It cannot be recovered
	from the census, because the list of riverside schools set aside by the Department
	of Education was never written down in the data. Everything else below is computed,
	and the do-file asserts the numbers add up before it writes anything.
	*/
	*/
	*/
	*NOTE: the two extra closers above end the legacy blocks commented out at "Imperfect complience" (line ~1114)
	*and "Contaminação" (line ~1176) -- Stata block comments NEST, so each /* needs its own */. Those explorations
	*now live in 5_Contaminacao.do.


	*Paths -- this do-file is self-contained; run it from anywhere
	*----------------------------------------------------------------------------------------------------------------------*
	if "$projectfolder" == "" {
	}
	cap mkdir "$textables"

	*Frame sizes in the two sampled strata (August 2016 report -- see header)
	local frame_B1 = 202
	local frame_B2 = 35


	*STEP 1 -- rebuild the de-identified school-level frame
	*----------------------------------------------------------------------------------------------------------------------*
	capture confirm file "$identified/Classrooms in Manaus and Joinville_2015.dta"
	if _rc == 0 {

		*Location and size in 2015, one record per school
		use "$identified/Enrollment by school_2007-2017.dta", clear
		keep if Year == 2015 & Network == 3
		keep Codschool Location Enrollment5Grade Enrollment9Grade
		duplicates drop
		isid Codschool
		tempfile enrol2015
		save `enrol2015'

		*Classes in each pilot grade, for every municipal school
		use "$identified/Classrooms in Manaus and Joinville_2015.dta", clear
		keep if Network == 3
		collapse (sum) TClass3Grade TClass5Grade TClass7Grade TClass9Grade, by(Codschool Codmunic)

		*School type. A school serves the elementary grades if it offers grade 3, and the
		*middle school grades if it offers grade 7 or 9. This reproduces the strata used
		*in the randomization for 198 of the 201 study schools; the alternatives ("offers
		*grade 3 or 5", "offers grade 3 and 5") do worse and, for the first, imply a frame
		*larger than the census count in stratum B.2, which is impossible.
		gen byte elementary = TClass3Grade > 0 & !mi(TClass3Grade)
		gen byte middle     = (TClass7Grade > 0 & !mi(TClass7Grade)) | ///
							  (TClass9Grade > 0 & !mi(TClass9Grade))
		drop if !elementary & !middle								//no pilot grade offered
		gen byte type = cond(elementary & middle, 3, cond(elementary, 1, 2))
		drop elementary middle

		merge 1:1 Codschool using `enrol2015', keep(master match) nogen
		tempfile here
		save `here'

		*2013 IDEB, from the public school-level files. The IDEB of a stage comes from the
		*assessment taken in its terminal grade, so it exists only for schools offering
		*grade 5 (early grades) or grade 9 (middle school grades). The 2013 score sits in
		*column BS of the "anos iniciais" file and column BM of the "anos finais" file;
		*both have their header block in rows 1-9.
		foreach s in AI AF {
			if "`s'" == "AI" {
				local file "IDEB_2015_ANOS_INICIAIS_ESCOLAS.xlsx"
				local col  "BS"
			}
			else {
				local file "IDEB_2015_ANOS_FINAIS_ESCOLAS.xlsx"
				local col  "BM"
			}
			import excel using "$dtraw/`file'", cellrange(A10) allstring clear
			keep if inlist(B, "1302603", "4209102") & F == "Municipal"
			keep D `col'
			rename D Codschool
			rename `col' ideb_`s'
			destring Codschool ideb_`s', replace force			//"-" becomes missing
			duplicates drop Codschool, force
			tempfile ideb`s'
			save `ideb`s''
			use `here', clear
			merge 1:1 Codschool using `ideb`s'', keep(master match) nogen
			save `here', replace
		}
		gen byte has_ideb = !mi(ideb_AI) | !mi(ideb_AF)

		*Study schools: stratum recorded at randomization, and treatment assignment
		preserve
			use "$identified/Treatment and Control Groups.dta", clear
			rename cd_escola Codschool
			keep Codschool munic tipo_escola resultado
			tempfile study
			save `study'
		restore
		merge 1:1 Codschool using `study', keep(master match using) nogen
		gen byte instudy = !mi(tipo_escola)
		replace type = tipo_escola if instudy == 1				//the stratum actually used
		gen byte manaus = Codmunic == 1302603
		replace manaus = munic == 13 if mi(Codmunic)

		*De-identify: the counts need none of the identifiers
		drop Codschool Codmunic munic tipo_escola
		label define type 1 "Grades 1-5" 2 "Grades 6-9" 3 "Grades 1-9"
		label values type type
		label define manaus 0 "Joinville" 1 "Manaus"
		label values manaus manaus
		label var type 			"Grades offered (randomization stratum)"
		label var manaus 		"Municipality"
		label var Location 		"1 urban, 2 rural"
		label var has_ideb 		"Has a 2013 IDEB and could be ranked"
		label var instudy 		"Entered the evaluation sample"
		label var resultado 	"1 treatment, 0 control"
		order manaus type Location instudy resultado
		sort manaus type Location Enrollment5Grade Enrollment9Grade
		compress
		save "$dtinter/School frame_2015.dta", replace
		display as result "School frame_2015.dta rebuilt from the identified data"
	}
	else {
		display as text "Identified data not found -- using the de-identified frame as is"
	}


	*STEP 2 -- Table A.1, from the de-identified frame alone
	*----------------------------------------------------------------------------------------------------------------------*
	use "$dtinter/School frame_2015.dta", clear

	*Counts by stratum
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			count if manaus == `m' & type == `t'
			local census_`m'`t' = r(N)
			count if manaus == `m' & type == `t' & instudy == 1
			local study_`m'`t' = r(N)
			count if manaus == `m' & type == `t' & instudy == 1 & resultado == 1
			local treat_`m'`t' = r(N)
			count if manaus == `m' & type == `t' & instudy == 1 & resultado == 0
			local ctrl_`m'`t'  = r(N)
			local frame_`m'`t' = `study_`m'`t''					//no sampling: frame = study
		}
	}
	local frame_11 = `frame_B1'									//B.1 and B.2 were sampled
	local frame_12 = `frame_B2'
	local perq_11 = `study_11' / 4								//schools drawn per quartile
	local perq_12 = `study_12' / 4

	*The schools left out of the Joinville frame. No sampling took place there, so the
	*schools outside the study are exactly the schools outside the frame.
	count if manaus == 0 & instudy == 0
	local jout_n = r(N)
	summarize Enrollment5Grade if manaus == 0 & instudy == 0, meanonly
	local jout_mean = round(r(mean))
	summarize Enrollment5Grade if manaus == 0 & instudy == 1, meanonly
	local jin_mean = round(r(mean))
	count if manaus == 0 & instudy == 0 & Location == 2
	local jout_rural = r(N)

	*Schools eligible for the draw in B.1 and B.2: only those the 2013 IDEB of their
	*own cycle could rank. These are counted over the census stratum, not the frame.
	*B.2 had no schools set aside, so "33 of 35" is exact; in B.1 a few of the schools
	*removed from the frame may carry an IDEB, so the note states the count on its own
	*and not as a share of the 202.
	count if manaus == 1 & type == 1 & !mi(ideb_AI)
	local rank_11 = r(N)
	count if manaus == 1 & type == 2 & !mi(ideb_AF)
	local rank_12 = r(N)

	*The table notes now live in Paper/Fin_Lit_Paper.tex and hard-code the figures
	*below; stop rather than let the data drift away from the printed notes
	assert `jout_n'    == 11  & `jout_rural' == `jout_n'		//"the 11 schools left out are all rural"
	assert `jout_mean' == 6   & `jin_mean'   == 76			//"enroll 6 students ... against 76"
	assert `rank_11'   == 181 & `rank_12'    == 33			//"181 schools could be ranked in B.1, and 33 in B.2"
	assert `perq_11'   == 9   & `perq_12'    == 7			//"9 in B.1 and 7 in B.2"
	assert `treat_13'  == 33  & `ctrl_13'    == 32			//"hence 33 treated and 32 control"

	*Totals
	foreach r in census frame study treat ctrl {
		local tot_`r' = 0
		forvalues m = 0/1 {
			forvalues t = 1/3 {
				local tot_`r' = `tot_`r'' + ``r'_`m'`t''
			}
		}
	}

	*Stop rather than write a table that does not add up
	assert `jout_n' > 0 & `jin_mean' > `jout_mean'
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			assert `study_`m'`t'' <= `frame_`m'`t'' & `frame_`m'`t'' <= `census_`m'`t''
		}
	}
	assert mod(`study_11', 4) == 0 & mod(`study_12', 4) == 0
	assert `tot_study' == `tot_treat' + `tot_ctrl'
	*The schools that could be ranked must sit between the schools drawn and the frame
	assert `study_11' <= `rank_11' & `rank_11' <= `frame_11'
	assert `study_12' <= `rank_12' & `rank_12' <= `frame_12'


	*Write the LaTeX fragment -- data rows only; the table shell (caption, column
	*headers, notes) lives in Paper/Fin_Lit_Paper.tex (appendix)
	*----------------------------------------------------------------------------------------------------------------------*
	file open tex using "$textables/tableSample.tex", write replace
	file write tex "% Generated by Do files/2_Descriptives.do (sample block) -- data rows only, do not edit by hand." _n
	file write tex "% The table shell (caption, headers, notes) lives in Paper/Fin_Lit_Paper.tex (appendix)." _n

	file write tex "(1) Municipal schools, 2015 School Census"
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			file write tex " & " (`census_`m'`t'')
		}
	}
	file write tex " & " (`tot_census') " \\" _n

	file write tex "(2) \quad less: not in the sampling frame"
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			local d = `census_`m'`t'' - `frame_`m'`t''
			if `d' == 0   file write tex " & 0"
			else          file write tex " & $-$" (`d')
		}
	}
	file write tex " & $-$" (`tot_census' - `tot_frame') " \\" _n

	file write tex "(3) \textbf{= Sampling frame}"
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			file write tex " & \textbf{" (`frame_`m'`t'') "}"
		}
	}
	file write tex " & \textbf{" (`tot_frame') "} \\" _n
	file write tex "\addlinespace" _n

	file write tex "(4) Schools drawn from each IDEB quartile & --- & --- & --- & "
	file write tex (`perq_11') " & " (`perq_12') " & --- & \\" _n

	file write tex "(5) \textbf{= Schools in the study}"
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			file write tex " & \textbf{" (`study_`m'`t'') "}"
		}
	}
	file write tex " & \textbf{" (`tot_study') "} \\" _n
	file write tex "\addlinespace" _n

	file write tex "(6) Assigned to treatment"
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			file write tex " & " (`treat_`m'`t'')
		}
	}
	file write tex " & " (`tot_treat') " \\" _n

	file write tex "(7) Assigned to control"
	forvalues m = 0/1 {
		forvalues t = 1/3 {
			file write tex " & " (`ctrl_`m'`t'')
		}
	}
	file write tex " & " (`tot_ctrl') " \\" _n
	file close tex

	display as result _n "tableSample.tex written to $textables"

	*exit removed 2026-08-10: legacy from the standalone sampling do-file; it truncated every section below (A.7, implementation, A.5, A.6) in full runs


