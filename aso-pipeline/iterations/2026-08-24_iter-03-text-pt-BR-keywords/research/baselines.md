# Baselines — Meus Gastos (6502218501) — captured 2026-08-24

Three independent methods, each with its own window and source. Numbers are NOT interchangeable — always cite the method.

---

## Method A — `pull_analytics.py` (ASC Sales Reports, 60-day window)

Source: `reports/baseline_2026-08-24.md` (copied here as `baseline_salesreports_60d.md`)
Window: **2026-06-25 → 2026-08-23**, 59/60 days with data.

| Metric | Value |
|---|---|
| Total downloads | **314** |
| Avg downloads/day | **5.32** |
| IAP units | 1 (`yearly.pro`) |
| Estimated proceeds | **US$ 7.71** |

Top countries: **BR 162 (51.6%)**, DE 30 (9.6%), JP 22 (7.0%), TR 13 (4.1%), US 13 (4.1%), FR 7, ID 7, EG 5. 39 countries total.

---

## Method B — `kill_or_scale.py --days 45` (ASC Sales Reports, 45-day window)

Window: last **45 days** ending 2026-08-23.

| Metric | Value |
|---|---|
| Total downloads | **227** |
| Avg downloads/day | **5.0** |
| Revenue (window) | **US$ 0.00** |
| Run-rate | US$ 0/month |
| Trend | **↑ rising** |
| Verdict | 🟡 **WATCH** |

Note text returned by the script: *"tendência de alta — vale observar +30d antes de decidir"*.

> A and B disagree by 0.32 dl/day purely because of window length (60d includes an early-August bump: 12, 12, 8, 8 on Aug 2-5). Both agree the trend is rising.

---

## Method C — ASC Analytics, App Store Discovery & Engagement (impressions / page views / CVR)

Source: ONGOING analytics request `a31193ac-6b49-4efe-9978-0c23da47df4d`, report `r14` (Standard), 43 daily instances downloaded and de-duplicated → `asc_engagement_impressions_2026-08-24.tsv` (44,070 unique rows).
**This is a new baseline dimension the previous iterations never captured** — it gives impressions and store-page CVR, which is what an ASO text change actually moves first.

Full data range in file: **2025-12-29 → 2026-08-23** (236 days).

### Lifetime (236 days)

| Event | Total | Per day |
|---|---|---|
| Impression | 153,947 | 652.3 |
| Page view | 9,415 | 39.9 |
| Tap | 731 | 3.1 |

By source type: **App Store search 145,549 impressions (94.5%)** vs App Store browse 8,398 (5.5%). Search is essentially the only discovery channel — which is what makes a keyword iteration the right lever.

### Windowed, to match Methods A and B

| Window | Impressions | /day | Page views | /day | Imp→PV CVR |
|---|---|---|---|---|---|
| Last 45d (2026-07-10 → 08-23) | 22,768 | 506.0 | 1,364 | 30.3 | **5.99%** |
| Last 60d (2026-06-25 → 08-23) | 38,802 | 646.7 | 2,401 | 40.0 | **6.19%** |

### Per target store

| Store | 45d impressions | /day | 45d page views | Imp→PV CVR |
|---|---|---|---|---|
| **BR** | 6,419 | 142.6 | 528 | **8.23%** |
| **DE** | 2,217 | 49.3 | 166 | **7.49%** |

| Store | 60d impressions | /day | 60d page views | Imp→PV CVR |
|---|---|---|---|---|
| **BR** | 12,143 | 202.4 | 1,016 | **8.37%** |
| **DE** | 3,833 | 63.9 | 281 | **7.33%** |

Lifetime by territory (top 12 by impressions):

| Territory | Impressions | Page views | CVR |
|---|---|---|---|
| BR | 68,679 | 5,027 | 7.3% |
| US | 16,753 | 834 | 5.0% |
| JP | 8,369 | 380 | 4.5% |
| MX | 6,516 | 258 | 4.0% |
| DE | 6,363 | 383 | 6.0% |
| ID | 4,182 | 210 | 5.0% |
| KR | 3,366 | 70 | 2.1% |
| AR | 3,351 | 110 | 3.3% |
| GB | 3,033 | 90 | 3.0% |
| CN | 2,797 | 101 | 3.6% |
| IN | 2,497 | 56 | 2.2% |
| FR | 2,483 | 123 | 5.0% |

BR-specific source split (lifetime): App Store search 63,037 impressions vs browse 5,642 — 91.8% search.
DE-specific source split (lifetime): App Store search 6,023 vs browse 340 — 94.7% search.

---

## Method D — real per-query search volume: **UNAVAILABLE**

Not pending — **absent**. Neither analytics request exposes an "App Store Search Terms" report at all:

| Request | accessType | Total reports | Search-terms report? | Instances |
|---|---|---|---|---|
| `a31193ac-6b49-4efe-9978-0c23da47df4d` | ONGOING | 156 | **none in catalog** | has daily instances on other reports |
| `ea59a3c9-1916-40ba-b2a0-5658af7761c0` | ONE_TIME_SNAPSHOT | 147 | **none in catalog** | **zero on every report** |

The `APP_STORE_ENGAGEMENT` category contains exactly five reports: Discovery and Engagement Standard, Discovery and Engagement Detailed, Web Preview Engagement Standard, Web Preview Engagement Detailed, Retention Messaging. The Detailed variant carries a `Source Info` column but it is **empty** for every App Store search row — no query string is exposed.

Consequence for downstream stages: **Astro popularity is the only volume signal available.** A pop=5 reading is a measurement floor, not evidence of zero searches, and there is no second source to corroborate it this iteration.

---

## Ratings mass (rating-first gate, RULES.md)

| Store | Ratings | Avg |
|---|---|---|
| **br** | **18** | 4.94 |
| de | 2 | — |
| us | 1 | — |
| jp | 0 | — |
| tr | 0 | — |
| mx | 0 | — |

BR is **below the 25-rating threshold** in RULES.md ("app com <25 ratings na store-alvo não roda iteração ASO agressiva"). DE is far below it. Recorded here as a constraint for the composer/reporter stages — no judgment applied at this stage.
