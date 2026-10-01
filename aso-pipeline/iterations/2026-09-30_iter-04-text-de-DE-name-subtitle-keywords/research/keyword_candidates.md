# Meus Gastos / My Expenses (6502218501) — iter-04 · name + subtitle + keywords · alvo `de-DE`, escopo 29 locales

**Estado em 01/10/2026 (estágios 7-8 concluídos):**
- **Deploy FEITO, mas o texto NÃO está no ar.** Versão iOS **45.4.0** criada (`61e6fb32-27fc-41d2-aa6f-4cdb75e19a99`, `PREPARE_FOR_SUBMISSION`); 29 locales × 4 campos = **116/116** read-back ok; deploy-verifier **232/232**, 0 divergências; **19 descriptions corrigidas**. Chega ao usuário só quando for submetida **e** aprovada — archive rodando agora, **submissão não autorizada**. D0 = `live_at`, nunca o dia do PATCH.
- **`casal` FICA no pt-BR** (decisão final do João, 01/10 — reverteu a da manhã). As 40 posições MISMATCH ficam porque trazem tráfego hoje; a variante honesta está guardada em `proposed/metadata/pt-BR__sem-casal/` (§1).
- **`excel` mantido em 15 locales** (9 já live + 6 novos: `cs`, `es-ES`, `fr-FR`, `hu`, `id`, `uk`) — pt-BR **não** carrega `excel`. Risco 5.2.5 aceito (§7).

## Antes de qualquer número: o que esta iteração NÃO vai conseguir provar

1. **Os dois gates do pipeline reprovaram e a cadeia rodou assim mesmo** (autorização do João, 30/09 — `meta.json > gates_overridden`). Piso de tráfego: 100 instalações `1*`/30d no país-alvo; **DE tem 25**, BR 45, US 9. Rating-first: < 25 avaliações na loja-alvo; **DE tem 2**. Consequência direta: **nenhuma mudança de texto aqui produz sinal estatisticamente separável do ruído.** `results.final` vai sair **sem intervalo de confiança** e todo checkpoint é leitura **direcional**. Isso fica registrado agora para que nenhuma sessão futura relate vitória falsa.
2. **Não existe fonte de volume real.** O app não tem report App Store Search Terms e não tem campanha Apple Ads. O único volume é o `pop` do Astro — estimativa de uma escala congelada em out/2025. **Toda aposta desta iteração carrega `volume_source: pop não confiável — só Astro`.** E **`pop=5` / `diff=5` é o PISO da escala**, ou seja *volume desconhecido* — nunca "termo fácil com volume".
3. **A cabeça está perdida em todo lugar.** `ausgaben` (pop 48) rankeia **#207** sendo a **primeira palavra do NAME**, o campo de peso 7×. A SERP alemã é Monee (10.274 avaliações), MoneyStats (22.507), Finanzguru (127.441) — contra **2 avaliações** nossas na Alemanha. Nenhuma composição de campo compra isso. **O ativo real do app é cauda longa de 2 palavras**, onde a SERP tem 5-12 resultados e os donos têm 0-20 avaliações. É nela que esta iteração aposta inteira.

Instalações `1*`: **256 em 45 dias = 5,7/dia** (Sales Report, `pull_analytics.py`, conferido contra recomputo do mesmo cache — LEARNINGS #100). Atualizações `7*` no mesmo período: 434 — **nunca somadas**. 439 instalações em 90 dias. Avaliações: BR 18 · DE 2 · US 1 · **21 das 29 storefronts com zero**.

---

## Locales — a regra dos 5 e o escopo que o João pediu

Regra do João (28/09): base `en-US`/`es-ES`/`pt-BR` + os 2 locales com mais instalações **novas** (`1*`) em 90d, piso 30. Fonte: `research/locales.json`.

| papel | locale | países | inst. `1*`/90d | share | avaliações |
|---|---|---|---|---|---|
| base | **en-US** (locale primário do app) | US +15 | 19 | 4,3% | 1 |
| base | **es-ES** | ES | 8 | 1,8% | 0 |
| base | **pt-BR** | BR | 161 | 36,7% | 18 |
| **top-2 #1** | **de-DE** ← alvo primário | DE 46 · AT 11 · CH 7 | **64** | **14,6%** | 2 |
| **top-2 #2** | — | — | — | — | *sem tráfego suficiente* (fr-FR e ja empatam em 27, abaixo do piso de 30) |

**Escopo real: 29 locales**, não 5 — João, 30/09: *"todos os idiomas da loja"*. O estágio 1 corrigiu o brief: existem **29 localizações vivas** (não 13) e o locale primário é **en-US** (não pt-BR). Só `en-GB` não tem listing próprio e cai no en-US — mesma língua, impacto baixo.

---

## 1. A maior decisão da iteração: `casal` FICA no pt-BR

**Decisão final do João, 01/10/2026 (reverteu a da manhã): `casal` e `compartilhados` ficam.** Texto aplicado = **variante A**; a **variante B** (sem o cluster) está composta, validada (0 blockers) e arquivada em `proposed/metadata/pt-BR__sem-casal/` com README.

| o que fica | quanto |
|---|---|
| posições ≤#50 preservadas pelo cluster | **40** — `casal` 21, `compartilhados` 9, `do` 7, `planilha` 3 |
| quantas são FIT | **zero. As 40 são MISMATCH** (queries de conta a dois que o app não responde — `CardModel` sem campo de pessoa, todo path do Firestore é `.collection(userId)`, N1/N2) |
| por que ficam | **trazem tráfego hoje** — `gastos mensais casal` **#1**, `planilha compartilhada` **#1**, `gastos compartilhados` **#2** e mais 37, num locale que é **37% das instalações** (161/439 em 90d) |

**Trade-off aceito conscientemente, por escrito:** a promessa de casal segue viva no subtitle **sem a feature existir**; risco de nota no único storefront com massa de avaliação (BR, 18 ratings; 21 de 29 lojas têm zero); risco de App Review **2.3.1** (metadata que descreve função inexistente).

**Reabrir a variante B quando** (qualquer um): (1) a nota do BR virar o gargalo **medido** — média caindo e reviews citando expectativa de conta compartilhada; (2) o app ganhar modo casal de verdade — aí o subtitle vira promessa verdadeira e o cluster deixa de ser MISMATCH. Se B entrar, entra **inteira**: tirar `casal` e manter `compartilhados` é a pior das três opções (mantém a promessa errada e perde metade das posições).

**Posição em jogo no pt-BR aplicado:** nada cai. Sai só `contas` (duplicata exata do NAME; as 7 posições seguem a 7×), entra `offline` (única aposta do locale). As 47 posições ≤#50 do pt-BR seguem cobertas.

---

## 2. Alemão — o alvo, campo a campo

### Antes × Depois

| campo | Antes (no ar) | chars | Depois (aplicado) | chars |
|---|---|---|---|---|
| **name** | `Ausgaben` <span style="color:#777">-</span> `Haushaltsbuch` | 24/30 | `Ausgaben` `Haushaltsbuch` <span style="color:#4aa3df">`Budget`</span> | **29/30** |
| **subtitle** | <span style="color:#4aa3df">`Budget`</span> & `Finanzen` `verwalten` | 27/30 | `Finanzen` & <span style="color:#4aa3df">`Fixkosten`</span> `verwalten` | **30/30** |
| **keywords** | `monatsbudget`,`kontrolle`,`kategorien`,`kosten`,`planer`,`statistik`,`haushalt`,`einkauf`, <span style="color:#c62828">`konto`</span>, <span style="color:#c62828">`bilanz`</span>, <span style="color:#4aa3df">`fixkosten`</span> | 97/100 | `monatsbudget`,`kontrolle`,`kategorien`,`kosten`,`planer`,`statistik`,`haushalt`, <span style="color:#1b7f3b">`widget`</span>, <span style="color:#1b7f3b">`offline`</span>, <span style="color:#1b7f3b">`kostenlos`</span>,`einkauf` | **99/100** |

<span style="color:#c62828">vermelho</span> = saiu · <span style="color:#1b7f3b">verde</span> = entrou · <span style="color:#4aa3df">azul</span> = subiu de peso

### Por quê

- <span style="color:#4aa3df">`budget`</span> — está **#11** (`budget kategorien`), **#13** (`budget pro kategorie`) e #26 (`budget kontrolle`) → **alvo top-5 em todas as três até D28** (SERP: donos com 0-37 avaliações, massa vazia); risco: o ganho de peso 3×→7× não se materializa se a Apple já tratava `monatsbudget` como portador do stem — rollback devolve `Budget` ao subtitle em 1 PATCH.
- <span style="color:#4aa3df">`fixkosten`</span> — está **#8** (`fixkosten verwalten`) → **alvo top-5**; `monatliche fixkosten` **#12** → top-10; `fixkosten planer` #31 → top-15; `fixkosten app` #41 → top-15; o termo nu #53 → top-40. É a palavra que a própria UI alemã do app usa.
- <span style="color:#c62828">`konto`</span> — segurava #29 (`konto ausgaben`) e #41 (`haushaltskonto`), **as duas MISMATCH** (o app não tem entidade conta/carteira — N18). Duas posições fora do top-25 em intenção errada, por 6 chars no único campo 100% load-bearing do app.
- <span style="color:#c62828">`bilanz`</span> — segurava **`monatliche bilanz` #1** e `bilanz` #104, **as duas MISMATCH** (quem busca *Bilanz* quer receita × despesa; o app só registra despesa — N3). A SERP de `monatliche bilanz` tem **5 resultados no total** e pop 5 = piso da escala. **Um #1 de vitrine vendido por 7 chars** — vai sumir do quadro de propósito.
- <span style="color:#1b7f3b">`widget`</span> / <span style="color:#1b7f3b">`offline`</span> / <span style="color:#1b7f3b">`kostenlos`</span> — hoje **OUT** em `ausgaben widget` (d=13), `haushaltsbuch widget` (d=19), `ausgaben offline` (d=11), `haushaltsbuch offline` (d=13), `budget widget` (d=39) → **alvo entrar no top-20 até D28** com a cabeça já no NAME a 7×; `ausgaben kostenlos` está #104 → alvo top-50. `kostenlos` entra **só no keywords a 1×** — é LOTTERY, alvo #38-45 em `haushaltsbuch kostenlos` (hoje #54), abaixo do penhasco, e pop 61 é astro-only.
- **Protegidas e intocadas:** `ausgaben` (NAME, 10 posições, melhor **#2**) · `monatsbudget` (7) · `kontrolle` (5, **#6**) · `kategorien` (4, **#2**) · `haushaltsbuch` (NAME, 4, **#4**) · `kosten` (4) · `planer` (4) · `verwalten` (SUBTITLE, 3, **#8**) · `haushalt` (3) · `statistik` (2, **#2**) · `einkauf` (1).

### A mecânica que pagou tudo

O separador `-` do NAME é tokenizado igual ao espaço pela Apple — trocar é **neutro para o índice** e liberou **8 chars**. Com eles `Budget` migrou do subtitle (3×) para o NAME (7×). O slot vago no subtitle recebeu `Fixkosten`, que subiu do keywords (1×) para 3×. Os 10 chars que `fixkosten` deixou, mais os 13 de `konto`+`bilanz`, pagaram as 3 apostas. **Nenhuma aposta recebeu char de NAME ou SUBTITLE.**

### Posições-alvo D28 — os 11 DOMINATE de `serp_winnability_de.csv`

| termo | pop/diff | hoje | alvo D28 | massa do top-3 da SERP |
|---|---|---|---|---|
| `ausgaben kategorien` | 5/5 | **#2** | **#1** | 7 avaliações (vazio) |
| `ausgaben statistik` | 5/11 | **#2** | **#1-2** | 928 (leve) |
| `haushaltsbuch kategorien` | 5/5 | **#4** | **top 3** | 8 (vazio) |
| `ausgabenkontrolle` | 5/5 | **#6** | **top 3** | 169 (leve) |
| `budget kategorien` | 5/5 | #11 | **top 5** | 4 (vazio) |
| `kosten statistik` | 5/11 | #12 | **top 5** | 1.497 — mas é SERP de custo de **veículo**, ninguém de orçamento pessoal disputa |
| `budget pro kategorie` | 5/5 | #13 | **top 5** | 19 (vazio) |
| `budget kontrolle` | 5/5 | #26 | **top 5** | 37 (vazio) |
| `haushaltsbuch monatlich` | 5/9 | #33 | **top 10** | 19 (vazio) |
| `kosten verwalten` | 5/13 | #42 | **top 10** | 105 (leve) |
| `kosten kontrolle` | 5/9 | #48 | **top 10** | 429 (leve) |

Os 11 são **pop 5 = piso da escala**. O que os torna apostáveis não é volume (desconhecido) — é que **já rankeamos neles** e o dono da SERP tem massa de avaliação quase nula. 29 posições ≤#50 vivem no alemão; **3 caem** (as duas de `konto` e o #1 de `bilanz`), as outras 26 seguem protegidas.

---

## 3. Resultado final — os outros 5 locales Tier A

### pt-BR (161 inst/90d · 18 avaliações) — variante A aplicada

| campo | Antes | Depois |
|---|---|---|
| name | `Meus Gastos: Contas e Despesas` (30) | intocado (30) |
| subtitle | `Finanças do casal e pessoais` (28) | intocado (28) — `casal` fica por decisão do João (§1) |
| keywords | `compartilhados`,<span style="color:#4aa3df">`contas`</span>,`economias`,`planilha`,`orcamento`,`diario`,`mensais`,`categorias`,`fixas`,`resumo`,`extrato` (97) | `diario`,`mensais`,`categorias`,`extrato`,`fixas`,`resumo`,`orcamento`,`economias`,`compartilhados`,`planilha`,<span style="color:#1b7f3b">`offline`</span> (98) |

- <span style="color:#4aa3df">`contas`</span> — duplicata exata do NAME; as 7 posições seguem sustentadas a 7×, char liberado sem custo.
- <span style="color:#1b7f3b">`offline`</span> — hoje OUT em `financas pessoais offline` (d=5), `gastos offline` (d=33) → **alvo entrar no top-20 até D28**; mecanismo provado em 8 storefronts. **Única aposta do pt-BR** — com o cluster mantido sobraram 2 chars e não cabia mais nada honesto.
- Protegidas e intocadas: `casal` (SUB, 21 pos, **#1**), `mensais` (6, **#1**), `categorias` (6, **#1**), `compartilhados` (9, **#1**), `diario` (4, **#1**), `economias` (4, **#9**), `orcamento` (4, **#10**), `extrato` (3, **#2**), `fixas` (3, **#3**), `planilha` (3, **#1**), `resumo` (1, **#1**), `finanças` (#19).
- A variante B (`Finanças pessoais e categorias` / `…controle,recorrentes,offline,excel,grafico`) subiria `categorias` a 3× (6 posições → alvo top-3) ao custo das 40 MISMATCH. Dossiê completo em `composition_rationale.md` §2 e no README da pasta.

### en-US (19 inst/90d · locale primário · 1 avaliação) — o campo mais desperdiçado dos 29

| campo | Antes | Depois |
|---|---|---|
| name | `My Expenses: Personal Finances` (30) | intocado (30) |
| subtitle | `Where's My Money? Easy Control` (30) | intocado (30) |
| keywords | `finance`,`financial`,`manage`,<span style="color:#c62828">`money`</span>,`budgeting`,<span style="color:#c62828">`savings`</span>,<span style="color:#c62828">`control`</span>,`planning`,<span style="color:#c62828">`personal`</span>,`costs`,`save`,<span style="color:#c62828">`financial`</span>,<span style="color:#c62828">`easy`</span> (100) | `finance`,`financial`,`manage`,`budgeting`,`planning`,`costs`,`save`,<span style="color:#1b7f3b">`category`</span>,<span style="color:#1b7f3b">`offline`</span>,<span style="color:#1b7f3b">`spending`</span> (80) |

- Campo em **100/100 chars** sustentando **uma única posição ≤#50 no app inteiro** (`my expenses` **#5**, e quem a sustenta é o NAME). `financial` aparecia **duas vezes** na mesma lista; `money`/`control`/`personal`/`easy` eram duplicatas exatas do NAME/SUBTITLE; `savings` é MISMATCH (N9: `GoalModel` é teto de gasto, não meta de poupança).
- <span style="color:#1b7f3b">`category`</span> alimenta 5 composições (d=11-21), <span style="color:#1b7f3b">`offline`</span> 4 (d=5-37), <span style="color:#1b7f3b">`spending`</span> 2.
- **20 chars ociosos** — teto de 3 apostas batendo antes do orçamento. Próximos: `recurring` (d=19), `charts` (d=23), `widget` (d=15).
- **Correção do brief:** o token `managemen` truncado **não existe no iOS**. Era o keyword field da listagem **macOS**: `sync_current_from_asc.py` lia `GET /v1/apps/{id}/appStoreVersions` sem `filter[platform]`, e num app universal a Apple devolve o macOS primeiro — `current/metadata/` nunca esteve defasado, estava na plataforma errada (LEARNINGS #85b; corrigido pelo deployer em 01/10). O único token parecido nos 29 locales iOS é o `manajemen` do indonésio, palavra completa.

### fr-FR (27 inst/90d) · it (12) · es-ES (8) / es-MX (10)

| locale | Antes → Depois (keywords) | nota |
|---|---|---|
| **fr-FR** 99→75 | <span style="color:#c62828">`compte`</span> #177, <span style="color:#c62828">`salaire`</span> #200, <span style="color:#c62828">`facture`</span>, <span style="color:#c62828">`ecologie`</span> #171 (MISMATCH) + <span style="color:#c62828">`suivi`</span>/<span style="color:#c62828">`economie`</span> (dup) → <span style="color:#1b7f3b">`categorie`</span>, <span style="color:#1b7f3b">`excel`</span>, <span style="color:#1b7f3b">`widget`</span> | `depense` **#3**, `finance` **#6** protegidos no NAME/SUBTITLE. 25 chars ociosos. |
| **it** 95→73 | <span style="color:#c62828">`bilancio`</span> (só a cópia do keywords; o do NAME **fica**), <span style="color:#c62828">`risparmio`</span>, <span style="color:#c62828">`budget`</span> (dup), <span style="color:#c62828">`conto`</span>, <span style="color:#c62828">`carta`</span>, <span style="color:#c62828">`denaro`</span> → <span style="color:#1b7f3b">`categoria`</span>, <span style="color:#1b7f3b">`widget`</span>, <span style="color:#1b7f3b">`fisse`</span> | `bilancio personale` **#5** e `spese bilancio` **#9** são as **únicas 2 posições ≤#50 do italiano** e vêm do NAME a 7×. Promessa se corrige na description, não no name. |
| **es-ES** 100→92 | <span style="color:#c62828">`dinero`</span>/<span style="color:#c62828">`financiero`</span> (dup), <span style="color:#c62828">`ingreso`</span> (MISMATCH N3), <span style="color:#c62828">`pagar`</span> → <span style="color:#1b7f3b">`categoria`</span>, <span style="color:#1b7f3b">`offline`</span>, <span style="color:#1b7f3b">`excel`</span> | `expensas` fica (**#49**). |
| **es-MX** 100→89 | idem + <span style="color:#c62828">`expensas`</span> (lê como taxa de condomínio no MX) → <span style="color:#1b7f3b">`categoria`</span>, <span style="color:#1b7f3b">`recurrentes`</span>, <span style="color:#1b7f3b">`mensual`</span> | **Os dois campos deixam de ser idênticos** — são storefronts diferentes; es-MX ainda indexa AR. |

### ja (27 inst/90d)

`支出` protegido (`シンプル支出管理` #23). Saem <span style="color:#c62828">`節約`</span>/<span style="color:#c62828">`予算`</span> (duplicatas exatas do subtitle — a proteção do **#5** vem do subtitle a 3×), <span style="color:#c62828">`収支`</span> (MISMATCH N3), <span style="color:#c62828">`貯金`</span> (MISMATCH N9). Entram <span style="color:#1b7f3b">`カテゴリ`</span>, <span style="color:#1b7f3b">`固定費`</span> (palavra da própria UI japonesa), <span style="color:#1b7f3b">`ウィジェット`</span>. **47→51/100 — ver §5.**

---

## 4. Tabela dos 29 locales

| locale | inst/90d | aval. | SAIU | ENTROU | KW chars | posições protegidas | posições perdidas |
|---|---|---|---|---|---|---|---|
| **de-DE** ← alvo | 64 | 2 | `konto`, `bilanz` *(`fixkosten`→SUB)* | `widget`, `offline`, `kostenlos` | 97→**99** | 26 de 29 | **3** — `konto` #29/#41, `bilanz` **#1** (todas MISMATCH) |
| **pt-BR** | 161 | 18 | `contas` *(dup do NAME)* | `offline` | 97→**98** | **47 de 47** — `casal` mantido por decisão (§1) | 0 |
| fr-FR | 27 | 1 | `compte`, `suivi`, `economie`, `salaire`, `facture`, `ecologie` | `categorie`, `excel`, `widget` | 99→75 | 5 de 5 | 0 |
| ja | 27 | 0 | `収支`, `節約`, `予算`, `貯金` | `カテゴリ`, `固定費`, `ウィジェット` | 47→51 | 3 de 3 | 0 |
| en-US | 19 | 1 | `money`, `savings`, `control`, `personal`, `easy`, `financial` *(2ª ocorrência)* | `category`, `offline`, `spending` | 100→80 | 1 de 1 | 0 |
| en-GB | 17 | — | *sem listing — cai no en-US (mesma língua)* | — | — | — | — |
| tr | 17 | 0 | `para`, `bütçe`, `tasarruf`, `gelir`, `kasa`, `maaş`, `bakkal`, `fatura` | `aylik`, `kategori`, `widget` | 89→61 | 3 de 3 | 0 |
| it | 12 | 0 | `bilancio` *(só KW)*, `risparmio`, `budget`, `conto`, `denaro`, `carta` | `categoria`, `widget`, `fisse` | 95→73 | 2 de 2 | 0 |
| ar-SA | 10 | 0 | `ميزانية` *(dup)*, `محفظة`, `حساب`, `راتب`, `فواتير` | `شهرية`, `فئات`, `يومية` | 77→63 | 6 de 6 | 0 |
| es-MX | 10 | 0 | `dinero`, `financiero`, `ingreso`, `pagar`, `expensas` | `categoria`, `recurrentes`, `mensual` | 100→89 | 1 de 1 | 0 |
| id | 10 | 0 | `uang`, `anggaran`, `catatan`, `hemat` *(dup)*, `tabungan`, `buku kas`, `gaji`, `dompet`, `tagihan` | `kategori`, `excel`, `offline` | 92→49 | 4 de 6 | **2** — `tabungan` #28, `buku kas` #43 (MISMATCH) |
| vi | 9 | 0 | só `tiền`; as outras 13 são **retokenização** de sílabas soltas em palavras reais | `danh mục`, `widget`, `cố định` | 77→**96** | 3 de 3 | 0 |
| es-ES | 8 | 0 | `dinero`, `financiero`, `ingreso`, `pagar` | `categoria`, `offline`, `excel` | 100→92 | 1 de 1 | 0 |
| hi | 7 | 0 | `सेविंग्स`, `खाता`, `बचत` | `मासिक`, `कैटेगरी`, `फिक्स्ड` | 94→**98** | 4 de 5 | **1** — `सेविंग्स` **#6** (MISMATCH) |
| ru | 6 | 0 | `кошелек`, `сбережения`, `цели`, `планирование` | `категории`, `оффлайн`, `постоянные` | 86→78 | 0 de 0 | 0 |
| zh-Hans | 5 | 0 | `收支`, `钱包`, `理财app`, `月账单` | `月度预算`, `固定支出`, `支出图表` | 48→47 | 3 de 3 | 0 |
| nl-NL | 4 | 0 | `kasboek`, `administratie` | `widget`, `overzicht`, `vaste` | 99→**100** | 5 de 5 | 0 |
| fi | 3 | 1 | `laskuri`, `pdf` | `kategoria`, `kuukausi`, `kiinteat` | 82→**98** | 9 de 9 | 0 |
| he | 3 | 0 | `יעדים` | `אופליין`, `קבועות`, `תקציב` | 72→87 | 6 de 6 | 0 |
| no | 3 | 0 | `regnskap`, `økonomi` | `offline`, `manedlig`, `daglige` | 90→**98** | 9 de 9 | 0 |
| uk | 3 | 0 | `гаманець`, `планування`, `цілі` | `постійні`, `щомісячні`, `excel` | 92→92 | 8 de 8 | 0 |
| ko | 2 | 0 | 9 tokens *(dup + MISMATCH, inclui `머니매니저` = marca de concorrente)*, `자산` do SUB, *(`생활비`→SUB)* | `카테고리`, `오프라인`, `그래프` | 46→**25** | 2 de 2 | 0 |
| ms | 2 | 0 | `simpanan`, `wang` | `bulanan`, `tetap`, `widget` | 89→**96** | 12 de 12 | 0 |
| pl | 2 | 0 | `pieniądze`, `planowanie` | `stale`, `miesieczne`, `widget` | 90→93 | 8 de 8 | 0 |
| hu | 1 | 0 | `pénz`, `tervező`, `célok` | `excel`, `havi`, `kategoria` | 93→95 | 6 de 6 | 0 |
| sv | 1 | 0 | `spara`, `sparande`, `mål` | `kategori`, `widget`, `dagliga` | 88→93 | 8 de 8 | 0 |
| cs | 0 | 0 | `úspory`, `platby`, `cíle` | `excel`, `pravidelne`, `mesicni` | 88→94 | 10 de 10 | 0 |
| da | 0 | 0 | `regnskab`, `finans`, `planlægning` | `widget`, `faste`, `offline` | 94→87 | 6 de 6 | 0 |
| el | 0 | 1 | `ταμείο`, `στόχοι` | `offline`, `μηνιαια`, `παγια` | 88→96 | 5 de 5 | 0 |
| th | 0 | 0 | `บัญชี`, `ออมเงิน`, `ประหยัด` | `หมวดหมู่`, `รายเดือน`, `ประจำ` | 65→67 | 5 de 5 | 0 |

**Totais: das 214 posições ≤#50 nos 29 locales, caem 6 — 3 trade-offs nomeados no de-DE, 2 no id, 1 no hi. As 6 são MISMATCH. Nenhuma posição FIT ou PARTIAL foi tocada em locale nenhum.** Teto de 3 apostas novas respeitado em 29/29 (pt-BR ficou com 1).

### A 2ª fonte que banca `widget` / `offline` / `excel` / `categoria`

Não entram por pop (que é astro-only). Entram por **posição observada em 12 storefronts do próprio app**, medida neste mesmo pull: `excel` → **#1** fi, **#2** no/sv, **#3** ms, **#4** pl, **#5** da/el, **#7** nl · `widget` → **#1** cs/el/hu, **#2** no, **#8** fi · `offline` → **#2** cs/sv, **#3** pl, **#4** ms, **#8** fi · `kategori*` → **#10** el, #15 cs, #18 he, #21 ms. O mecanismo é sempre o mesmo: **a cabeça já está no NAME a 7×**, o token de feature completa a composição a 1× e entrega top-10. São features reais (export Excel/PDF §1.9, widget §1.13, offline sem conta §1.12, categorias §1.3) que **20 de 29 descriptions nem mencionavam** antes das correções do deploy. `excel` fica em **15 locales** depois do deploy: 9 já live (`da, el, fi, ms, nl-NL, no, pl, sv, vi`; `hi` carrega a transliteração `एक्सेल`) + 6 novos (`cs, es-ES, fr-FR, hu, id, uk`). **pt-BR não carrega `excel`** — a variante A devolveu `planilha`.

---

## 5. Os 7 locales que esta iteração declara INCOMPLETOS

| locale | KW final | ocioso | NAME | o que o campo vivo era |
|---|---|---|---|---|
| **ko** | 25/100 | 75 | **15/30** | 9 tokens MISMATCH de 14, incluindo `머니매니저` (marca de concorrente) |
| **zh-Hans** | 47/100 | 53 | **11/30** | 4 MISMATCH, 1 com o token `app` proibido |
| **id** | 49/100 | 51 | 30/30 | 4 duplicatas + 5 MISMATCH de 12 |
| **ja** | 51/100 | 49 | **14/30** | 2 duplicatas exatas + 2 MISMATCH |
| **tr** | 61/100 | 39 | 26/30 | 3 duplicatas + 5 MISMATCH de 14 |
| **ar-SA** | 63/100 | 37 | 25/30 | 1 duplicata + 4 MISMATCH |
| **th** | 67/100 | 33 | 26/30 | 3 MISMATCH |

Nos sete o campo vivo não estava meio vazio — **estava cheio de coisa errada**. Tirar o que mente é ganho imediato; o buraco que sobra é teto de 3 apostas batendo antes do orçamento de chars.

**Em `ko`, `ja` e `zh-Hans` o NAME usa 11-15 de 30 chars.** É ali, no peso 7×, que o desperdício realmente está — e NAME não se enche com filler, exige composição.

**Recomendação: uma iteração dedicada a esses 7**, com pool de long tails próprio por locale (os `longtails_<store>.csv` já existem) e **name/subtitle reavaliados junto**. Enfiar 3 tokens e declarar pronto seria repetir, por outro caminho, o erro que esta iteração existe para evitar. **Não remendar.**

---

## 6. Correções de description — APLICADAS na 45.4.0 (defeito live, não keyword)

**19 descriptions corrigidas pelo deployer em 01/10** (read-back 116/116 inclui description). Ficam listadas porque a **45.3.1 continua no ar com os defeitos** até a 45.4.0 ser aprovada, e porque o item 2 ainda tem um resíduo (§8: `promotionalText`).

1. **`en-US` — locale primário — termina com lixo de UI de chat colado na loja.** A description fecha com `…itunes/dev/stdeula/`**`Tentar novamenteO Claude pode cometer erros. Confira sempre as respostas.`** Está na página que todo storefront sem listing próprio enxerga. **Corrigido na 45.4.0.**
2. **"100% grátis" com paywall — risco 2.3.1 em 12 locales.** Alegação **dura** em **cs, el, fi, hi, hu, nl-NL, sv, vi** (*100% zdarma · 100% Δωρεάν · 100 % ilmainen · 100% मुफ़्त · 100%-ban ingyenes · 100% gratis · 100 % gratis · hoàn toàn miễn phí*); forma **branda** em **da, ms, no, ru**. O app abre paywall mensal+anual logo depois do onboarding e gateia o sync. Reescrito nas 12 na 45.4.0. **Interage com o `kostenlos` alemão:** a keyword é defensável porque é token de keywords, não alegação de texto. **Resíduo:** 14 dos 16 `promotionalText` que não herdaram repetem a mesma alegação (§8) — enquanto não forem reescritos, a faxina 2.3.1 está incompleta.
3. **Promessa de notificação em `de-DE`, `fr-FR`, `it`, `ja`, `ko`** (*"bekommst du Bescheid" · "on te prévient" · "ti notifichiamo" · "通知でお知らせ" · "알려줍니다"*). **N6: o app não tem framework de notificação nenhum** — nem `flutter_local_notifications`, nem `firebase_messaging`, nem `UNUserNotification`. O único sinal é mudança de cor na aba de metas, **depois** de estourar. Promessa falsa, traduzida e repetida. **Removida nos 5 na 45.4.0.**
4. **`pt-BR` com inglês solto na description viva:** *"nunca mais perca o controle das suas **expenses**"*, *"Organize suas **finance**"*, *"aumentar suas **minhas economias**"*. **Corrigido na 45.4.0.**
5. **`en-US`, `pt-BR`, `es-ES`, `es-MX` rodam o texto de 2024** — não citam export, sync, gastos fixos nem widget. **Widget ausente em 20 das 29 descriptions, inclusive em todo o Tier A.** Correção de defeito feita; a reescrita de venda (export, sync, fixos, widget) **não** entrou — continua sendo a próxima alavanca de página.

---

## 7. Achados de produto (reportar, não agir — app Flutter em `intermediate/`)

- **Paywall cai em inglês em 9 locales** por falta de 7 chaves de tradução.
- **O paywall vende export como benefício PRO, e export não é gateado** — só login + backup na nuvem são. Dos 3 benefícios anunciados, **2 são ficção** (o outro é "sem anúncios" num app que nunca teve anúncio — N15).
- **`repeat` traduzido em espanhol como "Apelante"** (termo jurídico).
- **`excel` é marca da Microsoft** (risco 5.2.5) e esta submissão sobe a exposição de 9 para 15 locales. João optou por manter em 01/10, ciente. O app exporta `.xlsx` de verdade e não gateia. Incoerência registrada: o fit-checker tirou `머니매니저` (ko) por ser marca de concorrente e manteve `excel` no mesmo passe — nome de app rival ≠ formato que o app exporta, mas a regra de marca do lab não distingue isso hoje. Se a review reclamar: remover dos 15 e medir a perda nas composições `* excel` (#1 fi, #2 no/sv, #3 ms, #4 pl, #5 da/el, #7 nl).

---

## 8. Deploy — o que foi feito e o que ainda bloqueia a submissão

**Feito em 01/10 (estágios 7-8, autorização do João de 30/09):**
- `POST /v1/appStoreVersions` → iOS **45.4.0** (`61e6fb32-27fc-41d2-aa6f-4cdb75e19a99`, `PREPARE_FOR_SUBMISSION`, appInfo editável `cbd87354`). 45.4.0 já existia no **macOS** (READY_FOR_SALE) mas não no iOS — colisão conferida com `filter[platform]=IOS` antes do POST (LEARNINGS #85b).
- PATCH direto nos 29 locales; read-back **116/116** (29 × name/subtitle/keywords/description, `len()` do Python). deploy-verifier independente, GET-only: **232/232 asserts, 0 divergências, 0 correções**; appInfo LIVE `1c8c1360` e versão LIVE 45.3.1 intocadas. pt-BR re-conferido **depois** do revert para a variante A.
- Screenshots: 4 locales com sets próprios (en-US, es-ES, es-MX, pt-BR), contagens e checksums idênticos à 45.3.1 — herança fiel, sem duplicata.
- Gates reprovados e executados sob override registrado: piso de tráfego (DE 25/100, exit 2) e quarentena (PPO `9570de85` APPROVED, exit 3).

**O texto NÃO está no ar.** O público vê a 45.3.1 até a 45.4.0 ser submetida **e** aprovada. `status: staged`; `metrics/d00_baseline.json` não existe e não pode existir ainda.

**Bloqueia a submissão (passos do João):**
1. **`whatsNew` vazio nos 29 locales da 45.4.0** (a 45.3.1 tem nos 29). Obrigatório a partir da 1.0.1 — a ASC recusa o submit sem ele. Copy é do João (`/release-notes-style`).
2. **`promotionalText` não herdou em 16 locales** (`cs, da, el, fi, he, hi, hu, ms, nl-NL, no, pl, ru, sv, th, uk, vi`). **14 deles repetem o "100% grátis"** que a submissão está tirando das descriptions — restaurar literal seria autodestrutivo; só `pl` e `ru` são seguros de restaurar. **Não foi restaurado; decisão do João** (lista e textos em `research/promotional_text_not_inherited.json`). Nada se perde enquanto a 45.3.1 for a versão no ar.
3. **Build:** a 45.4.0 não tem build anexado — archive rodando agora pelo release-runner; upload e `submitted:true` **não autorizados**.
4. A appInfo é do **app**, não da plataforma: aprovada a `cbd87354`, o name/subtitle novos do de-DE valem também para a listagem **macOS** (universal).

**PPO `9570de85`** roda até 27/11 e atravessa a janela de medição. `quarantine_override` registrado (regra do João de 04/09: versão nova ganha de PPO rodando); a auditoria de 27/09 já julgou o experimento sem poder estatístico (1.430 impressões/semana, 3 tratamentos). Fica rodando; não parar sem a palavra dele.

**Bug de pipeline achado e corrigido no deploy:** `sync_current_from_asc.py` lia a listagem do **macOS** (primeiro READY_FOR_SALE sem `filter[platform]`) — o `managemen` "truncado" do en-US era o keyword field do macOS o tempo todo. Fix: `filter[platform]=IOS` + checagem de plataforma + `limit 200`; o sync reescreveu os 29 locales (86 arquivos).

---

## 9. Resultado final — todos os 29 locales

```text
TIER A
de-DE   NAME  Ausgaben Haushaltsbuch Budget                       29/30
        SUB   Finanzen & Fixkosten verwalten                      30/30
        KW    monatsbudget,kontrolle,kategorien,kosten,planer,statistik,
              haushalt,widget,offline,kostenlos,einkauf            99/100
pt-BR   NAME  Meus Gastos: Contas e Despesas                      30/30 (intocado)
        SUB   Finanças do casal e pessoais                        28/30 (intocado — decisão João 01/10)
        KW    diario,mensais,categorias,extrato,fixas,resumo,orcamento,
              economias,compartilhados,planilha,offline            98/100
en-US   NAME  My Expenses: Personal Finances                      30/30 (intocado)
        SUB   Where's My Money? Easy Control                      30/30 (intocado)
        KW    finance,financial,manage,budgeting,planning,costs,save,
              category,offline,spending                            80/100
fr-FR   KW    depense,finance,argent,gestion,planificateur,famille,
              categorie,excel,widget                               75/100
ja      KW    支出,家計,記録,出費,生活費,かけいぼ,お金,マネー,簡単,お小遣い,
              カテゴリ,固定費,ウィジェット                            51/100
es-ES   KW    presupuesto,ahorrar,gestion,familiar,pago,organizador,gasto,
              expensas,categoria,offline,excel                     92/100

TIER B
es-MX  89/100   tr  61/100   it  73/100   ar-SA 63/100
id     49/100   zh-Hans 47/100   ko  25/100 (SUB reescrito 13/30)

TIER C
vi 96 · hi 98 · ru 78 · nl-NL 100 · fi 98 · he 87 · no 98 · uk 92
ms 96 · pl 93 · hu 95 · sv 93 · cs 94 · da 87 · el 96 · th 67

NAME alterado:       1 de 29  (de-DE)
SUBTITLE alterado:   2 de 29  (de-DE, ko)
KEYWORDS alterado:  29 de 29
DESCRIPTION:        19 de 29 corrigidas (§6) — na 45.4.0, não no ar
PROMOTIONAL TEXT:   16 locales NÃO herdaram (§8) — pendente, decisão do João
WHATSNEW:           vazio nos 29 — bloqueia o submit (§8)
Versão portadora:   iOS 45.4.0 · 61e6fb32 · PREPARE_FOR_SUBMISSION · sem build
```

---

## 🎯 Hipótese formal

> **IF** o NAME alemão trocar o separador por espaço (neutro para o índice, +8 chars) e promover `Budget` de SUBTITLE (3×) para NAME (7×), o SUBTITLE receber `Fixkosten` vindo do keywords (1× → 3×), os dois tokens MISMATCH alemães (`konto`, `bilanz`) saírem pagando as apostas `widget`/`offline`/`kostenlos`, o pt-BR **manter** `casal`/`compartilhados` (decisão do João) trocando só `contas` (dup) por `offline`, e os 29 campos de keywords forem limpos de 24 duplicatas exatas e 58 tokens MISMATCH,
>
> **THEN** as impressões de busca sobem de ~450/dia para **≥ 500/dia em 28 dias** e as instalações `1*` de **5,7/dia** para **≥ 6,2/dia** (conservador) / **≥ 7,1/dia** (bold), com os 11 DOMINATE alemães subindo para as posições-alvo da §2, as 47 posições do pt-BR intactas e **nenhuma posição FIT perdida em locale nenhum**,
>
> **BECAUSE** (a) o ativo do app não é a cabeça — `ausgaben` pop 48 está **#207** contra SERPs de 10k-127k avaliações — e sim **214 posições ≤#50 em cauda longa de 2 palavras**, onde o dono da SERP tem 0-500 avaliações; (b) cada char novo foi pago por um token nomeado que só sustentava MISMATCH ou duplicata, com o protection map verificando os 29 conjuntos propostos token a token; (c) as apostas `widget`/`offline`/`excel`/`categoria` têm **2ª fonte de outra natureza** — posição top-10 observada em 12 storefronts do próprio app — e não dependem do pop astro-only; (d) no pt-BR a aposta é de preservação: as 40 posições MISMATCH do cluster `casal` seguem trazendo tráfego hoje, e o custo (nota, 2.3.1) foi aceito por escrito com gatilhos de reabertura da variante B.

---

## ⚠️ Riscos

1. **O resultado não será mensurável.** DE tem 25 instalações `1*`/30d contra um piso de 100. *Mitigação:* `results.final` sai declaradamente **sem IC**; a métrica de leitura primária passa a ser **posição Astro dos 11 DOMINATE alemães + das 6 composições de `categorias` no pt-BR**, não instalação. Instalação vira secundária e direcional.
2. **pt-BR mantém uma promessa que o produto não entrega** (`casal` no subtitle, 40 posições MISMATCH). Riscos: nota no único locale com massa de avaliação e App Review 2.3.1. *Mitigação:* aceito por escrito em `meta.json > decisions_by_joao`; variante B pronta e validada em `pt-BR__sem-casal/` para troca em 1 PATCH; checkpoint acompanha média e texto das reviews BR (gatilho 1 de reabertura).
3. **`budget` pode não ganhar nada ao subir para o NAME** se a Apple já atribuía o stem via `monatsbudget`. *Mitigação:* `budget kategorien` #11 e `budget pro kategorie` #13 são o oráculo — sem movimento até D14, `Budget` volta ao subtitle e os 7 chars do NAME viram `Fixkosten` lá.
4. **Faxina 2.3.1 incompleta:** as 12 descriptions foram corrigidas, mas **14 `promotionalText` não herdados repetem o "100% grátis"** e ainda não têm decisão. *Mitigação:* não restaurar literal; reescrever ou deixar vazio antes do submit. `excel` em 15 locales é marca da Microsoft (5.2.5) — aceito; se a review reclamar, sai dos 15.
5. **A 45.4.0 ainda não pode ser submetida:** `whatsNew` vazio nos 29, sem build anexado, submissão não autorizada. *Mitigação:* os passos estão em `meta.json > manual_steps_left_for_joao`; rodar `preflight.py --only asc,rating` antes do submit.
6. **7 locales saem incompletos** (ko 25/100 no pior caso). *Mitigação:* declarados na §5 com os próximos candidatos já ranqueados; **iteração 5 dedicada**, não remendo no próximo deploy.
7. **PPO `9570de85` atravessa toda a janela de medição.** *Mitigação:* `quarantine_override` registrado; a auditoria de 27/09 já declarou esse experimento sem poder estatístico, então ele contamina pouco — mas o checkpoint registra a sobreposição.

---

## 📈 Projeção

Baseline: **5,7 instalações `1*`/dia** (256/45d) · **~450 impressões de busca/dia** (13.053 em 29d, `asc_impressions_by_source_90d.csv`) · conversão impressão→install **1,33%**.

| cenário | impressões/dia D28 | conversão | instalações/dia | prob. |
|---|---|---|---|---|
| pessimista | 440 (−2%) | 1,25% | **5,5** | 30% |
| **realista (conservador)** | 500 (+11%) | 1,30% | **6,2** | 45% |
| **otimista (bold)** | 560 (+24%) | 1,35% | **7,1** | 25% |
| aspiracional 90d | 640 (+42%) | 1,40% | **8,5** | — |

Probabilidade de bater **conservador (6,2/dia): ~45%**. Probabilidade de bater **bold (7,1/dia): ~25%**. As duas são estimativas sobre uma base que **não permite teste de hipótese** — leia como ordem de grandeza, não como previsão.

```text
instalações/dia   D0    D7    D14   D21   D28
                  5,7   5,7   5,9   6,0   6,2
                  ▂▂▂   ▂▂▂   ▃▃▃   ▃▃▃   ▄▄▄
```
Sem queda esperada em D7: com `casal` mantido o pt-BR não perde posição nenhuma no re-index.

| checkpoint | sinal de SUCESSO | sinal de FALHA |
|---|---|---|
| **D7** | `ausgaben kategorien` em **#1**; `budget kategorien` saiu de #11; `widget`/`offline` alemães aparecem em qualquer rank | instalações DE caem >30%; qualquer uma das 26 posições alemãs protegidas sumiu (= token saiu por acidente) |
| **D14** | `ausgabenkontrolle` ≤ **#3**; as 47 posições do pt-BR de pé e `offline` indexado em `financas pessoais offline`; impressões +10% | `budget kategorien` parado em #11 → plano B: `Budget` volta ao subtitle |
| **D21** | ≥ 6 dos 11 DOMINATE alemães na posição-alvo; instalações ≥ 6,0/dia | média BR caindo com reviews citando conta compartilhada → gatilho 1 da variante B |
| **D28** | instalações ≥ 6,2/dia **ou** ≥ 8 dos 11 DOMINATE na meta; ratings BR ≥ 20 | nada se moveu → a alavanca seguinte **não é mais texto**: é conversão (prints/PPO) e ratings |

---

## 🎲 Confidence breakdown

| premissa crítica | confiança | impacto se falsa |
|---|---|---|
| Os ranks do Astro refletem a SERP real | **85%** | 24 SERPs foram conferidas ao vivo e bateram; o resto é pull do Astro |
| `pop` mede volume | **15%** | **Já assumida como falsa.** Sem ASC Search Terms e sem Apple Ads, `pop=5` é piso de escala = volume desconhecido. **Por isso nenhuma aposta recebeu char de NAME/SUBTITLE** e a 2ª fonte é posição cross-storefront |
| Apple tokeniza `-` igual a espaço no NAME | **90%** | Se não, o NAME alemão perde `haushaltsbuch` como token isolado — seria visível em D7 nas 4 posições que ele sustenta |
| Apple decompõe compostos alemães (`ausgabenkontrolle`) | **80%** | Já é o mecanismo que explica 4 posições vivas sem token correspondente; se não for, `kontrolle` e `haushalt` estão protegendo menos do que o mapa diz |
| Peso 7× do NAME > 3× do SUBTITLE na prática | **70%** | É heurística do playbook §7, não medida neste app. Oráculo em D14 |
| Manter `casal` não derruba a nota do BR em 28 dias | **55%** | Direcional. 18 avaliações é base pequena demais para medir; se a média cair com reviews citando conta compartilhada, a variante B entra inteira |
| O efeito será separável do ruído | **10%** | **Assumido falso desde o início** (gates reprovados). Daí `results.final` sem IC |

---

## Dívida registrada (datada 2026-10-01)

- **Tokens vivos com acento permanecem com acento** (`gestión`, `přehled`, `šetření`, `pénzügy`, `kişisel`, `säästäminen`, `privatøkonomi`…). É neutro para o índice (iOS normaliza) e normalizar só uma parte deixa o campo incoerente. **Todo token novo desta iteração entrou sem acento** (LEARNINGS #63b). Varrer num passe dedicado.
- **`kill_or_scale.py` classifica Product Type por prefixo** e este app emite `F1`/`F7` — por isso reportava "187 instalações / 0 updates". Bug de script compartilhado do lab, já documentado em LEARNINGS #100. Os números deste relatório vêm do `pull_analytics.py`/recomputo exato.
- **`sync_current_from_asc.py` lia a listagem macOS** (sem `filter[platform]`) — corrigido pelo deployer em 01/10; o "stale desde agosto" do brief era plataforma errada, não defasagem.
- **Validação:** `validate_proposed.py` → exit 0, **0 blockers**, 96 warnings, todos de 4 famílias conhecidas e justificadas (campos abaixo do teto por disciplina de aposta; falso positivo de `len(token) < 4` em CJK/tailandês; stopword `e` no subtitle pt-BR).
