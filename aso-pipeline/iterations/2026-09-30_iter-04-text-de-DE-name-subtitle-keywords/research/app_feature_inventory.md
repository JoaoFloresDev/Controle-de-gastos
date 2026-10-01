# App feature inventory — Meus Gastos / My Expenses: Personal Finances

Stage 3, first half. **Nothing here is judged as a keyword yet** — this is the ground truth the term verdicts will be measured against.

| | |
|---|---|
| App Store ID | `6502218501` · bundle `com.gambit.meusgastos` · Finance |
| Stack | **Flutter** (not SwiftUI) — `pubspec.yaml`, 32 app locales, Cupertino widgets |
| Source read | `/Users/joaoflores/Documents/GambitStudio/Apps/intermediate/Controle-de-gastos/meus_gastos` (working tree = `45.4.0+41`, `pubspec.yaml:5`) |
| Live iOS | **45.3.1** (`research/asc_state.json > live_ios_version`) — diffed against tag `release/45.3.1`; **no inventory-relevant feature differs** between live iOS and the working tree (only desktop shell, ReviewPrompt, analytics renames and l10n) |
| Live macOS | **45.4.0** READY_FOR_SALE (`asc_state.json > macos_versions_summary`) — the Mac build is one minor AHEAD of iOS |
| Store localizations | **29** (`asc_state.json > localizations`), primary `en-US` |
| Platforms | iOS + macOS universal; the repo also carries android/web/linux/windows folders, not shipped |

Sources, in order: (1) Dart/Swift source, (2) the 29 live store descriptions in `research/asc_state.json`, (3) the app's own `lib/l10n/app_*.arb` UI strings.

---

## 0. Verdict on the two open questions from iter-03

### 0.1 Couple / shared ledger — **iter-03 CONFIRMED. The app has no couple, shared or split feature of any kind.**

| Check | Result |
|---|---|
| `grep -rni "couple\|casal\|split\|dividir\|partner\|compartilh" lib --include='*.dart'` (excluding `lib/l10n/`) | **2 hits, both false positives**: `exportExcelScreen.dart:199` `String.split(' ')` on a date, `MonthInsightsScreen.dart:94` `phrase.split(':')`. **Zero domain logic.** |
| `CardModel` fields (`lib/models/CardModel.dart:3-17`) | `id, amount, description, date, category, idFixoControl, updatedAt, deleted`. **No `paidBy`, no `owner`, no `sharedWith`, no `splitRatio`, no person at all.** |
| Firestore layout | Every remote repository writes under a single uid: `TransactionsRepositoryRemote.dart:19-21` `.collection(userId).doc('NormalCards').collection('cardList')`; same shape in `GoalsRepositoryRemote`, `CategoryRepositoryRemote`, `FixedExpensesRepositoryRemote`. **No shared document, no group, no invite, no membership.** |
| Auth | `Login/AuthenticationSingleton.dart:12,19` — **Google Sign-In only**. There is no way to connect two identities. |

**The only way two people see one list is both signing into the same Google account.** That is account sharing, not a product feature. The pt-BR subtitle **"Finanças do casal e pessoais"** and the pt-BR keyword **`compartilhados`** are therefore selling a feature that does not exist. ("Casal" was already removed from the pt-BR *name* in commit `1c87ff9 aso: tira 'casal' do nome em pt-BR`; the subtitle was not.)

### 0.2 Income / receita / Einnahmen — **iter-03 CONFIRMED. The app records expenses only.**

| Check | Result |
|---|---|
| `grep -rni "income\|receita\|revenue\|earning\|salary" lib --include='*.dart'` (ex-l10n) | **1 hit**, and it is a code comment in `services/ReviewPrompt.dart:7`. Zero income logic. |
| `CardModel.amount` (`models/CardModel.dart:5`) | a bare `double`. There is **no `type`, no `isIncome`, no sign toggle**. |
| Amount input | `AddTransaction/UIComponents/Header/ValorTextField.dart:11` uses `MoneyMaskedTextController`; `AddTransactionController.dart:169,179` reads `header.valorController.numberValue` — a money mask that cannot produce a negative value. **No income workaround.** |
| Aggregations | `DashbordService.dart:36,99` only ever `totals[...] += card.amount`; `GoalsScreen` compares `spent > goal`. **Nothing anywhere computes income − expense.** |
| Store text | **No locale, in any of the 29, mentions income** (scanned for `einnahm·receita·ingreso·income·収入·revenu·수입` → zero hits in descriptions/subtitles). |

So: dropping `einnahmen` from the German keywords in iter-03 was correct, and **`ingreso` still sitting in the live es-ES keyword field is the same error, unfixed** (`asc_state.json > es-ES.keywords`). Likewise it-IT's name **"Spese - Bilancio Personale"** and de-DE's old `bilanz` promise a balance sheet, which needs income.

---

## 1. What the app DOES — feature by feature, with proof

### 1.1 Shell: 5 tabs (mobile) / sidebar (Mac)
`lib/main.dart:228-234` `_tabScreenNames = ['add_transaction','transactions','dashboards','goals','settings']`, rendered by `_buildContent` (`main.dart:388-414`).

| Tab | en | de | pt | Screen |
|---|---|---|---|---|
| 1 | Add | Ausgabe hinzufügen | Inserir Despesa | `AddTransactionController` |
| 2 | Transactions | Transaktionen | Transações | `TransactionsScrean` |
| 3 | **Charts** (`dashboards` key = "Charts") | Diagramme | Graficos | `DashboardScreen` |
| 4 | **Goal** (`budget` key = "Goal") | Ziel | **Orçamento** | `Goalsscrean` |
| 5 | Settings | Einstellungen | Configurações | `SettingsScreenCompact` |

**macOS-only**: left `DesktopSidebar` instead of a tab bar, `⌘1..⌘5 / ⌘N / ⌘,` shortcuts (`designSystem/Desktop/DesktopShortcuts.dart:36-55`), window min size 940×640 (`main.dart:48`, `macos/Runner/MainFlutterWindow.swift:41`), content column capped at 1120 pt (`main.dart:246`).

### 1.2 Logging an expense — the core job
Manual entry of **amount, category, date/time, description** (`AddTransactionController.dart:169-180` builds a `CardModel`). Masked currency field + quick-value buttons (`UIComponents/Header/QuickValueButton.dart`, `ValorTextField.dart`), category as a horizontal circle list (`VerticalCircleList.dart`), confirmation toast (`AddedExpenseToast.dart`). Saving is the declared aha-moment (`services/ReviewPrompt.dart:20-22`, trigger `expense_saved`).
**No OCR, no camera, no voice, no bank import, no AI categorisation** — see NOT-list.

### 1.3 Categories
- **14 built-in** + the synthetic `AddCategory` "+" tile: Shopping, Home, Transport, Restaurant, Hospital, GasStation, fun, ShoppingBasket, CreditCard, Education, Phone, Movie, VideoGame, Unknown (`services/CategoryService.dart:58-165`). *The de/fr/ja descriptions' claim of "14 Standard-Kategorien / 14 catégories / 14種類" is **accurate**.*
- **User-created categories** with free name, icon from a picker and custom colour (`CategoryCreater/CategoryCreater.dart`, `Components/ColorGridSelector.dart`, `CategoryModel{id,color,icon,name,frequency,available}`), reorderable and hideable (`CategoryService.saveOrderedCategories:50`, `available` flag). Reached from Settings → Categories.
- Built-in names are localised at render time by `TranslateService.getTranslatedCategoryName` (`services/TranslateService.dart:82-128`).

### 1.4 Transactions list + period filter
`TransactionsScreen.dart` — list grouped by day (`_buildDayHeader:406`), with today/yesterday labels, swipe to detail/edit/delete (`CardDetails/DetailScreen.dart`), and recurring items shown inline (`ViewComponents/ListCardRecorrent.dart`).
**Period filter**: day / week / month / year / **custom range with start+end date** (`ViewComponents/PeriodType.dart:8` enum + `:240-276` the picker).

### 1.5 Calendar — **live, but not where iter-03 said**
A **segmented toggle inside the Transactions tab**: `Transactions ⇄ Calendar` (`TransactionsScreen.dart:252-320`, `calendarView` flag at `:45`). When on, it renders `CalendarTable` (package `table_calendar`) + `CalendarHeader` (day total via `TranslateService.formatCurrency`) + `TransactionList` of the selected day (`TransactionsScreen.dart:168-192`).
**Correction to iter-03**: `controllers/Calendar/CustomCalendarScreen.dart` is **dead code** — `grep -rn "CustomCalendar("` finds no instantiation, and the calendar tab is commented out in the tab bar (`main.dart:482`). The feature is real; the file iter-03 cited is not the one that runs.

### 1.6 Charts tab ("Gráficos" / "Diagramme")
Header "My Control / Mein Haushaltsbuch / Meu Controle" (`DashboardScreenRefatore.dart:350`). Month selector (`ViewComponents/MonthSelector.dart`), then a swipeable 3-page chart deck (`:168-205`):
1. **Pie by category** (`DashboardCard.dart`, `fl_chart`)
2. **Weekly stacked bars** (`bar_chartWeek/BarChartWeek.dart`, `syncfusion_flutter_charts`) — last 5 weeks (`DashbordService.getLast5WeeksIntervals:64`)
3. **Daily stacked bars by day of week** (`bar_chartWeek/BarChartDaysofWeek.dart`)

Plus **total spent** (`:329`), **top expenses of the month** as progress bars (`:243-275`), and **Monthly Insights** (`ViewComponents/monthInsights/MonthInsightsViewModel.dart:157-206`): daily average, fixed vs variable cost split, weekdays vs weekends, biggest-variable-cost days, **end-of-month projection**, average cost per purchase, most expensive day, 1st/2nd/3rd ten-day distribution, current vs previous month (biggest rise / biggest drop), most-used category.

### 1.7 Fixed / recurring expenses
`FixedExpense{id, description, price, date, category, repetitionType, additionType}` (`RecurrentExpense/fixedExpensesModel.dart:3-20`).
- **Repetition**: daily · weekly · monthly · yearly · **Mon–Fri weekdays** (`UI/RepetitionMenu.dart:47-67`, logic in `UI/intervalsControl.dart`).
- **Two modes** (`fixedExpensesModel.dart:47-48`): `automatic` — posts itself when due (`TransactionsScreen.dart:338-343` calls `Intervalscontrol().IsapresentetionNecessary` and auto-adds); `suggestion` — shown in-app as a pending card to confirm. Picked in `UI/AdditionTypeSelector.dart`.
- Managed from Settings → "Fixed Expenses / Fixkosten / Gastos fixos" (`SettingsScreen.dart:302-307`).

### 1.8 Budget / goal per category (tab 4)
`GoalModel{categoryId, value}` (`Goals/GoalsModel.dart:1-5`) — **a monthly spending cap per category**, plus a **total month budget** (`GoalsScreen.dart:299` `totalGoalForMonth`), rendered as circular/linear progress (`percent_indicator`).
**Over-budget is signalled visually only**: `GoalsScreen.dart:349` `isOverGoal = spent > goal && goal > 0` and `viewModel.totalExpenseIsOverGoal()` flip the bar/label colour (`:255,265,288,413,475`). There is **no "approaching the limit" threshold and no notification** — see N6.

### 1.9 Export
`exportExcel/exportExcelScreen.dart` — a segmented control with **Excel (.xlsx)**, **PDF**, **plain text** (`:78-104`), then the **iOS/macOS share sheet** (`Share.shareXFiles`, `:163,176`); `export_toExcel.dart:63,140` also offers **save to a folder you pick** (`FilePicker.getDirectoryPath`). Columns: Date, Category, Expense, Description (`columnDate/columnCategory/columnExpense/columnDescription`).
Reachable from the Charts tab share icon (`DashboardScreenRefatore.dart:360-371`) and from the per-category extract (`ExtractByCategory.dart:95`).
**Correction to iter-03: export is NOT PRO-gated.** `grep -rn "isPro"` returns zero hits in `exportExcel/`, `ExtractByCategory/` or `Dashboards/`, in the working tree **and** in `git show release/45.3.1`. The paywall still *advertises* it as a PRO benefit (`ProModal.dart:302` `l.exportToExcelOrPdf`) — that is a stale paywall promise, not a gate.

### 1.10 Extract by category
Tap a category in the Charts tab → full statement of that category's expenses, with its own export entry point (`ExtractByCategory/ExtractByCategory.dart`, opened at `DashboardScreenRefatore.dart:314`).

### 1.11 Cloud backup / multi-device sync — **the only real PRO feature**
`services/firebase/syncService.dart:23 syncData(String userId)` merges local ⇄ Firestore for **expenses, fixed expenses, goals and categories**; conflicts resolved by `updatedAt` (most recent wins, `CardModel.dart:11-17`), deletions propagate as tombstones (`deleted` flag). Result is written back to local too (`:57-62`).
Gated: Settings → Backup & Sync checks `proVM.isPro` first (`SettingsScreen.dart:344-347`), and the login row sends non-subscribers straight to the paywall (`LoginRoute.dart:22-27`, `LoginButtonScrean.dart:30`).

### 1.12 Offline-first, no account required
Every repository is local-first on `SharedPreferences` (`TransactionsRepositoryLocal`, `CategoryRepositoryLocal`, `GoalsRepositoryLocal`, `FixedExpensesRepositoryLocal`); the remote one is only selected when logged in (`TransactionsRepositorySelector.dart:14-15`). **The app is fully usable with no account and no network.**

### 1.13 iOS home-screen widget — interactive quick add
Native target `ios/MeusGastosQuickAdd/` (Swift, WidgetKit + AppIntents):
- `QuickAddWidget.swift:275` `.supportedFamilies([.systemMedium, .systemLarge])` — **home screen only, no Lock Screen / accessory family**, `StaticConfiguration` (`:270`).
- **Interactive, iOS 17+**: `WidgetIntents.swift` ships `AddAmountIntent`, `ClearAmountIntent`, `UndoIntent`, `AddExpenseIntent` — amount buttons accumulate a pending total, tapping a category enqueues `{categoryId, amount, date}`.
- Bridge: App Group `group.com.gambit.meusgastos`; the app mirrors up to 12 categories + the currency symbol out (`services/widget/WidgetBridge.dart:72-95`) and **drains the queue on launch and on every resume** (`services/widget/WidgetSyncHost.dart:39-58`).
- **iOS/Android only — `WidgetBridge.isSupported` excludes macOS** (`WidgetBridge.dart:58`). **There is no Mac widget and no Apple Watch app.**

### 1.14 Currency
Derived from the **device locale**, never chosen: `TranslateService.getCurrencySymbol/formatCurrency` → `NumberFormat.simpleCurrency(locale: Localizations.localeOf(context))` (`services/TranslateService.dart:7-26`). **One currency, no picker, no conversion, no FX.**

### 1.15 Monetisation
- `in_app_purchase` (StoreKit, not RevenueCat), **monthly + yearly**, yearly carries the "best value" badge and a per-month breakdown (`Purchase/ProModal.dart:316-336`); **3-day free trial** labelled on both cards (`:588` `freeTrial3Days`).
- Entitlement is a local flag: `ProManeger` reads `yearly.pro` / `monthly.pro` from `SharedPreferences` (`services/ProManeger.dart:9-16`). Restore purchases in the paywall footer.
- **Paywall position: right after onboarding** (`main.dart:155-168` `_finishOnboarding` → `ProModal` → home) and from Settings / any sync tap.
- **Paywall advertises three benefits** (`ProModal.dart:300-308`): Export to Excel or PDF · Cloud Backup · **Ad-free**. Of these, **only Cloud Backup is actually gated**; export is free (§1.9) and **there are no ads at all** (§N15).

### 1.16 Onboarding, review prompt, analytics
- 3-page onboarding, keys `onboardingTrack* / onboardingCharts* / onboardingGoals*` (`Onboarding/OnboardingScreen.dart:35-48`), persisted as `hasSeenOnboarding`.
- **Native review prompt only, no pre-prompt** (`services/ReviewPrompt.dart`, lab template), fired at `expense_saved`, ≥3 aha-moments.
- Firebase Analytics + Crashlytics, canonical taxonomy (`services/AnalyticsService.dart`: `core_action`, `transaction_add`, `goal_set`, `export_share`, `paywall_shown`, `purchase_*`, `onboarding_*`).

### 1.17 Theme
**Dark only, hardcoded** — `CupertinoApp(theme: CupertinoThemeData(brightness: Brightness.dark))` (`main.dart:95`), background `0xFF0D1117` (`main.dart:321,334`). No toggle, no light palette.

---

## 2. NOT-list — verified absences

Each line is an *observed* absence (grep over `lib/`, `ios/`, `macos/`, `pubspec.yaml`), not an assumption.

| # | The app does NOT | Proof of absence |
|---|---|---|
| **N1** | **Split, share, settle or attribute an expense to a person.** No couple, partner, group, roommate, "who owes whom", settle-up. | §0.1. `CardModel` has no person field; the only `split`/`compartilh` hits in `lib/` are `String.split()`. |
| **N2** | **Let two accounts share one ledger.** | §0.1. Every Firestore path is `.collection(userId)`; Google Sign-In only; no invite/member/group code anywhere. |
| **N3** | **Record income, salary, balance or net worth.** | §0.2. No type field, money mask can't go negative, zero income strings in 32 ARB files, zero income mentions in 29 store descriptions. |
| **N4** | **Connect to a bank / Open Banking / Pix / card statement import.** | No bank SDK in `pubspec.yaml`. The de/fr/ja descriptions say so explicitly: *"Keine Bankkonten-Anbindung"*, *"Aucune connexion bancaire"*, *"銀行口座連携なし"*. |
| **N5** | **Scan receipts (OCR), photograph a bill, or use the camera.** | No camera/OCR/ML package in `pubspec.yaml`. `NSPhotoLibraryUsageDescription` sits in `ios/Runner/Info.plist:47` with **no code path that uses it** (no `image_picker`, no `PHPicker` call in Dart). |
| **N6** | **Send any notification, reminder or budget alert.** | **No notification package in `pubspec.yaml`** (no `flutter_local_notifications`, no `firebase_messaging`); **zero `UNUserNotification` / `requestAuthorization` in `ios/Runner` or `macos/Runner`**; the `notifications`/`notificationsDesc`/`getAlerts`/`getAlertsDescription` ARB keys are **never referenced** by any Dart file; there is no Notifications row in `SettingsScreen`. Over-budget is a **colour change only** (§1.8), and only *after* the cap is passed. |
| **N7** | **Track debts as a payoff plan** (snowball/avalanche, creditor, instalments). | `models/` holds only `CardModel`, `CategoryModel`, `ProgressIndicatorModel`. No debt entity. |
| **N8** | **Manage credit cards** (card registry, statement/fatura cycle, due date, limit). | `creditCard` is one of the 14 default **categories** (`CategoryService.dart`), nothing more. No card entity. |
| **N9** | **Savings goals, investments, piggy bank, net-worth growth.** | `GoalModel = {categoryId, value}` is a spending **cap**, compared with `spent > goal`. There is no target-to-reach, no deposit, no portfolio. |
| **N10** | **Multi-currency or conversion.** | `TranslateService.dart:7-26` — one symbol from the device locale, no picker, no rate source. |
| **N11** | **Accounting / MEI / invoicing / quotes / clients / profit.** | One domain entity: an expense. No such screen or model. |
| **N12** | **Edit or sync a spreadsheet.** | `export_toExcel.dart` **writes** a file; nothing reads or opens one. |
| **N13** | **Offer a light mode or any theme choice.** | `main.dart:95` hardcodes dark. (So "dark mode" in the de/fr/ja/ko/zh descriptions is true as a *fact*, false as a *setting*.) |
| **N14** | **Face ID / passcode lock, or iCloud sync.** | No `local_auth`, no CloudKit entitlement (`macos/Runner/Release.entitlements` has only sandbox/network/files/print). Sync is Firebase + Google only. |
| **N15** | **Show ads.** | No ad SDK anywhere in `pubspec.yaml`; `grep -rni "admob\|google_mobile_ads\|GADBanner\|interstitial"` over `lib/`, `ios/Runner`, `pubspec.yaml` → **zero hits**. The paywall's "Ad-free" row (`ProModal.dart:304`) and `proDescription` ("no ads / sem anúncios / werbefrei") are **legacy copy with nothing behind them**. |
| **N16** | **Sign in with Apple, or email/password login.** | `Login/AuthenticationSingleton.dart:12,19` — `GoogleSignIn` only; `LoginScrean.dart` lost its email form in the 45.4.0 diff. |
| **N17** | **Auto-categorise or suggest a category with AI.** | No AI package; a category tap is required on every entry. |
| **N18** | **Multiple accounts / wallets / cash-vs-card separation.** | No account entity; the only `wallet` hits in `lib/` are the `Icons.account_balance_wallet` glyph in the category icon picker and the onboarding illustration. |
| **N19** | **Ship a Mac widget, an Apple Watch app, Shortcuts/Siri (beyond the widget's own intents), or Live Activities.** | `WidgetBridge.isSupported` is iOS/Android only (`WidgetBridge.dart:58`); no watch target in `ios/`; no `AppShortcutsProvider`, no ActivityKit. |
| **N20** | **Store anything on a Lock Screen widget.** | `QuickAddWidget.swift:275` — `.systemMedium` and `.systemLarge` only. |

---

## 3. UI vocabulary by language (Tier A) — what the user actually SEES

Pulled from `lib/l10n/app_<lang>.arb`. **A term in this table is a term the product owns; a term that exists only in the store description is an argument, not evidence.**

| Concept (key) | en-US | de-DE | pt-BR | fr-FR | ja | es-ES |
|---|---|---|---|---|---|---|
| app title (`myExpenses`) | My Expenses | **Meine Ausgaben** | Minhas Despesas | Mes Dépenses | **支出管理** | Mis Gastos |
| add expense (`addExpense`) | Add Expense | **Ausgabe hinzufügen** | Inserir Despesa | Ajouter une dépense | 支出を追加 | Agregar Gasto |
| register (`registerExpense`) | Register Expense | Ausgabe erfassen | Registrar Despesa | Enregistrer la dépense | **支出を記録** | Registrar gasto |
| transactions (`transactions`) | Transactions | **Transaktionen** | Transações | Transactions | **取引** | Transacciones |
| category (`category`/`categories`) | Category / Categories | **Kategorie / Kategorien** | Categoria / Categorias | Catégorie / Catégories | **カテゴリ** | Categoría / Categorías |
| budget tab (`budget`) | *Goal* | **Ziel** | **Orçamento** | *Objectif* | **目標** | **Presupuesto** |
| month budget (`totalGoalForMonth`) | Total budget for a month | **Monatsbudget gesamt** | Orçamento total do mês | Budget total du mois | **今月の予算** | Presupuesto total para un mes |
| charts tab (`dashboards`) | *Charts* | **Diagramme** | **Graficos** | Graphiques | **グラフ** | **Gráficos** |
| home header (`myControl`) | My Control | **Mein Haushaltsbuch** | Meu Controle | Mon budget | **家計管理** | Mi Control |
| fixed expenses (`fixedExpenses`) | Fixed Expenses | **Fixkosten** | **Gastos fixos** | Dépenses fixes | **固定費** | Gastos fijos |
| recurring (`recurringExpenses`) | Recurring Expenses | **Wiederkehrende Ausgaben** | Gastos Recorrentes | Dépenses récurrentes | **定期支出** | Gastos Recurrentes |
| total spent (`totalSpent`) | Total spent | **Gesamtausgaben** | Total gasto | Total dépensé | **支出合計** | Total gastado |
| month by category (`expensesOfTheMonth`) | Expenses of the Month by Category | Monatsausgaben nach Kategorie | Gastos do Mês por Categoria | Dépenses du mois par catégorie | 今月のカテゴリ別支出 | Gastos del Mes por Categoría |
| export (`export`) | Export to Excel | Nach Excel exportieren | Exportar para Excel | Exporter vers Excel | **Excelに書き出し** | Exportar a Excel |
| calendar (`calendar`) | Calendar | **Kalender** | **Calendário** | Calendrier | **カレンダー** | Calendario |
| backup/sync (`backupSync`) | Backup & Sync | **Backup & Sync** | Backup & sincronização | Sauvegarde & Sync | **バックアップと同期** | Copia de seguridad y sincronización |
| insights (`monthlyInsights`) | Monthly insights | Monats-Insights | Insights do mês | Aperçu du mois | 月のインサイト | Insights del mes |
| account/wallet | — | — | — | — | — | — |
| balance | — | — | — | — | — | — |

Three things worth flagging:

1. **de-DE: the product itself says "Haushaltsbuch"** (`myControl` = *Mein Haushaltsbuch*) and **"Fixkosten"**, **"Gesamtausgaben"**, **"Wiederkehrende Ausgaben"**, **"Monatsbudget"**. Those are owned words. The German tab 4 is **"Ziel"**, not "Budget" — "Budget" appears only inside `Monatsbudget gesamt`.
2. **"Account" and "balance" have no UI string in any language** — matching N18/N3.
3. `repeat` is mistranslated in two locales: pt = `"Gastos Fixos"` (should be "Repetir") and **es = `"Apelante"`** (= *appellant*, a legal term — a machine-translation accident, `app_es.arb`).

### Catalogue coverage vs. the 29 store locales

- The app ships **32 locales** (`main.dart:107-141`): en pt es zh ja ko de fr it tr ar id ru hi nl pl vi th ms sv da nb fi uk el he cs hu ro sk hr ca.
- **All 29 store localizations are covered** (store `no` → app `nb`, store `es-MX` → app `es`, store `nl-NL` → app `nl`, store `ar-SA` → app `ar`, store `zh-Hans` → app `zh`). The app additionally ships `ro, sk, hr, ca` with no store page.
- **Coverage is complete except for the paywall**: 9 locales — **de, fr, ja, ar, id, it, ko, tr, zh** — are **missing the 7 newest keys** (`unlockPremium, bestValue, perMonthShort, planYearly, planMonthly, freeTrial3Days, startFreeTrial`) and fall back to **English**. So a German user sees *"Unlock Premium / Yearly / 3 days free / Start Free Trial"* in English on the paywall. Every other key is translated in all 32.
- Residual English strings outside the paywall: fr 12, de 10, ca 8, ro 8, sv 8, nl 6, da 6, es 6 (mostly `Excel`, `PDF`, `Wi-Fi`, `Total`, `OK` — legitimate) .

---

## 4. Delivery gaps by locale

Scanned all 29 live descriptions + subtitles in `research/asc_state.json`.

### 4.1 Cheap wins — features the app HAS and the locale never mentions

| Feature | Locales where the description is **silent** |
|---|---|
| **Home-screen widget (quick add)** | **20 of 29** — missing from **de-DE, pt-BR, fr-FR, ja, en-US, es-ES, es-MX** (the entire Tier A) and ar-SA, da, he, hi, id, it, ko, th, tr, uk, zh-Hans, no(partial), ms(partial). Mentioned only in cs, el, fi, hu, ms, nl-NL, no, pl, ru, sv, vi. |
| **Excel/PDF export** | **en-US, pt-BR, es-ES, es-MX** — the four locales still on the old 2024 description. Present in the other 25. |
| **Fixed / recurring expenses** | **22 of 29**, including **en-US, pt-BR, es-ES, es-MX**. Explicit only in de-DE, id, ja, ms, nl-NL, tr, zh-Hans (and implicitly fr-FR). |
| **Cloud backup / multi-device sync (the PRO feature)** | **en-US, pt-BR, es-ES, es-MX**, plus ar-SA, da, fi, he, hi, hu, ms, no, sv, th, vi. |
| **Monthly insights / end-of-month projection** | absent from ~20 locales. |
| **Custom period filter (day/week/month/year/custom range)** | **absent from all 29.** Nobody sells it. |
| **Category statement (extract by category)** | **absent from all 29.** |
| **macOS app** | **absent from all 29 iOS descriptions** even though the Mac build is live at 45.4.0. |
| **Offline / no sign-up required** | present in de-DE, fr-FR, ja and most of the newer locales; **absent from en-US, pt-BR, es-ES, es-MX**. |

The split is systematic: **de-DE, fr-FR, ja, it, ko, zh-Hans, nl-NL, id, tr** got a modern rewritten description; **en-US, pt-BR, es-ES, es-MX** are still the 2024 marketing text and under-sell the product badly (no export, no sync, no fixed expenses, no widget).

### 4.2 Promises the app does NOT keep — frustrated-install and 2.3.1 risk

| Risk | Locales | The claim | Reality |
|---|---|---|---|
| **HIGH — budget notification** | **de-DE, fr-FR, it, ja, ko** | de: *"Budget-Warnungen: … Beim Annähern bekommst du **Bescheid**"* · fr: *"Alertes de budget … on te **prévient avant le dépassement**"* · it: *"ti **notifichiamo** quando ti avvicini"* · ja: *"予算アラート … 近づくと**通知でお知らせ**"* · ko: *"예산 알림 … 가까워질 때 **알려줍니다**"* | **N6: the app cannot notify anything.** No notification framework at all. The only signal is a colour change in the Goals tab, and only *after* the cap is exceeded. This is a direct, repeated, translated false promise in 5 locales. |
| **HIGH — "100% free"** | **cs, el, fi, hi, hu, nl-NL, sv, vi** (hard claim: *"100% zdarma / 100% Δωρεάν / 100 % ilmainen / 100% मुफ़्त / 100%-ban ingyenes / 100% gratis / 100 % gratis / hoàn toàn miễn phí"*) + softer *"free app / download free"* in **da, ms, no, ru** | The app opens a **monthly+yearly paywall immediately after onboarding** (`main.dart:155-168`) and gates sync behind it. | "100% free" next to a subscription is the classic 2.3.1 trigger and reads as bait to the user. |
| **MEDIUM — couple / shared** | **pt-BR** | subtitle *"Finanças do **casal** e pessoais"* + keyword `compartilhados` | **N1/N2: no couple, no sharing, no split.** Also the only locale whose description mentions nothing of the sort — the promise lives entirely in the subtitle. |
| **MEDIUM — income / balance** | **es-ES, es-MX** (keyword `ingreso`), **it** (name *"Spese - **Bilancio** Personale"*), **ko** (subtitle *"**자산 추적**"* = asset tracking) | income, balance sheet, asset tracking | **N3/N9/N18.** None exists. |
| **LOW — "dark mode" as a feature** | de-DE, fr-FR, ja, ko, zh-Hans | *"Dunkelmodus / Mode sombre / ダークモード対応"* | True as a fact (the app is dark), false as a choice (N13). Harmless. |
| **DEFECT — en-US description tail** | **en-US** | The live description ends: `…dev/stdeula/` **`Tentar novamenteO Claude pode cometer erros. Confira sempre as respostas.`** | Leaked chat-UI text pasted into the live store listing of the **primary locale**. Must be cleaned regardless of this iteration. |
| **DEFECT — pt-BR language mixing** | **pt-BR** | *"nunca mais perca o controle das suas **expenses**"*, *"Organize suas **finance**"*, *"aumentar suas **minhas economias**"* | Untranslated English words and a broken phrase in the live pt-BR description. |

### 4.3 In-app promise that the app doesn't keep (not store metadata, but same family)
The paywall sells three benefits (`ProModal.dart:300-308`): **Export to Excel or PDF** (actually free — §1.9), **Cloud Backup** (real), **Ad-free** (there are no ads at all — N15). Two of the three reasons to pay are fiction. Noted here because it affects what the store page can honestly claim about "Premium".

---

## 5. One-paragraph summary for the fit gate

**Meus Gastos is a solo, manual, offline-first expense logger with categories, fixed/recurring expenses, per-category monthly spending caps, a calendar view, a charts tab with monthly insights, Excel/PDF/text export, and an interactive iOS home-screen quick-add widget; its only paid feature is Google-login cloud backup and multi-device sync; it is iOS + macOS, dark-only, one device-derived currency.** It does **not** do income, balance, bank sync, receipts/OCR, notifications or alerts of any kind, debt payoff, credit-card invoices, savings/investments, multi-currency, accounting, accounts/wallets, biometric lock, or anything shared between two people.
