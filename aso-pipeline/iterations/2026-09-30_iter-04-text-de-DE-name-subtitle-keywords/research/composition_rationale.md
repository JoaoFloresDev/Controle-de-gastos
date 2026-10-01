# Composition rationale — iter-04, Meus Gastos / My Expenses (6502218501), 29 locales

Estágio 5. Entrada: `protection_map.md` (lei desta iteração), `term_fit_<locale>.csv`, `serp_winnability_<store>.csv`, `app_feature_inventory.md`, `asc_state.json`.
Saída: `proposed/metadata/<locale>/{name,subtitle,keywords}.txt` × 29.
**Decisão FINAL do João em 2026-10-01 (§2)**: `casal` + `compartilhados` **FICAM** no pt-BR. Ele reverteu, ainda em 01/10 e com o deploy em curso, a decisão que tinha tomado mais cedo no mesmo dia. `proposed/metadata/pt-BR/` = **variante A** (com casal), que foi a aplicada. A variante B (sem casal) está preservada em `proposed/metadata/pt-BR__sem-casal/` com README — composta e validada, **não aplicada**.

**Resultado da verificação de proteção** (script sobre os 29 conjuntos propostos, cruzando as tabelas "carga por token" da §3 do protection_map): **das 214 posições ≤#50, só caem as nomeadas abaixo.** Nenhum token protetor saiu por acidente.

| locale | tokens protetores | posições | status |
|---|---|---|---|
| de-DE | 15 | 57 | caem 3: `konto` (#29, #41) e `bilanz` (#1) — trade-offs nomeados §4/§3b |
| hi | 7 | 7 | cai 1: `सेविंग्स` (#6 MISMATCH) — trade-off nomeado §3b |
| id | 9 | 12 | caem 2: `tabungan` (#28), `buku kas` (#43) — decisões do brief |
| pt-BR | 18 | 112 | caem 40 **por decisão**: `casal` 21, `compartilhados` 9, `do` 7, `planilha` 3 — **todas MISMATCH**; as 7 posições FIT/PARTIAL que não dependiam do cluster seguem cobertas (§2) |
| os outros 25 locales | — | — | **todas cobertas** |

---

## 0. Regras de composição aplicadas em todos os locales

1. **Token da tabela "carga por token" NUNCA sai** salvo trade-off nomeado. Quando precisei do char, a ordem foi a da §6 do protection_map: (a) duplicata de campo → (b) token sem posição ≤#50 → (c) MISMATCH com posição só >#50 → (d) um dos 11 da §3b, nomeando a posição.
2. **Mover token de KEYWORDS para SUBTITLE/NAME não é remoção, é upgrade de peso** (1× → 3×/7×). Nenhuma posição pode cair com isso. Usei em 3 lugares, todos declarados: `fixkosten` (de, KW→SUB), `categorias` (pt-BR B, KW→SUB), `생활비` (ko, KW→SUB).
3. **Máximo 3 apostas novas por locale.** Cumprido em 29/29 (pt-BR A ficou com 1, es-ES/es-MX/outros com 3). Onde o teto deixou char ocioso, está contabilizado na §3 com os candidatos ranqueados pra iteração 5 — não inventei token pra encher campo (regra "95 chars honestos > 100 com token morto").
4. **Ortografia de token VIVO não foi mexida.** Tirar acento é neutro pro índice (iOS normaliza) e mexer em alguns e não em todos deixaria o campo incoerente. **Tokens NOVOS entram sem acento** (regra do lab / LEARNINGS #63b), seguindo inclusive a grafia com que os termos aparecem nos CSVs (`mesicni`, `pravidelne`, `μηνιαια`, `παγια`, `aylik`, `manedlig`). O acento remanescente nos tokens vivos fica registrado aqui como **known_debt datado (2026-10-01)**, não como exceção silenciosa.
5. **Dup check por locale** com o mesmo regex do `validate_proposed.py`. 24 duplicatas exatas da §5 removidas; zero blockers.

### A tese que banca `excel` / `widget` / `offline` / `grafico` / `categoria`

Essas apostas **não entram por pop do Astro** (que é `pop não confiável` neste app inteiro — sem ASC Search Terms, sem Apple Ads). Entram por uma **segunda fonte de outra natureza: posição observada em 12 storefronts do próprio app**, medida neste mesmo pull:

- `excel` → `menot excel` **#1** (fi) · `utgifter excel` **#2** (no, sv) · `belanja excel` **#3** (ms) · `wydatki excel` **#4** (pl) · `udgifter excel` **#5** (da) · `εξοδα excel` **#5** (el) · `uitgaven excel` **#7** (nl)
- `widget` → `vydaje widget` **#1** (cs) · `εξοδα widget` **#1** (el) · `kiadaskoveto widget` **#1** (hu) · `utgifter widget` **#2** (no) · `menot widget` **#8** (fi) · `віджет витрат` **#12** (uk)
- `offline` → `vydaje offline` **#2** (cs) · `utgifter offline` **#2** (sv) · `wydatki offline` **#3** (pl) · `belanja offline` **#4** (ms) · `menot offline` **#8** (fi) · `chi tiêu offline` **#11** (vi) · `витрати офлайн` **#20** (uk) · `uitgaven offline` **#24** (nl)
- `kategori(a/e)` → `κατηγορίες` #10 (el) · `kategorie` #15 (cs) · `kategori` #21 (ms) · `kategori` #37 (no) · `kategorie` #28 (pl) · `категорії` #29 (uk) · `קטגוריות` #18 (he)

O mecanismo é sempre o mesmo e é barato: **a cabeça já está no NAME** (`ausgaben`, `gastos`, `dépenses`, `spese`, `pengeluaran`, `支出`…), então o token de feature completa a composição a 1× e entrega top-10. São features que o app **entrega de verdade** (inventário §1.9 export Excel/PDF, §1.13 widget interativo, §1.12 offline sem conta, §1.6 gráficos, §1.3 categorias) e que **20 de 29 descrições nem mencionam** (§4.1). É a aposta mais barata e mais provada do dataset.

Isso satisfaz a regra de 2ª fonte do playbook §4 melhor do que qualquer pop. **Mesmo assim, nenhuma dessas apostas recebeu char de NAME ou SUBTITLE** — todas entraram só no keywords field, como manda a regra 6 do brief. `volume_source` de **todas** as apostas desta iteração: **`pop não confiável — só Astro`**; o que as justifica é a posição observada cross-storefront, não o volume.

---

## 1. de-DE — o alvo

**Antes**
- NAME `Ausgaben - Haushaltsbuch` (24/30)
- SUBTITLE `Budget & Finanzen verwalten` (27/30)
- KEYWORDS `kosten,konto,planer,monatsbudget,bilanz,haushalt,einkauf,fixkosten,kontrolle,kategorien,statistik` (97/100)

**Depois**
- NAME **`Ausgaben Haushaltsbuch Budget`** (29/30)
- SUBTITLE **`Finanzen & Fixkosten verwalten`** (30/30)
- KEYWORDS **`monatsbudget,kontrolle,kategorien,kosten,planer,statistik,haushalt,widget,offline,kostenlos,einkauf`** (99/100)

### NAME
| token | ação | razão |
|---|---|---|
| `ausgaben` | FICA (pos. 1) | 10 posições ≤#50, melhor #2. Front-load. |
| `haushaltsbuch` | FICA (pos. 2) | 4 posições ≤#50, melhor #4. |
| `-` (separador) | SAI | A Apple tokeniza em não-alfanumérico: `-` e espaço produzem os mesmos dois tokens. Troca **neutra pro índice**, libera 8 chars (§1 do protection_map). |
| `budget` | ENTRA (SUB → NAME) | Não é aposta nova: é upgrade de peso 3× → **7×**. Melhora as 3 posições que ele sustenta (`budget kategorien` #11, `budget pro kategorie` #13, `budget kontrolle` #26, todas DOMINATE com alvo top-5) e torna `budget widget` uma composição barata que antes não existia. |

### SUBTITLE
| token | ação | razão |
|---|---|---|
| `verwalten` | FICA | 3 posições: `fixkosten verwalten` #8, `ausgaben verwalten` #15, `kosten verwalten` #42. §1 exige explicitamente que continue no subtitle. |
| `finanzen` | FICA | 0 posições, mas é o único lugar onde o conceito vive e é a cola semântica da frase (regra 8). |
| `budget` | SAI (→ NAME) | Vide acima. Mantê-lo aqui seria duplicata exata do NAME = desperdício (regra 4) e warning do validador. |
| `fixkosten` | ENTRA (KW → SUB) | **Não é aposta nova.** Upgrade 1× → 3× nas 4 posições que já sustenta (`fixkosten verwalten` #8, `monatliche fixkosten` #12, `fixkosten planer` #31, `haushaltskonto` #41) e no próprio `fixkosten` (#53 → alvo top-40, CLIMB). Libera 10 chars no keywords field sem perder nada. É a palavra que o próprio produto usa na UI alemã (`fixedExpenses` = *Fixkosten*). |

Rewrite de subtitle declarado (regra 7). O gatilho: mover `Budget` pro NAME criou duplicata exata no subtitle, e a §1 do protection_map autoriza o movimento nomeando a proteção que tem de sobreviver (`verwalten`).

### KEYWORDS — saídas
| token | chars | posições que caem | razão |
|---|---|---|---|
| `bilanz` | 7 | **#1 `monatliche bilanz`** + #104 `bilanz` | **Vendido, não perdido** (§4). Ambas MISMATCH: quem busca *Bilanz* quer receita × despesa e o app só registra despesa (N3). A SERP de `monatliche bilanz` tem **5 resultados no total** e pop 5 = piso da escala Astro = volume DESCONHECIDO. 7 chars no único campo 100% load-bearing valem mais que um #1 de vitrine em query que o app não responde. |
| `konto` | 6 | #29 `konto ausgaben`, #41 `haushaltskonto` | Ambas MISMATCH (N18: não existe entidade conta/carteira). Duas posições fora do top-25 em intenção errada. Melhor candidato a saída do alemão (§3b). |
| `fixkosten` | 10 | **nenhuma** | Não é saída: foi pro SUBTITLE a 3×. |

### KEYWORDS — entradas (3 apostas, o teto)
| token | chars | tese | volume_source |
|---|---|---|---|
| `widget` | 7 | Alimenta `ausgaben widget` (d=13), `haushaltsbuch widget` (d=19) e `budget widget` (d=39) — 3 composições, as duas primeiras com a cabeça já no NAME a 7×. Mecanismo provado: #1 em cs/el/hu, #2 em no. O widget interativo de quick-add é feature real (§1.13) e a descrição alemã **não o menciona** (§4.1). | `pop não confiável — só Astro` (a prova é posição cross-storefront) |
| `offline` | 8 | Alimenta `ausgaben offline` (d=11), `haushaltsbuch offline` (d=13), `finanzen offline` (d=44) — 3 composições, duas baratíssimas. Provado: #2 cs, #2 sv, #3 pl, #4 ms, #8 fi. Offline sem conta é real (§1.12) e **já está na descrição alemã** — é coerência, não promessa nova. | `pop não confiável — só Astro` |
| `kostenlos` | 10 | **Decisão já tomada no brief, aplicada sem re-litigar.** FIT (o gate é só login+backup na nuvem; export Excel/PDF é grátis). Entra **1× em keywords e nunca em name/subtitle**: é LOTTERY, alvo #38-45, abaixo do penhasco, e pop 61 é astro-only. O que ele compra não é o #54→#40 em `haushaltsbuch kostenlos`; é alimentar `ausgaben kostenlos` (#104 hoje), `budget kostenlos` e `fixkosten kostenlos` — composições baratas porque a cabeça está no NAME. | `pop não confiável — só Astro` |

### KEYWORDS — manutenções (todas as 8 restantes sustentam posição)
`monatsbudget` 7 pos (#11) · `kontrolle` 5 pos (#6, decompõe `ausgabenkontrolle`) · `kategorien` 4 pos (#2) · `kosten` 4 pos (#12, decompõe `kostenkontrolle`) · `planer` 4 pos (#31) · `statistik` 2 pos (#2 — a 2ª melhor posição do locale, intocável) · `haushalt` 3 pos (#35; a suspeita de duplicata por composto com `Haushaltsbuch` **não está provada**, §1 manda ficar) · `einkauf` 1 pos (#13 PARTIAL).

### Ordem (front-loading, regra 6)
NAME: `ausgaben` (10 pos) → `haushaltsbuch` (4 pos) → `budget` (3 pos, recém-promovido).
KEYWORDS: `monatsbudget`(7) → `kontrolle`(5) → `kategorien`(4) → `kosten`(4) → `planer`(4) → `statistik`(2) → `haushalt`(3) → **apostas** `widget`,`offline`,`kostenlos` → `einkauf`(1, feeder).

### Coerência semântica (regra 8)
"Ausgaben Haushaltsbuch Budget / Finanzen & Fixkosten verwalten" lê como **um app que registra despesas num livro-caixa doméstico, com orçamento, e que gerencia finanças e custos fixos**. Todo token do keywords field completa "ein App, das ___": categoriza, controla, planeja, mostra estatística, tem widget, funciona offline, é grátis. Nenhum token de vaidade.

---

## 2. pt-BR — decisão FINAL: `casal` e `compartilhados` FICAM

> **REVISÃO 2026-10-01 (estágio 7, durante o deploy).** De manhã o João mandou tirar o cluster de casal; o estágio 5
> compôs a variante B e apagou a variante A do disco. Ainda em 01/10 ele **reverteu: `casal` fica.** O que está escrito
> abaixo sobre o *custo* e o *mecanismo* continua valendo palavra por palavra — mudou só a decisão no fim. O texto
> aplicado é a **variante A**; a **variante B** está arquivada em `proposed/metadata/pt-BR__sem-casal/`.
>
> **Motivo da reversão:** manter as 40 posições ≤#50 enquanto elas ainda trazem tráfego.
>
> **Trade-off aceito conscientemente, por escrito:** a promessa de casal segue viva no SUBTITLE **sem a feature existir**
> (`CardModel` sem campo de pessoa; todo path do Firestore é `.collection(userId)`). Risco de nota no único locale com
> massa de avaliação (BR, 18 ratings, 37% das instalações) e risco de App Review **2.3.1** — ambos aceitos.
>
> **Reabrir a variante B quando:** (1) a nota do BR virar o gargalo **medido**, ou (2) o app ganhar modo casal de verdade.
> Se B entrar, entra **inteira** — tirar `casal` e manter `compartilhados` é a pior das três opções.

**Antes (vivo)**
- NAME `Meus Gastos: Contas e Despesas` (30/30)
- SUBTITLE `Finanças do casal e pessoais` (28/30)
- KEYWORDS `compartilhados,contas,economias,planilha,orcamento,diario,mensais,categorias,fixas,resumo,extrato` (97/100)

**Depois — APLICADO (variante A)**
- NAME **`Meus Gastos: Contas e Despesas`** (30/30) — intocado
- SUBTITLE **`Finanças do casal e pessoais`** (28/30) — intocado
- KEYWORDS **`diario,mensais,categorias,extrato,fixas,resumo,orcamento,economias,compartilhados,planilha,offline`** (98/100)
  — sai só `contas` (duplicata exata do NAME, char grátis), entra a aposta `offline`, resto reordenado por front-loading.

**Variante B — composta, validada, NÃO aplicada** (`pt-BR__sem-casal/`)
- SUBTITLE `Finanças pessoais e categorias` (30/30) · KEYWORDS `diario,mensais,extrato,fixas,resumo,orcamento,economias,controle,recorrentes,offline,excel,grafico` (98/100)

O resto desta seção descreve a variante B e o que ela custaria/ganharia. Mantido como está: é o dossiê de quando B voltar.

### O que a troca custa e por que foi feita

Caem **40 posições ≤#50** — 21 de `casal`, 9 de `compartilhados`, 7 de `do`, 3 de `planilha`. **As 40 são MISMATCH.** Nenhuma posição FIT ou PARTIAL do pt-BR foi tocada: as 7 que não dependiam do cluster seguem cobertas.

A troca é deliberada e o motivo é o **gargalo de ratings do BR**. O app não tem casal, split, rateio nem ledger compartilhado (N1/N2: `CardModel` sem campo de pessoa, todo path do Firestore é `.collection(userId)`), e a promessa vivia **inteira no subtitle** — nem a description pt-BR a mencionava. Cada install vindo de `gastos do casal` / `planilha compartilhada` chegava esperando conta a dois, não achava, e saía. BR é o **único locale com massa de avaliação** (18 das 29 storefronts têm 0) e é 37% das instalações do app (161 de 1*/90d): é exatamente o lugar onde comprar install que não fica custa mais caro, porque contamina a única base de avaliação que existe.

Perder 40 posições de topo aparece feio no antes/depois. Elas foram **vendidas de propósito**, como o `monatliche bilanz` #1 do alemão — não é piora de iteração. Registrar assim no `meta.json`.

### Linha por token

| token | campo | ação | razão |
|---|---|---|---|
| `casal` | SUBTITLE | **SAI** | 21 posições ≤#50, **nenhuma FIT**. A promessa não existe no produto (N1/N2) e vivia só aqui. |
| `compartilhados` | KEYWORDS | **SAI** | 9 posições, mesma doença. Sai **junto** por obrigação — o protection_map é explícito: tirar um e manter o outro mantém a promessa errada e perde metade das posições. |
| `do` | SUBTITLE | SAI junto | 7 posições, **todas** dependentes de `casal`. Some com a frase. |
| `planilha` | KEYWORDS | **SAI** | Reavaliado à luz da decisão: sem o cluster, sustenta **só #118** `planilha de gastos mensais` — >#50 é tráfego zero. Também é MISMATCH (N12: o app **escreve** .xlsx, não edita planilha). Libera 9 chars. |
| `contas` | KEYWORDS | **SAI** | Duplicata exata do NAME `Contas` (§5): char grátis, as 7 posições seguem sustentadas pelo NAME a 7×. |
| `categorias` | KEYWORDS → **SUBTITLE** | **UPGRADE, não remoção** | 1× → 3× nas 6 posições que sustenta (#1 `gastos mensais por categoria`, #2 `despesas por categoria`, #2 `extrato por categoria`, #3 `gastos por categoria`, #7 `categorias de gastos`, #10 `orcamento por categoria`). As duas últimas são DOMINATE com alvo **top-3** — é o maior ganho disponível depois da saída do cluster. |
| `economias` | KEYWORDS | **FICA** | Reavaliado à luz da decisão, como pedido: 3 das 4 posições eram do cluster, mas a 4ª — **#17 `economias mensais`** — é **FIT** e sobrevive sozinha, desde que o token continue vivo. Trocar um FIT #17 já rankeado por um LOTTERY não-rankeado é exatamente o erro da iter-03 do Walk. |
| `diario` | KEYWORDS | **FICA** | **MISMATCH isolado, carregador em composição.** 4 posições, 3 FIT: **#1 `meus gastos diarios`**, #13 `despesas diárias`, #28 `diário gastos`, #34 `diario de despesas`. Tirar é perda líquida. |
| `mensais`(6 pos, #1) · `extrato`(3, #2) · `fixas`(3, #3) · `resumo`(1, #1) · `orcamento`(4, #10) | KEYWORDS | FICAM | Todos com posição ≤#50. |
| `finanças` · `pessoais` | SUBTITLE | FICAM | `finanças` sustenta **#19 `gastos finanças`** (FIT, CLIMB → top-10), que sobrevive ao cluster. `pessoais` perde as 2 posições (eram casal) mas continua feeder FIT de `gastos pessoais` (#150 → top-50) e `controle de despesas pessoais` (d=23). |

### Repack — os 23 chars que o cluster liberou

O campo tinha caído para 77/100. **Num locale de 161 instalações/90d (37% do app inteiro), 23 chars ociosos são perda real** — diferente dos 2 chars que sobraram na hipótese com casal, onde não cabia nada honesto. Preenchido até **98/100**:

| token | chars | classificação | tese |
|---|---|---|---|
| `controle` | 9 | **recuperação de char, não aposta** — é vocabulário de UI do app (`myControl` = **"Meu Controle"**, o header da home) e FIT confirmado no `term_fit_pt-BR.csv` | Alimenta **8 composições LOTTERY**, várias baratas: `controle de assinaturas` (d=7), `controle de gastos sem internet` (d=7), `controle vendas` (d=15), `controle de gastos ia` (d=21), `controle orçamento` (d=21), `controle de despesas pessoais` (d=23), **`controle de gastos offline` (d=23)**, `controle financeiro e gastos` (d=23). A última ficou barata agora que `offline` também entrou. É o head da frase que o brasileiro de fato digita nesta categoria. |
| `recorrentes` | 12 | **recuperação de char, não aposta** — vocabulário de UI (`recurringExpenses` = **"Gastos Recorrentes"**) e FIT confirmado | Alimenta `despesas recorrentes` (**d=5**) e `gastos recorrentes` (**d=5**) — duas composições baratíssimas com a cabeça já no NAME a 7×. O motor de despesa fixa/recorrente (§1.7) é feature real e **22 de 29 descrições nunca o mencionam**, pt-BR inclusive. |

**O teto de 3 apostas continua respeitado**: as apostas do pt-BR seguem sendo `offline`, `excel` e `grafico` (§0). `controle` e `recorrentes` não são apostas — são FIT, são palavras que o próprio produto mostra na tela, e entraram para recuperar char que o cluster liberou.

Sobraram **2 chars** (98/100). Não cabe token honesto nenhum; não preenchi com lixo.

### As 3 apostas do pt-BR
| token | chars | tese | volume_source |
|---|---|---|---|
| `offline` | 8 | `financas pessoais offline` (d=5), `controle de gastos offline` (d=23), `gastos offline` (d=33) — 3 composições. Offline sem cadastro é real (§1.12) e a descrição pt-BR **não menciona** (é uma das 4 presas no texto de 2024). Mecanismo provado em 8 storefronts (§0). | `pop não confiável — só Astro` |
| `excel` | 6 | `gastos em excel` (d=5) e `exportar despesas excel` (d=5) — 2 composições baratas, passa o gate de LOTTERY. Export é real (§1.9), nunca vendido em pt-BR. Recorde cross-storefront: #1 fi, #2 no/sv, #3 ms, #4 pl (§0). | `pop não confiável — só Astro` |
| `grafico` | 8 | `gráfico despesas` (d=13), `gráficos` (d=21), `grafico de gastos` (d=36) — 3 composições. Aba de gráficos é real (§1.6). | `pop não confiável — só Astro` |

### Ordem (front-loading, regra 6)
`diario`(#1) → `mensais`(#1) → `extrato`(#2) → `fixas`(#3) → `resumo`(#1) → `orcamento`(#10) → `economias`(#17) → `controle` → `recorrentes` → apostas `offline`, `excel`, `grafico`.

### Coerência semântica (regra 8)
"Meus Gastos: Contas e Despesas / Finanças pessoais e categorias" lê como **um app que registra gastos, contas e despesas pessoais por categoria** — e todo token do keywords field completa "um app que ___": é diário, mensal, dá extrato, trata despesa fixa e recorrente, resume, orça, controla, funciona offline, exporta pra Excel, faz gráfico. Saiu justamente o que **não** completava a frase com verdade (casal, compartilhados, planilha).

## 3. Os outros 27 locales — SAIU / ENTROU / MANTÉM

(de-DE na §1, pt-BR na §2.)

Legenda: **dup** = duplicata exata de NAME/SUBTITLE (§5, char grátis — quem sustenta a posição é o campo pesado, não a cópia a 1×). **MM** = MISMATCH. **>50** = só sustenta posição abaixo de #50 (tráfego zero). Toda entrada tem `volume_source: pop não confiável — só Astro`; a prova é a posição cross-storefront da §0.

### en-US (100 → 80/100) · o campo mais desperdiçado dos 29, 1 posição ≤#50
- **SAI** `financial` (2ª ocorrência — repetido **duas vezes** no mesmo campo, zero índice), `money` (dup SUBTITLE), `control` (dup SUBTITLE), `personal` (dup NAME), `easy` (dup SUBTITLE), `savings` (**MM** — N9: `GoalModel` é teto de gasto, não meta de poupança).
- **ENTRA** `category` (alimenta 5: `expenses by category` d=15, `spending by category` d=13, `monthly budget by category` d=11, `total spent by category` d=15, `budget by category app` d=21) · `offline` (alimenta 4: `budget planner offline` d=5, `track expenses offline` d=17, `expense tracker offline` d=21, `money tracker offline` d=37) · `spending` (alimenta 2: `spending by category` d=13, `monthly spending insights` d=15).
- **MANTÉM** `my`+`expenses` (NAME, sustentam `my expenses` #5 — a única posição do locale) · finance, financial, manage, budgeting, planning, costs, save.
- **20 chars ociosos** (teto de apostas). Próximos: `recurring` (d=19), `charts` (d=23), `widget` (d=15).

### es-ES (100 → 92/100) · e **es-MX (100 → 89/100)** — agora DIFERENTES
Os dois rodavam metadata idêntica. NAME/SUBTITLE continuam estáveis (o NAME sustenta `mis gastos` #37 no MX; regra 7), mas os **keywords fields foram diferenciados** — são storefronts diferentes e es-MX ainda indexa AR e os EUA (regra 12).
- **SAI (nos dois)** `dinero` (dup NAME), `financiero` (dup SUBTITLE), `ingreso` (**MM** — N3: o app não registra receita; sobrevivente da iter-03), `pagar` (redundante por radical com `pago`).
- **SAI só no es-MX** `expensas` — no ES sustenta **#49** (fica); no MX não rankeia e "expensas" lê como taxa de condomínio.
- **ENTRA es-ES** `categoria` (2: `gastos por categoria` d=5, `presupuesto por categoria` d=5) · `offline` (2: `finanzas personales offline` d=9, `gastos offline` d=13) · `excel` (`exportar gastos excel` d=5 + o recorde cross-storefront).
- **ENTRA es-MX** `categoria` (2: idem + `limite de gastos por categoria` d=5) · `recurrentes` (`gastos recurrentes` d=5) · `mensual` (`resumen mensual de gastos` d=5).
- **MANTÉM** presupuesto, ahorrar, gestión, familiar, pago, organizador, gasto (+ expensas no ES).

### fr-FR (99 → 75/100)
- **SAI** `suivi` (dup NAME), `economie` (dup SUBTITLE, variante com acento — iOS normaliza, é a mesma palavra), `compte` (**MM** N4/N18, só #177), `salaire` (**MM** N3, só #200), `facture` (**MM** N8 — cobranças com vencimento não existem), `ecologie` (**MM** — outra categoria de app, só #171).
- **ENTRA** `categorie` (3: `depenses par categorie` d=5, `budget par categorie` d=5, `categories de depenses` d=5) · `excel` (2: `export depenses excel` d=5, `depenses excel` d=11) · `widget` (`depenses widget` d=5).
- **MANTÉM** `depense` (2 pos, #3) · finance (#6) · argent, gestion, planificateur, famille. NAME/SUBTITLE intocados (`dépenses`, `suivi`, `budget`, `perso`, `finances` todos protegidos lá).
- **25 chars ociosos.** Próximos: `graphique` (d=5), `fixes` (d=9), `recurrentes` (d=5), `calendrier` (d=7), `hors ligne` (d=9).

### ja (47 → 51/100)
- **SAI** `節約` e `予算` (**dup** exatas do SUBTITLE `節約・予算・お金の見える化` — a proteção do #5 vem do subtitle a 3×), `収支` (**MM** N3 receita×despesa), `貯金` (**MM** N9 poupança).
- **ENTRA** `カテゴリ` (2: `予算 カテゴリ` d=5, `支出 カテゴリ` d=7) · `固定費` (palavra que o próprio app usa na UI japonesa; alimenta `定期支出` d=11) · `ウィジェット` (widget real, nunca vendido em ja).
- **MANTÉM** `支出` (sustenta `シンプル支出管理` #23) · 家計, 記録, 出費, 生活費, かけいぼ, お金, マネー, 簡単, お小遣い.

### it (95 → 73/100)
- **SAI** `bilancio` **só do keywords** (§3b: duplicata gratuita — as **únicas 2 posições ≤#50 do italiano** (`bilancio personale` #5, `spese bilancio` #9) são sustentadas pelo **NAME** a 7×; a cópia a 1× é desperdício. **O `bilancio` do NAME FICA** — trocar as 2 posições por "honestidade de intenção" num locale de 12 inst/90d é trade-off ruim; a promessa se corrige na description/prints), `risparmio` (dup SUBTITLE), `budget` (dup SUBTITLE), `conto` (**MM** N18), `carta` (**MM** N8), `denaro` (redundante com `soldi`, nenhum com posição).
- **ENTRA** `categoria` (2: `spese per categoria` d=5, `budget per categoria` d=5) · `widget` (`widget spese` d=11) · `fisse` (`spese fisse` d=5 — motor de despesa fixa é real e nunca vendido em it).
- **MANTÉM** `spesa` (#9), monitoraggio, gestione, finanza, soldi, famiglia.

### tr (89 → 61/100)
- **SAI** `bütçe` (dup NAME), `para` (dup SUBTITLE), `tasarruf` (dup SUBTITLE), `gelir` (**MM** N3 receita, sobrevivente da iter-03), `kasa` (**MM** N11 caixa de negócio), `maaş` (**MM** N3, só #231), `bakkal` (**MM** — lista de compras, só #77), `fatura` (**MM** N8).
- **ENTRA** `aylik` (3: `aylik butce` d=5, `aylik gider takibi` d=5, `aylik harcama takibi` d=5) · `kategori` (2: `harcama kategorileri` d=5, `kategori bazli butce` d=5) · `widget` (`harcama widget` d=5).
- **MANTÉM** gider, masraf, defter, finans, kişisel, aile. `harcamalar` (3 pos, #2) e `bütçe` seguem no NAME.
- **39 chars ociosos** — o campo era metade dup e metade MISMATCH. Próximos: `sabit` (d=5), `excel` (d=5), `grafigi` (d=5), `internetsiz` (d=5).

### ar-SA (77 → 63/100)
- **SAI** `ميزانية` (dup NAME — a proteção de #3 e #44 vem do NAME), `محفظة` (**MM** N18 carteira), `حساب` (**MM** N18 conta), `راتب` (**MM** N3 salário), `فواتير` (**MM** N8 faturas).
- **ENTRA** `شهرية` (4: `المصروفات الشهرية`, `ميزانية شهرية`, `نفقات شهرية`, `مصاريف شهرية`, todas d=5-11) · `فئات` (2: `المصروفات حسب الفئة` d=5, `ميزانية حسب الفئة` d=5) · `يومية` (2: `المصروفات اليومية` d=5, `مصاريف يومية` d=5).
- **MANTÉM** `تخطيط`+`مالي`+`شخصي` (sustentam `تخطيط مالي شخصي` #8) · مصاريف, نفقات, توفير, أموال, عائلة.

### id (92 → 49/100)
- **SAI** `uang`, `anggaran`, `catatan`, `hemat` (as 4 são **dup** exatas de NAME/SUBTITLE — §5, 28 chars grátis; a proteção fica no campo pesado), `tabungan` (**MM** N9; **trade-off nomeado: cai #28 `tabungan bulanan`**), `buku kas` (**MM** N11 livro-caixa de negócio; **trade-off nomeado: cai #43** — decisão do brief: #43 está abaixo do penhasco e o install que vier converte pior ainda; `kas` sai junto), `gaji` (**MM** N3, só #241), `dompet` (**MM** N18), `tagihan` (**MM** N8).
- **ENTRA** `kategori` (2: `pengeluaran per kategori` d=5, `anggaran per kategori` d=5) · `excel` (`pengeluaran excel` d=9) · `offline` (`pengeluaran offline` d=13).
- **MANTÉM** `bulanan` (3 pos, #5 — intocável), keuangan, manajemen.
- **51 chars ociosos**, o 2º pior do lote. Próximos: `widget` (d=5), `grafik` (d=5), `tetap` (d=5), `harian`.

### zh-Hans (48 → 47/100)
- **SAI** `收支` (**MM** N3), `钱包` (**MM** N18), `理财app` (**MM** gestão de patrimônio + contém o token `app`, proibido pela regra 5), `月账单` (PARTIAL redundante com `账单`, só #247).
- **ENTRA** `月度预算` (d=11) · `固定支出` (d=17) · `支出图表` (d=17) — as três são a query medida inteira, não fragmento.
- **MANTÉM** `家庭账本` (2 pos, #2/#29) · `日常开销` (#44) · 消费记录, 个人理财, 小账本, 财务, 账单, 省钱.

### ko (46 → 25/100) · **SUBTITLE reescrito**
- SUBTITLE `예산·자산 추적·절약 도우미` → **`예산·절약·생활비 한눈에`** (13/30). `자산` **não protege nada** (as 2 posições coreanas vêm de `가계부`/NAME e `절약`/SUBTITLE) e promete *asset tracking*, que o app não tem (N9/N18, §4.2). `절약` permanece — sustenta `절약 가계부` #41. `생활비` sobe de KEYWORDS pra SUBTITLE (upgrade 1×→3×, não é aposta nova).
- **SAI** `지출`, `예산`, `절약`, `자산` (**dup** de NAME/SUBTITLE, §5) + `재테크` (**MM**, só #195), `수입` (**MM** N3), `통장` (**MM** N18), `월급` (**MM** N3, só #140), `머니매니저` (**MM** — marca de concorrente, risco além do ASO).
- **ENTRA** `카테고리` (2: `카테고리 예산` d=5, `카테고리별 지출` d=5) · `오프라인` (`가계부 오프라인` d=23) · `그래프` (`지출 그래프` d=11).
- **MANTÉM** `가계부`+`간단한` no NAME (sustentam `간단한 가계부` #25 e `절약 가계부` #41) · 머니, 용돈, 가족, 장부.
- **75 chars ociosos — o pior do lote.** O campo vivo tinha 9 tokens MISMATCH de 14. **ko precisa de uma reconstrução dedicada na iteração 5**, não de 3 apostas.

### vi (77 → 96/100) · correção de tokenização
O campo vivo estava **quebrado em sílabas** (`tiết,kiệm,kế,hoạch,sổ,nhật,ký,cá,nhân,thống,kê,biểu,đồ`) — o fit-checker marcou as 13 como "sílaba isolada de um composto vietnamita, não é query". **Rejuntei em palavras reais**: `tiết kiệm`, `kế hoạch`, `sổ nhật ký`, `cá nhân`, `thống kê`, `biểu đồ`. **Não é remoção** — é o mesmo conteúdo lexical corretamente tokenizado, e `biểu đồ` como token exato **fortalece** `biểu đồ chi tiêu` #12 em vez de depender de recomposição.
- **SAI de fato** só `tiền` (sílaba solta, PARTIAL, sem posição).
- **ENTRA** `danh mục` (`chi tiêu theo danh mục` d=11, `ngân sách theo danh mục` d=5) · `widget` · `cố định`.
- **MANTÉM** `offline` (#11), excel, pdf. NAME/SUBTITLE intocados (`chi`, `tiêu`, `lý` protegem 3 posições).

### hi (94 → 98/100)
- **SAI** `सेविंग्स` (**MM** N9; **trade-off nomeado: cai #6** — o protection_map §3b classifica como "a única remoção quase indolor" das 11: protege só a si mesma, num locale de 7 inst/90d e 0 avaliações), `खाता` (**MM** N18), `बचत` (**MM** N9, só #177).
- **ENTRA** `मासिक` (2: `मासिक खर्च` d=5, `मासिक बजट` d=5) · `कैटेगरी` (`कैटेगरी बजट` d=5) · `फिक्स्ड` (`फिक्स्ड खर्च` d=5).
- **MANTÉM** `एक्सपेंस` (#3), `एक्सेल` (#43), `फाइनेंस` (#26), `खर्चा` (#2), रिपोर्ट, ऑफलाइन, पीडीएफ, कैलेंडर, डायरी, प्लानर, मनी.

### ru (86 → 78/100) · 0 posições ≤#50, recomposição livre
- **SAI** `кошелек` (**MM** N18, sobrevivente da iter-03), `сбережения` (**MM** N9, só #177), `цели` (PARTIAL — "metas" são tetos de gasto, N9), `планирование` (PARTIAL sem posição).
- **ENTRA** `категории` (2: `расходы по категориям` d=5, `бюджет по категориям` d=5) · `оффлайн` (`расходы оффлайн` d=5) · `постоянные` (`постоянные расходы` d=5).
- **MANTÉM** календарь, аналитика, экспорт, отчет, экономия, деньги.

### nl-NL (99 → **100/100**)
- **SAI** `kasboek` (**MM** N11, só #116), `administratie` (**MM** N11).
- **ENTRA** `widget` (`uitgaven widget` d=5) · `overzicht` (`financien overzicht` d=5) · `vaste` (despesa fixa, real e nunca vendida em nl).
- **MANTÉM** `grafiek` (#6), `excel` (#7), `offline` (#24), categorie, kosten, exporteren, pdf, financien, sparen, beheer (substring suspeita de `Budgetbeheer` — §5 manda não mexer).

### fi (82 → 98/100)
- **SAI** `laskuri` (**MM** — quem busca calculadora quer calculadora), `pdf` (FIT mas **zero composição medida em fi**; `excel` carrega o export e sustenta `menot excel` **#1**).
- **ENTRA** `kategoria` (2: `menot kategorioittain` d=5, `budjetti kategorioittain` d=5) · `kuukausi` (2: `budjetti kuukausi` d=5, `kuukausittaiset menot` d=5) · `kiinteat` (`kiinteat kustannukset` d=5).
- **MANTÉM** excel(#1), kaavio(#2), widget(#8), offline(#8), kustannukset(#24), säästäminen(#43), kirjaus, kalenteri.

### he (72 → 87/100)
- **SAI** `יעדים` (PARTIAL — "metas" são tetos, N9, só #153).
- **ENTRA** `אופליין` (`הוצאות אופליין` d=5) · `קבועות` (`הוצאות קבועות` d=5) · `תקציב` (3: `תקציב לפי קטגוריה` d=5, `ניהול תקציב אישי` d=5, `תקציב חודשי` d=7 — a forma nua; o SUBTITLE só tem `בתקציב` com prefixo).
- **MANTÉM** `קטגוריות` (#18), גרפים(#61), דוח, אקסל, חודשי, יומי, תכנון, חיסכון, אישי, כספים, פיננסים.

### no (90 → 98/100)
- **SAI** `regnskap` (**MM** N11, só #149), `økonomi` (redundante por radical com `privatøkonomi`, que sustenta #22).
- **ENTRA** `offline` (`utgifter offline` d=5) · `manedlig` (`manedlige utgifter` d=5) · `daglige` (`daglige utgifter` d=5).
- **MANTÉM** kategori(#5/#37), excel(#2), widget(#2), faste(#3), privatøkonomi(#22), pdf, kontroll, logg, dagbok (sustenta `utgiftsdagbok` d=5), penger.

### uk (92 → 92/100)
- **SAI** `гаманець` (**MM** N18), `планування` (PARTIAL, só #180), `цілі` (PARTIAL metas=tetos).
- **ENTRA** `постійні` (`постійні витрати` d=5) · `щомісячні` (`щомісячні витрати` d=5) · `excel` (`експорт витрат excel` d=5).
- **MANTÉM** категорії(#29), віджет(#12), офлайн(#20), звіт(#17), календар(#22), контроль, експорт, записи, гроші.

### ms (89 → 96/100)
- **SAI** `simpanan` (**MM** N9, só #154), `wang` (redundante com `duit`; nenhum dos dois com posição ≤#50 — e `wang` é substring suspeita de `Kewangan`).
- **ENTRA** `bulanan` (2: `bajet bulanan` d=5, `belanja bulanan` d=5) · `tetap` (`perbelanjaan tetap` d=5) · `widget` (nunca vendido em ms).
- **MANTÉM** os 11 com posição: graf(#1), excel(#3), offline(#4), perekod(#5), laporan(#11), penyata(#16), kategori(#21), kalendar, pdf, duit, jimat.

### pl (90 → 93/100)
- **SAI** `pieniądze` (PARTIAL dinheiro, sem posição), `planowanie` (PARTIAL, só #187).
- **ENTRA** `stale` (`stale wydatki` d=5) · `miesieczne` (`miesieczne wydatki` d=7) · `widget` (nunca vendido em pl; mecanismo #1 em cs/el/hu).
- **MANTÉM** offline(#3), excel(#4), kategorie(#28), wykresy(#66), raporty(#81), koszty, zapis, pdf, oszczędzanie. O campo polonês já cobria bem suas composições baratas.

### hu (93 → 95/100)
- **SAI** `pénz` (PARTIAL, coberto pelo radical de `pénzügy`), `tervező` (PARTIAL planner sem posição), `célok` (PARTIAL metas=tetos, só #155).
- **ENTRA** `excel` (`kiadasok excel` d=5) · `havi` (2: `havi kiadasok` d=5, `koltsegvetes havi` d=5) · `kategoria` (`kiadasok kategoriankent` d=5).
- **MANTÉM** widget(#1), spórolás(#44), költségek(#56), offline, statisztika, elemzés, export, napló (sustenta `kiadas naplo` d=5), pénzügy.

### sv (88 → 93/100)
- **SAI** `spara` e `sparande` (par redundante PARTIAL de poupança, nenhum com posição; N9), `mål` (PARTIAL metas=tetos).
- **ENTRA** `kategori` (2: `utgifter per kategori` d=5, `budget kategori` d=5) · `widget` (`utgifter widget` d=5) · `dagliga` (`dagliga utgifter` d=5).
- **MANTÉM** fasta(#2), kostnad(#2), kostnader(#112), excel(#2), offline(#2), analys, månad, rapport, pdf, dagbok (sustenta `utgiftsdagbok` d=5).

### cs (88 → 94/100)
- **SAI** `úspory` (**MM** N9, só #56), `platby` (**MM** N8, só #75), `cíle` (PARTIAL metas=tetos, só #102).
- **ENTRA** `excel` (`vydaje excel` d=11) · `pravidelne` (`pravidelne vydaje` d=5) · `mesicni` (`mesicni vydaje` d=7).
- **MANTÉM** widget(#1), offline(#2), šetření(#10), kategorie(#15), přehled(#80), grafy, export, sledování, deník.

### da (94 → 87/100)
- **SAI** `regnskab` (**MM** N11), `finans` (PARTIAL amplo sem posição), `planlægning` (PARTIAL sem posição).
- **ENTRA** `widget` (`udgifter widget` d=5) · `faste` (`faste udgifter` d=5 — é **#3** no norueguês com o mesmo token) · `offline` (`udgifter offline` d=5).
- **MANTÉM** excel(#5), forbrug(#7), oversigt(#7), kalender, kontrol, pdf, dagbog (sustenta `udgiftsdagbog` d=5), penge, opsparing.

### el (88 → 96/100)
- **SAI** `ταμείο` (**MM** N11 caixa de negócio, só #71), `στόχοι` (PARTIAL metas=tetos, só #126).
- **ENTRA** `offline` (`εξοδα offline` d=5) · `μηνιαια` (2: `μηνιαια εξοδα` d=5, `προυπολογισμος μηνιαιος` d=5) · `παγια` (`παγια εξοδα` d=5).
- **MANTÉM** κατηγορίες(#10), widget(#1), excel(#5), ημερολόγιο, εξαγωγή, pdf, οικονομία, οικονομικά, αγορές.

### th (65 → 67/100)
- **SAI** `บัญชี` (**MM** N18 conta bancária, só #123), `ออมเงิน` (PARTIAL poupança, só #135), `ประหยัด` (PARTIAL, só #230).
- **ENTRA** `หมวดหมู่` (`รายจ่ายตามหมวดหมู่` d=5) · `รายเดือน` (2: `รายจ่ายรายเดือน` d=9, `งบประมาณรายเดือน` d=9) · `ประจำ` (`รายจ่ายประจำ` d=5).
- **MANTÉM** กราฟ(#11), รายวัน(#28), สมุดบัญชี(#50), การเงิน(#14), ส่งออก, วางแผน.
- Nota: `รายรับ` (receita) **não existe** no campo vivo — o token de receita que o brief listou pra th já tinha saído.

### Char ocioso por locale (o teto de 3 apostas batendo antes do orçamento)
| locale | campo | ocioso | próximos candidatos (iteração 5) |
|---|---|---|---|
| ko | 25/100 | 75 | reconstrução dedicada — o campo vivo era 9/14 MISMATCH |
| zh-Hans | 47/100 | 53 | `分类` d=15, `离线` d=13, `excel` d=5, `图表` d=17 |
| id | 49/100 | 51 | `widget` d=5, `grafik` d=5, `tetap` d=5, `harian` |
| ja | 51/100 | 49 | `グラフ`, `カレンダー`, `エクセル`, `オフライン` |
| tr | 61/100 | 39 | `sabit` d=5, `excel` d=5, `grafigi` d=5, `internetsiz` d=5 |
| ar-SA | 63/100 | 37 | `الثابتة` d=5, `تسجيل` d=5, `excel`, `widget` |
| th | 67/100 | 33 | `widget`, `excel`, `ปฏิทิน` (calendário), `ออฟไลน์` |
| it | 73/100 | 27 | `grafico` d=9, `offline` d=13, `ricorrenti` d=5 |
| fr-FR | 75/100 | 25 | `graphique` d=5, `fixes` d=9, `recurrentes` d=5, `calendrier` d=7 |
| ru | 78/100 | 22 | `excel` d=5, `виджет` d=15, `по категориям` |
| en-US | 80/100 | 20 | `recurring` d=19, `charts` d=23, `widget` d=15 |

Os 17 locales restantes ficaram entre 87 e 100.

### Recomendação: 7 locales precisam de RECONSTRUÇÃO DEDICADA, não de 3 apostas

**ko (25/100) · zh-Hans (47) · id (49) · ja (51) · tr (61) · ar-SA (63) · th (67).**

Nos sete, o campo vivo não estava "meio vazio" — estava **cheio de coisa errada**: duplicata exata de name/subtitle e MISMATCH. ko tinha 9 tokens MISMATCH de 14 (incluindo `머니매니저`, marca de concorrente); tr tinha 3 duplicatas + 5 MISMATCH de 14; id tinha 4 duplicatas + 5 MISMATCH de 12. Tirar o que mente é ganho imediato; **refazer o campo inteiro a partir do pool de termos do locale é um trabalho de composição, não um teto de 3 apostas improvisadas**. Enfiar 3 tokens e declarar pronto seria repetir, por outro caminho, o erro que esta iteração existe para evitar.

Encaminhamento sugerido: uma iteração só para esses 7, com pool de long tails próprio por locale (os `longtails_<store>.csv` já existem) e nome/subtítulo reavaliados junto — em ko, ja e zh-Hans o **name tem 11-15 de 30 chars** usados, que é onde o peso 7× está sendo desperdiçado de verdade.

---

## 4. Correções de DESCRIPTION obrigatórias no deploy (fora do meu escopo de composição)

Não componho description, mas estes defeitos estão **vivos na loja** e o deploy desta iteração tem de levá-los junto:

1. **en-US (locale primário) — lixo de UI de chat colado na loja.** A description termina com `…dev/stdeula/`**`Tentar novamenteO Claude pode cometer erros. Confira sempre as respostas.`** Está na página do locale primário. **Correção obrigatória, independe de qualquer decisão de ASO.**
2. **"100% grátis" com paywall — risco 2.3.1 em 12 locales.** Alegação **dura** em **cs, el, fi, hi, hu, nl-NL, sv, vi** (*100% zdarma / 100% Δωρεάν / 100 % ilmainen / 100% मुफ़्त / 100%-ban ingyenes / 100% gratis / 100 % gratis / hoàn toàn miễn phí*) e **branda** em **da, ms, no, ru**. O app abre paywall mensal+anual logo depois do onboarding e gateia o sync. Reescrever pra "grátis para usar, backup na nuvem é opcional" ou equivalente.
   *Interação com o `kostenlos` alemão*: a keyword é defensável (o core é grátis, export inclusive) justamente porque é **token de keywords, não alegação de texto**. Se as descriptions continuarem com "100% grátis", o conjunto fica indefensável — resolver os dois no mesmo deploy.
3. **Promessa de notificação em 5 locales — de-DE, fr-FR, it, ja, ko.** *"Beim Annähern bekommst du Bescheid" / "on te prévient avant le dépassement" / "ti notifichiamo" / "通知でお知らせ" / "알려줍니다"*. **N6: o app não tem framework de notificação nenhum** — nem `flutter_local_notifications`, nem `firebase_messaging`, nem `UNUserNotification`. O único sinal é mudança de cor na aba de metas, e **depois** de estourar. Promessa falsa, traduzida, repetida.
4. **pt-BR com inglês solto na description viva**: *"nunca mais perca o controle das suas **expenses**"*, *"Organize suas **finance**"*, *"aumentar suas **minhas economias**"*.
5. **Oportunidade, não defeito**: en-US, pt-BR, es-ES e es-MX ainda rodam o texto de 2024 e **não vendem** export Excel/PDF, backup/sync, despesas fixas, widget nem offline (§4.1). São as 4 descriptions a reescrever primeiro.

Também fora de metadata, pro backlog de produto: o paywall vende 3 benefícios e **2 são ficção** (export já é grátis; "sem anúncios" num app que nunca teve anúncio — N15).

---

## 5. Validação

`./scripts/validate_proposed.py iterations/2026-09-30_iter-04-text-de-DE-name-subtitle-keywords` → **exit 0, 0 blockers, 96 warnings**, todos de 4 famílias conhecidas:

| família | n | justificativa |
|---|---|---|
| `name`/`subtitle` abaixo do teto | 49 | **47 são campos que esta iteração NÃO tocou** (estado vivo: `ja` 14/30, `zh-Hans` 11/30, `ko` 15/30 — nomes CJK não se enchem com filler). Os 2 meus: `de-DE` name 29/30 (o 30º char não cabe palavra nenhuma) e `ko` subtitle 13/30. |
| `keywords` abaixo do teto | 28 | Teto de 3 apostas (regra 3) batendo antes da regra de orçamento (regra 5). Quantificado locale a locale na §3 com os próximos candidatos. Nenhum char foi deixado vazio por preguiça — foi por disciplina de aposta. **pt-BR não está mais nessa lista**: o repack da §2 levou o campo a 98/100. |
| `short tokens possibly truncated` | 13 | Falso positivo do heurístico `len(t) < 4`: são palavras CJK/tailandesas inteiras (`财务`, `账单`, `省钱`, `小账本`, `カテゴリ`…) e `pdf`, que é palavra de verdade. Nenhum token truncado. **Correção ao brief**: o `managemen` "cortado" não existe — o único token dessa família nos 29 locales é o **`manajemen` do id, que é a palavra indonésia completa** para "gestão" (PARTIAL, mantida). O desperdício real do en-US era outro e foi removido: `financial` repetido **duas vezes** no mesmo campo. |
| `subtitle: words also in name` | 6 | 5 são subtitles vivos intocados (en-US `My`, es-ES/es-MX `gastos`, ms `Belanja`, vi `Chi`). O 6º é o `e` do pt-BR novo — stopword, a Apple ignora (e é o conectivo que faz a frase ser frase, regra 8). |

### known_debt datado (2026-10-01)
Tokens **vivos** com acento permanecem com acento (`gestión`, `přehled`, `šetření`, `sledování`, `oszczędzanie`, `pénzügy`, `kişisel`, `säästäminen`, `månad`, `privatøkonomi`, `økonomi`…). É neutro pro índice (iOS normaliza) e normalizar só uma parte deixaria o campo incoerente. **Todo token NOVO desta iteração entrou sem acento.** Varrer a dívida inteira num passe dedicado.


---

## 10. `excel` — decisão do João, 2026-10-01: MANTER

Registro, não mudança de campo. Para que nenhuma sessão futura tire `excel` achando que foi descuido.

**Alcance real depois do deploy: 15 locales**, não 16. Já era live em 9 (`da, el, fi, ms, nl-NL, no, pl, sv, vi`);
entrou em 6 (`cs, es-ES, fr-FR, hu, id, uk`). **`pt-BR` não carrega `excel`** — o revert para a variante A devolveu
`planilha`/`compartilhados` no lugar de `excel`/`grafico`. A contagem de "7 novos incluindo pt-BR" valia para a
variante B, que não foi aplicada.

**Por que funciona:** não mira a busca `excel` isolada (UNWINNABLE, SERP da Microsoft). Completa composição com a
cabeça já no NAME, a 1×. Posições reais onde já está vivo: `menot excel` #1 (fi), `utgifter excel` #2 (no/sv),
`belanja excel` #3 (ms), `wydatki excel` #4 (pl), `udgifter excel` #5 (da/el), `uitgaven excel` #7 (nl).

**Base no produto:** o app exporta `.xlsx` de verdade e **não** é PRO-gated (§1.9).

**Risco conhecido e aceito:** "Excel" é marca registrada da Microsoft. Esta iteração aumenta a exposição de 9 para 15
locales na **mesma submissão** que faz a faxina de risco 2.3.1 ("100% grátis"). João optou por manter em 01/10, ciente disso.

**Incoerência registrada:** o fit-checker removeu `머니매니저` (ko) **por ser marca de concorrente** ("risco além do ASO")
e manteve `excel` no mesmo passe. As duas coisas não são equivalentes — `머니매니저` é nome de app rival, `excel` é
formato que o app realmente exporta — mas a regra de marca do lab não distingue isso hoje. Se a review reclamar de
`excel`, o contexto está aqui.

**Se der errado:** rejeição por 5.2.5 → remover `excel` dos 15 e medir a perda nas composições acima, que são o ativo real.
