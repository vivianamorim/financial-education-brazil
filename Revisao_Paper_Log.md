# Log da Revisão do Paper AEJ — Financial Education in Elementary and Middle Schools (Brazil)

Arquivo de acompanhamento do trabalho de resposta aos comentários do reviewer sobre o working paper.
Última atualização: 2026-04-16.

---

## 1. Contexto

- **Paper**: "Experimental Evaluation of a Financial Education Program in Elementary and Middle School Grades"
- **Target**: AEJ (American Economic Journal)
- **Autores**: Caio Piza (DIME/WB), Isabela Furtado (Insper), Vivian Amorim (DIME/WB)
- **Status**: working paper; em revisão substantiva com base em um parecer de reviewer.
- **Arquivo principal**: `Paper/AEJ_paper.tex` (inclui os 7 capítulos `01_intro.tex` a `07_conclusion.tex` + `online_appendix.tex`).

---

## 2. O que já foi feito

### 2.1 Planilha de comentários do reviewer
- Arquivo: `Financial Literacy To do List.xlsx` (aba `Comments`).
- Foram adicionadas **duas colunas novas** (preservando o conteúdo original nas colunas B–F):
  - **Coluna G — "Resumo em português"**: reescrita em linguagem simples de cada comentário do reviewer.
  - **Coluna H — "Como endereçar"**: plano de ação concreto por comentário.
- Cobre todas as **49 observações** (linhas 5 a 53) agrupadas pelas tags do reviewer: Data, Empirical, Implementation, Intro, Minor, Pilot, Results.

### 2.2 Leitura do Relatório Ago/2016
- Arquivo: `Relatorio_EF_Ago2016.docx`.
- **Confirmado**: a maioria das estatísticas de compliance (recebimento do livro, semestre de uso, % de cobertura) **já está na Tabela 5 do paper** (`tab:implementation`, `AEJ_paper.tex:409`). A correção desses pontos é editorial — trazer os números para a narrativa da Seção 4 — não requer análise nova.
- **O que o relatório acrescenta** de fato (não está no paper hoje):
  - Modelo de treinamento em **cascata / train-the-trainer**: AEF → coordenadores pedagógicos (Joinville) / coordenadores das regionais (Manaus) → professores.
  - Datas dos treinamentos dos multiplicadores: Joinville fev/2015; Manaus fim de mar/2015.
  - **Encontro presencial com professores no início do 2º semestre** (correção intra-ano, motivada por baixa utilização no 1º semestre).
  - Questionários de monitoramento enviados aos supervisores ao longo do ano.
  - Liberdade explícita dada às escolas ("livres para usarem o material da maneira mais adequada a seus cronogramas pedagógicos") — ou seja, **sem protocolo padronizado de entrega**.
  - Estrutura conceitual dos 4 livros: dimensões **espacial** (indivíduo → global) e **temporal** (passado → presente → futuro, intertemporalidade).

### 2.3 Pendências técnicas identificadas no repo
- **Typo no `AEJ_paper.tex:182`**: `"thdee Brazilian Association"` → deve ser `"the Brazilian Association"` (introduzido em relação ao HEAD).
- **Caminho obsoleto no `Do files/Master.do:116`** (user 3 = Vivian): aponta para `C:\Users\Brian\OneDrive\Desktop\...` em vez do caminho atual do OneDrive.

---

## 3. Decisões tomadas

### 3.1 Divisão dos comentários entre seções

Alguns comentários do reviewer estavam tagueados em uma seção na planilha, mas logicamente pertencem a outra. Acordado:

| Row | Tag original | **Onde mora agora** | Motivo |
|---|---|---|---|
| 12 | Implementation | Implementation | Treinamento/coordenação |
| 13 | Implementation | Implementation | Compliance |
| 39 | Pilot | **Data (Seção 3)** | É sobre o instrumento/prova, não sobre o material didático |
| 40 | Pilot | **Dividido** | Conteúdo dos livros → Pilot; entrega/instrução → Implementation |
| 41 | Pilot | **Implementation** | É comportamento do professor em sala |
| 42 | Pilot | Pilot | Claim conceitual sobre o desenho |
| 43 | Pilot | Pilot | Conteúdo dos livros — requer tabela nova |
| 44 | Pilot | **Implementation** | É compliance |
| 31 | Minor | Implementation | "Cobertura ≠ qualidade" |
| 38 | Minor | Implementation | Timing do tratamento |
| 50 | Results | Implementation (conceito); Results (consequência) | Separar intensidade de qualidade |

### 3.2 Outras decisões
- **Atitudes de 3º ano (row 5)**: excluir da análise principal, manter só como robustez em apêndice. Questionário do 3º foi respondido pelos responsáveis, não pelos alunos — problema de validade.
- **Atitudes vs. preferências (row 6)**: no texto, tratar como "atitudes auto-declaradas", não como preferências reveladas. Reavaliar outcome "mesada".
- **MHT (rows 23, 34)**: aplicar correção Romano-Wolf ou List-Shaikh-Xu nas tabelas principais de ITT.
- **Lee bounds (rows 14, 49)**: estimar para lidar com seleção de turmas dentro das escolas.
- **Benchmarks da literatura (rows 28, 46, 52)**: remover comparação com Jamison et al. (2014) e com Carpena & Zia (adultos rurais na Índia). Incluir Kaiser & Menkhoff (2020) meta-analysis e Mangrum (2022).
- **Heterogeneidade entre séries (rows 32, 45, 53)**: rodar Wald/F-test formal de igualdade de coeficientes; onde não rejeitar, moderar linguagem e possivelmente deletar parágrafos especulativos.

---

## 4. Pendências / Próximos passos

### 4.1 Reescrita de seções (pendente)
- [ ] **Seção 4 (Implementation)**: reescrever cobrindo rows 12, 13, 31, 38, 41, 44, 50 + parte "como" do 40. Base: Tabela 5 existente + trechos qualitativos do Relatório Ago/2016.
- [ ] **Seção 2 (Pilot)**: reescrever cobrindo rows 42, 43 + parte "o quê" do 40. Base: notas em português já presentes em `02_pilot.tex:35-58` + possivelmente tese da Isabela (ver abaixo).
- [ ] **Seção 3 (Data)**: atacar rows 7, 8, 39 quando chegar a vez.
- [ ] **Seção 1 (Intro)**: atacar rows 15, 16, 17, 18 com foco em reformular contribuições.

### 4.2 Fontes externas a consultar
- [ ] **Tese da Isabela Furtado Brandão** (FGV/EESP, 2018): "Essays on Health at Birth, Financial Literacy and Educational Outcomes". O **Capítulo 1** trata exatamente deste piloto. Pode conter descrição detalhada do conteúdo dos livros por série, que ajudaria a responder rows 40, 41, 43.
  - Tentei baixar automaticamente mas o repositório da FGV bloqueia acesso (Anubis).
  - **Ação**: Isabela provavelmente tem o PDF, ou a Vivian baixa direto do repositório FGV no browser.
  - Links: [FGV Digital Library](https://bibliotecadigital.fgv.br/dspace/handle/10438/24575) | [BDTD](https://bdtd.ibict.br/vufind/Record/FGV_ae6a5804daaa33d48856da6d131bede6)
- [ ] **AEF-Brasil**: perguntar (i) carga horária do treinamento dos multiplicadores e dos professores; (ii) se os professores foram orientados a começar os livros pela Lição 1 ou se havia flexibilidade de ponto de partida.
- [ ] **Livros didáticos do programa ENEF/AEF**: se for necessário mapear conteúdo lição-a-lição e a tese não cobrir, precisaremos dos livros direto.

### 4.3 Análises a rodar
- [ ] Correção MHT (Romano-Wolf) nas tabelas principais de ITT.
- [ ] Lee bounds nos outcomes principais.
- [ ] Teste formal de igualdade de coeficientes entre séries/ciclos (Wald/F-test).
- [ ] Robustness: escore financeiro recalculado sem os descritores D01, D10, D11, D12 (row 22).
- [ ] Médias do grupo controle dos índices de consumo/poupança por série (gráfico/tabela) para dar contexto à interpretação do row 47.
- [ ] Taxa de match survey × dados administrativos por série; teste de balanceamento do atrito (row 7).
- [ ] Taxa de participação no ENEM por grupo (row 7).
- [ ] Teste de diferença de médias nas Tabelas A.5–A.10 com p-valores (rows 20, 25).
- [ ] Investigar variação de N na Tabela A.10 (row 26).

### 4.4 Correções editoriais pequenas
- [ ] Typo em `AEJ_paper.tex:182` ("thdee" → "the").
- [ ] Atualizar caminho do user 3 em `Do files/Master.do:116`.
- [ ] P-valores = 0 na Tabela 2 → usar "<0.001" (row 29).
- [ ] Corrigir referências a equações inexistentes no Online Appendix; definir `Mi(t)` na primeira aparição; discutir Figuras 1-3 do apêndice (row 27).
- [ ] Reescrever última frase do paper (row 24).
- [ ] Decidir se Figura B.2 vai para o corpo (row 21).
- [ ] Proofreading final (row 19).

---

## 5. Arquivos de apoio no repo

| Arquivo | Para que serve |
|---|---|
| `Financial Literacy To do List.xlsx` | Master tracker dos comentários do reviewer com resumo e plano de ação. |
| `Relatorio_EF_Ago2016.docx` | Relatório técnico de 2016 — útil para descrever o modelo de treinamento, datas e monitoramento. |
| `Paper/AEJ_paper.tex` | Arquivo principal. |
| `Paper/0{1..7}_*.tex` | Capítulos. |
| `Paper/online_appendix.tex` | Apêndice online (precisa revisão — row 27). |
| `Do files/Master.do` | Pipeline Stata (caminho do user 3 está obsoleto). |
| `Output/Tables/` e `Output/Figures/` | Saídas das análises. |
