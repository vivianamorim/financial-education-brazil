"""
Reconstrucao do procedimento de amostragem do piloto ENEF em Manaus (2015).

CONTEXTO
--------
O do-file original da amostragem de 2015 se perdeu e nenhum autor lembra do
procedimento. O paper dizia apenas que as escolas foram selecionadas "based on
the distribution of the Educational Development Index (IDEB)", sem explicar como.
Este script recupera o procedimento a partir dos dados.

RESULTADO
---------
Etapa 1 -- amostragem (so em Manaus, so nos estratos de ciclo unico):
  Em ambos os estratos as escolas foram ordenadas pelo IDEB 2013 do ciclo que
  ofertavam, divididas em quartis, e um numero IGUAL foi sorteado de cada quartil:

    EF1 (so 1o-5o)   frame de 180 escolas com IDEB  ->  9 por quartil  =  36
    EF2 (so 6o-9o)   frame de  32 escolas com IDEB  ->  7 por quartil  =  28

  As duas divisoes sao exatas. P sob amostragem aleatoria simples: 0,0062 no EF1
  e 0,036 no EF2; conjuntamente 0,0002. Dentro de cada quartil as sorteadas sao
  indistinguiveis das nao-sorteadas, ou seja, o sorteio interno foi aleatorio.

Etapa 2 -- randomizacao (nos 6 estratos): sorteio uniforme por escola, rank dentro
do estrato, metade de cima tratada. Reproduz o tratamento em 201/201 escolas.

CUIDADO METODOLOGICO
--------------------
O IDEB vem arredondado a uma casa decimal, entao ha muitos empates. Quartis
calculados por RANK (pandas qcut) quebram os empates arbitrariamente e destroem o
padrao -- foi assim que a alocacao igual do EF2 passou despercebida numa primeira
analise. E preciso usar quartis por VALOR, como faz o xtile do Stata: corta nos
percentis 25/50/75 e atribui pelo valor, aceitando grupos de tamanhos diferentes.
No EF2 os quartis tem 9/9/7/7 escolas, e mesmo assim saiu 7 de cada.

DADOS
-----
Data/0. DeIdentification/Identified/
  - Treatment and Control Groups.dta ....... as 201 escolas do estudo, com codigo
                                             INEP real, estrato e tipo de escola
  - Enrollment by school_2007-2017.dta ..... matricula no 5o e no 9o ano de TODAS
                                             as escolas -> define tipo e frame
Data/1. Raw/
  - IDEB_2015_ANOS_INICIAIS_ESCOLAS.xlsx ... IDEB por escola (serie 2005-2015)
  - IDEB_2015_ANOS_FINAIS_ESCOLAS.xlsx
    Fonte: https://download.inep.gov.br/educacao_basica/portal_ideb/
           planilhas_para_download/2015/divulgacao_anos_{iniciais,finais}_escolas_2015.zip

Dependencias: pandas, numpy, scipy, pyreadstat, openpyxl
Rodar a partir da pasta "Do files".
"""

import pandas as pd
import numpy as np
from math import comb
from scipy import stats
import pyreadstat

IDENT = "../Data/0. DeIdentification/Identified/"
RAW = "../Data/1. Raw/"
MANAUS, MUNICIPAL = 1302603, 3

# Coluna do IDEB 2013 em cada arquivo do INEP. As posicoes diferem porque os anos
# iniciais tem 5 series (1o-5o) e os anos finais tem 4 (6o-9o).
IDEB_ARQ = {"AI": ("IDEB_2015_ANOS_INICIAIS_ESCOLAS.xlsx", 70),
            "AF": ("IDEB_2015_ANOS_FINAIS_ESCOLAS.xlsx", 64)}


def ideb_2013(ciclo):
    """IDEB 2013 por escola, so Manaus, rede municipal."""
    import openpyxl
    arquivo, coluna = IDEB_ARQ[ciclo]
    ws = openpyxl.load_workbook(RAW + arquivo, read_only=True).worksheets[0]
    linhas = []
    for r in ws.iter_rows(min_row=9, values_only=True):
        if r[1] and str(r[1]) == str(MANAUS) and r[5] == "Municipal":
            linhas.append({"cod": int(r[3]), "ideb2013": r[coluna]})
    df = pd.DataFrame(linhas)
    df["ideb2013"] = pd.to_numeric(df.ideb2013.replace("-", np.nan), errors="coerce")
    return df


def escolas_de_manaus():
    """Uma linha por escola municipal de Manaus, com o tipo definido pela
    matricula no 5o e no 9o ano em 2015 e com o tipo atribuido pelo estudo."""
    estudo, _ = pyreadstat.read_dta(IDENT + "Treatment and Control Groups.dta")
    estudo["cod"] = estudo.cd_escola.astype("int64")

    matr, _ = pyreadstat.read_dta(IDENT + "Enrollment by school_2007-2017.dta")
    e = matr[(matr.Year == 2015) & (matr.Network == MUNICIPAL) &
             (matr.Codmunic == MANAUS)].copy()
    e["cod"] = e.Codschool.astype("int64")

    tem_ef1, tem_ef2 = e.Enrollment5Grade > 0, e.Enrollment9Grade > 0
    e["tipo"] = np.where(tem_ef1 & tem_ef2, "1-9",
                np.where(tem_ef1, "1-5", np.where(tem_ef2, "6-9", None)))
    return estudo, e.merge(estudo[["cod", "tipo_escola"]], on="cod", how="left")


def quartis_por_valor(x):
    """Quartis no estilo xtile do Stata: corta nos percentis 25/50/75 e atribui
    pelo valor. Com empates os grupos ficam de tamanhos diferentes -- e isso e o
    correto. Nao usar qcut sobre ranks (ver CUIDADO METODOLOGICO no cabecalho)."""
    p25, p50, p75 = np.percentile(x.dropna().values, [25, 50, 75])
    return x.map(lambda v: np.nan if pd.isna(v) else
                 1 if v <= p25 else 2 if v <= p50 else 3 if v <= p75 else 4)


def testar_alocacao(frame, rotulo, esperado):
    """Distribui o frame em quartis de IDEB e conta quantas foram sorteadas."""
    d = frame.dropna(subset=["ideb2013"]).copy()
    d["quartil"] = quartis_por_valor(d.ideb2013)
    t = d.groupby("quartil").agg(populacao=("cod", "size"), sorteadas=("sorteada", "sum"),
                                 ideb_min=("ideb2013", "min"), ideb_max=("ideb2013", "max"))
    print(f"\n=== {rotulo} (N={len(d)}, sorteadas={int(d.sorteada.sum())}) ===")
    print(t.to_string())

    if t.sorteadas.tolist() == [esperado] * 4:
        num = 1
        for g in t.populacao:
            num *= comb(int(g), esperado)
        p = num / comb(int(t.populacao.sum()), esperado * 4)
        print(f"    ALOCACAO IGUAL: {esperado} por quartil"
              f"   |   P sob amostragem aleatoria simples = {p:.4f}  (1 em {1/p:.0f})")
    else:
        print(f"    alocacao desigual: {t.sorteadas.tolist()}")
    return d


def sorteio_dentro_do_quartil(d, variaveis):
    """As sorteadas se distinguem das demais dentro do mesmo quartil?"""
    d = d.copy()
    d["posicao"] = d.groupby("quartil").ideb2013.rank(pct=True)
    print("\n   sorteadas vs nao-sorteadas dentro do quartil:")
    for v in ["ideb2013", "posicao"] + variaveis:
        a, b = d.loc[d.sorteada, v].dropna(), d.loc[~d.sorteada, v].dropna()
        _, p = stats.ttest_ind(a, b, equal_var=False)
        print(f"     {v:<18} sorteadas={a.mean():8.2f}  nao={b.mean():8.2f}  p={p:.3f}")


def main():
    estudo, manaus = escolas_de_manaus()

    print("ETAPA 2 -- randomizacao")
    regra = (estudo.ordem <= estudo.nro_selec).astype(float)
    print(f"   'ordem <= nro_selec' reproduz o tratamento em "
          f"{int((regra == estudo.resultado).sum())}/{len(estudo)} escolas")

    print("\nETAPA 1 -- amostragem")

    # EF1: escolas que ofertavam apenas os anos iniciais.
    ef1 = manaus[manaus.tipo == "1-5"].merge(ideb_2013("AI"), on="cod", how="left")
    ef1["sorteada"] = ef1.tipo_escola.eq(1)
    d1 = testar_alocacao(ef1, "EF1 -- escolas que ofertavam so 1o-5o", 9)
    sorteio_dentro_do_quartil(d1, ["Enrollment5Grade"])

    # EF2: o frame sao as 28 escolas que o estudo classificou como de anos finais
    # (21 sem matricula no 5o ano e 7 com turmas residuais de anos iniciais) mais
    # as 6 escolas sem 5o ano que ficaram de fora. Da 34; a Tabela A.2 registra 35,
    # e a 35a escola nao foi identificada.
    ef2 = manaus[(manaus.tipo == "6-9") | manaus.tipo_escola.eq(2)].merge(
        ideb_2013("AF"), on="cod", how="left")
    ef2["sorteada"] = ef2.tipo_escola.eq(2)
    d2 = testar_alocacao(ef2, "EF2 -- escolas que ofertavam so 6o-9o", 7)
    sorteio_dentro_do_quartil(d2, ["Enrollment9Grade"])


if __name__ == "__main__":
    main()
