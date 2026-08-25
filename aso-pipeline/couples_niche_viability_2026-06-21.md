# Couples/Family Expense Niche — Viability Gate + ASO Ceiling (BR/ES)

**Data:** 2026-06-21 · **Source:** Astro MCP (search_app_store, search_rankings, get_keyword_suggestions) + grep da metadata live do Meus Gastos
**Pergunta:** Tem espaço pra um app de controle de gastos pra casais/família com "dividir extrato entre devices"? Qual o teto real de volume?
**Contexto:** Meus Gastos (appId `6502218501`, Flutter+Firebase, live BR+MX) já está posicionado pra casais — name `Meus Gastos: Casal e Despesas`, subtitle `Finanças do casal e pessoais`, 4.94★ (18 ratings BR).

---

## 🚦 VEREDITO — Viability Gate

| Cenário | Veredito | Por quê |
|---------|----------|---------|
| **App NOVO standalone de couples** | 🔴 **NO-GO** | Nicho tem ~0 oxigênio de ASO orgânico (todo termo couples = pop 5, o piso). Heads com volume são dos gigantes. Dependeria 100% de paid/boca-a-boca. |
| **Feature "Modo Casal" no Meus Gastos** | 🟢 **GO** | Não é aposta de ASO — é conversão/retenção/diferenciação sobre tráfego que JÁ existe. MG já ranqueia #3-9 nos termos couples a custo ~zero. Name já tem "Casal". |

### Os 3 sinais do gate (computados dos dados Astro)
- **Oxigênio de ASO** (≥3 termos pop≥6 + diff≤20 + intenção alinhada): **ZERO.** Único termo do nicho com pop≥6 é `dividir gastos` ES (pop 8) — mas diff 40. Reprova.
- **Saturação dos heads:** **SIM.** BR `gastos`/`planilha` diff 63 + Mobills **165k** reviews, Organizze 45k, Minhas Economias 57k. ES `presupuesto familiar` diff 39, `gastos en pareja` em gold rush.
- **Wedge:** existe um **wedge de PRODUTO** ("pra casais que dividem despesas e querem ver quem deve quanto, sincronizado entre 2 celulares") — mas **NÃO é um wedge de ASO** (ninguém busca isso em volume).

**Conclusão:** o nicho couples não se ganha por ASO — se ganha por **produto + funil de finanças amplo + boca-a-boca**. Construir app novo do zero pra brigar nesse espaço = cold-start de ratings contra gold rush, por um keyword de volume nulo. Empurrar via Meus Gastos (que já tem o ranking, os ratings e o Firebase) é o único caminho com ROI.

---

## 📊 Dados — BR (couples/família)

Filtro decisão: pop≥6 + diff≤20 = sweet spot real. **Nenhum termo couples passa** (todos pop 5).

| Termo | Pop | Diff | Rank Meus Gastos | Classificação |
|-------|-----|------|------------------|---------------|
| `orcamento do casal` | 5 | 5–13 | **#3** | 🔵 floor (já domina) |
| `gastos compartilhados` | 5 | 15 | **#5** | 🔵 floor (já domina) |
| `app de gastos casal` | 5 | 5 | **#7** | 🔵 floor (já domina) |
| `despesas do casal` | 5 | 5–13 | **#8** | 🔵 floor (já domina) |
| `gastos casal` | 5 | 13 | **#9** | 🔵 floor (já domina) |
| `financas a dois` | 5 | 22 | — | ⚠️ floor + diff médio |
| `dividir despesas` | 5 | 23 | — | ⚠️ floor + diff médio |
| `orçamento familiar` | 5 | 52 | #1000 | 🚫 floor + diff alto |

**Leitura:** Meus Gastos já está TOP 3-9 em quase todo termo couples do BR — e mesmo assim isso entrega pouquíssimo tráfego, porque pop 5 = piso de medição (sem volume real). Estar #3 num termo pop 5 ≈ migalhas de instalação/dia.

## 📊 Dados — BR (heads com volume real, mas saturados)

| Termo | Pop | Diff | Dono do topo |
|-------|-----|------|--------------|
| `planilhas` | 67 | 54 | genéricos |
| `minhas economias` | 61 | 53 | Minhas Economias (57k) |
| `planilha` | 60 | 63 | genéricos |
| `minhas despesas` | 57 | 51 | gigantes |
| `minhas financas` | 57 | 58 | gigantes |
| `despesas` | 52 | 49 | Mobills/Organizze |
| `personal` | 47 | 58 | — |
| `gastos` | 31 | 63 | **Mobills (165k)** |
| `gastos diarios` | 30 | 64 | gigantes |
| `money saving app` | 30 | 39 | — |

**Leitura:** o volume vive nos heads de finanças geral — todos diff 49-64 e travados por Mobills (165k), Organizze (45k), Minhas Economias (57k). Inalcançável organicamente.

## 📊 Dados — ES (couples/família)

| Termo | Pop | Diff | Classificação |
|-------|-----|------|---------------|
| `dividir gastos` | 8 | 40 | ⚠️ único pop≥6, mas diff alto |
| `finanzas en pareja` | 5 | 5 | 🔵 floor |
| `presupuesto en pareja` | 5 | 5 | 🔵 floor |
| `presupuesto familiar` | 5 | 39 | 🚫 floor + diff médio |
| `gastos en pareja` (head do nicho) | ~5 | médio | gold rush (15-19 apps, quase todos 0-3 ratings, <12 meses) |

**Leitura:** ES é um **gold rush recém-chegado** — ParejaPro, DuoBalance, WeZioo, DuoDivvy, Inali, famlyy, Finanzas Pareja… todos 0-3 ratings, lançados nos últimos 12 meses. Ninguém estabelecido, mas todo mundo brigando pelo mesmo termo de volume mínimo ao mesmo tempo. Entrar agora = ser mais um 0-rating.

---

## 🏟️ Competição (resumo)

**BR — head genérico travado por gigantes, couples-específico fraco:**
- Genéricos: Mobills (165k), Minhas Economias (57k), Organizze (45k), Despezzas (5.5k), Fleur (4.5k), Pierre IA (3.5k)
- Couples-específicos (todos fracos): **Junto$ 3.7★/68 ratings**, dividi 5★/10, Balance "Despesas do Casal" 13

**ES — gold rush:** 15-19 apps em "gastos en pareja", quase todos 0-3 ratings, todos <12 meses.

**US (referência, não atacar):** Honeydue 10k, Splitwise 25k, Tricount 6k, Settle Up 1.6k, Tandem 740 + dezenas de 0-rating 2024-2026. Saturadíssimo.

---

## 💸 "Dividir o extrato entre devices" — realidade técnica

- **Bank-connect real** (importar extrato do banco): exige Open Finance (BR) / Plaid (US) — caro, regulado, foge do modelo GambitStudio. ❌
- **Versão viável** (entrada manual + sync tempo real entre 2 devices via Firebase): **já é o que Honeydue, Tandem, Junto$ e dividi fazem.** Não é diferencial. ⚠️
- Meus Gastos **já tem Firebase (auth + firestore + realtime db)** instalado → o sync multi-device é viável sem custo de infra novo.

---

## 🎯 Recomendação

**Não criar app novo.** Implementar **"Modo Casal"** no Meus Gastos:
1. Convite do parceiro por código → ambos lançam gastos → app divide (50/50 ou proporcional à renda) → mostra "quem deve quanto", sincronizado entre os 2 celulares (Firebase que já existe).
2. Ganho real ≠ ASO volume (que é nulo) → é **conversão + retenção + diferenciação** sobre o tráfego do funil amplo de finanças que MG já capta, + defender o long-tail couples que os concorrentes (Junto$, dividi) são fracos demais pra segurar.

### Metadata BR — micro-ajustes (não é rewrite; já está couples-led)
Atual: NAME `Meus Gastos: Casal e Despesas` (30) · SUBTITLE `Finanças do casal e pessoais` (28) · KEYWORDS `compartilhados,contas,minhas,economias,planilha,orcamento,diario,cartao,dividas,fatura,mensais`

- KEYWORDS field tem espaço pra packing (está ~88 chars). Candidatos de baixo risco a adicionar (todos pop 5 mas custo ~zero e MG já ranqueia): `dividir,despesas,familiar,a dois,gastos`. **Mas:** como o volume é piso, o ganho é marginal — priorizar a FEATURE, não o keyword field.
- es-ES e es-MX estão com name/subtitle **vazios** no fastlane (a app é live em MX) — se quiser empurrar ES, preencher, mas o teto de ES couples é igualmente baixo + gold rush.

---

## 📐 Teto estimado (realista)

- **App novo couples-only via ASO couples:** ~0-3 instalações orgânicas/dia (pop 5 = sem volume mensurável). **Não viável como standalone.**
- **Meus Gastos + Modo Casal:** sem uplift de ASO de couples (volume é nulo), mas: (a) defende o long-tail couples a custo zero, (b) lift de conversão/retenção sobre o funil amplo que MG já capta, (c) história de diferenciação contra Junto$/dividi fracos. O motor de instalação continua sendo o funil de finanças geral + boca-a-boca, não os termos couples.

## ⚠️ Riscos / armadilhas
1. **Falso sweet spot:** diff baixo (5-15) nos termos couples NÃO é oportunidade — é baixo porque ninguém disputa um termo de volume nulo. Não celebrar "diff 5".
2. **Construir bonito ≠ ganhar nicho:** o gargalo aqui é demanda de busca, não execução. App novo nesse nicho vira pasta `recovery/`.
3. **ES gold rush:** entrar agora = mais um 0-rating num mar de 0-ratings.
