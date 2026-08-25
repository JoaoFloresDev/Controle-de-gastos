# Mapa de proteção — iter-03 (Meus Gastos)

Derivado dos dados MEDIDOS nos estágios 1-3 (`longtails_br.csv`, `longtails_de.csv`, `term_fit_*.csv`, `asc_state.json`), cruzando cada composição em que já ranqueamos ≤ #50 com o token do campo que a sustenta.

**Regra que este arquivo impõe ao estágio 5:** token listado na coluna "token do campo" NÃO pode ser cortado sem substituição equivalente — mesmo quando o termo isolado for MISMATCH. Onde há conflito (token protege ranking mas atrai intenção alheia), a decisão é documentada aqui e fica para o compositor resolver com custo/benefício explícito, nunca por corte silencioso.

**Fonte e limite:** SERP/incumbentes vêm de `competitors.md` e da coluna `Top of SERP` do estágio 2 — não houve rodada nova de SERP nesta etapa (o agente do estágio 4 falhou três vezes seguidas: dois stalls de watchdog e uma queda por sleep da máquina). Rankings e pop/diff são os do Astro de 2026-08-24. Popularity Astro é a única fonte de volume: **pop 5 é piso de medição, não ausência de busca.**

## Contexto que calibra o alcançável

- 5,3 downloads/dia, ↑. 94,5% das impressões vêm de busca (506 imp/dia; BR 142,6 CVR 8,23%; DE 49,3 CVR 7,49%).
- **Massa de ratings é o gargalo: BR 18 (4,94), DE 2.** Gate da RULES.md = 25. Termo cujo SERP tem incumbente de 20k+ ratings não é alcançável nesta rodada.
- Todas as 24 composições rankeadas em br e as 9 em de são **pop 5**. Não há nenhum termo de volume medido acima do piso onde já ranqueemos.

## pt-BR — 24 composições rankeadas ≤ #50

| # | Termo | pop | dif | fit | Token que protege | Também vem de |
|---|---|---|---|---|---|---|
| 1 | contas mensais casal | 5 | 15 | PARTIAL | `contas`, `mensais` | name+subtitle |
| 1 | despesas mensais casal | 5 | 10 | PARTIAL | `mensais` | name+subtitle |
| 1 | despesas pessoais casal | 5 | 11 | PARTIAL | — | name+subtitle |
| 1 | planilha compartilhada | 5 | 29 | PARTIAL | `planilha` | — |
| 2 | financas pessoais casal | 5 | 11 | PARTIAL | — | name+subtitle |
| 2 | planilha casal | 5 | 7 | PARTIAL | `planilha` | name+subtitle |
| 2 | planilha do casal | 5 | 5 | PARTIAL | `planilha` | name+subtitle |
| 3 | dividas do casal | 5 | 9 | **MISMATCH** | `dividas` | name+subtitle |
| 4 | economia do casal | 5 | 5 | PARTIAL | — | name+subtitle |
| 4 | economias do casal | 5 | 5 | PARTIAL | `economias` | name+subtitle |
| 4 | gastos compartilhados em casal | 5 | 5 | PARTIAL | `compartilhados` | name+subtitle |
| 5 | faturas mensais | 5 | 5 | **MISMATCH** | `mensais` | — |
| 6 | meus gastos diarios | 5 | 31 | FIT | — | name |
| 7 | contas casal | 5 | 9 | PARTIAL | `contas` | name+subtitle |
| 9 | cartao casal | 5 | 33 | PARTIAL | `cartao` | name+subtitle |
| 10 | app de despesas casal | 5 | 13 | PARTIAL | — | name+subtitle |
| 10 | financas compartilhadas | 5 | 19 | PARTIAL | — | subtitle |
| 11 | orcamento compartilhado | 5 | 13 | PARTIAL | `orcamento` | — |
| 14 | economias mensais | 5 | 39 | FIT | `economias`, `mensais` | — |
| 15 | orcamento casal | 5 | 9 | PARTIAL | `orcamento` | name+subtitle |
| 18 | financas casal | 5 | 37 | PARTIAL | — | name+subtitle |
| 22 | despesas cartao | 5 | 46 | PARTIAL | `cartao` | name |
| 32 | diario de despesas | 5 | 15 | FIT | `diario` | name |
| 40 | despesas casal | 5 | 13 | PARTIAL | — | name+subtitle |

### O achado estrutural: o name+subtitle já carrega o cluster casal sozinho

**7 das 24 composições rankeiam sem NENHUM token de keywords sustentando** — `despesas pessoais casal` #1, `financas pessoais casal` #2, `economia do casal` #4, `app de despesas casal` #10, `financas compartilhadas` #10, `financas casal` #18, `despesas casal` #40. Todas saem de `Meus Gastos: Casal e Despesas` + `Finanças do casal e pessoais`, que carregam `gastos`, `casal`, `despesas`, `finanças`, `pessoais` com peso de name/subtitle.

Consequência para o estágio 5: **o keywords field não precisa gastar chars defendendo o cluster casal** — ele já está defendido pelos dois campos de maior peso. Os 94 chars podem ir para intenção que hoje não é coberta.

### Tokens live por poder de proteção

| Token | Sustenta | Veredito do termo isolado | Conflito? |
|---|---|---|---|
| `planilha` | **3 rankings, incl. #1 e #2** (planilha compartilhada, planilha casal, planilha do casal) | **MISMATCH** — SERP puro é Sheets 322k / Excel 304k, e ranqueamos #222 nele | **SIM — o mais caro do campo** |
| `mensais` | **4 rankings, incl. dois #1** (contas mensais casal, despesas mensais casal, faturas mensais, economias mensais) | PARTIAL | não |
| `contas` | 2 (contas mensais casal #1, contas casal #7) | PARTIAL — divide SERP com bancos (Santander/Bradesco/Pix) | leve |
| `economias` | 2 (economias do casal #4, economias mensais #14) | PARTIAL | não |
| `orcamento` | 2 (orcamento compartilhado #11, orcamento casal #15) | PARTIAL — divide com orçamento-cotação (pdf/vendas) | leve |
| `cartao` | 2 (cartao casal #9, despesas cartao #22) | **MISMATCH** — não existe entidade cartão/fatura/limite no app | **SIM** |
| `compartilhados` | 1 (gastos compartilhados em casal #4) | PARTIAL | não |
| `dividas` | 1 (**dividas do casal #3**) | **MISMATCH** — não há modelo de dívida no app | **SIM** |
| `diario` | 1 (diario de despesas #32 — e este é **FIT**) | MISMATCH isolado (diário pessoal / calendário menstrual) | resolvido pela composição |
| `fatura` | **0** — quem sustenta `faturas mensais` #5 é `mensais` (o plural "faturas" não é token) | **MISMATCH** | **não protege nada** |
| `minhas` | **0** — só aparece em `minhas economias` #58, que é **navegação de marca** do concorrente Minhas Economias | — | **não protege nada** |

### Conflitos — decisão que o compositor precisa tomar explicitamente

1. **`planilha`** — protege três rankings, dois deles #1/#2, mas é o token que mais desperdiça peso: sozinho joga o app contra Sheets/Excel, onde é #222. O estágio 3 mostrou que o qualificador é quem faz o trabalho (`planilha de gastos` cai na nossa categoria; `planilha` puro não). **Custo/benefício: manter só se nenhum candidato FIT valer mais que 3 posições pop-5.** Se cortar, os três rankings caem — não há substituto, porque nem name nem subtitle carregam `planilha`.
2. **`dividas`** — protege um único ranking (#3) e traz intenção que o app frustra (não há dívida no produto). Barato de cortar: perde-se 1 posição pop-5.
3. **`cartao`** — protege dois rankings fracos (#9 e #22, diff 33 e 46) e é MISMATCH duro (o app tem "Cartão de Crédito" apenas como uma das 14 categorias). Barato de cortar.
4. **`fatura` e `minhas` não protegem nada** — são os dois cortes livres do campo, ~13 chars liberados sem perda medida.

## de-DE — 9 composições rankeadas ≤ #50

| # | Termo | pop | dif | fit | Token que protege | Também vem de |
|---|---|---|---|---|---|---|
| 2 | monatliche bilanz | 5 | 5 | **MISMATCH** | `bilanz` | — |
| 10 | fixkosten verwalten | 5 | 17 | FIT | `fixkosten`, `kosten` | subtitle |
| 15 | einkauf ausgaben | 5 | 17 | PARTIAL | `einkauf` | name |
| 26 | einnahmen verwalten | 5 | 13 | **MISMATCH** | `einnahmen` | subtitle |
| 32 | haushalt ausgaben | 5 | 49 | FIT | `haushalt` | name |
| 33 | haushaltskonto | 5 | 46 | PARTIAL | `konto`, `haushalt` | — |
| 34 | haushaltsbuch monatlich | 5 | 11 | FIT | `haushalt` | name |
| 46 | monatsbudget planer | 5 | 19 | FIT | `monatsbudget`, `planer` | subtitle |
| 48 | kosten verwalten | 5 | 11 | FIT | `kosten` | subtitle |

### Tokens live de-DE

- **Protegem algo:** `bilanz` (1, MISMATCH), `fixkosten` (1, FIT), `kosten` (2, FIT), `einkauf` (1, PARTIAL — SERP de supermercado Edeka/Rewe/Aldi), `einnahmen` (1, MISMATCH — o app não registra receitas), `haushalt` (3 — o mais produtivo do campo), `konto` (1, PARTIAL), `monatsbudget` (1, FIT), `planer` (1, FIT).
- **Não protegem nada:** `sparen`, `geld`, `finanzen` — três cortes livres, ~18 chars. Os três são MISMATCH pelo estágio 3 (`finanzen` cai em SERP de banco/broker: Revolut 76, N26 69, ETF).

### Conflitos de-DE

1. **`einnahmen`** protege `einnahmen verwalten` #26 mas o app **não registra receitas** — promessa que o produto não cumpre. O estágio 3 marcou `einnahmen ausgaben` como PARTIAL justamente porque a categoria é a certa e metade da promessa não é. Cortar é honesto; custa 1 posição.
2. **`bilanz`** protege o melhor ranking do locale (`monatliche bilanz` #2, diff 5) e é MISMATCH isolado. Mesmo dilema do `planilha`, mas mais barato: um único termo.
3. **`einkauf`** protege #15 mas puxa SERP de supermercado — intenção alheia com volume alheio.

## Nota de método

Este arquivo foi montado pelo coordenador a partir dos CSVs medidos, e não pelo `aso-serp-analyst` (três execuções falhas). O que ele **não** tem: rodada nova de SERP por termo, massa de ratings dos incumbentes termo a termo, e score DOMINATE/CLIMB/LOTTERY/UNWINNABLE por linha. Onde o veredito de intenção aparece, ele vem do estágio 3 (`term_fit_*.csv`), que checou SERP. O estágio 5 deve tratar as posições-alvo como **não estimadas** e se apoiar no que está medido: ranking atual, pop, diff e fit.
