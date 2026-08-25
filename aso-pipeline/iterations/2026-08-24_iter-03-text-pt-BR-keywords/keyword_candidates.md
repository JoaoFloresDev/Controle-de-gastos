# Meus Gastos — iter-03 · decisão

App 6502218501 · 5,3 downloads/dia (↑) · 94,5% das impressões vêm de busca · BR 18 ratings (4,94), DE 2 · versão live 45.2.0

---

## A descoberta que muda a conversa: o app não tem a feature que ele vende

O estágio 3 foi ao source e provou três coisas:

- `CardModel` guarda `id, amount, description, date, category, idFixoControl, updatedAt, deleted`. **Não há pagador, participante nem proporção de divisão.**
- `grep -rniE "split|divid|rateio|metade|settle|reembols|owe"` em todo o `lib/` devolve **só** `String.split(' ')` e widgets `Divider`. Zero lógica de domínio.
- Todo caminho do Firestore é `.collection(userId)` — `GoalsRepositoryRemote:14`, `CategoryRepositoryRemote:23`, `FixedExpensesRepositoryRemote:14`, `TransactionsRepositoryRemote`.

O que existe é **duas pessoas no mesmo login vendo a mesma lista** — sincronização multi-device, não feature de casal. E mais: as 250 strings de `app_pt.arb` não contêm `casal`, `compartilh*`, `parceiro` ou `juntos` uma única vez, e a description live também não. **"Casal" existe apenas no name e no subtitle da loja.**

Só que é justamente o cluster casal que ranqueia: **24 composições dentro do top 50**, várias em #1 e #2. O app é encontrado por uma promessa que não cumpre — e com 18 avaliações, atrair quem vai se frustrar é o pior negócio possível.

**Decisão pendente com você (registrada no now.json):** construir a feature de verdade (conta compartilhada com atribuição por pessoa) ou ajustar a promessa para "sincronizado entre dispositivos". Esta iteração não decide isso — mexer em name/subtitle é exatamente essa decisão.

---

## O que muda agora

Só o **keywords field**, nos dois locales. Name e subtitle ficam intactos porque sustentam sozinhos 7 das 24 composições rankeadas.

### pt-BR — 97 chars

**De:** `compartilhados,contas,minhas,economias,planilha,orcamento,diario,cartao,dividas,fatura,mensais`
**Para:** `compartilhados,contas,economias,planilha,orcamento,diario,mensais,categorias,fixas,resumo,extrato`

| Sai | Motivo | Custo |
|---|---|---|
| `minhas` | não protege nada — só aparece em `minhas economias` #58, que é busca pela **marca do concorrente** Minhas Economias | zero |
| `fatura` | não protege nada (quem sustenta `faturas mensais` #5 é `mensais`) e não existe fatura no app | zero |
| `cartao` | MISMATCH: não há entidade cartão, limite ou data de fechamento — é uma das 14 categorias | `cartao casal` #9, `despesas cartao` #22 |
| `dividas` | MISMATCH: não há modelo de dívida em `models/` | **`dividas do casal` #3** |

| Entra | Ativa | Feature real |
|---|---|---|
| `categorias` | `categorias de gastos`, `gastos por categoria`, `orcamento por categoria` — dif **5** | §1.2, 14 categorias + criador custom |
| `fixas` | `despesas fixas` — dif 11 | §1.5, `RecurrentExpense/` |
| `resumo` | `resumo de gastos`, `resumo mensal` — dif **5** | §1.3, Month Insights |
| `extrato` | `extrato de gastos`, `extrato gastos` — dif 11 | §1.3, `ExtractByCategory/` (a tela se chama Extrato) |

**Fica tudo que protege ranking:** `compartilhados` (#4), `contas` (#1, #7), `economias` (#4, #14), `planilha` (#1, #2, #2), `orcamento` (#11, #15), `diario` (#32), `mensais` (#1, #1, #5, #14).

`planilha` foi o conflito mais caro e ficou: sustenta três posições, duas no topo, e nenhum outro campo carrega esse token. O SERP puro dele é Sheets/Excel, onde o app é **#222** — ou seja, não há tráfego real sendo desperdiçado, só um ranking ruim que nunca converteria.

### de-DE — 97 chars

**De:** `kosten,sparen,geld,konto,finanzen,planer,monatsbudget,bilanz,haushalt,einkauf,fixkosten,einnahmen`
**Para:** `kosten,konto,planer,monatsbudget,bilanz,haushalt,einkauf,fixkosten,kontrolle,kategorien,statistik`

Saem `sparen`, `geld` e `finanzen` (não protegem nada; `finanzen` puxa SERP de banco/broker — Revolut, N26, ETF) e `einnahmen`, que protegia `einnahmen verwalten` #26 mas **promete registro de receitas, que o app não faz**.

Entra `kontrolle`, o token de maior alavancagem do locale — sozinho ativa `ausgabenkontrolle`, `budget kontrolle` e `kosten kontrolle` —, mais `kategorien` e `statistik`.

Fica `haushalt`, o mais produtivo (#32, #33, #34), e `bilanz`, que sustenta `monatliche bilanz` **#2**, o melhor ranking do locale.

---

## Saldo

Perde 4 posições, todas pop-5 e todas MISMATCH: `dividas do casal` #3, `cartao casal` #9, `despesas cartao` #22, `einnahmen verwalten` #26.
Ganha cobertura de ~8 composições FIT em pt-BR e ~5 em de-DE, todas difficulty 5-11, todas ligadas a features que existem no código.

---

## O que este documento não tem

**Nenhuma projeção de downloads e nenhuma posição-alvo por termo.** O estágio de SERP/winnability falhou três vezes seguidas (dois travamentos de watchdog e uma queda quando a máquina dormiu), então não existe score DOMINATE/CLIMB/LOTTERY por termo nesta rodada. O mapa de proteção foi montado a partir dos dados medidos nos estágios 1-3, e cada decisão acima se apoia em ranking atual, popularity, difficulty e verdict de fit — tudo medido, nada estimado.

Duas ressalvas de fonte que valem para a iteração inteira:

- **Popularity Astro é a única medida de volume.** Não existe App Store Search Terms report para este app (não é atraso de 24-48h — o relatório não é gerado). Nenhum número aqui tem segunda fonte.
- **Todas as 24 composições rankeadas em br e as 9 em de são pop 5**, que é o *piso de medição* do Astro, não ausência de busca.

---

## Bloqueios para o deploy

1. **Deploy não autorizado.** Os estágios 7-8 só rodam com o seu aval explícito.
2. **A versão editável 45.3.0 está `DEVELOPER_REJECTED`**, não `PREPARE_FOR_SUBMISSION` — qualquer mudança de metadata viaja junto da próxima submissão.

## Dois achados colaterais que valem ação independente

- **`Mis Despesas` no name de es-MX e es-ES** — "Despesas" é português; em espanhol é "Gastos". Os dois locales têm name/subtitle/keywords idênticos, ambos com o erro. Corrigível por PATCH em `appInfoLocalizations`, sem build novo.
- **`transaction_add` não disparou uma única vez em 28 dias de GA4**, apesar de 10 usuários terem completado o onboarding. É o evento central do app e o call site parece correto (`TransactionsRepositorySelector.addCard`, o repositório realmente injetado). Vale confirmar no DebugView antes de confiar nesse número.
