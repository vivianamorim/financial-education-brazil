*Experimento: Romano-Wolf com familia UNICA (desfechos x amostras) vs. familia por coluna
*Pergunta da equipe: os p ajustados sobem quando testamos todas as hipoteses juntas?

clear all
set more off

global dtfinal "C:/Users/vivia/OneDrive/Documentos/GitHub/financial-education-brazil/Datawork/Data/3. Final"
global estrato "strata421 strata422 strata423 strata131 strata132 strata133"

cap which rwolf2
if _rc ssc install rwolf2

use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

*Clones com nomes distintos: rwolf2 guarda e(rw_<depvar>_d); depvars repetidos colidiriam
foreach v in sm pca_consump_sm pca_save_sm {
    gen double `v'_P = `v'                  //pooled
    gen double `v'_E = `v' if serie<7       //elementary (3,5)
    gen double `v'_M = `v' if serie>5       //middle (7,9)
    gen double `v'_5 = `v' if serie==5
    gen double `v'_7 = `v' if serie==7
    gen double `v'_9 = `v' if serie==9
}
gen double sm_3 = sm if serie==3

di as res _n "===================== EXPERIMENTO 1: familia unica, 9 hipoteses (3 desfechos x pooled/elem/middle) ====================="
rwolf2 (reg sm_P             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_P d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_P    d $estrato, cluster(cd_escola)) ///
       (reg sm_E             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_E d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_E    d $estrato, cluster(cd_escola)) ///
       (reg sm_M             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_M d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_M    d $estrato, cluster(cd_escola)) ///
     , indepvars(d, d, d, d, d, d, d, d, d) cluster(cd_escola) strata(estrato) reps(1000) seed(20150101) nodots

di as res _n "--- RESULTADO EXP 1 (rw = ajustado familia unica) ---"
foreach s in P E M {
    foreach v in sm pca_consump_sm pca_save_sm {
        di as txt "`v'_`s' : rw_joint9 = " as res %6.4f e(rw_`v'_`s'_d)
    }
}

di as res _n "===================== EXPERIMENTO 2: familia maxima, 19 hipoteses (+ colunas de serie) ====================="
rwolf2 (reg sm_P             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_P d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_P    d $estrato, cluster(cd_escola)) ///
       (reg sm_E             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_E d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_E    d $estrato, cluster(cd_escola)) ///
       (reg sm_M             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_M d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_M    d $estrato, cluster(cd_escola)) ///
       (reg sm_3             d $estrato, cluster(cd_escola)) ///
       (reg sm_5             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_5 d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_5    d $estrato, cluster(cd_escola)) ///
       (reg sm_7             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_7 d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_7    d $estrato, cluster(cd_escola)) ///
       (reg sm_9             d $estrato, cluster(cd_escola)) ///
       (reg pca_consump_sm_9 d $estrato, cluster(cd_escola)) ///
       (reg pca_save_sm_9    d $estrato, cluster(cd_escola)) ///
     , indepvars(d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d, d) cluster(cd_escola) strata(estrato) reps(1000) seed(20150101) nodots

di as res _n "--- RESULTADO EXP 2 (rw = ajustado familia maxima, 19 hipoteses) ---"
foreach s in P E M {
    foreach v in sm pca_consump_sm pca_save_sm {
        di as txt "`v'_`s' : rw_joint19 = " as res %6.4f e(rw_`v'_`s'_d)
    }
}
di as txt "sm_3 : rw_joint19 = " as res %6.4f e(rw_sm_3_d)
foreach s in 5 7 9 {
    foreach v in sm pca_consump_sm pca_save_sm {
        di as txt "`v'_`s' : rw_joint19 = " as res %6.4f e(rw_`v'_`s'_d)
    }
}

di as res _n "FIM DO EXPERIMENTO"
