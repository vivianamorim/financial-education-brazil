    *____________________________________________________________________________________________________________________________________*

                                                              *RESULTS*

                                               *Financial Literacy Pilot in Brazil*
    *____________________________________________________________________________________________________________________________________*
    *
    *Estimates the treatment effects and exports the tables and figures of the paper.
    *Paths and globals come from Master.do ($dtfinal, $dtinter, $estrato, $textables).
    *
    *CONTENTS:
    *  Section 1: Programs               -- helper programs used throughout (add, chart, charts)
    *  Section 2: Table 3                -- ITT estimates: financial proficiency and the consumption and savings indices
    *  Section 3: Table 4                -- ITT estimates: behavioural outcomes
    *  Section 4: Table 5                -- Intention-to-treat (ITT) and local average treatment effect (LATE)
    *  Section 5: Table A.10             -- Average causal mediation effects (ACME)
    *  Section 6: Figures 1, B.2a, B.2b  -- Quantile treatment effects on financial proficiency
    *  Section 7: Appendix figures       -- ACME sensitivity analysis (medsens)
    *  Section 8: Table OA1              -- Table 3 re-estimated with class-clustered standard errors (online appendix)
    *____________________________________________________________________________________________________________________________________*


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 1: Programs
    *Helper programs used by the tables and figures below.
    *____________________________________________________________________________________________________________________________________*
    **
    {
        *-------------------------------------------------------------------------------------------------------------->
        *add: saves the randomization inference results
        cap program drop add                                                         //para salvar os resultados de RI
        program define   add
            syntax, results(string)
            scalar pvalue = el(r(p),1,1)
            estadd scalar pvalue = pvalue : test`results'
        end

        *-------------------------------------------------------------------------------------------------------------->
        *chart: sensitivity analysis charts (medsens)
        cap program drop chart
        program define   chart
            syntax, ciclo(string) var(string)

            if "`var'"   == "pca_consump_sm" local title  "Consumption index"
            if "`var'"   == "pca_save_sm"    local title  "Saving index"
            if "`var'"   == "talk_parents"   local title  "Talk to parents"
            if "`var'"   == "talk_friends"   local title  "Talk to friends"
            if "`var'"   == "pigg"           local title  "Piggy's bank use"
            if "`var'"   == "finan_serv"     local title  "Use of finantial services"
            if "`var'"   == "allowance2"     local title  "Allowance"
            if "`ciclo'" == "pooled"         local title2 "pooled"
            if "`ciclo'" == "1st"            local title2 "Primary education"
            if "`ciclo'" == "2nd"            local title2 "Middle school"

            twoway rarea _med_updelta0 _med_lodelta0 _med_rho, bcolor(gs14) || line _med_delta0 _med_rho, lcolor(black) saving("A`ciclo'`var'.gph", replace) ///
                ytitle("ACME({&rho})",size(medium)) title("`title', `title2'", size(medium)) xtitle("Sensitivity parameter: {&rho}", size(medium)) legend(off) scheme(sj) ///
                ylabel(, nogrid) ///
                graphregion(fcolor(white) lcolor(white))
            *graph export "$figures/`ciclo'_`var'.emf", as(emf) replace
        end

        *-------------------------------------------------------------------------------------------------------------->
        *charts: charts of the quantile regressions
        cap program drop charts
        program define   charts
            syntax, model(string)

            local paneltitle = cond("`model'" == "Elementary education", "Elementary", "`model'")

            matrix results = r(table)'
            matrix A = (0, 0, 0, 0)
            local  i = 1
            forvalues f = 5(5)95 {
                matrix A = A \ (`f', results[`i',1], results[`i',5], results[`i',6]) //quantile of analysis, coefficient, lower and upper bound
                local i = `i' + 2
            }
            matrix list A
            clear
            svmat  A
            drop   in 1
            rename (A1 A2 A3 A4) (quantile b lower upper)
            twoway ///
                (scatter b quantile, msymbol(O) msize(medium) color(cranberry) yline(0,lpattern(dash))) ///
                (rcap    lower upper quantile, color(navy) ///
                graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
                plotregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
                ylabel(-0.15(0.05)0.30, nogrid labsize(small) format(%4.2fc)) ///
                xlabel(5(15)95, labsize(small) gmax angle(horizontal)) ///
                ytitle("Standard deviation", size(medlarge)) ///
                xtitle("Quantiles of financial proficiency", size(medlarge)) ///
                title("`paneltitle'", pos(12) color(black) size(large)) ///
                subtitle(, pos(12) size(medsmall)) ///
                ysize(5) xsize(7) ///
                legend(off) ///
                note("$gr_note", color(black) fcolor(background) pos(7) size(small)))

            *Each panel is saved on its own and the three are combined into Figure 1 after the last call
            if "`model'" == "Pooled"               graph save "$figures/uqitt_pooled.gph"    , replace
            if "`model'" == "Elementary education" graph save "$figures/uqitt_elementary.gph", replace
            if "`model'" == "Middle school"        graph save "$figures/uqitt_middle.gph"    , replace
        end

    }


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 2: Table 3 -- ITT estimates: financial proficiency and the consumption and savings indices
    *Per column: OLS with strata controls and school-clustered SEs, RI p-value (add + ritest) and Romano-Wolf
    *adjusted p-value (rwolf2). esttab writes the coefficient rows to Output/Tables/Table3.tex.
    *The 3rd-grade column is empty for the attitude indices (inserted with estout's extracols(4) option).
    *____________________________________________________________________________________________________________________________________*
    **
    {
        local REPS = 1000                                                            //ritest repetitions

        use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

        *-------------------------------------------------------------------------------------------------------------->
        *Romano-Wolf adjusted p-values -- ALL outcome-by-column hypotheses of the table are tested as ONE family
        *(19 hypotheses: financial proficiency in the 7 columns plus the two attitude indices in the 6 columns where
        *they exist), the most conservative family definition. The bootstrap resamples school clusters within
        *randomization strata. Clones with distinct names (<var>_R<c>) are needed because rwolf2 stores each adjusted
        *p-value as e(rw_<depvar>_<indepvar>) and repeated depvars across equations would collide; each clone carries
        *the column's sample restriction through missings, so estimates are identical to using "if". Each adjusted
        *p-value is saved as scalar rw_<outcome>_<column> and attached below with estadd ("pvalue RW" line).
        foreach v in sm pca_consump_sm pca_save_sm {
            gen double `v'_R1 = `v'
            gen double `v'_R2 = `v' if serie<7
            gen double `v'_R3 = `v' if serie>5
            gen double `v'_R5 = `v' if serie==5
            gen double `v'_R6 = `v' if serie==7
            gen double `v'_R7 = `v' if serie==9
        }
        gen double sm_R4 = sm if serie==3

        rwolf2 (reg sm_R1             d $estrato, cluster(cd_escola)) ///
               (reg pca_consump_sm_R1 d $estrato, cluster(cd_escola)) ///
               (reg pca_save_sm_R1    d $estrato, cluster(cd_escola)) ///
               (reg sm_R2             d $estrato, cluster(cd_escola)) ///
               (reg pca_consump_sm_R2 d $estrato, cluster(cd_escola)) ///
               (reg pca_save_sm_R2    d $estrato, cluster(cd_escola)) ///
               (reg sm_R3             d $estrato, cluster(cd_escola)) ///
               (reg pca_consump_sm_R3 d $estrato, cluster(cd_escola)) ///
               (reg pca_save_sm_R3    d $estrato, cluster(cd_escola)) ///
               (reg sm_R4             d $estrato, cluster(cd_escola)) ///
               (reg sm_R5             d $estrato, cluster(cd_escola)) ///
               (reg pca_consump_sm_R5 d $estrato, cluster(cd_escola)) ///
               (reg pca_save_sm_R5    d $estrato, cluster(cd_escola)) ///
               (reg sm_R6             d $estrato, cluster(cd_escola)) ///
               (reg pca_consump_sm_R6 d $estrato, cluster(cd_escola)) ///
               (reg pca_save_sm_R6    d $estrato, cluster(cd_escola)) ///
               (reg sm_R7             d $estrato, cluster(cd_escola)) ///
               (reg pca_consump_sm_R7 d $estrato, cluster(cd_escola)) ///
               (reg pca_save_sm_R7    d $estrato, cluster(cd_escola)) ///
             , indepvars(d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d) cluster(cd_escola) strata(estrato) reps(1000) seed(20150101) nodots

        forvalues c = 1/7 {
            foreach v in sm pca_consump_sm pca_save_sm {
                if `c' == 4 & "`v'" != "sm" continue                                 //attitude indices do not exist in the 3rd grade
                scalar rw_`v'_`c' = e(rw_`v'_R`c'_d)
            }
        }
        drop sm_R* pca_consump_sm_R* pca_save_sm_R*

        set seed 20150101                                                            //reproducible randomization-inference p-values (rwolf2 resets the RNG state)

        *-------------------------------------------------------------------------------------------------------------->
        *One vertical panel per outcome. The LaTeX table shell (caption, column headers, notes) lives in
        *Paper/05_results.tex; this loop writes only the coefficient rows to $textables/Table3.tex
        local mode replace
        local sep  ""
        foreach var of varlist sm pca_consump_sm pca_save_sm {
            if "`var'" == "sm"             local pname "Financial proficiency"
            if "`var'" == "pca_consump_sm" local pname "Consumption index"
            if "`var'" == "pca_save_sm"    local pname "Saving index"

            est clear
            local models ""
            local extra  ""
            forvalues c = 1/7 {
                *Column -> subsample (single-token conditions, no macro word-lists)
                local cond ""
                if `c' == 2 local cond "if serie<7"
                if `c' == 3 local cond "if serie>5"
                if `c' == 4 local cond "if serie==3"
                if `c' == 5 local cond "if serie==5"
                if `c' == 6 local cond "if serie==7"
                if `c' == 7 local cond "if serie==9"

                *Attitude indices were not collected in the 3rd grade -> flag an empty 4th column (extracols) and skip it
                if `c' == 4 & "`var'" != "sm" {
                    local extra "extracols(4)"
                }
                else {
                    eststo test`c': reg `var' d $estrato `cond', cluster(cd_escola)
                    ritest d _b[d], reps(`REPS') cluster(cd_escola) strata(estrato) nodots: ///
                        reg `var' d $estrato `cond', cluster(cd_escola)
                    add, results(`c')
                    matrix define   pwolf_m = J(1,1,0)
                    matrix colnames pwolf_m = "d"
                    matrix pwolf_m[1,1]     = rw_`var'_`c'
                    estadd matrix pwolfmat = pwolf_m : test`c'
                    estadd scalar pwolf = rw_`var'_`c' : test`c'  //column 4 now belongs to the joint family too
                    local models "`models' test`c'"
                }
            }

            esttab `models' using "$textables/Table3.tex", `mode' `extra' ///
                keep(d) coeflabels(d "Treatment") ///
                cells(b(star pvalue(pwolfmat) fmt(%9.3f)) se(par fmt(%9.3f))) ///
                stats(pwolf pvalue N r2, fmt(%9.3f %9.3f %9.0f %9.3f) labels("pvalue RW" "pvalue RI" "N. obs" "R-squared")) ///
                starlevels(* 0.10 ** 0.05 *** 0.01) fragment nolines nonumbers nomtitles collabels(none) ///
                prehead("`sep'") refcat(d "\textbf{`pname'}", nolabel)
            local mode append
            local sep  "\midrule"
        }
        display "ITT_TABLE_DONE"
    }


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 3: Table 4 -- ITT estimates: behavioural outcomes
    *Per column: OLS with strata controls and school-clustered SEs, RI p-value (add + ritest) and Romano-Wolf
    *adjusted p-value (rwolf2). esttab writes the coefficient rows to Output/Tables/Table4.tex.
    *____________________________________________________________________________________________________________________________________*
    **
    {
        local REPS = 1000
        use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

        *-------------------------------------------------------------------------------------------------------------->
        *Romano-Wolf adjusted p-values -- ALL 15 outcome-by-column hypotheses of the table as ONE family (5 behaviours
        *x 3 columns), the most conservative family definition; the bootstrap resamples school clusters within
        *randomization strata. Clones give distinct depvar names (see the note in Section 2). Each adjusted p-value is
        *saved as scalar rw_<outcome>_<column> and attached to the stored estimates below with estadd ("pvalue RW" line)
        foreach v in talk_parents talk_friends pigg finan_serv allowance2 {
            gen double `v'_R1 = `v' if serie>3
            gen double `v'_R2 = `v' if serie==5
            gen double `v'_R3 = `v' if serie>5
        }

        rwolf2 (reg talk_parents_R1 d $estrato, cluster(cd_escola)) ///
               (reg talk_friends_R1 d $estrato, cluster(cd_escola)) ///
               (reg pigg_R1         d $estrato, cluster(cd_escola)) ///
               (reg finan_serv_R1   d $estrato, cluster(cd_escola)) ///
               (reg allowance2_R1   d $estrato, cluster(cd_escola)) ///
               (reg talk_parents_R2 d $estrato, cluster(cd_escola)) ///
               (reg talk_friends_R2 d $estrato, cluster(cd_escola)) ///
               (reg pigg_R2         d $estrato, cluster(cd_escola)) ///
               (reg finan_serv_R2   d $estrato, cluster(cd_escola)) ///
               (reg allowance2_R2   d $estrato, cluster(cd_escola)) ///
               (reg talk_parents_R3 d $estrato, cluster(cd_escola)) ///
               (reg talk_friends_R3 d $estrato, cluster(cd_escola)) ///
               (reg pigg_R3         d $estrato, cluster(cd_escola)) ///
               (reg finan_serv_R3   d $estrato, cluster(cd_escola)) ///
               (reg allowance2_R3   d $estrato, cluster(cd_escola)) ///
             , indepvars(d, d, d, d, d, d, d, d, d, d, d, d, d, d, d) cluster(cd_escola) strata(estrato) reps(1000) seed(20150101) nodots

        forvalues c = 1/3 {
            foreach v in talk_parents talk_friends pigg finan_serv allowance2 {
                scalar rw_`v'_`c' = e(rw_`v'_R`c'_d)
            }
        }
        drop talk_parents_R* talk_friends_R* pigg_R* finan_serv_R* allowance2_R*

        set seed 20150101                                                            //reproducible randomization-inference p-values (rwolf2 resets the RNG state)

        *-------------------------------------------------------------------------------------------------------------->
        *One vertical panel per outcome. The LaTeX table shell (caption, column headers, notes) lives in
        *Paper/05_results.tex; this loop writes only the coefficient rows to $textables/Table4.tex
        local mode replace
        local sep  ""
        foreach var of varlist talk_parents talk_friends pigg finan_serv allowance2 {
            if "`var'" == "talk_parents" local pname "Talks about money or expenses with parents"
            if "`var'" == "talk_friends" local pname "Talks about money with friends"
            if "`var'" == "pigg"         local pname "Piggy bank use"
            if "`var'" == "finan_serv"   local pname "Use of financial services"
            if "`var'" == "allowance2"   local pname "Receiving an allowance"

            est clear
            forvalues c = 1/3 {
                *3rd graders are excluded from all columns: they answered only the piggy-bank and financial-services
                *items, so restricting to grades 5, 7 and 9 makes every outcome cover the same grades
                local cond "if serie>3"
                if `c' == 2 local cond "if serie==5"
                if `c' == 3 local cond "if serie>5"
                eststo test`c': reg `var' d $estrato `cond', cluster(cd_escola)
                ritest d _b[d], reps(`REPS') cluster(cd_escola) strata(estrato) nodots: ///
                    reg `var' d $estrato `cond', cluster(cd_escola)
                add, results(`c')
                matrix define   pwolf_m = J(1,1,0)
                matrix colnames pwolf_m = "d"
                matrix pwolf_m[1,1]     = rw_`var'_`c'
                estadd matrix pwolfmat = pwolf_m : test`c'
                estadd scalar pwolf = rw_`var'_`c' : test`c'
            }

            esttab test1 test2 test3 using "$textables/Table4.tex", `mode' ///
                keep(d) coeflabels(d "Treatment") ///
                cells(b(star pvalue(pwolfmat) fmt(%9.3f)) se(par fmt(%9.3f))) ///
                stats(pwolf pvalue N r2, fmt(%9.3f %9.3f %9.0f %9.3f) labels("pvalue RW" "pvalue RI" "N. obs" "R-squared")) ///
                starlevels(* 0.10 ** 0.05 *** 0.01) fragment nolines nonumbers nomtitles collabels(none) ///
                prehead("`sep'") refcat(d "\textbf{`pname'}", nolabel)
            local mode append
            local sep  "\midrule"
        }
        display "BEHA_TABLE_DONE"
    }


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 4: Table 5 -- Intention-to-treat (ITT) and local average treatment effect (LATE)
    *ITT  = reduced-form effect of random assignment (d), from reg.
    *LATE = effect of actual exposure, instrumented by assignment, from ivregress 2sls (treated = d).
    *esttab writes the table; rename(treated d) aligns the LATE coefficient onto the ITT "Treatment" row.
    *Inference: RW only, each column within the 27-regression family. No RI here (see the note in the loop).
    *____________________________________________________________________________________________________________________________________*
    **
    {
        use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

        *-------------------------------------------------------------------------------------------------------------->
        *Romano-Wolf adjusted p-values -- ALL 27 regressions of the table (3 outcomes x 3 subsamples x 3 estimators:
        *the reduced form and the two IV columns) as ONE family, so every column carries its own adjusted p-value.
        *Clones give distinct depvar names (see the note in Section 2); the ITT and IV p-values of the same cell do
        *not collide because rwolf2 keys them by indepvar (d, treated, treated2).
        *Saved as scalars rw_<outcome>_<subsample> (ITT), rw1_... (conservative LATE) and rw2_... (broad LATE)
        foreach v in sm pca_consump_sm pca_save_sm {
            gen double `v'_G1 = `v'
            gen double `v'_G2 = `v' if serie<7
            gen double `v'_G3 = `v' if serie>5
        }

        rwolf2 (reg sm_G1             d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls sm_G1             $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls sm_G1             $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg pca_consump_sm_G1 d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls pca_consump_sm_G1 $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls pca_consump_sm_G1 $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg pca_save_sm_G1    d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls pca_save_sm_G1    $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls pca_save_sm_G1    $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg sm_G2             d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls sm_G2             $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls sm_G2             $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg pca_consump_sm_G2 d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls pca_consump_sm_G2 $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls pca_consump_sm_G2 $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg pca_save_sm_G2    d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls pca_save_sm_G2    $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls pca_save_sm_G2    $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg sm_G3             d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls sm_G3             $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls sm_G3             $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg pca_consump_sm_G3 d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls pca_consump_sm_G3 $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls pca_consump_sm_G3 $estrato (treated2 = d), vce(cluster cd_escola)) ///
               (reg pca_save_sm_G3    d $estrato, cluster(cd_escola))                          ///
               (ivregress 2sls pca_save_sm_G3    $estrato (treated  = d), vce(cluster cd_escola)) ///
               (ivregress 2sls pca_save_sm_G3    $estrato (treated2 = d), vce(cluster cd_escola)) ///
             , indepvars(d, treated, treated2, d, treated, treated2, d, treated, treated2,     ///
                         d, treated, treated2, d, treated, treated2, d, treated, treated2,     ///
                         d, treated, treated2, d, treated, treated2, d, treated, treated2)     ///
               cluster(cd_escola) strata(estrato) reps(1000) seed(20150101) nodots

        forvalues g = 1/3 {
            foreach v in sm pca_consump_sm pca_save_sm {
                scalar rw_`v'_`g'  = e(rw_`v'_G`g'_d)
                scalar rw1_`v'_`g' = e(rw_`v'_G`g'_treated)
                scalar rw2_`v'_`g' = e(rw_`v'_G`g'_treated2)
            }
        }
        drop sm_G* pca_consump_sm_G* pca_save_sm_G*

        set seed 20150101                                                            //reproducible randomization-inference p-values (rwolf2 resets the RNG state)

        *-------------------------------------------------------------------------------------------------------------->
        *-------------------------------------------------------------------------------------------------------------->
        *One vertical panel per outcome; per subsample, three columns: ITT, then the LATE under the conservative
        *exposure measure (treated) and under the broad one (treated2). The LaTeX table shell (caption, column
        *headers, notes) lives in Paper/05_results.tex; this loop writes only the rows to $textables/Table5.tex
        local mode replace
        local sep  ""
        foreach var of varlist sm pca_consump_sm pca_save_sm {
            if "`var'" == "sm"             local pname "Financial proficiency"
            if "`var'" == "pca_consump_sm" local pname "Consumption index"
            if "`var'" == "pca_save_sm"    local pname "Saving index"

            est clear
            local models ""
            local m = 0

            *Every column carries its own RW p-value, from its regression within the 27-strong family. No RI in
            *this table: permuting the assignment destroys the first stage, so the permuted IV coefficient
            *explodes and its RI p-value is meaningless (~0.9 everywhere); the reduced-form RI already lives in
            *Table 3
            forvalues g = 1/3 {
                local cond ""
                if `g' == 2 local cond "if serie<7"
                if `g' == 3 local cond "if serie>5"

                *------------------->
                *ITT: reduced form
                local ++m
                eststo test`m': reg `var' d $estrato `cond', cluster(cd_escola)

                matrix define   pwolf_m = J(1,1,0)
                matrix colnames pwolf_m = "d"
                matrix pwolf_m[1,1]     = rw_`var'_`g'
                estadd matrix pwolfmat  = pwolf_m     : test`m'
                estadd scalar pwolf     = rw_`var'_`g' : test`m'
                local models "`models' test`m'"

                *------------------->
                *LATE: conservative exposure (rw1), then broad exposure (rw2)
                local k = 0
                foreach z in treated treated2 {
                    local ++m
                    local ++k
                    eststo test`m': ivregress 2sls `var' $estrato (`z' = d) `cond', vce(cluster cd_escola)

                    matrix define   pwolf_m = J(1,1,0)
                    matrix colnames pwolf_m = "`z'"
                    matrix pwolf_m[1,1]     = rw`k'_`var'_`g'
                    estadd matrix pwolfmat  = pwolf_m       : test`m'
                    estadd scalar pwolf     = rw`k'_`var'_`g' : test`m'
                    local models "`models' test`m'"
                }
            }

            esttab `models' using "$textables/Table5.tex", `mode' ///
                rename(treated d treated2 d) keep(d) coeflabels(d "Treatment") ///
                cells(b(star pvalue(pwolfmat) fmt(%9.3f)) se(par fmt(%9.3f))) ///
                stats(pwolf N r2, fmt(%9.3f %9.0f %9.3f) labels("pvalue RW" "N. obs" "R-squared")) ///
                starlevels(* 0.10 ** 0.05 *** 0.01) fragment nolines nonumbers nomtitles collabels(none) ///
                prehead("`sep'") refcat(d "\textbf{`pname'}", nolabel)
            local mode append
            local sep  "\midrule"
        }

        display "IV_TABLE_DONE"
    }


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 5: Table A.10 -- Average causal mediation effects (ACME)
    *Generates the LaTeX fragment for the causal-mediation table (Table A.10 in the paper, ACME).
    *Mediator = financial proficiency (sm). Estimated with medeff (mediation package).
    *Sample: 5th, 7th and 9th grades only -- 3rd graders (who answered only pigg and finan_serv) are excluded,
    *so every outcome covers the same grades. Seeds kept from the original 3_Regressions.do, one per level.
    *The strata controls are detected automatically per estimation sample: medeff breaks if any coefficient is
    *omitted, so a stratum with no variation in the (level x outcome) sample is dropped from the controls
    *(this replaces the hand-picked strata lists of the original code).
    *
    *NOTE on labels: 3_Regressions.do assigned the row labels in an order that swapped
    *"Total effect" and "ACME". medeff returns:
    *  r(delta0)=ACME, r(zeta1)=ADE, r(tau)=Total effect, r(navg)=proportion mediated.
    *This do-file uses the CORRECT mapping (Total=tau, ADE=zeta1, ACME=delta0, %=navg).
    *
    *medsens / sensitivity charts are NOT run here (only the table is produced).
    *Output: Output/Tables/TableA10.tex -- data rows only; the table shell lives in Paper/Fin_Lit_Paper.tex (appendix)
    *____________________________________________________________________________________________________________________________________*
    **
    {
        use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear
        merge m:1 cd_escola using "$dtinter/School characteristics.dta", keep(match master) nogen
        tab complexidade, gen(complexidade)

        local scov ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess complexidade2 complexidade3

        *-------------------------------------------------------------------------------------------------------------->
        *Estimation -- one group per level, 3rd graders excluded everywhere.
        *Column order: 1 consump 2 save 3 talk_parents 4 talk_friends 5 pigg 6 finan_serv 7 allowance2.
        *Each estimate -> matrix R_`level'_`col' (rows: Total(tau) ADE(zeta1) ACME(delta0) %med(navg); cols: mean lo hi).
        local levels   pooled primary middle
        local conds    `" "if serie>3" "if serie==5" "if serie>5" "'
        local seeds    896749 089770 410672
        local outcomes pca_consump_sm pca_save_sm talk_parents talk_friends pigg finan_serv allowance2
        local strata   strata421 strata422 strata423 strata132 strata133

        forvalues s = 1/3 {
            local lev  : word `s' of `levels'
            local ifc  : word `s' of `conds'
            local seed : word `s' of `seeds'
            local c = 0
            foreach v of local outcomes {
                local ++c

                *Keep only the strata whose coefficient is not omitted in this (level x outcome) estimation sample
                qui reg `v' d sm `strata' `scov' `ifc'
                matrix b = e(b)
                local names : colfullnames b
                local strat ""
                foreach x of local strata {
                    if strpos("`names'", "o.`x'") == 0 local strat "`strat' `x'"
                }

                medeff (regress sm d `strat' `scov') (regress `v' d sm `strat' `scov') `ifc', treat(d) mediate(sm) seed(`seed')
                matrix R_`lev'_`c' = (r(tau)   , r(taulo)   , r(tauhi)    \ ///
                                      r(zeta1) , r(zeta1lo) , r(zeta1hi)  \ ///
                                      r(delta0), r(delta0lo), r(delta0hi) \ ///
                                      r(navg)  , r(navglo)  , r(navghi))
            }
        }

        *-------------------------------------------------------------------------------------------------------------->
        *Write the LaTeX fragment -- data rows only; the table shell (caption, column headers, notes) lives in
        *Paper/Fin_Lit_Paper.tex (appendix)
        local rownames `" "Total effect" "ADE" "ACME" "\% mediated" "'
        local levnames `" "Pooled" "Primary education students" "Middle school students" "'
        local levkeys  pooled primary middle

        file open tex using "$textables/TableA10.tex", write replace
        file write tex "% Generated by 3_Regressions.do (Section 5) -- data rows only, do not edit by hand." _n
        forvalues lv = 1/3 {
            local L     : word `lv' of `levkeys'
            local Lname : word `lv' of `levnames'
            file write tex "\multicolumn{15}{l}{\textit{`Lname'}} \\" _n
            forvalues r = 1/4 {
                local rn : word `r' of `rownames'
                file write tex "`rn'"
                forvalues c = 1/7 {
                    local m  = R_`L'_`c'[`r',1]
                    local lo = R_`L'_`c'[`r',2]
                    local hi = R_`L'_`c'[`r',3]
                    if missing(`m') file write tex " &  & "
                    else file write tex " & " (strtrim(string(`m',"%9.3f"))) " & [" (strtrim(string(`lo',"%9.3f"))) ", " (strtrim(string(`hi',"%9.3f"))) "]"
                }
                file write tex " \\" _n
            }
            if `lv' < 3 file write tex "\addlinespace" _n
        }

        file close tex

        display "ACME_TABLE_DONE"
    }


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 6: Figures 1, B.2a and B.2b -- quantile treatment effects on financial proficiency
    *____________________________________________________________________________________________________________________________________*
    **
    {
        estimates clear
        use "$dtfinal/Fin_Lit_pooled_data_clean.dta", replace
        reg sm $estrato
        predict resid, residuals

        set seed 551118

        *-------------------------------------------------------------------------------------------------------------->
        *Pooled
        preserve
            cap noi eststo: sqreg resid d,              quantile(.05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .55 .6 .65 .7 .75 .8 .85 .9 .95) reps(1000)
            charts, model("Pooled")
        restore

        *-------------------------------------------------------------------------------------------------------------->
        *Primary education
        preserve
            cap noi eststo: sqreg resid d if serie < 7, quantile(.05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .55 .6 .65 .7 .75 .8 .85 .9 .95) reps(1000)
            charts, model("Elementary education")
        restore

        *-------------------------------------------------------------------------------------------------------------->
        *Middle school
        preserve
            cap noi eststo: sqreg resid d if serie > 5, quantile(.05 .1 .15 .2 .25 .3 .35 .4 .45 .5 .55 .6 .65 .7 .75 .8 .85 .9 .95) reps(1000)
            charts, model("Middle school")
        restore

        *-------------------------------------------------------------------------------------------------------------->
        *Figure 1: the three samples side by side in a single figure
        graph combine "$figures/uqitt_pooled.gph" "$figures/uqitt_elementary.gph" "$figures/uqitt_middle.gph", ///
            rows(1) ycommon ///
            graphregion(color(white) fcolor(white) lcolor(white) icolor(white) ifcolor(white) ilcolor(white)) ///
            ysize(4.5) xsize(13)
        graph export "$figures/Figure1.pdf", as(pdf) replace

        erase "$figures/uqitt_pooled.gph"
        erase "$figures/uqitt_elementary.gph"
        erase "$figures/uqitt_middle.gph"
        *grqreg, ols
    }


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 7: Appendix figures -- ACME sensitivity analysis (medsens)
    *Table A13, Figures 1, 2, 3 appendix.
    *____________________________________________________________________________________________________________________________________*
    **
    {
        use   "$dtfinal/Fin_Lit_pooled_data_clean.dta", replace
        merge m:1 cd_escola using "$dtinter/School characteristics.dta", keep (match master) nogen

        tab complexidade, gen (complexidade)                                         //Fiz isso porque o comando medeff nao aceita factor variables
        //Este comando não aceita nenhum coeficiente que seja missing na regressão. Depois de rodar pela primeira vez, eu vi os eventuais missings e os excluí dos controles das regressões abaixo.

        *-------------------------------------------------------------------------------------------------------------->
        *Pooled
        local nvar = 1
        foreach var of varlist pca_consump_sm pca_save_sm talk_parents talk_friends pigg finan_serv allowance2 {
            medsens (regress sm d strata421 strata422 strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) 	(regress `var' d sm  strata421 strata422 strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3), treat(d) mediate(sm)
            chart, ciclo(pooled) var(`var')
            local nvar = `nvar' + 1
        }

        *-------------------------------------------------------------------------------------------------------------->
        *Primary education
        local nvar = 1
        foreach var of varlist pca_consump_sm pca_save_sm talk_parents talk_friends allowance2 {
            medsens  (regress sm d strata421 		  strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3)  (regress `var' d sm strata421 		    strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie < 7 , treat(d) mediate(sm)
            chart, ciclo(1st) var(`var')
            local nvar = `nvar' + 1
        }

        foreach var of varlist pigg finan_serv {
            medsens  (regress sm d strata421 strata422 strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3)  (regress `var' d sm strata421 strata422 strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie < 7 , treat(d) mediate(sm)
            chart, ciclo(1st) var(`var')
            local nvar = `nvar' + 1
        }

        *-------------------------------------------------------------------------------------------------------------->
        *Middle school
        local nvar = 1
        foreach var of varlist pca_consump_sm pca_save_sm talk_parents pigg finan_serv allowance2 {
            medsens  (regress sm d 				      strata423 strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) (regress `var' d sm   					strata423 	strata132 strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie > 5 , treat(d) mediate(sm)
            chart, ciclo(2nd) var(`var')
            local nvar = `nvar' + 1
        }

        foreach var of varlist talk_friends {
            medsens  (regress sm d  		strata422 strata423 		  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) 	(regress `var' d sm 		  strata422 strata423 			  strata133 ComputerLab ScienceLab WasteCollection WasteRecycling SportCourt SewerAccess  complexidade2 complexidade3) if serie > 5 , treat(d) mediate(sm)
            chart, ciclo(2nd) var(`var')
            local nvar = `nvar' + 1
        }

        *-------------------------------------------------------------------------------------------------------------->
        *Combine the .gph panels into the three appendix figures and clean up
        graph combine "$projectfolder/Apooledpca_consump_sm.gph" "$projectfolder/Apooledpca_save_sm.gph"    "$projectfolder/Apooledtalk_parents.gph" ///
                      "$projectfolder/Apooledtalk_friends.gph"   "$projectfolder/Apooledpigg.gph"           "$projectfolder/Apooledfinan_serv.gph"   ///
                      "$projectfolder/Apooledallowance2.gph", cols(2) xsize(4) ysize(8)
        graph export  "$figures\FigureOA1.pdf", as(pdf) replace

        graph combine "$projectfolder/A1stpca_consump_sm.gph"    "$projectfolder/A1stpca_save_sm.gph"       "$projectfolder/A1sttalk_parents.gph"    ///
                      "$projectfolder/A1sttalk_friends.gph"      "$projectfolder/A1stpigg.gph"              "$projectfolder/A1stfinan_serv.gph"      ///
                      "$projectfolder/A1stallowance2.gph",    cols(2) xsize(4) ysize(8)
        graph export  "$figures\FigureOA2.pdf", as(pdf) replace

        graph combine "$projectfolder/A2ndpca_consump_sm.gph"    "$projectfolder/A2ndpca_save_sm.gph"       "$projectfolder/A2ndtalk_parents.gph"    ///
                      "$projectfolder/A2ndtalk_friends.gph"      "$projectfolder/A2ndpigg.gph"              "$projectfolder/A2ndfinan_serv.gph"      ///
                      "$projectfolder/A2ndallowance2.gph",    cols(2) xsize(4) ysize(8)
        graph export  "$figures\FigureOA3.pdf", as(pdf) replace

        foreach name in pca_consump_sm pca_save_sm talk_parents talk_friends pigg finan_serv allowance2 {
            cap noi erase "$projectfolder\Apooled`name'.gph"
            cap noi erase "$projectfolder\A1st`name'.gph"
            cap noi erase "$projectfolder\A2nd`name'.gph"
        }
    }


    **
    *____________________________________________________________________________________________________________________________________*
    **
    *Section 8: Table OA1 -- Table 3 re-estimated with class-clustered standard errors (online appendix)
    *Same point estimates and structure as Section 2; the only change is the level of clustering, from the school
    *(the randomization unit) to the class (cd_turma). The Romano-Wolf bootstrap therefore resamples class clusters
    *within randomization strata. The RI p-value still permutes the treatment across schools within strata, the
    *actual randomization design; only the test statistic uses the class-clustered standard error.
    *esttab writes the coefficient rows to $textables/TableOA1.tex; the shell lives in Paper/online_appendix.tex.
    *____________________________________________________________________________________________________________________________________*
    **
    {
        local REPS = 1000                                                            //ritest repetitions

        use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

        *-------------------------------------------------------------------------------------------------------------->
        *Romano-Wolf adjusted p-values -- same 19-hypothesis family as Section 2, with class clusters
        foreach v in sm pca_consump_sm pca_save_sm {
            gen double `v'_R1 = `v'
            gen double `v'_R2 = `v' if serie<7
            gen double `v'_R3 = `v' if serie>5
            gen double `v'_R5 = `v' if serie==5
            gen double `v'_R6 = `v' if serie==7
            gen double `v'_R7 = `v' if serie==9
        }
        gen double sm_R4 = sm if serie==3

        rwolf2 (reg sm_R1             d $estrato, cluster(cd_turma)) ///
               (reg pca_consump_sm_R1 d $estrato, cluster(cd_turma)) ///
               (reg pca_save_sm_R1    d $estrato, cluster(cd_turma)) ///
               (reg sm_R2             d $estrato, cluster(cd_turma)) ///
               (reg pca_consump_sm_R2 d $estrato, cluster(cd_turma)) ///
               (reg pca_save_sm_R2    d $estrato, cluster(cd_turma)) ///
               (reg sm_R3             d $estrato, cluster(cd_turma)) ///
               (reg pca_consump_sm_R3 d $estrato, cluster(cd_turma)) ///
               (reg pca_save_sm_R3    d $estrato, cluster(cd_turma)) ///
               (reg sm_R4             d $estrato, cluster(cd_turma)) ///
               (reg sm_R5             d $estrato, cluster(cd_turma)) ///
               (reg pca_consump_sm_R5 d $estrato, cluster(cd_turma)) ///
               (reg pca_save_sm_R5    d $estrato, cluster(cd_turma)) ///
               (reg sm_R6             d $estrato, cluster(cd_turma)) ///
               (reg pca_consump_sm_R6 d $estrato, cluster(cd_turma)) ///
               (reg pca_save_sm_R6    d $estrato, cluster(cd_turma)) ///
               (reg sm_R7             d $estrato, cluster(cd_turma)) ///
               (reg pca_consump_sm_R7 d $estrato, cluster(cd_turma)) ///
               (reg pca_save_sm_R7    d $estrato, cluster(cd_turma)) ///
             , indepvars(d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d) cluster(cd_turma) strata(estrato) reps(1000) seed(20150101) nodots

        forvalues c = 1/7 {
            foreach v in sm pca_consump_sm pca_save_sm {
                if `c' == 4 & "`v'" != "sm" continue                                 //attitude indices do not exist in the 3rd grade
                scalar rw_`v'_`c' = e(rw_`v'_R`c'_d)
            }
        }
        drop sm_R* pca_consump_sm_R* pca_save_sm_R*

        set seed 20150101                                                            //reproducible randomization-inference p-values (rwolf2 resets the RNG state)

        *-------------------------------------------------------------------------------------------------------------->
        *One vertical panel per outcome, exactly as in Section 2
        local mode replace
        local sep  ""
        foreach var of varlist sm pca_consump_sm pca_save_sm {
            if "`var'" == "sm"             local pname "Financial proficiency"
            if "`var'" == "pca_consump_sm" local pname "Consumption index"
            if "`var'" == "pca_save_sm"    local pname "Saving index"

            est clear
            local models ""
            local extra  ""
            forvalues c = 1/7 {
                *Column -> subsample (single-token conditions, no macro word-lists)
                local cond ""
                if `c' == 2 local cond "if serie<7"
                if `c' == 3 local cond "if serie>5"
                if `c' == 4 local cond "if serie==3"
                if `c' == 5 local cond "if serie==5"
                if `c' == 6 local cond "if serie==7"
                if `c' == 7 local cond "if serie==9"

                *Attitude indices were not collected in the 3rd grade -> flag an empty 4th column (extracols) and skip it
                if `c' == 4 & "`var'" != "sm" {
                    local extra "extracols(4)"
                }
                else {
                    eststo test`c': reg `var' d $estrato `cond', cluster(cd_turma)
                    ritest d _b[d], reps(`REPS') cluster(cd_escola) strata(estrato) nodots: ///
                        reg `var' d $estrato `cond', cluster(cd_turma)
                    add, results(`c')
                    matrix define   pwolf_m = J(1,1,0)
                    matrix colnames pwolf_m = "d"
                    matrix pwolf_m[1,1]     = rw_`var'_`c'
                    estadd matrix pwolfmat = pwolf_m : test`c'
                    estadd scalar pwolf = rw_`var'_`c' : test`c'
                    local models "`models' test`c'"
                }
            }

            esttab `models' using "$textables/TableOA1.tex", `mode' `extra' ///
                keep(d) coeflabels(d "Treatment") ///
                cells(b(star pvalue(pwolfmat) fmt(%9.3f)) se(par fmt(%9.3f))) ///
                stats(pwolf pvalue N r2, fmt(%9.3f %9.3f %9.0f %9.3f) labels("pvalue RW" "pvalue RI" "N. obs" "R-squared")) ///
                starlevels(* 0.10 ** 0.05 *** 0.01) fragment nolines nonumbers nomtitles collabels(none) ///
                prehead("`sep'") refcat(d "\textbf{`pname'}", nolabel)
            local mode append
            local sep  "\midrule"
        }
        display "TABLEOA1_DONE"
    }
