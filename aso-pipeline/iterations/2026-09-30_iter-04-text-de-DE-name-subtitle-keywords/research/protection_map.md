# Mapa de proteção — Meus Gastos / My Expenses (6502218501), iter-04

Estágio 4. Para cada composição que o app **já rankeia**, qual token do campo vivo a sustenta e em que campo ele vive.
Regra que este arquivo existe para impor (desastre da iter-03 do Walk): **token que sustenta posição NUNCA sai do campo, mesmo que pareça fraco isolado.** Se o estágio 5 quiser o char, tem que nomear a posição que aceita perder.

Fonte dos ranks: `research/term_fit_<locale>.csv` (Astro, pull de 2026-09-30/10-01). Fonte dos campos: `research/asc_state.json` (estado LIVE na ASC). Atribuição token→posição calculada por casamento exato + stem + decomposição de composto alemão/dinamarquês + folding de diacrítico, conferida contra as SERPs ao vivo puxadas neste estágio.

## 0. Quanto existe para proteger

**456 posições rankeadas no total nos 29 locales; 214 delas ≤#50** (o brief estimava ~80 — o número real é 2,7× maior, porque long tails de 2-3 palavras rankeiam em quase todo locale). Distribuição: pt-BR 47 · de-DE 29 · ms 12 · cs 10 · fi 9 · no 9 · pl 8 · sv 8 · uk 8 · ar-SA 6 · da 6 · he 6 · hu 6 · id 6 · el 5 · fr-FR 5 · hi 5 · nl-NL 5 · th 5 · ja 3 · tr 3 · vi 3 · zh-Hans 3 · it 2 · ko 2 · en-US 1 · es-ES 1 · es-MX 1 · ru 0.

Dentro dessas 214, **107 posições estão no top-10** — 74 FIT, 8 PARTIAL e **25 MISMATCH** (21 das 25 são o cluster `casal` do pt-BR; as outras 4 são `monatliche bilanz` #1 em de-DE, `सेविंग्स` #6 em hi e `bilancio personale` #5 / `spese bilancio` #9 em it). Distribuição do top-10: pt-BR 34 · de-DE 7 · fi 6 · ms 6 · no 6 · cs 5 · sv 5 · da 4 · he 4 · hu 4 · pl 4 · el 3 · hi 3 · ar-SA 2 · fr-FR 2 · id 2 · it 2 · nl-NL 2 · uk 2 · en-US 1 · ja 1 · tr 1 · zh-Hans 1. **É esse o ativo que este arquivo protege.**

Calibração que vale para o documento inteiro: **5,7 instalações/dia no app inteiro** e massa de avaliação local quase nula — BR 18, DE 2, US/FR/FI/GR/AE/AU/BH/DO/HK 1 cada, **os outros 18 locales com ZERO avaliação na storefront** (`astro_ratings.json`). Posição ≤#50 aqui é sempre fruto de relevância de metadata, nunca de sinal comportamental. É por isso que ela é frágil: tirar o token tira a posição no mesmo re-index.

## 1. Alemão — as 29 posições ≤#50 e o que cabe nos 6 chars livres do name

As 15 posições citadas no brief estão todas no mapa da §3 (seção `de-DE`), mais 14 que o brief não listou (`ausgabenkontrolle` #6, `budget kontrolle` #26, `haushaltsbuch ausgaben` #27, `monatsbudget` #28, `konto ausgaben` #29, `haushaltsbuch monatlich` #33, `haushalt ausgaben` #35, `haushaltskonto` #41, `kosten verwalten` #42, `monatsbudget planer` #47, `kosten kontrolle` #48, `haushaltsplaner` #50, `ausgaben kategorien` #2, `fixkosten verwalten` #8).

Três mecanismos sustentam o alemão, e os três precisam ficar explícitos antes de qualquer recomposição:

1. **Decomposição de composto.** `ausgabenkontrolle` #6, `kostenkontrolle` #40, `haushaltskonto` #41 e `haushaltsplaner` #50 **não existem como token em campo nenhum** — a Apple quebra o composto e casa as partes (`ausgaben`+`kontrolle`, `kosten`+`kontrolle`, `haushalt`+`konto`, `haushalt`+`planer`). Consequência dura: `kontrolle` sozinho parece uma palavra genérica de keywords field e é o token que sustenta **5 posições**, três delas top-10.
2. **Stem de família.** `monatsbudget` é o único token vivo da família *monat-* e carrega, por stem, `ausgaben pro monat` #22, `monatliche fixkosten` #12, `haushaltsbuch monatlich` #33 e `monatliche bilanz` #1 — além de ser o substring que entrega `budget` para `budget kategorien` #11, `budget pro kategorie` #13 e `budget kontrolle` #26 (junto do `Budget` do subtitle). **`monatsbudget` é o token mais carregado do alemão: 7 posições ≤#50.** Era o que mais parecia "só mais uma keyword".
3. **Name faz o trabalho pesado nas cabeças de composição.** `ausgaben` (NAME) sustenta 10 posições, `haushaltsbuch` (NAME) sustenta 4. Nenhum dos dois sai, em hipótese alguma.

**Os 11 tokens do keywords field alemão sustentam, todos, pelo menos uma posição ≤#50.** O campo está em 97/100 chars e é 100% load-bearing. Não existe "slot livre" em de-DE: entrada nova = saída nomeada.

Custo de remoção, do mais barato ao mais caro (o estágio 5 escolhe daqui, não de outro lugar):

| token | chars liberados (com vírgula) | posições que caem | natureza das posições |
|---|---|---|---|
| `bilanz` | 7 | 1 (#1 `monatliche bilanz`) | MISMATCH — ver §4 |
| `einkauf` | 8 | 1 (#13 `einkauf ausgaben`) | PARTIAL |
| `konto` | 6 | 2 (#29 `konto ausgaben`, #41 `haushaltskonto`) | ambas MISMATCH (o app não tem conta bancária) |
| `statistik` | 10 | 2 (#2 `ausgaben statistik`, #12 `kosten statistik`) | FIT, uma delas é a 2ª melhor posição do locale — **não tocar** |
| `haushalt` | 9 | 3 (#35, #41, #50) | ver ressalva abaixo |
| `planer` | 7 | 4 (#31, #42, #47, #50) | FIT |
| `kosten` | 7 | 4 (#12, #40, #42, #48) | FIT |
| `fixkosten` | 10 | 4 (#8, #12, #31, #41) | FIT |
| `kategorien` | 11 | 4 (#2, #4, #11, #13) | FIT, três no top-13 |
| `kontrolle` | 10 | 5 (#6, #10, #26, #40, #48) | FIT |
| `monatsbudget` | 13 | 7 (#11, #13, #22, #26, #28, #42, #47) | FIT |

Ressalva sobre `haushalt`: o NAME já contém `Haushaltsbuch`, e se a Apple decompõe o composto do name (como decompõe o da query) o token `haushalt` do keywords field é redundante. **Isso não está provado** — as três posições que ele sustenta (`haushalt ausgaben`, `haushaltskonto`, `haushaltsplaner`) também podem estar vindo só do keywords field. Testar custa uma iteração inteira; nesta, `haushalt` fica.

### Os 6 chars livres do name (`Ausgaben - Haushaltsbuch`, 24/30)

Resposta honesta: **com 6 chars e sem mexer na estrutura, não cabe nada que valha a pena.** Todo token alemão com valor medido precisa de mais: `Budget` 6+1 espaço = 7, `Fixkosten` 10, `Kosten` 7, `Statistik` 10, `Kostenlos` 10, `Planer` 7, `Monat` 6+1 = 7. Enfiar uma palavra de 6 chars só porque cabe (`Geld`, `Plan`) duplicaria token que já existe em keywords e desperdiçaria peso 7×.

O que **abre** espaço de verdade é trocar o separador: `Ausgaben - Haushaltsbuch` → `Ausgaben Haushaltsbuch` (22 chars) libera **8**, e a troca é neutra para o índice (a Apple tokeniza em não-alfanumérico; `-` e espaço produzem os mesmos dois tokens). Com 8 chars cabe ` Budget` (7) → `Ausgaben Haushaltsbuch Budget` (29/30). Efeito: `budget` sobe de SUBTITLE (3×) para NAME (7×) — ganho de peso nas 3 posições que ele sustenta (#11, #13, #26) e nos termos `budget`-de-cabeça onde hoje estamos OUT. **Proteção que precisa sobreviver a essa troca:** `verwalten` (3 posições: #8, #15, #42) tem que continuar no subtitle, e `ausgaben`+`haushaltsbuch` continuam no name — a ordem muda, os tokens não. Decisão de composição é do estágio 5; o que o mapa autoriza é: nenhum token sai nesse movimento.

## 2. `haushaltsbuch kostenlos` — pop 61, estamos #54

**Winnability: LOTTERY. Posição-alvo realista em 28 dias: #38-45. Não é alvo de name nem de subtitle.**

Os números, não a vontade:

- SERP ao vivo (`de`, 2026-10-01): #1 Haushaltsbuch Ausgaben Monee **10.274** avaliações · #2 Ausgaben Budget Planner Fleur **1.995** · #3 Haushaltsbuch MoneyStats **22.507**. Massa do top-3 = **34.776 avaliações contra as nossas 2 na Alemanha.**
- Hoje rankeamos #54 **sem o token `kostenlos` em campo nenhum** — a posição vem do `Haushaltsbuch` do NAME mais o viés que a Apple dá a app grátis em query com "kostenlos" (mesmo mecanismo que nos põe em #104 em `ausgaben kostenlos`, também sem token).
- Pôr `kostenlos` no keywords field (1×) vale, pela heurística do playbook §7, **10-30% de ganho de rank** → #38-48. Pôr no subtitle (3×, 30-50%) → #27-38. Nos dois casos a posição fica **abaixo do penhasco**: TTR de #3 já é 2,7%, e desde 03/03/2026 o 2º slot de anúncio empurra o orgânico mais uma posição para baixo. Posição #30 em termo de cabeça rende zero instalação.
- Para o top-10 seria preciso passar por cima de apps com 2.000 a 22.500 avaliações **sem nenhum sinal comportamental para oferecer**: 25 instalações/30d na Alemanha e 2 avaliações. Não existe composição de campo que compre isso.
- E pop 61 é **Astro-only**: não há report de App Store Search Terms nem campanha de Apple Ads neste app (`locales.json`, correções do estágio 1). Pop 61 é estimativa de uma tool cuja escala quebrou em out/2025 — **`pop não confiável`**. Gastar char de name/subtitle em cima dela viola a regra de 2ª fonte do playbook §4.

**Recomendação de proteção:** `kostenlos` só entra como token de keywords field (1×), e só se o estágio 5 pagar o char cortando `bilanz` (7) ou `konto` (6) — nunca cortando `statistik`, `kategorien`, `kontrolle`, `monatsbudget`, `fixkosten`, `kosten` ou `planer`. O que o token compra de verdade não é o #54→#40 em `haushaltsbuch kostenlos`; é alimentar `ausgaben kostenlos` (#104 hoje), `budget kostenlos` e `fixkosten kostenlos` — composições baratas porque a cabeça já está no NAME.

## 3b. Os 58 tokens LIVE condenados pelo estágio 3 — quais protegem posição

Dos **58** tokens vivos marcados MISMATCH, **47 não sustentam nenhuma posição ≤#50**; destes, **28 não sustentam posição alguma em rank nenhum** (saem sem trade-off nenhum, liberando char em 18 locales) e 19 só sustentam posição abaixo de #50, que é tráfego zero. Os **11 que protegem** estão abaixo, cada um com o trade-off nomeado. Nenhum deles é "remoção automática".

| locale | token | campo | posições que caem | trade-off nomeado |
|---|---|---|---|---|
| pt-BR | `casal` | SUBTITLE | **21 ≤#50** (#1 ×2, #3 ×5, #4 ×4, #5 ×4, #6, #9 ×3, #22, #23, #34) + 4 abaixo de #50 | **O maior trade-off da iteração.** São 21 posições de topo em queries de casal/conta compartilhada que o app **não entrega** (todo path do Firestore é de um dono só). Cada install vindo daí chega esperando ledger compartilhado, não acha, e vira desinstalação — e BR é o único locale com massa de avaliação (18) a perder. Tirar `casal` destrói o número mais bonito do relatório e provavelmente melhora a retenção e a nota. Manter = continuar comprando install que não fica. Decisão é do João, não do pipeline; o que o mapa exige é que ninguém tire `casal` *sem saber* que são 21 posições. |
| pt-BR | `compartilhados` | KEYWORDS | 9 ≤#50 (#1 `planilha compartilhada`, #2 `gastos compartilhados`, #3 ×2, #5, #9, #12 ×2, #15) | Mesma doença do `casal`, mesmo diagnóstico. Sai junto ou fica junto — meio-termo (tirar um e manter o outro) mantém a promessa errada e perde metade das posições. |
| pt-BR | `planilha` | KEYWORDS | 3 ≤#50 (#1 `planilha compartilhada`, #4 `planilha casal`, #4 `planilha do casal`) + #118 | As 3 posições dependem **também** de `casal`/`compartilhados`. Se o cluster casal cair, `planilha` sozinho só sustenta #118 `planilha de gastos mensais` — vira remoção barata. Se o cluster ficar, `planilha` fica junto. **Ordem importa: avaliar depois da decisão do `casal`.** |
| pt-BR | `economias` | KEYWORDS | 4 ≤#50 (#9 ×3 de casal, **#17 `economias mensais` que é FIT**) | 3 das 4 são do cluster casal. A 4ª é FIT e sobrevive sozinha — mas só com `economias` vivo. Trade-off: tirar `economias` custa um FIT #17 por 10 chars. |
| pt-BR | `diario` | KEYWORDS | 4 posições, **3 delas FIT**: #1 `meus gastos diarios`, #13 `despesas diárias`, #28 `diário gastos`, #34 `diario de despesas` | **O caso mais claro de "MISMATCH isolado, carregador em composição".** O estágio 3 condenou `diario` por polissemia (o pool de `diário` solto é app de diário pessoal) — correto como termo solto. Mas como token ele entrega um **#1 FIT** e mais três. Tirar é perda líquida. **Fica.** |
| de-DE | `konto` | KEYWORDS | 2 ≤#50 (#29 `konto ausgaben`, #41 `haushaltskonto`) | Ambas MISMATCH: quem busca conta quer conta bancária/multi-carteira, que o app não tem. 6 chars por duas posições fora do top-25 em queries erradas. **Melhor candidato a saída no alemão.** |
| de-DE | `bilanz` | KEYWORDS | 1 ≤#50 (#1 `monatliche bilanz`) + #104 `bilanz` | Ver §4. |
| it | `bilancio` | **NAME** + KEYWORDS | 2 ≤#50 (#5 `bilancio personale`, #9 `spese bilancio`) + #77 `bilancio` | São as **únicas 2 posições ≤#50 do italiano inteiro**. O token está no NAME (`Spese - Bilancio Personale`), peso 7×. Tirar do name = o italiano fica com zero posição de topo em troca de "honestidade de intenção" num locale de 12 instalações/90d e 0 avaliações. **Trade-off ruim nesta iteração: manter, e corrigir a promessa na description/prints, não no name.** Duplicata em KEYWORDS é que é gratuita: `bilancio` aparece nos dois campos — tirar da lista de keywords libera 9 chars sem derrubar nada, porque o NAME sustenta as duas posições. |
| hi | `सेविंग्स` | KEYWORDS | 1 ≤#50 (#6 `सेविंग्स`, o próprio token) | O termo-alvo é "savings" e o app só tem teto de gasto, não meta de poupança. #6 num locale com 7 instalações/90d e 0 avaliações. 9 chars. Trade-off pequeno dos dois lados; se o estágio 5 precisar do char, **sai** — é a única das 11 que eu classificaria como remoção quase indolor. |
| id | `tabungan` | KEYWORDS | 1 ≤#50 (#28 `tabungan bulanan`) + #155 `tabungan` | Mesma lógica de poupança do hi. A posição #28 cai; `bulanan` (que sustenta 3 posições) fica. |
| id | `buku kas` | KEYWORDS | 1 ≤#50 (#43 `buku kas`, pop 57) | É o único token da lista com pop alto E posição. Mas é intenção de **livro-caixa de negócio** (fechamento, IVA) — o app é pessoal. #43 está abaixo do penhasco e não converte; o install que vier converte pior ainda. Ocupa 9 chars num field de 92/100. **Sai**, e `kas` (que sustenta a mesma posição junto) sai com ele. |

Tokens condenados que sustentam posição **só abaixo de #50** (remoção barata, mas que custa a própria posição): (19 tokens) `cs:platby` #75 · `cs:úspory` #56 · `el:ταμείο` #71 · `es-ES:ingreso` #120/#147 · `fr-FR:compte` #177 · `fr-FR:ecologie` #171 · `fr-FR:salaire` #200 · `hi:बचत` #177 · `id:gaji` #241 · `ko:월급` #140 · `ko:재테크` #195 · `ms:simpanan` #154 · `nl-NL:kasboek` #116/#126 · `no:regnskap` #149 · `ru:сбережения` #177 · `th:บัญชี` #123 · `tr:bakkal` #77 · `tr:maaş` #231 · `zh-Hans:理财app` #117. Nenhuma dessas posições vale um char: >#50 é tráfego zero.

**Resposta explícita aos casos citados no brief:** `सेविंग्स` (hi) rankeia #6 e protege **só a si mesmo** — remoção quase indolor. `bilancio` (it) está no NAME e as 2 posições ≤#50 do locale dependem dele; a cópia em KEYWORDS é duplicata removível. `자산` (ko) está no SUBTITLE e **não protege nada** (as 2 posições coreanas são `간단한 가계부` #25 e `절약 가계부` #41, ambas sustentadas por `가계부`/NAME) — sai livre, junto de `머니매니저`, `수입`, `통장`, `지출`, `예산` e os outros 12 tokens coreanos sem posição. `casal` (pt-BR, SUBTITLE) protege 21 posições ≤#50 — nenhuma delas FIT. `buku kas` (id) protege #43 e `tabungan` (id) protege #28 + #155.

## 4. `monatliche bilanz` #1 — a remoção custa exatamente duas posições, e nenhuma é FIT

Confirmado por varredura de todas as 456 posições rankeadas do app: **`bilanz` sustenta duas, e só duas** — `monatliche bilanz` **#1** (MISMATCH) e `bilanz` **#104** (MISMATCH). Nenhum termo FIT ou PARTIAL, em nenhum rank, depende do token. Não há família oculta (não existe outro termo alemão rankeado com *bilanz-* no mapa).

O que o #1 vale: SERP ao vivo de `monatliche bilanz` tem **5 resultados no total**, e o top-3 é nós (2 avaliações) + dois apps com 0 avaliações. É um #1 real num termo onde não há disputa — e pop 5, que é o **piso da escala Astro, ou seja volume DESCONHECIDO**, não "volume baixo". Com 5 resultados na SERP inteira, a leitura honesta é que a demanda é residual.

**Veredito:** soltar `bilanz` é seguro — custa um #1 de vitrine e um #104, ambos em query que o app não responde (quem busca *Bilanz* quer receita × despesa; o app só registra despesa). Libera 7 chars no único campo alemão que está 100% load-bearing. É, junto de `konto` (6 chars, 2 posições MISMATCH), a fonte de char que o estágio 5 deve usar antes de tocar em qualquer outro token alemão.

> Aviso para o relatório: perder um `#1` aparece feio no antes/depois. O #1 some do quadro porque foi **vendido de propósito** por 7 chars, não porque a iteração piorou. Registrar assim no `meta.json`.

## 5. Char grátis: duplicatas de campo (keywords repetindo token que já está no name/subtitle)

A Apple compõe entre os campos; token repetido no keywords field não acrescenta índice, só consome char. Varredura dos 29 locales achou **24 duplicatas exatas em 10 locales** — char liberado sem custo de proteção nenhum, porque quem sustenta a posição é o NAME/SUBTITLE (peso 7×/3×), não a cópia no keywords field (1×):

| locale | tokens duplicados no keywords field | chars liberados |
|---|---|---|
| en-US | `money`, `control`, `personal`, `easy` (+ `financial` aparece **duas vezes** na própria lista) | 28 + 10 da repetição interna |
| id | `uang`, `anggaran`, `catatan`, `hemat` | 28 |
| ko | `지출`, `예산`, `절약`, `자산` | 12 |
| it | `bilancio`, `risparmio`, `budget` | 26 |
| tr | `para`, `bütçe`, `tasarruf` | 20 |
| fr-FR | `suivi`, `economie` | 15 |
| es-ES / es-MX | `dinero`, `financiero` | 18 cada |
| ar-SA | `ميزانية` | 8 |
| pt-BR | `contas` | 7 |

Destaque: **en-US tem `financial` repetido duas vezes no mesmo keywords field** (`finance,financial,manage,money,budgeting,savings,control,planning,personal,costs,save,financial,easy`), num campo que está em 100/100 chars e sustenta **uma única posição ≤#50** no app inteiro (`my expenses` #5, sustentada pelo NAME). O keywords field americano é o mais desperdiçado dos 29.

Casos de **substring** (`haushalt` dentro de `Haushaltsbuch` em de-DE, `beheer` dentro de `Budgetbeheer` em nl-NL, `wang` dentro de `Kewangan` em ms, `家庭账本` dentro de `简单家庭账本` em zh-Hans, `finance`/`depense` em fr-FR, `gasto` em es, `توفير`/`أموال` em ar-SA, `การเงิน` em th) **não são char grátis**: dependem de a Apple decompor o composto do NAME, o que é provável em alemão e chinês e duvidoso em malaio. Nesta iteração: não mexer.

## 6. Como o estágio 5 usa este arquivo

1. Abrir a seção do locale. Todo token que aparece na coluna "token(s) que sustentam" **fica**, salvo decisão nomeada.
2. Precisa de char? A ordem é: (a) duplicata de campo da §5 → (b) token de keywords sem posição ≤#50 (listado no fim de cada seção do locale) → (c) token condenado que só sustenta posição >#50 → (d) só então um dos 11 da §3b, nomeando a posição que cai.
3. Nunca tirar token da coluna "melhor posição ≤#10" — são 60+ posições de topo em 29 locales e é tudo que esta iteração tem de ativo.
4. de-DE e pt-BR **não têm slot livre**: todo token de keywords sustenta posição ≤#50. Entrada nova nesses dois exige saída nomeada.

---

## 3. Mapa por locale — composição → posição → token que a sustenta

### de-DE (store `de`, tier A, 64 inst 1*/90d, 2 avaliações na loja) — 29 posições ≤#50

**NAME** `Ausgaben - Haushaltsbuch` (24/30, 6 livres) · **SUBTITLE** `Budget & Finanzen verwalten` (27/30, 3 livres) · **KEYWORDS** (97/100, 3 livres) `kosten,konto,planer,monatsbudget,bilanz,haushalt,einkauf,fixkosten,kontrolle,kategorien,statistik`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `monatliche bilanz` | #1 | MISMATCH | **monatliche** = SEM TOKEN no campo · **bilanz** = `bilanz` (KEYWORDS) |
| `ausgaben kategorien` | #2 | FIT | **ausgaben** = `ausgaben` (NAME) · **kategorien** = `kategorien` (KEYWORDS) |
| `ausgaben statistik` | #2 | FIT | **ausgaben** = `ausgaben` (NAME) · **statistik** = `statistik` (KEYWORDS) |
| `haushaltsbuch kategorien` | #4 | FIT | **haushaltsbuch** = `haushaltsbuch` (NAME) · **kategorien** = `kategorien` (KEYWORDS) |
| `ausgabenkontrolle` | #6 | FIT | **ausgabenkontrolle** = composto por `ausgaben` (NAME) + `kontrolle` (KEYWORDS) |
| `fixkosten verwalten` | #8 | FIT | **fixkosten** = `fixkosten` (KEYWORDS) · **verwalten** = `verwalten` (SUBTITLE) |
| `ausgaben kontrolle` | #10 | FIT | **ausgaben** = `ausgaben` (NAME) · **kontrolle** = `kontrolle` (KEYWORDS) |
| `budget kategorien` | #11 | FIT | **budget** = `monatsbudget` (KEYWORDS) e `budget` (SUBTITLE) · **kategorien** = `kategorien` (KEYWORDS) |
| `kosten statistik` | #12 | FIT | **kosten** = `kosten` (KEYWORDS) · **statistik** = `statistik` (KEYWORDS) |
| `monatliche fixkosten` | #12 | FIT | **monatliche** = SEM TOKEN no campo · **fixkosten** = `fixkosten` (KEYWORDS) |
| `budget pro kategorie` | #13 | FIT | **budget** = `monatsbudget` (KEYWORDS) e `budget` (SUBTITLE) · **pro** = SEM TOKEN no campo · **kategorie** = `kategorien` (KEYWORDS) |
| `einkauf ausgaben` | #13 | PARTIAL | **einkauf** = `einkauf` (KEYWORDS) · **ausgaben** = `ausgaben` (NAME) |
| `ausgaben verwalten` | #15 | FIT | **ausgaben** = `ausgaben` (NAME) · **verwalten** = `verwalten` (SUBTITLE) |
| `ausgaben pro monat` | #22 | FIT | **ausgaben** = `ausgaben` (NAME) · **pro** = SEM TOKEN no campo · **monat** = `monatsbudget` (KEYWORDS) |
| `budget kontrolle` | #26 | FIT | **budget** = `monatsbudget` (KEYWORDS) e `budget` (SUBTITLE) · **kontrolle** = `kontrolle` (KEYWORDS) |
| `haushaltsbuch ausgaben` | #27 | FIT | **haushaltsbuch** = `haushaltsbuch` (NAME) · **ausgaben** = `ausgaben` (NAME) |
| `monatsbudget` | #28 | FIT | **monatsbudget** = `monatsbudget` (KEYWORDS) |
| `konto ausgaben` | #29 | MISMATCH | **konto** = `konto` (KEYWORDS) · **ausgaben** = `ausgaben` (NAME) |
| `fixkosten planer` | #31 | FIT | **fixkosten** = `fixkosten` (KEYWORDS) · **planer** = `planer` (KEYWORDS) |
| `haushaltsbuch monatlich` | #33 | FIT | **haushaltsbuch** = `haushaltsbuch` (NAME) · **monatlich** = SEM TOKEN no campo |
| `haushalt ausgaben` | #35 | FIT | **haushalt** = `haushalt` (KEYWORDS) e `haushaltsbuch` (NAME) · **ausgaben** = `ausgaben` (NAME) |
| `kostenkontrolle` | #40 | FIT | **kostenkontrolle** = composto por `kosten` (KEYWORDS) + `kontrolle` (KEYWORDS) |
| `fixkosten app` | #41 | FIT | **fixkosten** = `fixkosten` (KEYWORDS) · **app** = SEM TOKEN no campo |
| `haushaltskonto` | #41 | MISMATCH | **haushaltskonto** = composto por `haushalt` (KEYWORDS) + `konto` (KEYWORDS) |
| `kosten verwalten` | #42 | FIT | **kosten** = `kosten` (KEYWORDS) · **verwalten** = `verwalten` (SUBTITLE) |
| `monatsbudget planen` | #42 | FIT | **monatsbudget** = `monatsbudget` (KEYWORDS) · **planen** = `planer` (KEYWORDS) |
| `monatsbudget planer` | #47 | FIT | **monatsbudget** = `monatsbudget` (KEYWORDS) · **planer** = `planer` (KEYWORDS) |
| `kosten kontrolle` | #48 | FIT | **kosten** = `kosten` (KEYWORDS) · **kontrolle** = `kontrolle` (KEYWORDS) |
| `haushaltsplaner` | #50 | PARTIAL | **haushaltsplaner** = composto por `haushalt` (KEYWORDS) + `planer` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `ausgaben` | NAME | 10 | #2 |
| `monatsbudget` | KEYWORDS | 7 | #11 |
| `kontrolle` | KEYWORDS | 5 | #6 |
| `kategorien` | KEYWORDS | 4 | #2 |
| `haushaltsbuch` | NAME | 4 | #4 |
| `fixkosten` | KEYWORDS | 4 | #8 |
| `kosten` | KEYWORDS | 4 | #12 |
| `planer` | KEYWORDS | 4 | #31 |
| `verwalten` | SUBTITLE | 3 | #8 |
| `budget` | SUBTITLE | 3 | #11 |
| `haushalt` | NAME+KEYWORDS | 3 | #35 |
| `statistik` | KEYWORDS | 2 | #2 |
| `konto` | KEYWORDS | 2 | #29 |
| `bilanz` | KEYWORDS | 1 | #1 |
| `einkauf` | KEYWORDS | 1 | #13 |

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `haushalt` (9 chars)

**Todos os tokens do keywords field sustentam pelo menos uma posição ≤#50.** Campo 100% load-bearing: qualquer entrada nova exige nomear a posição que se aceita perder.

### pt-BR (store `br`, tier A, 161 inst 1*/90d, 18 avaliações na loja) — 47 posições ≤#50

**NAME** `Meus Gastos: Contas e Despesas` (30/30, 0 livres) · **SUBTITLE** `Finanças do casal e pessoais` (28/30, 2 livres) · **KEYWORDS** (97/100, 3 livres) `compartilhados,contas,economias,planilha,orcamento,diario,mensais,categorias,fixas,resumo,extrato`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `contas mensais casal` | #1 | MISMATCH | **contas** = `contas` (KEYWORDS) e `contas` (NAME) · **mensais** = `mensais` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `gastos mensais casal` | #1 | MISMATCH | **gastos** = `gastos` (NAME) · **mensais** = `mensais` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `gastos mensais por categoria` | #1 | FIT | **gastos** = `gastos` (NAME) · **mensais** = `mensais` (KEYWORDS) · **por** = SEM TOKEN no campo · **categoria** = `categorias` (KEYWORDS) |
| `meus gastos diarios` | #1 | FIT | **meus** = `meus` (NAME) · **gastos** = `gastos` (NAME) · **diarios** = `diario` (KEYWORDS) |
| `planilha compartilhada` | #1 | MISMATCH | **planilha** = `planilha` (KEYWORDS) · **compartilhada** = `compartilhados` (KEYWORDS) |
| `resumo de gastos` | #1 | FIT | **resumo** = `resumo` (KEYWORDS) · **gastos** = `gastos` (NAME) |
| `despesas por categoria` | #2 | FIT | **despesas** = `despesas` (NAME) · **por** = SEM TOKEN no campo · **categoria** = `categorias` (KEYWORDS) |
| `extrato por categoria` | #2 | FIT | **extrato** = `extrato` (KEYWORDS) · **por** = SEM TOKEN no campo · **categoria** = `categorias` (KEYWORDS) |
| `gastos compartilhados` | #2 | MISMATCH | **gastos** = `gastos` (NAME) · **compartilhados** = `compartilhados` (KEYWORDS) |
| `gastos contas` | #2 | PARTIAL | **gastos** = `gastos` (NAME) · **contas** = `contas` (KEYWORDS) e `contas` (NAME) |
| `contas compartilhadas casal` | #3 | MISMATCH | **contas** = `contas` (KEYWORDS) e `contas` (NAME) · **compartilhadas** = `compartilhados` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `despesas mensais casal` | #3 | MISMATCH | **despesas** = `despesas` (NAME) · **mensais** = `mensais` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `despesas pessoais casal` | #3 | MISMATCH | **despesas** = `despesas` (NAME) · **pessoais** = `pessoais` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `financas pessoais casal` | #3 | MISMATCH | **financas** = `finanças` (SUBTITLE) · **pessoais** = `pessoais` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `gastos compartilhados em casal` | #3 | MISMATCH | **gastos** = `gastos` (NAME) · **compartilhados** = `compartilhados` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `gastos fixos mensais` | #3 | FIT | **gastos** = `gastos` (NAME) · **fixos** = `fixas` (KEYWORDS) · **mensais** = `mensais` (KEYWORDS) |
| `gastos por categoria` | #3 | FIT | **gastos** = `gastos` (NAME) · **por** = SEM TOKEN no campo · **categoria** = `categorias` (KEYWORDS) |
| `app de gastos casal` | #4 | MISMATCH | **app** = SEM TOKEN no campo · **gastos** = `gastos` (NAME) · **casal** = `casal` (SUBTITLE) |
| `gastos do casal` | #4 | MISMATCH | **gastos** = `gastos` (NAME) · **do** = `do` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `planilha casal` | #4 | MISMATCH | **planilha** = `planilha` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `planilha do casal` | #4 | MISMATCH | **planilha** = `planilha` (KEYWORDS) · **do** = `do` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `contas casal` | #5 | MISMATCH | **contas** = `contas` (KEYWORDS) e `contas` (NAME) · **casal** = `casal` (SUBTITLE) |
| `despesas compartilhadas casal` | #5 | MISMATCH | **despesas** = `despesas` (NAME) · **compartilhadas** = `compartilhados` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `extrato gastos` | #5 | FIT | **extrato** = `extrato` (KEYWORDS) · **gastos** = `gastos` (NAME) |
| `gastos casal` | #5 | MISMATCH | **gastos** = `gastos` (NAME) · **casal** = `casal` (SUBTITLE) |
| `contas do casal` | #6 | MISMATCH | **contas** = `contas` (KEYWORDS) e `contas` (NAME) · **do** = `do` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `categorias de gastos` | #7 | FIT | **categorias** = `categorias` (KEYWORDS) · **gastos** = `gastos` (NAME) |
| `extrato de gastos` | #7 | FIT | **extrato** = `extrato` (KEYWORDS) · **gastos** = `gastos` (NAME) |
| `despesas fixas` | #8 | FIT | **despesas** = `despesas` (NAME) · **fixas** = `fixas` (KEYWORDS) |
| `contas compartilhadas` | #9 | MISMATCH | **contas** = `contas` (KEYWORDS) e `contas` (NAME) · **compartilhadas** = `compartilhados` (KEYWORDS) |
| `economia do casal` | #9 | MISMATCH | **economia** = `economias` (KEYWORDS) · **do** = `do` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `economias casal` | #9 | MISMATCH | **economias** = `economias` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `economias do casal` | #9 | MISMATCH | **economias** = `economias` (KEYWORDS) · **do** = `do` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `orcamento por categoria` | #10 | FIT | **orcamento** = `orcamento` (KEYWORDS) · **por** = SEM TOKEN no campo · **categoria** = `categorias` (KEYWORDS) |
| `financas compartilhadas` | #12 | MISMATCH | **financas** = `finanças` (SUBTITLE) · **compartilhadas** = `compartilhados` (KEYWORDS) |
| `orcamento compartilhado` | #12 | MISMATCH | **orcamento** = `orcamento` (KEYWORDS) · **compartilhado** = `compartilhados` (KEYWORDS) |
| `despesas diárias` | #13 | FIT | **despesas** = `despesas` (NAME) · **diárias** = `diario` (KEYWORDS) |
| `despesas compartilhadas` | #15 | MISMATCH | **despesas** = `despesas` (NAME) · **compartilhadas** = `compartilhados` (KEYWORDS) |
| `economias mensais` | #17 | FIT | **economias** = `economias` (KEYWORDS) · **mensais** = `mensais` (KEYWORDS) |
| `gastos finanças` | #19 | FIT | **gastos** = `gastos` (NAME) · **finanças** = `finanças` (SUBTITLE) |
| `financas do casal` | #22 | MISMATCH | **financas** = `finanças` (SUBTITLE) · **do** = `do` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `orcamento do casal` | #23 | MISMATCH | **orcamento** = `orcamento` (KEYWORDS) · **do** = `do` (SUBTITLE) · **casal** = `casal` (SUBTITLE) |
| `contas fixas` | #26 | PARTIAL | **contas** = `contas` (KEYWORDS) e `contas` (NAME) · **fixas** = `fixas` (KEYWORDS) |
| `diário gastos` | #28 | FIT | **diário** = `diario` (KEYWORDS) · **gastos** = `gastos` (NAME) |
| `diario de despesas` | #34 | FIT | **diario** = `diario` (KEYWORDS) · **despesas** = `despesas` (NAME) |
| `orcamento casal` | #34 | MISMATCH | **orcamento** = `orcamento` (KEYWORDS) · **casal** = `casal` (SUBTITLE) |
| `despesas gastos` | #36 | FIT | **despesas** = `despesas` (NAME) · **gastos** = `gastos` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `casal` | SUBTITLE | 21 | #1 |
| `gastos` | NAME | 18 | #1 |
| `compartilhados` | KEYWORDS | 9 | #1 |
| `despesas` | NAME | 9 | #2 |
| `contas` | NAME+KEYWORDS | 7 | #1 |
| `do` | SUBTITLE | 7 | #4 |
| `mensais` | KEYWORDS | 6 | #1 |
| `categorias` | KEYWORDS | 6 | #1 |
| `diario` | KEYWORDS | 4 | #1 |
| `finanças` | SUBTITLE | 4 | #3 |
| `economias` | KEYWORDS | 4 | #9 |
| `orcamento` | KEYWORDS | 4 | #10 |
| `planilha` | KEYWORDS | 3 | #1 |
| `extrato` | KEYWORDS | 3 | #2 |
| `fixas` | KEYWORDS | 3 | #3 |
| `pessoais` | SUBTITLE | 2 | #3 |
| `meus` | NAME | 1 | #1 |
| `resumo` | KEYWORDS | 1 | #1 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `contas` (7 chars, já em NAME)

**Todos os tokens do keywords field sustentam pelo menos uma posição ≤#50.** Campo 100% load-bearing: qualquer entrada nova exige nomear a posição que se aceita perder.

### fr-FR (store `fr`, tier A, 27 inst 1*/90d, 1 avaliações na loja) — 5 posições ≤#50

**NAME** `Dépenses - Suivi & Budget` (25/30, 5 livres) · **SUBTITLE** `Finances perso & économie` (25/30, 5 livres) · **KEYWORDS** (99/100, 1 livres) `argent,compte,finance,gestion,suivi,economie,depense,planificateur,salaire,facture,ecologie,famille`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `dépenses suivi` | #3 | FIT | **dépenses** = `depense` (KEYWORDS) e `dépenses` (NAME) · **suivi** = `suivi` (KEYWORDS) e `suivi` (NAME) |
| `finances perso` | #6 | PARTIAL | **finances** = `finance` (KEYWORDS) e `finances` (SUBTITLE) · **perso** = `perso` (SUBTITLE) |
| `budget perso` | #15 | FIT | **budget** = `budget` (NAME) · **perso** = `perso` (SUBTITLE) |
| `my costa` | #35 | MISMATCH | **costa** = SEM TOKEN no campo |
| `dépenses` | #46 | FIT | **dépenses** = `depense` (KEYWORDS) e `dépenses` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `dépenses` | NAME | 2 | #3 |
| `depense` | KEYWORDS | 2 | #3 |
| `perso` | SUBTITLE | 2 | #6 |
| `suivi` | NAME+KEYWORDS | 1 | #3 |
| `finances` | SUBTITLE | 1 | #6 |
| `finance` | SUBTITLE+KEYWORDS | 1 | #6 |
| `budget` | NAME | 1 | #15 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `suivi` (6 chars, já em NAME), `economie` (9 chars, já em SUBTITLE)

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `finance` (8 chars), `depense` (8 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `argent`, `compte`, `gestion`, `economie`, `planificateur`, `salaire`, `facture`, `ecologie`, `famille`

### ja (store `jp`, tier A, 27 inst 1*/90d, 0 avaliações na loja) — 3 posições ≤#50

**NAME** `家計簿 - シンプル支出管理` (14/30, 16 livres) · **SUBTITLE** `節約・予算・お金の見える化` (13/30, 17 livres) · **KEYWORDS** (47/100, 53 livres) `支出,収支,節約,予算,お金,家計,記録,簡単,かけいぼ,マネー,出費,お小遣い,貯金,生活費`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `節約・予算・お金の見える化` | #5 | FIT | **節約・予算・お金の見える化** = `節約` (KEYWORDS) e `節約・予算・お金の見える化` (SUBTITLE) |
| `シンプル支出管理` | #23 | FIT | **シンプル支出管理** = `支出` (KEYWORDS) e `シンプル支出管理` (NAME) |
| `personal finance` | #45 | PARTIAL | **personal** = SEM TOKEN no campo · **finance** = SEM TOKEN no campo |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `節約・予算・お金の見える化` | SUBTITLE | 1 | #5 |
| `節約` | SUBTITLE+KEYWORDS | 1 | #5 |
| `シンプル支出管理` | NAME | 1 | #23 |
| `支出` | NAME+KEYWORDS | 1 | #23 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `収支`, `予算`, `お金`, `家計`, `記録`, `簡単`, `かけいぼ`, `マネー`, `出費`, `お小遣い`, `貯金`, `生活費`

### en-US (store `us`, tier A, 19 inst 1*/90d, 1 avaliações na loja) — 1 posições ≤#50

**NAME** `My Expenses: Personal Finances` (30/30, 0 livres) · **SUBTITLE** `Where's My Money? Easy Control` (30/30, 0 livres) · **KEYWORDS** (100/100, 0 livres) `finance,financial,manage,money,budgeting,savings,control,planning,personal,costs,save,financial,easy`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `my expenses` | #5 | FIT | **my** = `my` (NAME) e `my` (SUBTITLE) · **expenses** = `expenses` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `my` | NAME+SUBTITLE | 1 | #5 |
| `expenses` | NAME | 1 | #5 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `money` (6 chars, já em SUBTITLE), `control` (8 chars, já em SUBTITLE), `personal` (9 chars, já em NAME), `easy` (5 chars, já em SUBTITLE)

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `finance` (8 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `finance`, `financial`, `manage`, `money`, `budgeting`, `savings`, `control`, `planning`, `personal`, `costs`, `save`, `financial`, `easy`

### es-ES (store `es`, tier A, 8 inst 1*/90d, 0 avaliações na loja) — 1 posições ≤#50

**NAME** `Mis Gastos: Cuentas y Dinero` (28/30, 2 livres) · **SUBTITLE** `Control financiero de gastos` (28/30, 2 livres) · **KEYWORDS** (100/100, 0 livres) `dinero,presupuesto,financiero,ingreso,ahorrar,gestión,familiar,pago,organizador,pagar,gasto,expensas`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `expensas` | #49 | PARTIAL | **expensas** = `expensas` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `expensas` | KEYWORDS | 1 | #49 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `dinero` (7 chars, já em NAME), `financiero` (11 chars, já em SUBTITLE)

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `gasto` (6 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `dinero`, `presupuesto`, `financiero`, `ingreso`, `ahorrar`, `gestión`, `familiar`, `pago`, `organizador`, `pagar`, `gasto`

### tr (store `tr`, tier B, 17 inst 1*/90d, 0 avaliações na loja) — 3 posições ≤#50

**NAME** `Harcamalar - Bütçe & Takip` (26/30, 4 livres) · **SUBTITLE** `Para yönetimi ve tasarruf` (25/30, 5 livres) · **KEYWORDS** (89/100, 11 livres) `para,bütçe,gider,masraf,tasarruf,gelir,kasa,defter,finans,kişisel,maaş,bakkal,aile,fatura`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `harcamalar bütçe` | #2 | FIT | **harcamalar** = `harcamalar` (NAME) · **bütçe** = `bütçe` (KEYWORDS) e `bütçe` (NAME) |
| `harcamalar` | #11 | FIT | **harcamalar** = `harcamalar` (NAME) |
| `harcama defteri` | #44 | FIT | **harcama** = `harcamalar` (NAME) · **defteri** = SEM TOKEN no campo |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `harcamalar` | NAME | 3 | #2 |
| `bütçe` | NAME+KEYWORDS | 1 | #2 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `para` (5 chars, já em SUBTITLE), `bütçe` (6 chars, já em NAME), `tasarruf` (9 chars, já em SUBTITLE)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `para`, `gider`, `masraf`, `tasarruf`, `gelir`, `kasa`, `defter`, `finans`, `kişisel`, `maaş`, `bakkal`, `aile`, `fatura`

### it (store `it`, tier B, 12 inst 1*/90d, 0 avaliações na loja) — 2 posições ≤#50

**NAME** `Spese - Bilancio Personale` (26/30, 4 livres) · **SUBTITLE** `Budget, risparmio e finanze` (27/30, 3 livres) · **KEYWORDS** (95/100, 5 livres) `soldi,bilancio,risparmio,conto,finanza,gestione,monitoraggio,spesa,denaro,budget,carta,famiglia`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `bilancio personale` | #5 | MISMATCH | **bilancio** = `bilancio` (KEYWORDS) e `bilancio` (NAME) · **personale** = `personale` (NAME) |
| `spese bilancio` | #9 | MISMATCH | **spese** = `spesa` (KEYWORDS) e `spese` (NAME) · **bilancio** = `bilancio` (KEYWORDS) e `bilancio` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `bilancio` | NAME+KEYWORDS | 2 | #5 |
| `personale` | NAME | 1 | #5 |
| `spese` | NAME | 1 | #9 |
| `spesa` | KEYWORDS | 1 | #9 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `bilancio` (9 chars, já em NAME), `risparmio` (10 chars, já em SUBTITLE), `budget` (7 chars, já em SUBTITLE)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `soldi`, `risparmio`, `conto`, `finanza`, `gestione`, `monitoraggio`, `denaro`, `budget`, `carta`, `famiglia`

### ar-SA (store `sa`, tier B, 10 inst 1*/90d, 0 avaliações na loja) — 6 posições ≤#50

**NAME** `المصروفات - ميزانية وتتبع` (25/30, 5 livres) · **SUBTITLE** `إدارة الأموال والتوفير` (22/30, 8 livres) · **KEYWORDS** (77/100, 23 livres) `ميزانية,مصاريف,محفظة,توفير,أموال,حساب,نفقات,تخطيط,مالي,شخصي,راتب,فواتير,عائلة`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `المصروفات ميزانية` | #3 | FIT | **المصروفات** = `المصروفات` (NAME) · **ميزانية** = `ميزانية` (KEYWORDS) e `ميزانية` (NAME) |
| `تخطيط مالي شخصي` | #8 | PARTIAL | **تخطيط** = `تخطيط` (KEYWORDS) · **مالي** = `مالي` (KEYWORDS) · **شخصي** = `شخصي` (KEYWORDS) |
| `تتبع المصروفات` | #17 | FIT | **تتبع** = `وتتبع` (NAME) · **المصروفات** = `المصروفات` (NAME) |
| `ادارة المصروفات` | #19 | FIT | **ادارة** = `إدارة` (SUBTITLE) · **المصروفات** = `المصروفات` (NAME) |
| `المصروفات` | #20 | FIT | **المصروفات** = `المصروفات` (NAME) |
| `ميزانية شخصية` | #44 | FIT | **ميزانية** = `ميزانية` (KEYWORDS) e `ميزانية` (NAME) · **شخصية** = SEM TOKEN no campo |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `المصروفات` | NAME | 4 | #3 |
| `ميزانية` | NAME+KEYWORDS | 2 | #3 |
| `تخطيط` | KEYWORDS | 1 | #8 |
| `مالي` | KEYWORDS | 1 | #8 |
| `شخصي` | KEYWORDS | 1 | #8 |
| `وتتبع` | NAME | 1 | #17 |
| `إدارة` | SUBTITLE | 1 | #19 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `ميزانية` (8 chars, já em NAME)

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `توفير` (6 chars), `أموال` (6 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `مصاريف`, `محفظة`, `توفير`, `أموال`, `حساب`, `نفقات`, `راتب`, `فواتير`, `عائلة`

### es-MX (store `mx`, tier B, 10 inst 1*/90d, 0 avaliações na loja) — 1 posições ≤#50

**NAME** `Mis Gastos: Cuentas y Dinero` (28/30, 2 livres) · **SUBTITLE** `Control financiero de gastos` (28/30, 2 livres) · **KEYWORDS** (100/100, 0 livres) `dinero,presupuesto,financiero,ingreso,ahorrar,gestión,familiar,pago,organizador,pagar,gasto,expensas`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `mis gastos` | #37 | FIT | **mis** = `mis` (NAME) · **gastos** = `gasto` (KEYWORDS) e `gastos` (NAME) e `gastos` (SUBTITLE) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `mis` | NAME | 1 | #37 |
| `gastos` | NAME+SUBTITLE | 1 | #37 |
| `gasto` | NAME+SUBTITLE+KEYWORDS | 1 | #37 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `dinero` (7 chars, já em NAME), `financiero` (11 chars, já em SUBTITLE)

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `gasto` (6 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `dinero`, `presupuesto`, `financiero`, `ingreso`, `ahorrar`, `gestión`, `familiar`, `pago`, `organizador`, `pagar`, `expensas`

### id (store `id`, tier B, 10 inst 1*/90d, 0 avaliações na loja) — 6 posições ≤#50

**NAME** `Pengeluaran - Catatan Anggaran` (30/30, 0 livres) · **SUBTITLE** `Atur uang & hemat dengan mudah` (30/30, 0 livres) · **KEYWORDS** (92/100, 8 livres) `uang,anggaran,tabungan,catatan,keuangan,gaji,dompet,buku kas,manajemen,hemat,bulanan,tagihan`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `atur uang bulanan` | #5 | FIT | **atur** = `atur` (SUBTITLE) · **uang** = `uang` (KEYWORDS) e `uang` (SUBTITLE) · **bulanan** = `bulanan` (KEYWORDS) |
| `pengeluaran catatan` | #6 | FIT | **pengeluaran** = `pengeluaran` (NAME) · **catatan** = `catatan` (KEYWORDS) e `catatan` (NAME) |
| `hemat uang aplikasi` | #22 | PARTIAL | **hemat** = `hemat` (KEYWORDS) e `hemat` (SUBTITLE) · **uang** = `uang` (KEYWORDS) e `uang` (SUBTITLE) · **aplikasi** = SEM TOKEN no campo |
| `anggaran bulanan` | #26 | FIT | **anggaran** = `anggaran` (KEYWORDS) e `anggaran` (NAME) · **bulanan** = `bulanan` (KEYWORDS) |
| `tabungan bulanan` | #28 | MISMATCH | **tabungan** = `tabungan` (KEYWORDS) · **bulanan** = `bulanan` (KEYWORDS) |
| `buku kas` | #43 | MISMATCH | **buku** = `buku kas` (KEYWORDS) · **kas** = `kas` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `bulanan` | KEYWORDS | 3 | #5 |
| `uang` | SUBTITLE+KEYWORDS | 2 | #5 |
| `atur` | SUBTITLE | 1 | #5 |
| `pengeluaran` | NAME | 1 | #6 |
| `catatan` | NAME+KEYWORDS | 1 | #6 |
| `hemat` | SUBTITLE+KEYWORDS | 1 | #22 |
| `anggaran` | NAME+KEYWORDS | 1 | #26 |
| `tabungan` | KEYWORDS | 1 | #28 |
| `buku kas` | KEYWORDS | 1 | #43 |
| `kas` | — | 1 | #43 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `uang` (5 chars, já em SUBTITLE), `anggaran` (9 chars, já em NAME), `catatan` (8 chars, já em NAME), `hemat` (6 chars, já em SUBTITLE)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `keuangan`, `gaji`, `dompet`, `manajemen`, `tagihan`

### zh-Hans (store `cn`, tier B, 5 inst 1*/90d, 0 avaliações na loja) — 3 posições ≤#50

**NAME** `记账 - 简单家庭账本` (11/30, 19 livres) · **SUBTITLE** `支出管理｜预算追踪｜理财` (12/30, 18 livres) · **KEYWORDS** (48/100, 52 livres) `个人理财,消费记录,家庭账本,收支,财务,钱包,账单,理财app,日常开销,小账本,月账单,省钱`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `简单家庭账本` | #2 | FIT | **简单家庭账本** = `家庭账本` (KEYWORDS) e `简单家庭账本` (NAME) |
| `家庭账本` | #29 | FIT | **家庭账本** = `家庭账本` (KEYWORDS) e `简单家庭账本` (NAME) |
| `日常开销记录` | #44 | FIT | **日常开销记录** = `日常开销` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `简单家庭账本` | NAME | 2 | #2 |
| `家庭账本` | NAME+KEYWORDS | 2 | #2 |
| `日常开销` | KEYWORDS | 1 | #44 |

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `家庭账本` (5 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `个人理财`, `消费记录`, `收支`, `财务`, `钱包`, `账单`, `理财app`, `小账本`, `月账单`, `省钱`

### ko (store `kr`, tier B, 2 inst 1*/90d, 0 avaliações na loja) — 2 posições ≤#50

**NAME** `가계부 - 간단한 지출 관리` (15/30, 15 livres) · **SUBTITLE** `예산·자산 추적·절약 도우미` (15/30, 15 livres) · **KEYWORDS** (46/100, 54 livres) `머니,지출,예산,절약,자산,재테크,수입,통장,머니매니저,용돈,월급,생활비,가족,장부`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `간단한 가계부` | #25 | FIT | **간단한** = `간단한` (NAME) · **가계부** = `가계부` (NAME) |
| `절약 가계부` | #41 | FIT | **절약** = `절약` (KEYWORDS) e `절약` (SUBTITLE) · **가계부** = `가계부` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `가계부` | NAME | 2 | #25 |
| `간단한` | NAME | 1 | #25 |
| `절약` | SUBTITLE+KEYWORDS | 1 | #41 |

**Duplicata de campo** (token do KEYWORDS que o NAME/SUBTITLE já entrega — char grátis, zero custo de proteção): `지출` (3 chars, já em NAME), `예산` (3 chars, já em SUBTITLE), `절약` (3 chars, já em SUBTITLE), `자산` (3 chars, já em SUBTITLE)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `머니`, `지출`, `예산`, `자산`, `재테크`, `수입`, `통장`, `머니매니저`, `용돈`, `월급`, `생활비`, `가족`, `장부`

### vi (store `vn`, tier C, 9 inst 1*/90d, 0 avaliações na loja) — 3 posições ≤#50

**NAME** `Quản Lý Chi Tiêu: Tài Chính` (27/30, 3 livres) · **SUBTITLE** `Theo Dõi Chi Phí & Ngân Sách` (28/30, 2 livres) · **KEYWORDS** (77/100, 23 livres) `tiền,tiết,kiệm,kế,hoạch,sổ,nhật,ký,cá,nhân,thống,kê,biểu,đồ,excel,pdf,offline`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `chi tiêu offline` | #11 | FIT | **chi** = `chi` (NAME) e `chi` (SUBTITLE) · **tiêu** = `tiêu` (NAME) · **offline** = `offline` (KEYWORDS) |
| `biểu đồ chi tiêu` | #12 | FIT | **biểu** = `biểu` (KEYWORDS) · **đồ** = `đồ` (KEYWORDS) · **chi** = `chi` (NAME) e `chi` (SUBTITLE) · **tiêu** = `tiêu` (NAME) |
| `quan ly chi tieu` | #16 | FIT | **quan** = SEM TOKEN no campo · **ly** = `lý` (NAME) · **chi** = `chi` (NAME) e `chi` (SUBTITLE) · **tieu** = `tiêu` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `chi` | NAME+SUBTITLE | 3 | #11 |
| `tiêu` | NAME | 3 | #11 |
| `offline` | KEYWORDS | 1 | #11 |
| `biểu` | KEYWORDS | 1 | #12 |
| `đồ` | KEYWORDS | 1 | #12 |
| `lý` | NAME | 1 | #16 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `tiền`, `tiết`, `kiệm`, `kế`, `hoạch`, `sổ`, `nhật`, `ký`, `cá`, `nhân`, `thống`, `kê`, `excel`, `pdf`

### hi (store `in`, tier C, 7 inst 1*/90d, 0 avaliações na loja) — 5 posições ≤#50

**NAME** `मेरा खर्च: डेली बजट ट्रैकर` (26/30, 4 livres) · **SUBTITLE** `पैसे का हिसाब रखें आसानी से` (27/30, 3 livres) · **KEYWORDS** (94/100, 6 livres) `खर्चा,फाइनेंस,सेविंग्स,मनी,एक्सपेंस,डायरी,खाता,रिपोर्ट,ऑफलाइन,बचत,पीडीएफ,एक्सेल,कैलेंडर,प्लानर`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `मेरा खर्च` | #2 | FIT | **मेरा** = `मेरा` (NAME) · **खर्च** = `खर्चा` (KEYWORDS) e `खर्च` (NAME) |
| `एक्सपेंस` | #3 | FIT | **एक्सपेंस** = `एक्सपेंस` (KEYWORDS) |
| `सेविंग्स` | #6 | MISMATCH | **सेविंग्स** = `सेविंग्स` (KEYWORDS) |
| `फाइनेंस` | #26 | PARTIAL | **फाइनेंस** = `फाइनेंस` (KEYWORDS) |
| `एक्सेल` | #43 | FIT | **एक्सेल** = `एक्सेल` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `मेरा` | NAME | 1 | #2 |
| `खर्च` | NAME | 1 | #2 |
| `खर्चा` | KEYWORDS | 1 | #2 |
| `एक्सपेंस` | KEYWORDS | 1 | #3 |
| `सेविंग्स` | KEYWORDS | 1 | #6 |
| `फाइनेंस` | KEYWORDS | 1 | #26 |
| `एक्सेल` | KEYWORDS | 1 | #43 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `मनी`, `डायरी`, `खाता`, `रिपोर्ट`, `ऑफलाइन`, `बचत`, `पीडीएफ`, `कैलेंडर`, `प्लानर`

### ru (store `ru`, tier C, 6 inst 1*/90d, 0 avaliações na loja) — 0 posições ≤#50

**NAME** `Мои расходы: учет финансов` (26/30, 4 livres) · **SUBTITLE** `Контроль трат и личный бюджет` (29/30, 1 livres) · **KEYWORDS** (86/100, 14 livres) `деньги,календарь,аналитика,цели,экспорт,планирование,экономия,кошелек,сбережения,отчет`

_Nenhuma composição rankeada ≤#50. Nada a proteger neste locale — o campo pode ser recomposto livremente._

### nl-NL (store `nl`, tier C, 4 inst 1*/90d, 0 avaliações na loja) — 5 posições ≤#50

**NAME** `Mijn Uitgaven: Budgetbeheer` (27/30, 3 livres) · **SUBTITLE** `Snel geld & budget bijhouden` (28/30, 2 livres) · **KEYWORDS** (99/100, 1 livres) `financien,sparen,kasboek,kosten,beheer,administratie,exporteren,grafiek,categorie,offline,pdf,excel`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `uitgaven grafiek` | #6 | FIT | **uitgaven** = `uitgaven` (NAME) · **grafiek** = `grafiek` (KEYWORDS) |
| `uitgaven excel` | #7 | FIT | **uitgaven** = `uitgaven` (NAME) · **excel** = `excel` (KEYWORDS) |
| `uitgaven offline` | #24 | FIT | **uitgaven** = `uitgaven` (NAME) · **offline** = `offline` (KEYWORDS) |
| `mijn uitgaven` | #30 | FIT | **mijn** = `mijn` (NAME) · **uitgaven** = `uitgaven` (NAME) |
| `snel geld` | #40 | PARTIAL | **snel** = `snel` (SUBTITLE) · **geld** = `geld` (SUBTITLE) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `uitgaven` | NAME | 4 | #6 |
| `grafiek` | KEYWORDS | 1 | #6 |
| `excel` | KEYWORDS | 1 | #7 |
| `offline` | KEYWORDS | 1 | #24 |
| `mijn` | NAME | 1 | #30 |
| `snel` | SUBTITLE | 1 | #40 |
| `geld` | SUBTITLE | 1 | #40 |

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `beheer` (7 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `financien`, `sparen`, `kasboek`, `kosten`, `beheer`, `administratie`, `exporteren`, `categorie`, `pdf`

### fi (store `fi`, tier C, 3 inst 1*/90d, 1 avaliações na loja) — 9 posições ≤#50

**NAME** `Omat Menot: Budjetti & Raha` (27/30, 3 livres) · **SUBTITLE** `Helppo kuluseuranta ja säästö` (29/30, 1 livres) · **KEYWORDS** (82/100, 18 livres) `kirjaus,laskuri,säästäminen,excel,pdf,kaavio,widget,offline,kalenteri,kustannukset`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `menot excel` | #1 | FIT | **menot** = `menot` (NAME) · **excel** = `excel` (KEYWORDS) |
| `omat menot` | #1 | FIT | **omat** = `omat` (NAME) · **menot** = `menot` (NAME) |
| `menot kaavio` | #2 | FIT | **menot** = `menot` (NAME) · **kaavio** = `kaavio` (KEYWORDS) |
| `helppo kuluseuranta` | #7 | FIT | **helppo** = `helppo` (SUBTITLE) · **kuluseuranta** = `kuluseuranta` (SUBTITLE) |
| `menot offline` | #8 | FIT | **menot** = `menot` (NAME) · **offline** = `offline` (KEYWORDS) |
| `menot widget` | #8 | FIT | **menot** = `menot` (NAME) · **widget** = `widget` (KEYWORDS) |
| `kustannukset` | #24 | FIT | **kustannukset** = `kustannukset` (KEYWORDS) |
| `säästäminen` | #43 | PARTIAL | **säästäminen** = `säästäminen` (KEYWORDS) |
| `kuluseuranta` | #45 | FIT | **kuluseuranta** = `kuluseuranta` (SUBTITLE) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `menot` | NAME | 5 | #1 |
| `kuluseuranta` | SUBTITLE | 2 | #7 |
| `excel` | KEYWORDS | 1 | #1 |
| `omat` | NAME | 1 | #1 |
| `kaavio` | KEYWORDS | 1 | #2 |
| `helppo` | SUBTITLE | 1 | #7 |
| `offline` | KEYWORDS | 1 | #8 |
| `widget` | KEYWORDS | 1 | #8 |
| `kustannukset` | KEYWORDS | 1 | #24 |
| `säästäminen` | KEYWORDS | 1 | #43 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `kirjaus`, `laskuri`, `pdf`, `kalenteri`

### he (store `il`, tier C, 3 inst 1*/90d, 0 avaliações na loja) — 6 posições ≤#50

**NAME** `ההוצאות שלי: מעקב וניהול` (24/30, 6 livres) · **SUBTITLE** `איפה הכסף? שליטה בתקציב` (23/30, 7 livres) · **KEYWORDS** (72/100, 28 livres) `חיסכון,תכנון,דוח,אקסל,גרפים,קטגוריות,יעדים,אישי,יומי,חודשי,כספים,פיננסים`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `ההוצאות שלי` | #1 | FIT | **ההוצאות** = `ההוצאות` (NAME) · **שלי** = `שלי` (NAME) |
| `איפה הכסף` | #2 | PARTIAL | **איפה** = `איפה` (SUBTITLE) · **הכסף** = `הכסף` (SUBTITLE) |
| `ההוצאות` | #2 | FIT | **ההוצאות** = `ההוצאות` (NAME) |
| `בתקציב` | #4 | FIT | **בתקציב** = `בתקציב` (SUBTITLE) |
| `קטגוריות` | #18 | FIT | **קטגוריות** = `קטגוריות` (KEYWORDS) |
| `וניהול` | #24 | PARTIAL | **וניהול** = `וניהול` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `ההוצאות` | NAME | 2 | #1 |
| `שלי` | NAME+SUBTITLE | 1 | #1 |
| `איפה` | SUBTITLE | 1 | #2 |
| `הכסף` | SUBTITLE | 1 | #2 |
| `בתקציב` | SUBTITLE | 1 | #4 |
| `קטגוריות` | KEYWORDS | 1 | #18 |
| `וניהול` | NAME | 1 | #24 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `חיסכון`, `תכנון`, `דוח`, `אקסל`, `גרפים`, `יעדים`, `אישי`, `יומי`, `חודשי`, `כספים`, `פיננסים`

### no (store `no`, tier C, 3 inst 1*/90d, 0 avaliações na loja) — 9 posições ≤#50

**NAME** `Mine Utgifter: Budsjett` (23/30, 7 livres) · **SUBTITLE** `Enkel oversikt og sparing` (25/30, 5 livres) · **KEYWORDS** (90/100, 10 livres) `økonomi,penger,regnskap,dagbok,kategori,excel,pdf,faste,widget,privatøkonomi,kontroll,logg`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `utgifter excel` | #2 | FIT | **utgifter** = `utgifter` (NAME) · **excel** = `excel` (KEYWORDS) |
| `utgifter widget` | #2 | FIT | **utgifter** = `utgifter` (NAME) · **widget** = `widget` (KEYWORDS) |
| `faste utgifter` | #3 | FIT | **faste** = `faste` (KEYWORDS) · **utgifter** = `utgifter` (NAME) |
| `mine utgifter` | #3 | FIT | **mine** = `mine` (NAME) · **utgifter** = `utgifter` (NAME) |
| `budsjett kategori` | #5 | FIT | **budsjett** = `budsjett` (NAME) · **kategori** = `kategori` (KEYWORDS) |
| `enkel oversikt` | #6 | FIT | **enkel** = `enkel` (SUBTITLE) · **oversikt** = `oversikt` (SUBTITLE) |
| `utgifter oversikt` | #14 | FIT | **utgifter** = `utgifter` (NAME) · **oversikt** = `oversikt` (SUBTITLE) |
| `privatokonomi app` | #22 | PARTIAL | **privatokonomi** = `privatøkonomi` (KEYWORDS) · **app** = SEM TOKEN no campo |
| `kategori` | #37 | FIT | **kategori** = `kategori` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `utgifter` | NAME | 5 | #2 |
| `kategori` | KEYWORDS | 2 | #5 |
| `oversikt` | SUBTITLE | 2 | #6 |
| `excel` | KEYWORDS | 1 | #2 |
| `widget` | KEYWORDS | 1 | #2 |
| `faste` | KEYWORDS | 1 | #3 |
| `mine` | NAME | 1 | #3 |
| `budsjett` | NAME | 1 | #5 |
| `enkel` | SUBTITLE | 1 | #6 |
| `privatøkonomi` | KEYWORDS | 1 | #22 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `økonomi`, `penger`, `regnskap`, `dagbok`, `pdf`, `kontroll`, `logg`

### uk (store `ua`, tier C, 3 inst 1*/90d, 0 avaliações na loja) — 8 posições ≤#50

**NAME** `Мої витрати: облік фінансів` (27/30, 3 livres) · **SUBTITLE** `Зручний бюджет та аналітика` (27/30, 3 livres) · **KEYWORDS** (92/100, 8 livres) `гроші,гаманець,контроль,планування,експорт,цілі,категорії,офлайн,звіт,календар,записи,віджет`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `зручний бюджет` | #1 | FIT | **зручний** = `зручний` (SUBTITLE) · **бюджет** = `бюджет` (SUBTITLE) |
| `фінансів` | #8 | PARTIAL | **фінансів** = `фінансів` (NAME) |
| `віджет витрат` | #12 | FIT | **віджет** = `віджет` (KEYWORDS) · **витрат** = `витрати` (NAME) |
| `мої витрати` | #12 | FIT | **мої** = `мої` (NAME) · **витрати** = `витрати` (NAME) |
| `звіт витрат` | #17 | FIT | **звіт** = `звіт` (KEYWORDS) · **витрат** = `витрати` (NAME) |
| `витрати офлайн` | #20 | FIT | **витрати** = `витрати` (NAME) · **офлайн** = `офлайн` (KEYWORDS) |
| `витрати календар` | #22 | FIT | **витрати** = `витрати` (NAME) · **календар** = `календар` (KEYWORDS) |
| `категорії` | #29 | FIT | **категорії** = `категорії` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `витрати` | NAME | 5 | #12 |
| `зручний` | SUBTITLE | 1 | #1 |
| `бюджет` | SUBTITLE | 1 | #1 |
| `фінансів` | NAME | 1 | #8 |
| `віджет` | KEYWORDS | 1 | #12 |
| `мої` | NAME | 1 | #12 |
| `звіт` | KEYWORDS | 1 | #17 |
| `офлайн` | KEYWORDS | 1 | #20 |
| `календар` | KEYWORDS | 1 | #22 |
| `категорії` | KEYWORDS | 1 | #29 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `гроші`, `гаманець`, `контроль`, `планування`, `експорт`, `цілі`, `записи`

### ms (store `my`, tier C, 2 inst 1*/90d, 0 avaliações na loja) — 12 posições ≤#50

**NAME** `Belanja Saya: Urus Kewangan` (27/30, 3 livres) · **SUBTITLE** `Catat Belanja & Bajet Harian` (28/30, 2 livres) · **KEYWORDS** (89/100, 11 livres) `duit,wang,simpanan,laporan,pdf,excel,perekod,penyata,graf,kalendar,kategori,offline,jimat`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `belanja saya` | #1 | FIT | **belanja** = `belanja` (NAME) e `belanja` (SUBTITLE) · **saya** = `saya` (NAME) |
| `graf belanja` | #1 | FIT | **graf** = `graf` (KEYWORDS) · **belanja** = `belanja` (NAME) e `belanja` (SUBTITLE) |
| `belanja excel` | #3 | FIT | **belanja** = `belanja` (NAME) e `belanja` (SUBTITLE) · **excel** = `excel` (KEYWORDS) |
| `catat belanja` | #3 | FIT | **catat** = `catat` (SUBTITLE) · **belanja** = `belanja` (NAME) e `belanja` (SUBTITLE) |
| `belanja offline` | #4 | FIT | **belanja** = `belanja` (NAME) e `belanja` (SUBTITLE) · **offline** = `offline` (KEYWORDS) |
| `perekod` | #5 | FIT | **perekod** = `perekod` (KEYWORDS) |
| `laporan belanja` | #11 | FIT | **laporan** = `laporan` (KEYWORDS) · **belanja** = `belanja` (NAME) e `belanja` (SUBTITLE) |
| `belanja harian` | #13 | FIT | **belanja** = `belanja` (NAME) e `belanja` (SUBTITLE) · **harian** = `harian` (SUBTITLE) |
| `penyata` | #16 | FIT | **penyata** = `penyata` (KEYWORDS) |
| `kategori` | #21 | FIT | **kategori** = `kategori` (KEYWORDS) |
| `urus` | #32 | PARTIAL | **urus** = `urus` (NAME) |
| `kewangan` | #47 | PARTIAL | **kewangan** = `kewangan` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `belanja` | NAME+SUBTITLE | 7 | #1 |
| `saya` | NAME | 1 | #1 |
| `graf` | KEYWORDS | 1 | #1 |
| `excel` | KEYWORDS | 1 | #3 |
| `catat` | SUBTITLE | 1 | #3 |
| `offline` | KEYWORDS | 1 | #4 |
| `perekod` | KEYWORDS | 1 | #5 |
| `laporan` | KEYWORDS | 1 | #11 |
| `harian` | SUBTITLE | 1 | #13 |
| `penyata` | KEYWORDS | 1 | #16 |
| `kategori` | KEYWORDS | 1 | #21 |
| `urus` | NAME | 1 | #32 |
| `kewangan` | NAME | 1 | #47 |

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `wang` (5 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `duit`, `wang`, `simpanan`, `pdf`, `kalendar`, `jimat`

### pl (store `pl`, tier C, 2 inst 1*/90d, 0 avaliações na loja) — 8 posições ≤#50

**NAME** `Moje Wydatki: Domowe Finanse` (28/30, 2 livres) · **SUBTITLE** `Kontrola finansów osobistych` (28/30, 2 livres) · **KEYWORDS** (90/100, 10 livres) `oszczędzanie,pieniądze,koszty,kategorie,wykresy,raporty,planowanie,excel,pdf,offline,zapis`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `wydatki offline` | #3 | FIT | **wydatki** = `wydatki` (NAME) · **offline** = `offline` (KEYWORDS) |
| `wydatki excel` | #4 | FIT | **wydatki** = `wydatki` (NAME) · **excel** = `excel` (KEYWORDS) |
| `osobistych` | #5 | PARTIAL | **osobistych** = `osobistych` (SUBTITLE) |
| `kontrola finansów` | #6 | FIT | **kontrola** = `kontrola` (SUBTITLE) · **finansów** = `finansów` (SUBTITLE) |
| `moje wydatki` | #18 | FIT | **moje** = `moje` (NAME) · **wydatki** = `wydatki` (NAME) |
| `domowe` | #19 | PARTIAL | **domowe** = `domowe` (NAME) |
| `finansów` | #27 | PARTIAL | **finansów** = `finansów` (SUBTITLE) |
| `kategorie` | #28 | FIT | **kategorie** = `kategorie` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `wydatki` | NAME | 3 | #3 |
| `finansów` | SUBTITLE | 2 | #6 |
| `offline` | KEYWORDS | 1 | #3 |
| `excel` | KEYWORDS | 1 | #4 |
| `osobistych` | SUBTITLE | 1 | #5 |
| `kontrola` | SUBTITLE | 1 | #6 |
| `moje` | NAME | 1 | #18 |
| `domowe` | NAME | 1 | #19 |
| `kategorie` | KEYWORDS | 1 | #28 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `oszczędzanie`, `pieniądze`, `koszty`, `wykresy`, `raporty`, `planowanie`, `pdf`, `zapis`

### hu (store `hu`, tier C, 1 inst 1*/90d, 0 avaliações na loja) — 6 posições ≤#50

**NAME** `Kiadásaim: Kiadáskövető` (23/30, 7 livres) · **SUBTITLE** `Egyszerű költségvetés` (21/30, 9 livres) · **KEYWORDS** (93/100, 7 livres) `pénzügy,pénz,spórolás,költségek,napló,tervező,statisztika,export,célok,offline,elemzés,widget`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `kiadaskoveto widget` | #1 | FIT | **kiadaskoveto** = `kiadáskövető` (NAME) · **widget** = `widget` (KEYWORDS) |
| `kiadásaim kiadáskövető` | #1 | FIT | **kiadásaim** = `kiadásaim` (NAME) · **kiadáskövető** = `kiadáskövető` (NAME) |
| `kiadásaim` | #4 | FIT | **kiadásaim** = `kiadásaim` (NAME) |
| `egyszerű költségvetés` | #8 | FIT | **egyszerű** = `egyszerű` (SUBTITLE) · **költségvetés** = `költségvetés` (SUBTITLE) |
| `kiadáskövető` | #29 | FIT | **kiadáskövető** = `kiadáskövető` (NAME) |
| `spórolás` | #44 | PARTIAL | **spórolás** = `spórolás` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `kiadáskövető` | NAME | 3 | #1 |
| `kiadásaim` | NAME | 2 | #1 |
| `widget` | KEYWORDS | 1 | #1 |
| `egyszerű` | SUBTITLE | 1 | #8 |
| `költségvetés` | SUBTITLE | 1 | #8 |
| `spórolás` | KEYWORDS | 1 | #44 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `pénzügy`, `pénz`, `költségek`, `napló`, `tervező`, `statisztika`, `export`, `célok`, `offline`, `elemzés`

### sv (store `se`, tier C, 1 inst 1*/90d, 0 avaliações na loja) — 8 posições ≤#50

**NAME** `Mina Utgifter: Privatekonomi` (28/30, 2 livres) · **SUBTITLE** `Koll på Pengarna: Enkel Budget` (30/30, 0 livres) · **KEYWORDS** (88/100, 12 livres) `spara,sparande,kostnad,kostnader,analys,månad,rapport,excel,pdf,dagbok,offline,mål,fasta`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `fasta kostnader` | #2 | FIT | **fasta** = `fasta` (KEYWORDS) · **kostnader** = `kostnad` (KEYWORDS) |
| `utgifter excel` | #2 | FIT | **utgifter** = `utgifter` (NAME) · **excel** = `excel` (KEYWORDS) |
| `utgifter offline` | #2 | FIT | **utgifter** = `utgifter` (NAME) · **offline** = `offline` (KEYWORDS) |
| `koll pa utgifter` | #7 | FIT | **koll** = `koll` (SUBTITLE) · **pa** = `på` (SUBTITLE) · **utgifter** = `utgifter` (NAME) |
| `mina utgifter` | #10 | FIT | **mina** = `mina` (NAME) · **utgifter** = `utgifter` (NAME) |
| `privatekonomi budget` | #12 | FIT | **privatekonomi** = `privatekonomi` (NAME) · **budget** = `budget` (SUBTITLE) |
| `privatekonomi` | #22 | PARTIAL | **privatekonomi** = `privatekonomi` (NAME) |
| `utgifter budget` | #47 | FIT | **utgifter** = `utgifter` (NAME) · **budget** = `budget` (SUBTITLE) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `utgifter` | NAME | 5 | #2 |
| `privatekonomi` | NAME | 2 | #12 |
| `budget` | SUBTITLE | 2 | #12 |
| `fasta` | KEYWORDS | 1 | #2 |
| `kostnad` | KEYWORDS | 1 | #2 |
| `excel` | KEYWORDS | 1 | #2 |
| `offline` | KEYWORDS | 1 | #2 |
| `koll` | SUBTITLE | 1 | #7 |
| `på` | SUBTITLE | 1 | #7 |
| `mina` | NAME | 1 | #10 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `spara`, `sparande`, `kostnader`, `analys`, `månad`, `rapport`, `pdf`, `dagbok`, `mål`

### cs (store `cz`, tier C, 0 inst 1*/90d, 0 avaliações na loja) — 10 posições ≤#50

**NAME** `Moje Výdaje: Správa Financí` (27/30, 3 livres) · **SUBTITLE** `Peníze pod kontrolou, rozpočet` (30/30, 0 livres) · **KEYWORDS** (88/100, 12 livres) `sledování,úspory,šetření,grafy,kategorie,export,widget,offline,cíle,deník,platby,přehled`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `vydaje widget` | #1 | FIT | **vydaje** = `výdaje` (NAME) · **widget** = `widget` (KEYWORDS) |
| `moje výdaje` | #2 | FIT | **moje** = `moje` (NAME) · **výdaje** = `výdaje` (NAME) |
| `vydaje offline` | #2 | FIT | **vydaje** = `výdaje` (NAME) · **offline** = `offline` (KEYWORDS) |
| `peníze pod` | #4 | PARTIAL | **peníze** = `peníze` (SUBTITLE) · **pod** = `pod` (SUBTITLE) |
| `šetření` | #10 | PARTIAL | **šetření** = `šetření` (KEYWORDS) |
| `kategorie` | #15 | FIT | **kategorie** = `kategorie` (KEYWORDS) |
| `financí` | #21 | PARTIAL | **financí** = `financí` (NAME) |
| `kontrolou` | #24 | FIT | **kontrolou** = `kontrolou` (SUBTITLE) |
| `správa` | #27 | PARTIAL | **správa** = `správa` (NAME) |
| `výdaje` | #43 | FIT | **výdaje** = `výdaje` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `výdaje` | NAME | 4 | #1 |
| `widget` | KEYWORDS | 1 | #1 |
| `moje` | NAME | 1 | #2 |
| `offline` | KEYWORDS | 1 | #2 |
| `peníze` | SUBTITLE | 1 | #4 |
| `pod` | SUBTITLE | 1 | #4 |
| `šetření` | KEYWORDS | 1 | #10 |
| `kategorie` | KEYWORDS | 1 | #15 |
| `financí` | NAME | 1 | #21 |
| `kontrolou` | SUBTITLE | 1 | #24 |
| `správa` | NAME | 1 | #27 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `sledování`, `úspory`, `grafy`, `export`, `cíle`, `deník`, `platby`, `přehled`

### da (store `dk`, tier C, 0 inst 1*/90d, 0 avaliações na loja) — 6 posições ≤#50

**NAME** `Mine Udgifter: Privatøkonomi` (28/30, 2 livres) · **SUBTITLE** `Enkel udgiftsstyring & budget` (29/30, 1 livres) · **KEYWORDS** (94/100, 6 livres) `forbrug,regnskab,penge,opsparing,oversigt,kalender,kontrol,excel,pdf,dagbog,finans,planlægning`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `enkel udgiftsstyring` | #2 | FIT | **enkel** = `enkel` (SUBTITLE) · **udgiftsstyring** = `udgiftsstyring` (SUBTITLE) |
| `udgifter excel` | #5 | FIT | **udgifter** = `udgifter` (NAME) · **excel** = `excel` (KEYWORDS) |
| `mine udgifter` | #6 | FIT | **mine** = `mine` (NAME) · **udgifter** = `udgifter` (NAME) |
| `forbrug oversigt` | #7 | FIT | **forbrug** = `forbrug` (KEYWORDS) · **oversigt** = `oversigt` (KEYWORDS) |
| `udgiftsstyring` | #20 | FIT | **udgiftsstyring** = `udgiftsstyring` (SUBTITLE) |
| `udgiftsstyring app` | #21 | FIT | **udgiftsstyring** = `udgiftsstyring` (SUBTITLE) · **app** = SEM TOKEN no campo |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `udgiftsstyring` | SUBTITLE | 3 | #2 |
| `udgifter` | NAME | 2 | #5 |
| `enkel` | SUBTITLE | 1 | #2 |
| `excel` | KEYWORDS | 1 | #5 |
| `mine` | NAME | 1 | #6 |
| `forbrug` | KEYWORDS | 1 | #7 |
| `oversigt` | KEYWORDS | 1 | #7 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `regnskab`, `penge`, `opsparing`, `kalender`, `kontrol`, `pdf`, `dagbog`, `finans`, `planlægning`

### el (store `gr`, tier C, 0 inst 1*/90d, 1 avaliações na loja) — 5 posições ≤#50

**NAME** `Έξοδα: Διαχείριση Χρημάτων` (26/30, 4 livres) · **SUBTITLE** `Προϋπολογισμός & Αποταμίευση` (28/30, 2 livres) · **KEYWORDS** (88/100, 12 livres) `οικονομία,οικονομικά,αγορές,ταμείο,ημερολόγιο,κατηγορίες,στόχοι,εξαγωγή,pdf,excel,widget`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `εξοδα widget` | #1 | FIT | **εξοδα** = `έξοδα` (NAME) · **widget** = `widget` (KEYWORDS) |
| `εξοδα excel` | #5 | FIT | **εξοδα** = `έξοδα` (NAME) · **excel** = `excel` (KEYWORDS) |
| `κατηγορίες` | #10 | FIT | **κατηγορίες** = `κατηγορίες` (KEYWORDS) |
| `έξοδα διαχείριση` | #26 | FIT | **έξοδα** = `έξοδα` (NAME) · **διαχείριση** = `διαχείριση` (NAME) |
| `χρημάτων` | #39 | PARTIAL | **χρημάτων** = `χρημάτων` (NAME) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `έξοδα` | NAME | 3 | #1 |
| `widget` | KEYWORDS | 1 | #1 |
| `excel` | KEYWORDS | 1 | #5 |
| `κατηγορίες` | KEYWORDS | 1 | #10 |
| `διαχείριση` | NAME | 1 | #26 |
| `χρημάτων` | NAME | 1 | #39 |

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `οικονομία`, `οικονομικά`, `αγορές`, `ταμείο`, `ημερολόγιο`, `στόχοι`, `εξαγωγή`, `pdf`

### th (store `th`, tier C, 0 inst 1*/90d, 0 avaliações na loja) — 5 posições ≤#50

**NAME** `My Expenses: บันทึกรายจ่าย` (26/30, 4 livres) · **SUBTITLE** `คุมงบประมาณ จัดการเงินง่ายๆ` (27/30, 3 livres) · **KEYWORDS** (65/100, 35 livres) `การเงิน,สมุดบัญชี,ออมเงิน,ประหยัด,บัญชี,วางแผน,กราฟ,ส่งออก,รายวัน`

| composição | posição | fit | token(s) que sustentam → campo |
|---|---|---|---|
| `กราฟรายจ่าย` | #11 | FIT | **กราฟรายจ่าย** = `กราฟ` (KEYWORDS) |
| `คุมงบประมาณ` | #13 | FIT | **คุมงบประมาณ** = `คุมงบประมาณ` (SUBTITLE) |
| `จัดการเงินง่ายๆ` | #14 | PARTIAL | **จัดการเงินง่ายๆ** = `การเงิน` (KEYWORDS) e `จัดการเงินง่ายๆ` (SUBTITLE) |
| `รายจ่ายรายวัน` | #28 | FIT | **รายจ่ายรายวัน** = `รายวัน` (KEYWORDS) |
| `สมุดบัญชีรายจ่าย` | #50 | PARTIAL | **สมุดบัญชีรายจ่าย** = `สมุดบัญชี` (KEYWORDS) |

**Carga por token** (quantas posições ≤#50 caem se o token sair):

| token vivo | campo | posições ≤#50 | melhor posição |
|---|---|---|---|
| `กราฟ` | KEYWORDS | 1 | #11 |
| `คุมงบประมาณ` | SUBTITLE | 1 | #13 |
| `จัดการเงินง่ายๆ` | SUBTITLE | 1 | #14 |
| `การเงิน` | SUBTITLE+KEYWORDS | 1 | #14 |
| `รายวัน` | KEYWORDS | 1 | #28 |
| `สมุดบัญชี` | KEYWORDS | 1 | #50 |

**Duplicata provável por composto/substring** (não comprovada, tratar como suspeita, não como char livre): `การเงิน` (8 chars)

**Tokens de KEYWORDS que NÃO sustentam nenhuma posição ≤#50** (candidatos a saída no estágio 5, sem custo de proteção): `ออมเงิน`, `ประหยัด`, `บัญชี`, `วางแผน`, `ส่งออก`

