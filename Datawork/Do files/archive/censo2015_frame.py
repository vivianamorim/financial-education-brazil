"""
Quantas escolas de Manaus e Joinville ofertavam EF1, EF2, ou os dois, em 2015.

PARA QUE SERVE
--------------
A Tabela A.2 do paper parte de um universo de escolas municipais dividido em tres
tipos (so 1o-5o, so 6o-9o, 1o-9o). Este arquivo reconstroi essa contagem direto do
Censo Escolar 2015, separando urbanas e rurais, para documentar de onde vem cada
numero do frame.

FONTE
-----
Data/1. Raw/CensoEscolar_2015/DADOS/microdados_ed_basica_2015.csv
  (microdados de escolas do Censo Escolar 2015, INEP -- uma linha por escola)

DUAS DEFINICOES DE "OFERTA"
---------------------------
O censo marca a oferta em blocos (anos iniciais / anos finais), mas o piloto so
avaliou as series 3, 5, 7 e 9. As duas definicoes nao dao o mesmo numero, entao o
script reporta as duas:

  (a) BLOCO   -- IN_FUND_AI / IN_FUND_AF do proprio censo.
  (b) SERIES-ALVO -- turmas nas series 3, 5, 7 e 9, a partir de
      Data/0. DeIdentification/Identified/Classrooms in Manaus and Joinville_2015.dta

RESSALVA IMPORTANTE
-------------------
Nenhuma das duas definicoes reproduz sozinha os 202 / 35 / 65 da Tabela A.2. Faltam
dois passos que nao estao no censo:
  1. oito escolas com 9o ano e turmas residuais de anos iniciais foram tratadas
     pelo estudo como escolas de EF2 (isso e o que produz o 35);
  2. as escolas ribeirinhas foram excluidas por uma lista da Secretaria de Educacao,
     que nao e derivavel do censo -- nao coincide com "rural".
Ver Revisao_Paper_Log.md, secao 2.3.

Rodar a partir da pasta "Do files".
"""

import pandas as pd
import numpy as np

CENSO = "../Data/1. Raw/CensoEscolar_2015/DADOS/microdados_ed_basica_2015.csv"
TURMAS = "../Data/0. DeIdentification/Identified/Classrooms in Manaus and Joinville_2015.dta"
IDEB = "../Data/1. Raw/"

MUNICIPIOS = {1302603: "Manaus", 4209102: "Joinville"}
MUNICIPAL = 3          # TP_DEPENDENCIA / Network
EM_ATIVIDADE = 1       # TP_SITUACAO_FUNCIONAMENTO
LOCALIZACAO = {1: "Urbana", 2: "Rural"}

# Arquivos de IDEB POR ESCOLA (a divulgacao de 2015 traz a serie 2005-2015).
# Os xlsx "IDEB at municipal level" da mesma pasta sao agregados por municipio e
# nao servem para contar escolas.
IDEB_ARQ = {"AI": "IDEB_2015_ANOS_INICIAIS_ESCOLAS.xlsx",
            "AF": "IDEB_2015_ANOS_FINAIS_ESCOLAS.xlsx"}
# A coluna do IDEB 2013 muda de posicao entre os dois arquivos porque os anos
# iniciais tem 5 series (1o-5o) e os anos finais tem 4 (6o-9o).
IDEB_2013_COL = {"AI": 70, "AF": 64}

COLS = ["CO_ENTIDADE", "NO_ENTIDADE", "CO_MUNICIPIO", "TP_DEPENDENCIA",
        "TP_LOCALIZACAO", "TP_SITUACAO_FUNCIONAMENTO",
        "IN_FUND_AI", "IN_FUND_AF", "QT_MAT_FUND_AI", "QT_MAT_FUND_AF"]


def rotular(tem_ef1, tem_ef2):
    return np.where(tem_ef1 & tem_ef2, "EF1 e EF2 (1-9)",
           np.where(tem_ef1, "so EF1 (1-5)",
           np.where(tem_ef2, "so EF2 (6-9)", "sem EF")))


def ler_censo():
    """Escolas municipais em atividade de Manaus e Joinville, do Censo 2015."""
    pedacos = pd.read_csv(CENSO, sep=";", encoding="latin-1", low_memory=False,
                          usecols=lambda c: c in COLS, chunksize=200_000)
    df = pd.concat([p[p.CO_MUNICIPIO.isin(MUNICIPIOS)] for p in pedacos])
    df = df[(df.TP_DEPENDENCIA == MUNICIPAL) &
            (df.TP_SITUACAO_FUNCIONAMENTO == EM_ATIVIDADE)].copy()
    df["municipio"] = df.CO_MUNICIPIO.map(MUNICIPIOS)
    df["localizacao"] = df.TP_LOCALIZACAO.map(LOCALIZACAO)
    df["tipo"] = rotular(df.IN_FUND_AI == 1, df.IN_FUND_AF == 1)
    df["cod"] = df.CO_ENTIDADE.astype("int64")
    return df


def ler_series_alvo():
    """Tipo de escola definido pelas turmas nas series avaliadas (3, 5, 7, 9)."""
    import pyreadstat
    turmas, _ = pyreadstat.read_dta(TURMAS)
    g = (turmas.groupby(["Codschool", "Codmunic", "Network"])
         [["TClass3Grade", "TClass5Grade", "TClass7Grade", "TClass9Grade"]]
         .sum().reset_index())
    g = g[g.Network == MUNICIPAL].copy()
    g["cod"] = g.Codschool.astype("int64")
    g["tipo_alvo"] = rotular((g.TClass3Grade > 0) | (g.TClass5Grade > 0),
                             (g.TClass7Grade > 0) | (g.TClass9Grade > 0))
    return g[["cod", "tipo_alvo"]]


def ler_ideb_escolas(ciclo):
    """Codigos das escolas municipais de Manaus e Joinville com IDEB 2013."""
    import openpyxl
    ws = openpyxl.load_workbook(IDEB + IDEB_ARQ[ciclo], read_only=True).worksheets[0]
    col = IDEB_2013_COL[ciclo]
    com_nota = set()
    for r in ws.iter_rows(min_row=9, values_only=True):
        if r[1] is None or str(r[1]).strip() == "":
            continue
        if int(r[1]) in MUNICIPIOS and r[5] == "Municipal" and r[col] not in (None, "-"):
            com_nota.add(int(r[3]))
    return com_nota


def cobertura_ideb(df):
    """Quantas escolas de cada tipo tem nota no IDEB 2013.

    Uma escola so pode ter nota no ciclo que oferta: as de 1o-5o so aparecem nos
    anos iniciais, as de 6o-9o so nos anos finais, e as de 1o-9o podem ter as duas.
    """
    tem = {c: ler_ideb_escolas(c) for c in ("AI", "AF")}
    df = df[df.tipo != "sem EF"].copy()
    df["tem_ai"] = df.cod.isin(tem["AI"])
    df["tem_af"] = df.cod.isin(tem["AF"])
    df["com_nota"] = np.where(df.tipo == "so EF1 (1-5)", df.tem_ai,
                     np.where(df.tipo == "so EF2 (6-9)", df.tem_af,
                              df.tem_ai | df.tem_af))

    print("\nEscolas com nota no IDEB 2013")
    print("-" * 28)
    g = (df.groupby(["municipio", "tipo", "localizacao"])
           .agg(escolas=("cod", "size"), com_nota=("com_nota", "sum"),
                so_anos_iniciais=("tem_ai", "sum"), so_anos_finais=("tem_af", "sum")))
    g["pct"] = (100 * g.com_nota / g.escolas).round(0).astype(int)
    g = g.rename(columns={"so_anos_iniciais": "nota_AI", "so_anos_finais": "nota_AF"})
    print(g[["escolas", "com_nota", "pct", "nota_AI", "nota_AF"]].to_string())

    ambos = df[df.tipo == "EF1 e EF2 (1-9)"]
    print("\n  entre as escolas de 1o-9o, quantas tem as DUAS notas:")
    print(ambos.groupby(["municipio", "localizacao"])
               .apply(lambda s: pd.Series({"escolas": len(s),
                                           "as duas": int((s.tem_ai & s.tem_af).sum()),
                                           "nenhuma": int((~s.tem_ai & ~s.tem_af).sum())}),
                      include_groups=False).to_string())
    return df


def mostrar(df, coluna, titulo):
    print(f"\n{titulo}")
    print("-" * len(titulo))
    com_ef = df[df[coluna] != "sem EF"]
    tab = pd.crosstab([com_ef.municipio, com_ef[coluna]], com_ef.localizacao,
                      margins=True, margins_name="Total")
    print(tab.to_string())
    print(f"\n  escolas municipais em atividade sem nenhum ano do fundamental: "
          f"{(df[coluna] == 'sem EF').sum()}")


def main():
    censo = ler_censo()
    print(f"Censo Escolar 2015 -- escolas municipais em atividade: {len(censo)}")
    mostrar(censo, "tipo", "(a) Oferta por BLOCO (IN_FUND_AI / IN_FUND_AF do censo)")

    censo = censo.merge(ler_series_alvo(), on="cod", how="left")
    censo["tipo_alvo"] = censo.tipo_alvo.fillna("sem EF")
    mostrar(censo, "tipo_alvo", "(b) Oferta pelas SERIES-ALVO do piloto (3o, 5o, 7o, 9o)")

    print("\nOnde as duas definicoes discordam")
    print("-" * 33)
    dif = censo[censo.tipo != censo.tipo_alvo]
    print(pd.crosstab(dif.tipo, dif.tipo_alvo).to_string())
    print("\n  Sao escolas que ofertam algum ano do bloco mas nenhuma serie avaliada")
    print("  (p.ex. 1o ao 4o ano, sem 5o), ou o contrario.")

    cobertura_ideb(censo)


if __name__ == "__main__":
    main()
