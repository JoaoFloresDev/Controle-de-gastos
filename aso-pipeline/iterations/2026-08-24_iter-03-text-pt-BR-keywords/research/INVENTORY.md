# INVENTORY — iter-03 extraction (stage 1) — 2026-08-24

App: **Meus Gastos** · App Store ID `6502218501` · bundle `com.gambit.meusgastos` · Finance
Target locales this iteration: **pt-BR (primary)** and **de-DE (secondary)** · Astro stores `br`, `de`
All paths below are relative to
`/Users/joaoflores/Documents/GambitStudio/Apps/recovery/flutter/Controle-de-gastos/aso-pipeline/iterations/2026-08-24_iter-03-text-pt-BR-keywords/research/`

---

## Files produced

| File | Contents | Size |
|---|---|---|
| `asc_state.json` | Full live + editable ASC state for **all 13 locales**: name, subtitle, keywords (+length +token list), promo text, whatsNew, description length, and BOTH `appInfoLocalization` and `appStoreVersionLocalization` ids per locale for the live *and* the editable record. Plus `issues[]` (7 entries) and `ratings{}`. | 13 locales |
| `astro_br_2026-08-24.json` | Astro ranking pull, store `br` — raw | **237 terms** (32 ranked <1000) |
| `astro_de_2026-08-24.json` | Astro ranking pull, store `de` — raw | **65 terms** (16 ranked <1000) |
| `current_pool_pt-BR.csv` | Astro 14-column. Terms whose every non-stopword word is a token of the live pt-BR fields | **47 rows** (22 ranked, 25 OUT) |
| `candidates_pt-BR.csv` | Astro 14-column. Everything else, each with a traceable `Note` | **190 rows** (10 ranked, 180 OUT) |
| `current_pool_de-DE.csv` | Astro 14-column, de-DE field tokens | **22 rows** (9 ranked, 13 OUT) |
| `candidates_de-DE.csv` | Astro 14-column, de-DE | **43 rows** (7 ranked, 36 OUT) |
| `competitors.md` | SERP top-10 for 4 head terms (br: `controle de gastos`, `gastos do casal`; de: `haushaltsbuch`, `ausgaben`) with names, subtitles, ratings mass + factual observations | 4 SERPs |
| `baselines.md` | All baseline methods side by side (A/B/C) + the unavailable-D note + ratings mass | — |
| `baseline_salesreports_60d.md` / `_sales.csv` | Copy of `reports/baseline_2026-08-24*` into the iteration | 314 dl |
| `asc_engagement_impressions_2026-08-24.tsv` | ASC Discovery & Engagement Standard, 43 daily instances merged + de-duplicated. Impressions / page views / taps by date × event × source type × device × territory | **44,070 rows**, 2025-12-29 → 2026-08-23 |

Also modified outside `research/`:
- `aso-pipeline/scripts/verify_current.py` — **ported `--pull`** from the Walk pipeline (it was missing; `write_local()` + PULL_MODE branch).
- `aso-pipeline/scripts/astro_mcp.py` — **copied in** from `_GambitStudio/aso/pipeline-template/scripts/` (did not exist in this app's pipeline).
- `aso-pipeline/current/metadata/` — refreshed from live: **13 locale folders**, 6 files each.

---

## ASC state — the ids the deployer will need

| | id | state |
|---|---|---|
| Live version (IOS) | `4ca2f89a-7539-4cfc-9daf-e75dd0178a30` — **45.2.0** | READY_FOR_SALE |
| **Editable version** | `137699c4-7e96-4abc-9b9a-77723dd65cf0` — **45.3.0** | ⚠️ **DEVELOPER_REJECTED** (not PREPARE_FOR_SUBMISSION) |
| Live appInfo | `4286a76c-b2e7-4baf-b1f2-da89b55f5036` | READY_FOR_SALE |
| **Editable appInfo** | `d05dd4f3-4b35-415f-8d88-5f6f6ee787de` | ⚠️ **DEVELOPER_REJECTED** |

Per-locale localization ids for the two target locales (editable record):

| locale | appInfoLocalization (name/subtitle) | appStoreVersionLocalization (keywords) |
|---|---|---|
| pt-BR | `85150ed8-1df9-4cb6-bc2d-fd4cdd0eaa1d` | `6444baac-fa5a-48f2-8ce3-d64d299eb9b9` |
| de-DE | `d6f8bb41-353a-45ea-a8c7-e1d0be5b0bab` | `3da18ac7-4958-4597-82df-33f1fb3e42e9` |

All 13 locales' ids (live and editable) are in `asc_state.json`.

---

## Baselines — three methods, all captured

| Method | Window | Downloads | /day | Notes |
|---|---|---|---|---|
| **A** `pull_analytics.py` (Sales Reports) | 60d, 2026-06-25→08-23 | 314 | **5.32** | 59/60 days with data; 1 IAP, US$7.71 |
| **B** `kill_or_scale.py --days 45` | 45d ending 08-23 | 227 | **5.0** | verdict 🟡 **WATCH**, trend ↑ rising, US$0 revenue |
| **C** ASC Discovery & Engagement | 45d / 60d / 236d | — | — | **impressions + CVR**, see below |

Method C headline (this dimension was never captured in iter-01/02):

| Window | Impressions/day | Page views/day | Imp→PV CVR | BR imp/day | BR CVR | DE imp/day | DE CVR |
|---|---|---|---|---|---|---|---|
| 45d | 506.0 | 30.3 | 5.99% | 142.6 | 8.23% | 49.3 | 7.49% |
| 60d | 646.7 | 40.0 | 6.19% | 202.4 | 8.37% | 63.9 | 7.33% |

**94.5% of all impressions come from App Store search** (145,549 of 153,947 lifetime), vs 5.5% browse. BR alone is 91.8% search, DE 94.7%.

Downloads by country (60d): BR 162 (51.6%), DE 30 (9.6%), JP 22, TR 13, US 13 — 39 countries.

---

## Real search-terms volume — **NOT available** (and not merely pending)

Both analytics report requests exist and were re-probed today:

| Request | accessType | Reports | Search-terms report present? |
|---|---|---|---|
| `a31193ac-6b49-4efe-9978-0c23da47df4d` | ONGOING | 156 | **no — absent from catalog** |
| `ea59a3c9-1916-40ba-b2a0-5658af7761c0` | ONE_TIME_SNAPSHOT | 147 | **no — absent from catalog**; zero instances on every report |

The `APP_STORE_ENGAGEMENT` category holds only: Discovery and Engagement Standard, Discovery and Engagement Detailed, Web Preview Engagement Standard/Detailed, Retention Messaging. The Detailed report's `Source Info` column is **empty on every App Store search row** — no query string is exposed anywhere.

Consequence: **Astro popularity is the sole volume signal for this iteration.** pop=5 remains a measurement floor, and there is no corroborating source. The ONGOING request *does* produce daily instances, which is what let me recover the impressions baseline (Method C) instead.

---

## Corrections to the briefing (verified against the API)

1. **iter-02 was FULLY deployed, not partially.** The briefing states the pt-BR keywords field was never applied and still reads `finanças,financeiro,gestão,dinheiro,orçamento,poup…`. It does not. Live 45.2.0 pt-BR keywords are exactly the iter-02 proposal: `compartilhados,contas,minhas,economias,planilha,orcamento,diario,cartao,dividas,fatura,mensais` (94 chars), on localization `33b381cf-5d83-4722-92d3-239125b77746`. Name and subtitle also match iter-02. The editable 45.3.0 carries the same values. **The "name/subtitle point at couples while keywords stayed generic" mismatch does not exist** — all three fields are on the couples angle. Only `meta.json`'s `deployed:false` / `status:running` is wrong.
2. **13 live locales, not 12.** The extra is **zh-Hans** (`记账 - 简单家庭账本`).
3. **The editable version is DEVELOPER_REJECTED, not PREPARE_FOR_SUBMISSION.** Metadata PATCHes are accepted, but the version needs re-submission for anything to ship.
4. **es-MX and es-ES are identical**, not just es-MX being wrong — same name, same subtitle, same keywords. The `Despesas` misspelling is present in **both**.

---

## Issues recorded in `asc_state.json` → `issues[]`

| # | Severity | Issue |
|---|---|---|
| 1 | high | es-MX **and** es-ES name is `Mis Despesas Gastos y Cuentas` — "Despesas" is Portuguese, not Spanish. Both locales share identical name/subtitle/keywords. |
| 2 | medium | iter-02 `meta.json` says `deployed:false` while all three fields are live. |
| 3 | medium | Editable version + appInfo are DEVELOPER_REJECTED. |
| 4 | low | 13 live locales (zh-Hans was uncounted). |
| 5 | medium | No App Store Search Terms report exists for this app. |
| 6 | low | **en-US keywords field wastes 10 of 100 chars**: `financial` appears twice. |
| 7 | high | BR ratings mass **18 < 25** — below the RULES.md rating-first gate. de 2, us 1, mx/jp/tr 0. |

---

## Astro — what changed in tracking

- Store **`de` did not exist** for this app (only `br`, `mx`). Created it and seeded **35 terms** from the live de-DE field tokens + compositions, then **30 candidates** from the DE SERP → `de` now tracks **65 terms**.
- Store `br` went from 208 → **237 terms** (+29 accepted, 6 already tracked).
- Astro's stored app name is stale: **"Meus Gastos: Contas e Despesas"** (a pre-iter-02 name). Cosmetic, does not affect rankings.

### Notable measurements (raw, no interpretation)

pt-BR couples cluster — all pop 5, we rank at the top:
`gastos compartilhados` #3 · `gastos do casal` #4 · `financas do casal` #4 · `app de gastos casal` #4 · `gastos casal` #5 · `contas do casal` #7 · `despesas compartilhadas` #9 · `orcamento do casal` #11 · `despesas do casal` #26

New pt-BR candidates that came back already ranked:
`gastos mensais casal` **#1** (diff 10, 4 apps) · `despesas compartilhadas casal` **#2** (diff 5, 28 apps) · `contas compartilhadas casal` **#4** · `economias casal` **#4** · `contas compartilhadas` **#26** (diff 19, 83 apps)

pt-BR heads we do **not** hold: `controle de gastos` (pop 53) OUT · `finanças pessoais` (pop 59) OUT · `minhas despesas` (pop 57) OUT · `despesas` (pop 52) OUT. Ranked but deep: `minhas economias` #58 (pop 61) · `minhas financas` #222 (pop 57) · `planilha` #222 (pop 60) · `casal` #212 (pop 54).

de-DE: `ausgaben verwalten` #12 · `monatsbudget` #23 · `haushaltsbuch` **#59** (pop 61) · `kontobuch` #59 · `fixkosten` #65 · `haushalt` #97 · `ausgaben` **#122** (pop 48) · `bilanz` #176. New: `haushaltsbuch ausgaben` #31 · `haushaltsbuch kostenlos` #54 (pop 61) · `einnahmen ausgaben` #119 · `haushaltsplaner` #132 (pop 35) · `haushaltsbuch familie` #176 · `meine ausgaben` #195. The DE couples cluster (`finanzen fuer paare`, `haushaltsbuch paare`, `gemeinsame kasse`, `ausgaben teilen`) all came back **OUT** at pop 5.

Every candidate row's `Note` column carries its traceable source (competitor name/subtitle + that competitor's SERP position, accent variant of one of our own live tokens, or a composition of our tokens). Pre-existing terms are marked `pre-existing Astro tracking (iter-01/iter-02 pool)`. Terms added this iteration are tagged `new-this-iter`.

---

## Pipeline history reconstructed (registry is empty)

`registry/keywords_tested.json`, `winners.json`, `ideation_backlog.json`, `headlines_used.json` are all `[]`. Nothing was ever recorded. From the two iteration folders:

| Iteration | Proposed | Fate |
|---|---|---|
| **iter-01** 2026-05-23 | subtitle `Controle financeiro e receitas`; keywords `controle de gastos,personal,casal,money,expenses,budget,gerenciador,dinheiro,gestão,pessoais,mensais` | `deployed:true` @ 2026-05-23T19:54:51Z, then **superseded 7 days later** by iter-02. Neither field is live now. `metrics/` **empty**, `verdict: null`. Baseline claimed 1.5 dl/day. |
| **iter-02** 2026-05-30 | name `Meus Gastos: Casal e Despesas`; subtitle `Finanças do casal e pessoais`; keywords `compartilhados,contas,…,mensais` | **All three ARE live** on 45.2.0 despite `deployed:false`. `metrics/` **empty**, `verdict: null`, `supersedes` iter-01. |

**No iteration in this pipeline has ever had its results measured.** iter-03 is the first with a Day-0 impressions baseline (Method C) to measure against.

`couples_niche_viability_2026-06-21.md` (read): concluded 🔴 NO-GO for a standalone couples app, 🟢 GO for pushing "Modo Casal" inside Meus Gastos — on the grounds that every couples term is pop 5 (measurement floor) while the volume heads are locked by Mobills (165k ratings), Organizze (45k), Minhas Economias (57k). Today's pull is consistent with that: we hold #3-#11 across the couples cluster, and all of it is pop 5.

---

## What failed / was not done

- **Real per-query search volume** — unavailable, see above. Not a tooling failure; the report does not exist for this app.
- **`--pull` was missing** from this app's `verify_current.py` — ported from the Walk pipeline before running (as the procedure directs).
- **`astro_mcp.py` was missing entirely** from this app's `scripts/` — copied from the pipeline template.
- Astro's stored app name for 6502218501 is stale (pre-iter-02). Not corrected — cosmetic and outside this stage's scope.
- No analysis, no term judgments, no field proposals were made. Stages 2-5 own that.
