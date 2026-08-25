# Composição dos campos — iter-03 (Meus Gastos)

**Natureza desta iteração: correção de alinhamento, não aposta.** BR tem 18 ratings (gate do lab é 25), o app faz 5,3 downloads/dia e 94,5% das impressões vêm de busca. Com essa massa de rating, disputar head term é perda de tempo — o que dá retorno é parar de atrair intenção que o app frustra e cobrir a intenção FIT que hoje está descoberta.

**Name e subtitle ficam como estão nos dois locales.** Eles sustentam sozinhos 7 das 24 composições rankeadas em pt-BR e o ônus da prova para mexer não foi pago: não houve rodada de SERP nova (o agente do estágio 4 falhou três vezes) e a decisão de fundo — o que fazer com o posicionamento "casal" — é de produto, não de keyword, e está registrada para o João no `now.json`.

---

## pt-BR

| | Campo |
|---|---|
| name (29) | `Meus Gastos: Casal e Despesas` — inalterado |
| subtitle (28) | `Finanças do casal e pessoais` — inalterado |
| keywords (97) | `compartilhados,contas,economias,planilha,orcamento,diario,mensais,categorias,fixas,resumo,extrato` |

### Diff token a token

| Token | Ação | Por quê |
|---|---|---|
| `compartilhados` | **fica** | protege `gastos compartilhados em casal` #4 |
| `contas` | **fica** | protege `contas mensais casal` #1 e `contas casal` #7 |
| `economias` | **fica** | protege `economias do casal` #4 e `economias mensais` #14 |
| `planilha` | **fica** | protege 3 rankings, dois deles #1/#2 — o token mais produtivo do campo (ver conflito 1) |
| `orcamento` | **fica** | protege `orcamento compartilhado` #11 e `orcamento casal` #15 |
| `diario` | **fica** | protege `diario de despesas` #32, que é **FIT** |
| `mensais` | **fica** | protege 4 rankings, dois deles #1 — segundo token mais produtivo |
| `minhas` | **sai** | não protege nada. Só aparece em `minhas economias` #58, que é **navegação de marca** do concorrente Minhas Economias — tráfego de quem procura outro app |
| `fatura` | **sai** | não protege nada: quem sustenta `faturas mensais` #5 é `mensais` (o plural "faturas" não é token). E é MISMATCH — não existe fatura no app |
| `cartao` | **sai** | conflito 2 |
| `dividas` | **sai** | conflito 3 |
| `categorias` | **entra** | ativa `categorias de gastos`, `gastos por categoria`, `orcamento por categoria` — todos pop 5 / **dif 5**. Feature real: §1.2, 14 categorias + criador de categoria custom |
| `fixas` | **entra** | ativa `despesas fixas` (dif 11). Feature real: §1.5, `RecurrentExpense/` |
| `resumo` | **entra** | ativa `resumo de gastos` e `resumo mensal` — pop 5 / **dif 5**. Feature real: §1.3, Month Insights |
| `extrato` | **entra** | ativa `extrato de gastos` e `extrato gastos` (dif 11). Feature real: §1.3, `ExtractByCategory/` — a tela se chama Extrato |

### Conflitos resolvidos, com o custo assumido

1. **`planilha` — MANTIDO.** Protege `planilha compartilhada` #1, `planilha casal` #2 e `planilha do casal` #2, e nenhum outro campo carrega esse token (se sair, os três caem sem substituto). O estágio 3 marcou o termo isolado como MISMATCH porque o SERP puro é Sheets 322k / Excel 304k — mas ali o app é **#222**, ou seja, não há tráfego real sendo desperdiçado, só um ranking ruim num termo que nunca converteria. Manter custa nada e protege três posições, duas delas no topo.
2. **`cartao` — CORTADO.** Protegia `cartao casal` #9 e `despesas cartao` #22, ambos fracos (dif 33 e 46). É MISMATCH duro: não existe entidade cartão, fatura, limite ou data de fechamento no app — "Cartão de Crédito" é só uma das 14 categorias. **Custo: 2 posições pop-5.**
3. **`dividas` — CORTADO.** Protegia `dividas do casal` **#3**, que é a posição mais alta que se perde nesta rodada. Cortei mesmo assim porque não há modelo de dívida em `models/`: quem busca "dívidas do casal", baixa e não acha gestão de dívida tende a avaliar mal — e **ratings são exatamente o gargalo do app**. Atrair intenção frustrada com 18 ratings é ativamente prejudicial, não neutro. **Custo: 1 posição pop-5 (#3).**

**Saldo pt-BR:** perde 3 posições pop-5, todas MISMATCH; ganha cobertura de ~8 composições FIT de dif 5-11 ligadas a features que o app realmente tem.

### Desvio de regra, declarado

Entraram **4 tokens novos**, e a regra do lab é ≤3 apostas. Assumo o desvio porque nenhum dos quatro é aposta no sentido da regra — a regra existe para impedir encher o campo de termos OUT arriscados (erro da iter-03 do Walk). Aqui saíram 4 tokens e entraram 4, todos com difficulty ≤11 e feature verificada no source. Se for para cortar um, o menos valioso é `resumo` (o mais próximo semanticamente de `extrato`).

---

## de-DE

| | Campo |
|---|---|
| name (24) | `Ausgaben - Haushaltsbuch` — inalterado |
| subtitle (27) | `Budget & Finanzen verwalten` — inalterado (ver nota) |
| keywords (97) | `kosten,konto,planer,monatsbudget,bilanz,haushalt,einkauf,fixkosten,kontrolle,kategorien,statistik` |

### Diff token a token

| Token | Ação | Por quê |
|---|---|---|
| `haushalt` | **fica** | o mais produtivo do locale: 3 rankings (#32, #33, #34) |
| `kosten` | **fica** | 2 rankings (#10, #48), FIT |
| `fixkosten` | **fica** | `fixkosten verwalten` #10, FIT |
| `monatsbudget` / `planer` | **ficam** | ambos sustentam `monatsbudget planer` #46, FIT |
| `konto` | **fica** | `haushaltskonto` #33 |
| `bilanz` | **fica** | `monatliche bilanz` **#2** — o melhor ranking do locale, dif 5. MISMATCH isolado, mas o app mostra Month Insights e média mensal, então a distância entre promessa e produto é bem menor que a de `einnahmen` |
| `einkauf` | **fica** | `einkauf ausgaben` #15. Puxa SERP de supermercado (Edeka/Rewe/Aldi), mas é o único ranking que sustenta e sai barato manter |
| `sparen` | **sai** | não protege nada, MISMATCH |
| `geld` | **sai** | não protege nada, MISMATCH |
| `finanzen` | **sai** das keywords | não protege nada e o SERP é banco/broker (Revolut 76, N26 69, ETF). Continua presente no subtitle |
| `einnahmen` | **sai** | protegia `einnahmen verwalten` #26, mas **o app não registra receitas** — promessa que o produto não cumpre. Mesma lógica de `dividas`. **Custo: 1 posição pop-5** |
| `kontrolle` | **entra** | o token de maior alavancagem do locale: ativa `ausgabenkontrolle`, `budget kontrolle` e `kosten kontrolle` — três termos pop 5 / dif 5-9 |
| `kategorien` | **entra** | ativa `ausgaben kategorien`, pop 5 / dif 5 |
| `statistik` | **entra** | ativa `ausgaben statistik`, pop 5 / dif 11. Feature real: gráficos + Month Insights |

**Saldo de-DE:** perde 1 posição (#26, MISMATCH); ganha 5 composições FIT de dif 5-11. Três apostas novas — dentro da regra.

### Nota sobre o subtitle de-DE

`Budget & Finanzen verwalten` fica, apesar de `Finanzen` cair em SERP de banco/broker. Motivo: `verwalten` sustenta três rankings (#10, #26, #48) e os substitutos naturais para `Finanzen` — `Kosten` e `Ausgaben` — **já estão** nas keywords e no name, então trocar duplicaria peso em vez de ganhar alcance. Sem SERP novo para embasar um token inédito, mexer seria chute.

---

## Avisos do validador que ficam em aberto

- **Os seis campos usam 97-29 chars dos seus limites**, deixando 1-6 chars livres. Não sobra espaço para outro token inteiro em nenhum deles — o resíduo é indivisível.
- **`casal` e `e` aparecem no name e no subtitle de pt-BR.** O validador está certo: duplicar no subtitle (peso 3×) o que já está no name (peso 7×) desperdiça o campo. Isso foi decisão deliberada da iter-02 ("concentrar casal em name + subtitle para capturar o cluster") e o cluster de fato ranqueia. Não desfiz porque a alternativa depende da decisão de posicionamento pendente — se o João optar por ajustar a promessa de "casal" para "sincronizado entre dispositivos", o subtitle é exatamente o campo a reescrever, e aí o desperdício se resolve junto.

## Limite de confiança desta composição

Não houve rodada de SERP nesta iteração (estágios 4 e 5 falharam por watchdog; a composição foi feita pelo coordenador a partir dos dados medidos nos estágios 1-3). Portanto: **não há posição-alvo estimada por termo, e nenhuma projeção de downloads.** O que sustenta cada decisão é ranking atual, popularity, difficulty e o verdict de fit — todos medidos. Popularity Astro é a única fonte de volume, sem segunda fonte, porque não existe App Store Search Terms report para este app.
