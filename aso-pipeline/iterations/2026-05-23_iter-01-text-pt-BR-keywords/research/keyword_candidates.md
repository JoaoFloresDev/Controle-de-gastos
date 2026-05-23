# Keyword analysis & proposal — iter-01 (pt-BR)

**Data**: 2026-05-23
**Source**: Astro export (`data.csv` = 194 termos trackeados na store BR — puxado via MCP `astro-mcp-server v2026.11.1`)
**Filtro decisão**: intent-match first, depois quadrante:
- 🥇 diff ≤ 20 (any pop) — gold
- 🥈 diff 21-40 + pop ≥ 10 — sweet spot
- 🥉 diff 41-60 + pop ≥ 25 — apostas moderadas
- 🔥 pop ≥ 40 + rank ≤ 50 — near-miss (push to top-30)
- 🛡 rank ≤ 30 — defenders (proteger composições)
- 🚫 cortar mesmo se quadrante bom — intent-mismatch destrói CVR

## Estado atual (live ASC)

```
Name      (29/30): Minhas Despesas Gastos Contas
Subtitle  (30/30): Controle financeiro de despesa
Keywords (100/100): finanças,financeiro,gestão,dinheiro,orçamento,poupança,despesas,controle,planejamento,gerenci,custos
```

## Tabela de pesos ASO

| Campo       | Peso indexação | Estratégia                                                           |
|-------------|---------------:|----------------------------------------------------------------------|
| Name        | 7×             | NÃO MEXER nesta iter — já cobre 3 head: despesas, gastos, contas    |
| Subtitle    | 3×             | Reescrever pra cobrir cluster `controle financeiro` + `receitas`     |
| Keywords    | 1×             | Cortar dups com name/subtitle (~25 chars), redirecionar pra near-miss e personas |
| Description | 0× (~)         | Mantém — não muda nesta iter                                         |

## Princípio operacional

**Não duplicar termos entre campos** (Apple indexa cada token na maior weight position). Cada char no keywords field só vale se NÃO está no name/subtitle. Stem matching: `despesa`/`despesas`, `finança`/`finanças`/`financeiro` contam como mesmo stem.

## Caveat Astro pop=5

Astro reporta `popularity=5` como piso (não distingue volume abaixo desse threshold). Termos pop=5 podem ser tudo de 0 buscas/dia a ~10 buscas/dia. Por isso PROTEGEMOS os termos top-30 com pop=5 (eles podem estar drivando trickle real) e tomamos cuidado ao apostar em termos novos só com pop=5 (incerteza alta).

## 🚫 Cortes por intent-mismatch (decisão crítica)

Removidos do pool de consideração mesmo quando quadrante seria gold/sweet — porque a **intent natural da busca não match com o produto**. Esses pareciam tentadores no Astro pelo pop+diff, mas instalar baseado em intent errada gera review 1-star, churn alto, e Apple penaliza o app no algoritmo de recomendação. (Ver memory `feedback-aso-search-intent`.)

| Termo cortado            | Pop | Diff | Rank | Razão de corte                                                              |
|--------------------------|----:|-----:|-----:|-----------------------------------------------------------------------------|
| `cofrinho`               |  51 |   17 |   23 | Savings-gamification niche (Caixinha, Mealheiro) — quem busca espera cofre virtual gamificado, não registro manual. CVR baixa, churn alto. |
| `cofrinho digital`       |   5 |   34 |   26 | Mesmo motivo                                                                |
| `caixinha`               |   5 |   39 |    — | Savings-gamification                                                        |
| `poupar dinheiro`        |   5 |   23 |    — | Intent "guardar" (cofrinho) vs trackear                                     |
| `economia doméstica`     |   5 |    8 |    — | Educação financeira / dicas — conteúdo, não app                            |
| `pix`                    |  65 |   91 |    — | Quer transferir, não trackear                                               |
| `calculadora`            |  72 |   57 |    — | Utility cross — quer calculadora, não finance manager                      |
| `mei contador`           |   5 |    5 |    — | B2B contabilidade — outro nicho                                             |
| `contabilidade simples`  |   5 |    5 |    — | B2B                                                                         |
| `lucro prejuízo`         |   5 |    5 |    — | B2B                                                                         |
| `balanço financeiro`     |   5 |    5 |    — | B2B                                                                         |
| `mobills`                |  65 |   50 |    — | Competitor brand search — usuário quer aquele app específico               |
| `minhas economias`       |  61 |   53 |   30 | Competitor brand search                                                     |
| `minhas financas`        |  57 |   58 |   26 | Variant de competitor brand                                                 |
| `fleur` / `fleur gastos` |   8 |   52 |    — | Competitor brand                                                            |
| `organizze`              |  61 |    — |    — | Competitor brand                                                            |
| `despezzas` / `pierre`   |   — |    — |    — | Competitor brand                                                            |
| `planilha`               |  60 |   63 |    — | Quem busca quer planilha, não app alternativo                              |
| `face id` / `widget` / `icloud` / `senha` / `backup` |  9-69 | 49-74 | — | Feature secundária isolada — intent fraca como query primária              |
| `caixa` / `casa` / `mercado` / `alimentação` |  60-85 | 66-87 | — | Single-word generic — diff alta + intent ambígua                  |

**Net char savings de cortes**: liberamos ~50% do char budget original do keywords field pra redirecionar.

---

## 📐 Diff visual — antes / depois

Legenda:
- <span style="color:#dc3545">🔴 Vermelho</span> = saiu completamente
- <span style="color:#28a745">🟢 Verde</span> = entrou totalmente novo
- <span style="color:#3b82f6">🔵 Azul claro</span> = mudou pra peso MAIOR (kw 1× → subtitle 3×)
- <span style="color:#1e3a8a">🔵 Azul escuro</span> = mudou pra peso MENOR (subtitle 3× → kw 1×)
- Preto = mantém posição

### 🏷 Name

| Antes (29/30)                                                                  | Depois (29/30)                                                                |
|--------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| Minhas Despesas Gastos Contas                                                  | Minhas Despesas Gastos Contas <span style="color:gray">(unchanged)</span>     |

### 🏷 Subtitle

| Antes (30/30)                                                                                                 | Depois (30/30)                                                                                                |
|---------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|
| Controle financeiro de <span style="color:#dc3545">despesa</span>                                              | Controle financeiro e <span style="color:#28a745">receitas</span>                                              |

### 🔑 Keywords field

| Antes (100/100)                                                                                                              | Depois (98/100)                                                                                                                                                                                                                                                                                                            |
|------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <span style="color:#dc3545">finanças</span>, <span style="color:#dc3545">financeiro</span>, gestão, dinheiro, <span style="color:#dc3545">orçamento</span>, <span style="color:#dc3545">poupança</span>, <span style="color:#dc3545">despesas</span>, <span style="color:#dc3545">controle</span>, planejamento, <span style="color:#dc3545">gerenci</span>, <span style="color:#dc3545">custos</span> | <span style="color:#28a745">controle de gastos</span>, <span style="color:#28a745">personal</span>, <span style="color:#28a745">casal</span>, <span style="color:#28a745">money</span>, <span style="color:#28a745">expenses</span>, <span style="color:#28a745">budget</span>, <span style="color:#28a745">gerenciador</span>, dinheiro, gestão, <span style="color:#28a745">pessoal</span>, <span style="color:#28a745">mensal</span> |

---

## 🏷 NAME (palavra-por-palavra — sem mudança nesta iter)

| Palavra   | Pop | Diff | Rank atual | Decisão                                                                          |
|-----------|----:|-----:|-----------:|----------------------------------------------------------------------------------|
| Minhas    |   — |    — |          — | Branding modifier — compose com "Minhas Despesas" (rank 31), "Minhas Contas" (rank 17) |
| Despesas  |  52 |   53 |         33 | Head — rank 33, near top-30. Manter peso 7×.                                     |
| Gastos    |  34 |   63 |         40 | Head — rank 40, próximo top-30. Manter peso 7×.                                  |
| Contas    |  55 |   79 |         96 | Head — rank 96, mas dups "minhas contas" rank 17, "gastos contas" rank 3.       |

**Decisão**: Name fica intocado. Mexer no name custaria reset de rank-protection nas composições já estabelecidas (`contas despesas` #4, `gastos contas` #3, `despesas gastos` #6).

---

## 🏷 SUBTITLE (decisão palavra-por-palavra)

### SAIU

| Termo         | Pop | Diff | Rank | Por quê removeu                                                                |
|---------------|----:|-----:|-----:|--------------------------------------------------------------------------------|
| `despesa`     |   — |    — |    — | Singular dup com `Despesas` no name (Apple stems). Peso 3× desperdiçado. ⚠️    |
| `de`          |   — |    — |    — | Stopword PT — Apple ignora. Liberou 2 chars + 1 espaço.                       |

### ENTROU

| Termo       | Pop | Diff | Rank | Por quê entrou                                                                  |
|-------------|----:|-----:|-----:|---------------------------------------------------------------------------------|
| `receitas`  |  50 |   42 |    — | 🥉 Melhor moderate intent-OK do pool. Par universal "receitas e despesas" (5/6 competitors). Mover pra peso 3× é GAIN puro. |

### MANTÉM

| Termo         | Pop | Diff | Rank | Por quê manteve                                                                  |
|---------------|----:|-----:|-----:|----------------------------------------------------------------------------------|
| `Controle`   |  69 |   65 |    — | Mantém peso 3× → compose com name pra `controle de despesas`, `controle de gastos`, `controle de contas`. Stem ESSENCIAL. |
| `financeiro` |  30 |   61 |  229 | Mantém peso 3× → compose `controle financeiro` (pop 54, atual rank 164 → target ↑) e stem cross com `finanças`. |
| `e`          |   — |    — |    — | Stopword Apple ignora — economia visual.                                        |

**Subtitle nova**: `Controle financeiro e receitas` (30/30 chars exato)

---

## 🔑 KEYWORDS FIELD (decisão palavra-por-palavra)

### SAIU

| Termo         | Pop | Diff | Rank | Por quê removeu (chars liberados)                                                |
|---------------|----:|-----:|-----:|----------------------------------------------------------------------------------|
| `finanças`    |  52 |   55 |    — | Stem dup com `financeiro` no subtitle peso 3× — liberou 9 chars.                |
| `financeiro`  |  30 |   61 |  229 | Dup com subtitle peso 3× — liberou 10 chars.                                    |
| `orçamento`   |   5 |    — |    — | Termo universal mas pop=5 (floor). Não rankeia. Liberou 9 chars.                |
| `poupança`    |   5 |    — |    — | Intent ambíguo (savings vs cofrinho niche). Liberou 8 chars.                    |
| `despesas`    |  52 |   53 |   33 | Stem dup com `Despesas` no name peso 7×. Liberou 9 chars.                       |
| `controle`    |  69 |   65 |    — | Stem dup com `Controle` no subtitle peso 3×. Liberou 8 chars.                   |
| `gerenci`     |   — |    — |    — | ❌ TOKEN TRUNCADO (bug). Substituído por `gerenciador` (pop 46 diff 54). +4 chars net. |
| `custos`      |   — |    — |    — | Synonym de `despesas` que já está no name peso 7×. Liberou 6 chars.             |

**Net chars liberados**: ~58 chars (de 100 → consumo livre)

### ENTROU

Front-loaded por valor descendente (high-pop + high-leverage primeiro):

| #  | Termo                | Pop | Diff | Rank | Por quê entrou                                                                   |
|----|----------------------|----:|-----:|-----:|----------------------------------------------------------------------------------|
| 1  | `controle de gastos` |  53 |   61 |   48 | 🔥 NEAR-MISS — único termo high-pop a 1 página do top-30. Head do nicho ocupado por Mobills+Fleur. Push primário. 18 chars. |
| 2  | `personal`           |  48 |   58 |   41 | 🛡 RANK-PROTECT — JÁ rankeia 41 em EN-cross. Pop 48. 8 chars.                    |
| 3  | `casal`              |  54 |   55 |    — | 🥉 Persona gap zero-competition. Mobills/Fleur não cobrem. Pop 54 unranked. 5 chars. |
| 4  | `money`              |  55 |   60 |    — | 🥉 EN-cross — Wallet/MoneyNote/Mobills cobrem em desc. Pop 55. 5 chars.         |
| 5  | `expenses`           |  30 |   45 |   39 | 🛡 RANK-PROTECT — JÁ rankeia 39 (EN-cross). 8 chars.                            |
| 6  | `budget`             |  43 |   49 |    — | 🥉 EN-cross sweet (diff 49). 6 chars.                                           |
| 7  | `gerenciador`        |  46 |   54 |    — | Fix do bug `gerenci` truncado + compose com `gerenciador de gastos` (Mobills desc). 11 chars. |
| 8  | `pessoal`            |   — |    — |    — | PT cross-stem — compose `finanças pessoais` (pop 59), `gastos pessoais`, `despesas pessoais`. 7 chars. |
| 9  | `mensal`             |   — |    — |    — | Period modifier — compose `gastos mensais`, `controle mensal`, `orçamento mensal`. 6 chars. |

### MANTÉM

| Termo          | Pop | Diff | Rank | Por quê mantém                                                                  |
|----------------|----:|-----:|-----:|----------------------------------------------------------------------------------|
| `dinheiro`     |  53 |   68 |    — | High-pop head — embora unranked, intent perfeita. 8 chars.                       |
| `gestão`       |   — |    — |    — | Abstract head — compose `gestão financeira` (Minhas Economias). 6 chars.        |

### CASE-FIX

Não há case-fix nesse field (já lowercase).

---

## 📄 Resultado final

```
Name      (29/30): Minhas Despesas Gastos Contas              ← unchanged
Subtitle  (30/30): Controle financeiro e receitas             ← changed
Keywords  (98/100): controle de gastos,personal,casal,money,expenses,budget,gerenciador,dinheiro,gestão,pessoal,mensal   ← changed
```

## 📋 Ordenação dos keywords (front-loading)

| Pos | Termo                | Pop | Diff | Rank | Bucket                  |
|----:|----------------------|----:|-----:|-----:|-------------------------|
|   1 | controle de gastos   |  53 |   61 |   48 | 🔥 near-miss (push)     |
|   2 | personal             |  48 |   58 |   41 | 🛡 rank-protect          |
|   3 | casal                |  54 |   55 |    — | 🥉 persona gap          |
|   4 | money                |  55 |   60 |    — | 🥉 EN cross             |
|   5 | expenses             |  30 |   45 |   39 | 🛡 rank-protect          |
|   6 | budget               |  43 |   49 |    — | 🥉 EN sweet             |
|   7 | gerenciador          |  46 |   54 |    — | bug-fix + intent        |
|   8 | dinheiro             |  53 |   68 |    — | head retention          |
|   9 | gestão               |   — |    — |    — | abstract head           |
|  10 | pessoal              |   — |    — |    — | persona composition     |
|  11 | mensal               |   — |    — |    — | period modifier         |

Lógica: o termo mais alto-valor é o "push to top-30" (`controle de gastos`), seguido dos rank-protects pra defender ganhos existentes, depois moderates pop alto unranked (territory exploration), depois compositions modifiers (mensal/pessoal compõem múltiplas frases).

---

## Cobertura por cluster (peso composto: name 7× + sub 3× + kw 1×)

| Cluster                              | Name 7×                  | Subtitle 3×                    | Keywords 1×                                                 | Peso total |
|--------------------------------------|--------------------------|--------------------------------|-------------------------------------------------------------|-----------:|
| **Controle (head verbo)**            |                          | Controle                       | controle de gastos                                          | 3+1 = **4** |
| **Despesas / gastos (head noun)**    | Despesas, Gastos         | (compose via stems)            | expenses                                                    | 7+7+1 = **15** |
| **Contas (head noun)**               | Contas                   |                                |                                                             | 7         |
| **Financeiro (head adj)**            |                          | financeiro                     |                                                             | 3         |
| **Receitas (income side)**           |                          | receitas                       |                                                             | 3         |
| **Persona casal**                    |                          |                                | casal                                                       | 1         |
| **Persona pessoal**                  |                          |                                | personal, pessoal                                           | 2         |
| **Period mensal**                    |                          |                                | mensal                                                      | 1         |
| **Dinheiro/money (head universal)**  |                          |                                | dinheiro, money                                             | 2         |
| **Budget/gestão (head abstract)**    |                          |                                | budget, gestão, gerenciador                                 | 3         |

---

## 🛡 Termos protegidos (verificar pós-deploy)

Esses já rankeiam top-30 — confirmar que continuam após mudança:

| Termo                | Pop | Rank atual | Mecanismo de rank                                              |
|----------------------|----:|-----------:|----------------------------------------------------------------|
| `gastos contas`      |   5 |          3 | Compose name (Gastos+Contas)                                   |
| `contas despesas`    |   5 |          4 | Compose name (Contas+Despesas)                                 |
| `despesas gastos`    |   5 |          6 | Compose name (Despesas+Gastos)                                 |
| `minhas contas`      |   5 |         17 | Compose name (Minhas+Contas)                                   |
| `meus gastos`        |   5 |         19 | Possessive composition                                         |
| `financeiro de despesa` |   5 |       20 | Composição com subtitle atual — ⚠️ pode PERDER após mudança subtitle |
| `cofrinho`           |  51 |         23 | Provavelmente via descrição ou stem indireto                   |
| `cofrinho digital`   |   5 |         26 | Mesmo                                                          |
| `minhas finanças`    |   5 |         23 | Compose Minhas+stem finanças                                   |
| `minhas economias`   |  61 |         30 | Compose Minhas+stem economias                                  |
| `minhas despesas`    |  57 |         31 | Compose name (Minhas+Despesas)                                 |
| `despesas`           |  52 |         33 | Name peso 7×                                                   |
| `personal`           |  48 |         41 | Adding to keywords (defend)                                    |
| `expenses`           |  30 |         39 | Adding to keywords (defend)                                    |
| `gastos`             |  34 |         40 | Name peso 7×                                                   |
| `gastos diarios`     |   9 |         39 | Compose via name+desc                                          |

**⚠️ Risk**: `financeiro de despesa` rank 20 pode cair porque subtitle muda de `Controle financeiro de despesa` → `Controle financeiro e receitas` (perde `despesa` singular). Aceitamos a perda — pop=5 e ganho na CVR esperada é maior.

---

## 🎯 Hipótese formal pra `meta.json`

> **If** subtitle muda de `Controle financeiro de despesa` (30/30) para `Controle financeiro e receitas` (30/30) — substituindo o dup `despesa` (sing/plur com name) por `receitas` (peso 3× novo, par universal cluster B);
>
> **E** keywords muda de `finanças,financeiro,gestão,dinheiro,orçamento,poupança,despesas,controle,planejamento,gerenci,custos` (100/100) para `controle de gastos,personal,casal,money,expenses,budget,gerenciador,dinheiro,gestão,pessoal,mensal` (98/100) — removendo 7 dups/bugs e adicionando 9 termos intent-clean com pop ≥ 30 ou rank-protect;
>
> **Then** esperamos:
> - **Impressions diárias ↑ ≥ 25%** em 30 dias (de gain em `controle de gastos`, `receitas`, persona `casal`, e EN-cross `personal/money/expenses/budget`);
> - **Downloads diários ↑ ≥ 50%** em 30 dias (de 1.5 → 2.25+, target bold).
> - **`controle de gastos`**: rank 48 → top-30 (alvo: 25-28) em 30 dias.
> - **Rank-protects** mantidos: top-30 nos 13 termos já protegidos.
>
> **Because**:
> (a) keyword field atual perde ~25 chars em dups+bug (`despesas`/`controle` dup name+subtitle, `gerenci` truncado, `custos` synonym do name);
> (b) `controle de gastos` (head do nicho, pop 53) está logo na rank 48 — um push via bigrama explícito no keywords field provavelmente cruza pra top-30;
> (c) `receitas` no subtitle (peso 3×) adiciona o par universal "receitas e despesas" — composição que 5/6 competitors usam, mas que estamos hoje sem peso;
> (d) intent filter elimina ruído de cofrinho/calculadora/pix que poderiam até rankear mas com CVR baixa — preservando review-velocity;
> (e) front-loading na ordem `controle de gastos > personal > casal > money > ...` posiciona os termos mais alto-valor nas posições com weight ligeiramente maior do parser Apple.

---

## ⚠️ Riscos identificados

1. **Perda de rank em `financeiro de despesa` (rank 20)** — subtitle muda e a singular `despesa` sai. Aceito porque pop=5.
2. **`casal` pode ter intent-mismatch se o app não suportar contas compartilhadas** — verificar feature; se não suporta, cortar em iter-02.
3. **EN-cross terms (`personal`/`money`/`budget`/`expenses`) podem ter CVR menor que PT-BR puros** — usuários BR buscando em inglês são minoria. Compensado pelo fato de `personal` e `expenses` JÁ rankearem 41/39 (defending existing).
4. **`gerenci` → `gerenciador` pode não compor com queries `gerenciamento`** — Apple stem matching pode não atravessar `gerenciador` ↔ `gerenciamento`. Tradeoff aceitável pelo gain em `gerenciador de gastos`.
5. **Cold-start cap**: app c/ 1.5 dl/dia tem Apple algorithm signals fracos. Mesmo rank top-10 pode não converter linearmente em downloads — pode precisar de iter-02 atacando descrição + screenshots se downloads não saltarem após 14d.
6. **Apple ASC review** improvável mas possível rejeição de `Controle financeiro e receitas` por trademark conflict — risco baixo, mitigação = manter pronto fallback `Gastos, contas e receitas` (29/30).
