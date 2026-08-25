# App feature inventory — Meus Gastos (stage 3 fit gate)

App Store ID `6502218501` · bundle `com.gambit.meusgastos` · Finance
Source of truth: `/Users/joaoflores/Documents/GambitStudio/Apps/recovery/flutter/Controle-de-gastos/meus_gastos`
Built from PRIMARY sources in this order: (1) Dart source, (2) live `current/metadata/<locale>/description.txt`, (3) store name/subtitle.

---

## 0. The headline finding — the app is a SOLO expense logger, not a shared-ledger app

The App Store name says **"Meus Gastos: Casal e Despesas"** and the subtitle **"Finanças do casal e pessoais"**.
The product does not contain the word *casal* anywhere.

Evidence:

| Check | Result |
|---|---|
| `lib/l10n/app_pt.arb` — 250 user-facing strings | **zero** occurrences of `casal`, `compartilh*`, `parceiro`, `juntos`, `a dois`. The only near-hit is `share = "Compartilhar"` (line 62), which is the **file share sheet** of the Excel/PDF export (`shareMensage = "Obtido pelo app Minhas Despesas"`). |
| `lib/l10n/app_pt.arb` line 1 | `app_name = "Minhas Despesas"` — the in-app name is singular/personal, not the store name. |
| `current/metadata/pt-BR/description.txt` | 5 bullets (registro, gráficos, calendário, categorias, interface). **Zero mentions of casal / compartilhado / dois usuários.** The couples angle exists only in name+subtitle. |

**"Casal" is a metadata-only positioning with no product behind it.** That is the single most important fact for this stage.

---

## 1. What the app ACTUALLY delivers

### 1.1 Core job — log an expense by hand, in seconds
- 5-tab shell (`lib/main.dart:238-263`): **Add** → **Transactions** → **Dashboards (Gráficos)** → **Goals (Orçamento)** → **Settings**.
- `CardModel` (`lib/models/CardModel.dart:3-17`): `id, amount, description, date, category, idFixoControl, updatedAt, deleted`. Manual entry only.
- Quick-value buttons + masked currency field (`AddTransaction/UIComponents/Header/`), category picker as a horizontal circle list.

### 1.2 Categories
- 14 seeded categories in pt (`app_pt.arb`): mercado, restaurante, posto, contas da casa, cesta, saúde, transporte, educação, filme, videogame, bebida, lazer, água, luz, wi-fi, telefone, cartão de crédito.
- User-created categories with custom name + icon + color (`CategoryCreater/`, `ColorGridSelector.dart`, `CategoryModel`).

### 1.3 Charts / analytics (tab "Gráficos")
- Pie by category, weekly bar by day-of-week, daily by category (`Dashboards/ViewComponents/bar_chartWeek/`, `fl_chart` + `syncfusion_flutter_charts`).
- **Month Insights** (`Dashboards/ViewComponents/monthInsights/`): média diária, custo fixo vs custo variável, dias úteis vs fins de semana, dias de maior custo variável, **projeção para o mês**, custo médio por compra, dia mais caro, distribuição por dezena (1ª/2ª/3ª), mês atual vs anterior (maior aumento / maior queda), categoria mais usada.
- Period filters: dia / semana / mês / ano / **período personalizado** com data inicial e final (`Transactions/ViewComponents/PeriodType.dart`).

### 1.4 Calendar
- `table_calendar`; month grid with the expenses of each day (`Calendar/CustomCalendarScreen.dart`, `CalendarTransactions.dart`).

### 1.5 Recurring / fixed expenses
- `FixedExpense` (`RecurrentExpense/fixedExpensesModel.dart`): `repetitionType` = daily / weekly / monthly / yearly / weekdays-Mon-Fri.
- Two modes (`additionType`): **automatic** (posts itself on the scheduled date) or **suggestion** (reminds you in-app to add it).

### 1.6 Budgets / goals (tab "Orçamento")
- `GoalModel` (`Goals/GoalsModel.dart:1-4`): `categoryId` + `value` — **a monthly spending cap per category**, plus a total month budget (`totalGoalForMonth`). Progress bars against the cap.

### 1.7 Export
- **Excel (.xlsx)** and **PDF** (`exportExcel/export_toExcel.dart`, packages `excel` + `syncfusion_flutter_pdf`). Columns: Data, Categoria, Gasto, Descrição. Save locally or open the iOS share sheet. **PRO-gated.**

### 1.8 iOS home-screen widget — quick add
- Native iOS 17+ widget (`services/widget/WidgetBridge.dart`, App Group `group.com.gambit.meusgastos`, widget `MeusGastosQuickAdd`): value buttons accumulate a pending amount, tapping a category enqueues the expense; the app drains the queue on next open. Includes an undo deadline.

### 1.9 Cloud backup / multi-device sync — **PRO + Google login**
- `SyncService.syncData(String userId)` (`services/firebase/syncService.dart:23`) merges local ⇄ Firestore for expenses, fixed expenses, goals and categories; conflict resolved by `updatedAt` (most recent wins), deletes propagate as tombstones.
- **Login is Google only** (`Login/AuthenticationSingleton.dart:12,21` — `GoogleSignIn`). No Sign in with Apple, no email/password in use.

### 1.10 Works offline / no account required
- Everything persists in `SharedPreferences` first (`TransactionsRepositoryLocal`, `CategoryRepositoryLocal`, `GoalsRepositoryLocal`). Login is optional and only enables the cloud copy. de-DE description states it explicitly: *"Keine Pflichtanmeldung. Daten bleiben lokal"*.

### 1.11 Monetization
- `ProManeger` (`services/ProManeger.dart`) reads `yearly.pro` / `monthly.pro` from SharedPreferences; `in_app_purchase` monthly + yearly, **3-day free trial** (`freeTrial3Days`, `startFreeTrial`).
- PRO gates: **export to Excel/PDF**, **login + cloud sync**, "remoção de anúncios" (legacy — see NOT-list).

### 1.12 Currency + locales
- `TranslateService.formatCurrency` → `NumberFormat.simpleCurrency(locale: locale)` — **one currency, taken from the device locale**. 13 store locales live.

---

## 2. NOT-list — what the app does NOT do (as important as the list above)

| # | Does NOT do | Evidence |
|---|---|---|
| **N1** | **Does NOT split / share out / settle expenses between people.** No `paidBy`, no `sharedWith`, no `splitRatio`, no member, no group, no invite, no "who owes whom", no settle-up. | `CardModel` has no person field at all (`models/CardModel.dart:3-17`). `grep -rniE "split\|divid\|rateio\|metade\|settle\|reembols\|owe"` over `lib/` returns **only** `String.split(' ')` calls and `Divider` widgets — zero domain logic. `grep -rniE "invite\|member\|partner\|couple\|casal\|household\|group"` returns only Flutter `groupValue`/iOS **App Group** hits. |
| **N2** | **Does NOT support two people on one budget.** Every Firestore path is keyed by a single `userId`. | `GoalsRepositoryRemote.dart:14`, `CategoryRepositoryRemote.dart:23`, `FixedExpensesRepositoryRemote.dart:14`, `TransactionsRepositoryRemote` all do `.collection(userId)`. The only way two people see one list is **both signing into the same Google account** — that is account sharing / multi-device sync (§1.9), not a couples feature. |
| **N3** | **Does NOT record income.** Expenses only — no receitas / entradas / salário / Einnahmen. | No income field on `CardModel`; no negative-amount or type toggle in the value input; `grep -niE "einnahm\|income"` on `app_de.arb` → **0 hits**; `app_pt.arb` has no income key. Every "entrada" hit in source is a Dart `Map.entries` variable (`monthInsightsServices.dart:314`). |
| **N4** | **Does NOT connect to a bank / Open Finance / Pix / card statement import.** All entry is manual. | No bank SDK in `pubspec.yaml`; de-DE description says it outright: *"Keine Bankkonten-Anbindung. Datenschutz hat Vorrang."* |
| **N5** | **Does NOT scan receipts / notas fiscais (no OCR, no camera).** | No camera/OCR/ML package in `pubspec.yaml`; only `Icons.receipt_long` decorative icons. |
| **N6** | **Does NOT send notifications, reminders or budget alerts.** | **No notification package at all** in `pubspec.yaml` (no `flutter_local_notifications`). The `notifications`/`notificationsDesc` strings exist in the ARB but are **never referenced** in `SettingsScreen.dart`, and the Goals onboarding promise `getAlerts = "Receba Alertas"` has no implementation behind it. |
| **N7** | **Does NOT track debts as a payoff plan** (no snowball/avalanche, no creditor, no installments). `dividas` is only usable as a user-named category. | No debt model anywhere; `models/` holds only `CardModel`, `CategoryModel`, `ProgressIndicatorModel`. |
| **N8** | **Does NOT manage credit cards** (no card registry, no fatura close/due date, no limit, no invoice cycle). "Cartão de Crédito" is one of the 14 default **categories**, nothing more. | `app_pt.arb: creditCard = "Cartão de Crédito"` sits in the category block; no card entity in `models/`. |
| **N9** | **Does NOT do investments, savings goals, or a piggy bank.** Goals are spending **caps**, not savings targets. | `GoalModel = {categoryId, value}` (a limit per category). "Investimentos" appears only as an icon choice in the category picker (`CategoryCreater.dart:115`). |
| **N10** | **Does NOT do multi-currency or conversion.** Single currency derived from the device locale. | `TranslateService.dart:11-23`. |
| **N11** | **Does NOT do accounting / MEI / invoicing / quotes / sales** (no orçamento-cotação, no recibo, no nota, no cliente, no lucro). | No such model or screen; the app has one entity: an expense. |
| **N12** | **Is NOT a spreadsheet editor.** It **exports** to .xlsx/PDF; it does not open, edit or sync a spreadsheet. | `export_toExcel.dart` writes a file only. |
| **N13** | **Has no light mode / no theme choice — dark only.** | `main.dart:72` hardcodes `CupertinoThemeData(brightness: Brightness.dark)`; no `ThemeMode`/`darkTheme` anywhere. (The de-DE description advertising "Dunkelmodus" is accurate; it just isn't a toggle.) |
| **N14** | **No Face ID / passcode lock, no iCloud sync.** Sync is Firebase + Google login only. | No `local_auth`, no CloudKit in `pubspec.yaml`. |
| **N15** | **No ads at present.** The paywall still advertises "Remoção completa de anúncios" but no ad SDK is installed — a legacy promise. | `google_mobile_ads` absent from `pubspec.yaml`; `controllers/ads_review/` contains only `constructReview.dart` (the rating prompt). |
| **N16** | **No Sign in with Apple, no email/password login.** | `Login/AuthenticationSingleton.dart` — `GoogleSignIn` only. |
| **N17** | **No AI / automatic categorization.** Category is chosen by hand on every entry. | No AI package; `AddTransactionController` requires a category tap. |

---

## 3. Fit rules derived from this inventory

1. **Any term whose intent is "split the bill / settle up / who owes whom / in a group / with friends"** → **MISMATCH** (N1, N2). This includes the whole `dividir *`, `* juntos`, `* em grupo`, `* com amigos`, `rachar`, `a dois` family, and DE `* teilen`, `wg *`, `gemeinsame kasse`, `gemeinsames konto`.
2. **Possessive couple compositions** (`gastos do casal`, `contas casal`, `financas do casal`) → **PARTIAL, not FIT**. The searcher plausibly wants "an app where my partner and I track our household spending". Two people *can* use it by sharing one Google login (§1.9), so it is not a lie — but there is no partner feature, no split, no per-person view. Composition-feeder only; never a headline promise.
3. **Any term implying income, bank sync, receipts/OCR, alerts, debt payoff, card invoice, investments, multi-currency, or accounting** → **MISMATCH** (N3-N11).
4. **Polysemous single words** where the SERP belongs to another category → **MISMATCH or PARTIAL**, per the co-occurrence evidence in §4 below.
5. `app` is a **forbidden stopword** (lab rule) — any term is judged on its remaining words, and `app`-only compositions are marked as such.

---

## 4. Audit of the LIVE field tokens against this inventory

The fit gate applied to the tokens the app is paying for **right now** (45.2.0).

### pt-BR — keywords `compartilhados,contas,minhas,economias,planilha,orcamento,diario,cartao,dividas,fatura,mensais`

| Live token | Verdict | Why |
|---|---|---|
| `compartilhados` | PARTIAL | Shared visibility yes, shared attribution no (N1) |
| `contas` | PARTIAL | Bank pool + bills-with-due-dates pool; we log bills as expenses only |
| `minhas` | PARTIAL | Possessive qualifier; also feeds `minhas economias` (competitor brand) |
| `economias` | PARTIAL | Savings/piggy-bank pool; app has no savings (N9) |
| **`planilha`** | **MISMATCH** | SERP verified: 7/10 are spreadsheet editors (N12) |
| `orcamento` | PARTIAL | Budget vs quote/estimate ambiguity in pt-BR |
| **`diario`** | **MISMATCH** | Unqualified pool is personal diary / period calendar |
| **`cartao`** | **MISMATCH** | Card invoice/limit management not delivered (N8) |
| **`dividas`** | **MISMATCH** | No debt tracking (N7) |
| **`fatura`** | **MISMATCH** | No card invoice (N8) |
| `mensais` | FIT (in composition) | Monthly framing is the app's default |

**5 of 11 live pt-BR keyword tokens are MISMATCH; 5 are PARTIAL. Not one is an unqualified FIT.**
Name `Meus Gastos: Casal e Despesas` — `Gastos`/`Despesas` FIT, `Casal` PARTIAL at best (metadata-only, §0).

### de-DE — keywords `kosten,sparen,geld,konto,finanzen,planer,monatsbudget,bilanz,haushalt,einkauf,fixkosten,einnahmen`

| Live token | Verdict | Why |
|---|---|---|
| `kosten` | FIT | Expense logging |
| **`sparen`** | **MISMATCH** | Savings targets not delivered (N9) |
| **`geld`** | **MISMATCH** | Too generic, wrong pool |
| **`konto`** | **MISMATCH** | Bank account (N4) |
| **`finanzen`** | **MISMATCH** | Bank/broker pool (Revolut/N26/ETF) |
| **`planer`** | **MISMATCH** | Generic planner pool |
| `monatsbudget` | FIT | Monthly budget cap |
| **`bilanz`** | **MISMATCH** | Balance needs income (N3) |
| **`haushalt`** | **MISMATCH** | Cleaning/chores pool (putzplan) |
| **`einkauf`** | **MISMATCH** | Supermarket pool (Edeka/Rewe/Aldi) |
| `fixkosten` | FIT | Recurring expenses |
| **`einnahmen`** | **MISMATCH** | No income tracking (N3) |

**8 of 12 live de-DE keyword tokens are MISMATCH.** Only `kosten`, `monatsbudget`, `fixkosten` are FIT.
Subtitle `Budget & Finanzen verwalten` — `Budget` FIT, `Finanzen` MISMATCH. Name `Ausgaben - Haushaltsbuch` — both FIT.
