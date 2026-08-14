*Teste de contaminacao: houve "tratamento" no grupo de controle?
*Lado 1 (alunos):     controle diz ter RECEBIDO o livro didatico? (socio_rp_61)
*Lado 2 (professores): controle responde as perguntas de APLICACAO do programa
*                      (prof1_rp_38-40: semestre de uso, avaliacao/qualidade, % coberto)

clear all
set more off

global dtfinal "C:/Users/vivia/OneDrive/Documentos/GitHub/financial-education-brazil/Datawork/Data/3. Final"
global estrato "strata421 strata422 strata423 strata131 strata132 strata133"

*=================== LADO 1: ALUNOS ===================
use "$dtfinal/Fin_Lit_pooled_data_clean.dta", clear

describe socio_rp_61
label list timing

cap drop received_book
gen received_book = inrange(socio_rp_61, 1, 3)   //1-3 = recebeu (inicio/meio/fim); 4 = nunca

di as res _n "--- % de alunos que dizem ter recebido o livro, por grupo ---"
tab d received_book if !missing(socio_rp_61), row

di as res _n "--- Distribuicao completa do timing (socio_rp_61) por grupo ---"
tab socio_rp_61 d, col

di as res _n "--- Escolas por faixa de % de alunos reportando livro, por grupo ---"
preserve
    collapse (mean) received_book (count) n=received_book, by(cd_escola d)
    gen faixa = 1 if received_book < .10
    replace faixa = 2 if received_book >= .10 & received_book < .25
    replace faixa = 3 if received_book >= .25 & received_book < .50
    replace faixa = 4 if received_book >= .50 & !missing(received_book)
    label define fx 1 "<10%" 2 "10-25%" 3 "25-50%" 4 ">=50%"
    label values faixa fx
    tab faixa d, col
restore

*=================== LADO 2: PROFESSORES ===================
use "C:/Users/vivia/OneDrive/Documentos/GitHub/financial-education-brazil/Datawork/Data/2. Intermediate/Teacher's data.dta", clear
keep cd_turma cd_escola prof1_rp_36 prof1_rp_37 prof1_rp_38 prof1_rp_39 prof1_rp_40 prof1_rp_41 prof1_rp_42
destring cd_escola, replace
merge m:1 cd_escola using "C:/Users/vivia/OneDrive/Documentos/GitHub/financial-education-brazil/Datawork/Data/2. Intermediate/Treatment and Control Groups.dta", keep(match master) nogen

describe prof1_rp_36-prof1_rp_42

di as res _n "--- Professores de CONTROLE respondendo as perguntas de aplicacao ---"
foreach v in prof1_rp_38 prof1_rp_39 prof1_rp_40 {
    di as res _n ">> `v' (respostas validas 1-8) por grupo:"
    gen answered_`v' = inrange(`v', 1, 8)
    tab resultado answered_`v', row
}

gen contaminada = inrange(prof1_rp_38,1,8) & inrange(prof1_rp_39,1,8) & inrange(prof1_rp_40,1,8) if resultado == 0
di as res _n "--- Turmas de controle 'tratadas' (professor respondeu as 3 perguntas) ---"
tab contaminada
codebook cd_escola if contaminada == 1, compact

di as res _n "--- % do livro coberto (prof1_rp_40) entre controles que responderam ---"
tab prof1_rp_40 if resultado == 0 & inrange(prof1_rp_40,1,8)

di as res _n "FIM DO TESTE DE CONTAMINACAO"
