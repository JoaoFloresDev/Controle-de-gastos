import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @myExpenses.
  ///
  /// In en, this message translates to:
  /// **'My Expenses'**
  String get myExpenses;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get chooseColor;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get createCategory;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @registerExpense.
  ///
  /// In en, this message translates to:
  /// **'Register Expense'**
  String get registerExpense;

  /// No description provided for @dateHour.
  ///
  /// In en, this message translates to:
  /// **'Date and Time'**
  String get dateHour;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// No description provided for @myControl.
  ///
  /// In en, this message translates to:
  /// **'My Control'**
  String get myControl;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @expensesOfTheMonth.
  ///
  /// In en, this message translates to:
  /// **'Expenses of the Month by Category'**
  String get expensesOfTheMonth;

  /// No description provided for @topExpensesOfTheMonth.
  ///
  /// In en, this message translates to:
  /// **'Top Expenses of the Month'**
  String get topExpensesOfTheMonth;

  /// No description provided for @addNewTransactions.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount, select the category, and tap \'Add\' to record your transaction'**
  String get addNewTransactions;

  /// No description provided for @addNewCallToAction.
  ///
  /// In en, this message translates to:
  /// **'We will structure your expenses so you can take control'**
  String get addNewCallToAction;

  /// No description provided for @youWillBeAbleToUnderstandYourExpensesHere.
  ///
  /// In en, this message translates to:
  /// **'You will be able to understand\n your expenses here'**
  String get youWillBeAbleToUnderstandYourExpensesHere;

  /// No description provided for @dailyExpensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Daily Expenses by Category'**
  String get dailyExpensesByCategory;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tues'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednes'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thurs'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Satur'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @weeklyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Weekly Expenses by Category'**
  String get weeklyExpenses;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get shopping;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @gasStation.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get gasStation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @shoppingBasket.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shoppingBasket;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get hospital;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @movie.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movie;

  /// No description provided for @videoGame.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get videoGame;

  /// No description provided for @fun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get fun;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wifi'**
  String get wifi;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'HH:mm MM/dd/yyyy'**
  String get dateFormat;

  /// No description provided for @resumeDateFormat.
  ///
  /// In en, this message translates to:
  /// **'MM/dd'**
  String get resumeDateFormat;

  /// No description provided for @noExpensesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No expenses this week'**
  String get noExpensesThisWeek;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @textExport.
  ///
  /// In en, this message translates to:
  /// **'Click on the button below to export your data to an Excel spreadsheet or PDF file.'**
  String get textExport;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveLocally.
  ///
  /// In en, this message translates to:
  /// **'Save Locally'**
  String get saveLocally;

  /// No description provided for @shareMensage.
  ///
  /// In en, this message translates to:
  /// **'Discover the best app for personal expense tracking'**
  String get shareMensage;

  /// No description provided for @valueTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you enter the value of your expense.'**
  String get valueTutorial;

  /// No description provided for @dateTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you enter the date when your expense was made.'**
  String get dateTutorial;

  /// No description provided for @commentTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you add comments about your expense.'**
  String get commentTutorial;

  /// No description provided for @categoryTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you select the category for your expense.'**
  String get categoryTutorial;

  /// No description provided for @addExpenseTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you add your expense to the monthly list.'**
  String get addExpenseTutorial;

  /// No description provided for @cardsTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here are your expense cards. You can edit them after adding.'**
  String get cardsTutorial;

  /// No description provided for @exportTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you can export your expenses to an Excel sheet or PDF file.'**
  String get exportTutorial;

  /// No description provided for @graphicsTutorial.
  ///
  /// In en, this message translates to:
  /// **'Here you can view graphics of your expenses by month, week, or day'**
  String get graphicsTutorial;

  /// No description provided for @pieGraphPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'See the percentage of spending by category'**
  String get pieGraphPlaceholder;

  /// No description provided for @weaklyGraphPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'See your weekly spending by category'**
  String get weaklyGraphPlaceholder;

  /// No description provided for @dailyGraphPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'See your daily spending by category'**
  String get dailyGraphPlaceholder;

  /// No description provided for @categoryExpensesDescription.
  ///
  /// In en, this message translates to:
  /// **'Here your expenses by category will be listed, \nclassified from largest to smallest'**
  String get categoryExpensesDescription;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @premiumVersion.
  ///
  /// In en, this message translates to:
  /// **'Premium Version'**
  String get premiumVersion;

  /// No description provided for @enjoyExclusiveFeatures.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all the exclusive features'**
  String get enjoyExclusiveFeatures;

  /// No description provided for @exportToExcelOrPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel or PDF'**
  String get exportToExcelOrPdf;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Complete ad removal'**
  String get removeAds;

  /// No description provided for @monthlySubscription.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscription'**
  String get monthlySubscription;

  /// No description provided for @yearlySubscription.
  ///
  /// In en, this message translates to:
  /// **'Yearly Subscription'**
  String get yearlySubscription;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @savefile.
  ///
  /// In en, this message translates to:
  /// **'Choose the file name'**
  String get savefile;

  /// No description provided for @reviewAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you like the app?'**
  String get reviewAppTitle;

  /// No description provided for @reviewAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Rate our app on the App Store to help more people discover it!'**
  String get reviewAppDescription;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @reviewButton.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get reviewButton;

  /// No description provided for @recurringExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recurring Expenses'**
  String get recurringExpenses;

  /// No description provided for @mediaDiaria.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get mediaDiaria;

  /// No description provided for @geral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get geral;

  /// No description provided for @custoFixo.
  ///
  /// In en, this message translates to:
  /// **'Fixed Cost'**
  String get custoFixo;

  /// No description provided for @custoVariavel.
  ///
  /// In en, this message translates to:
  /// **'Variable Cost'**
  String get custoVariavel;

  /// No description provided for @diasUteis.
  ///
  /// In en, this message translates to:
  /// **'Business Days'**
  String get diasUteis;

  /// No description provided for @finaisDeSemana.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get finaisDeSemana;

  /// No description provided for @diasMaiorCustoVariavel.
  ///
  /// In en, this message translates to:
  /// **'Days with Highest Variable Cost'**
  String get diasMaiorCustoVariavel;

  /// No description provided for @projecaoMes.
  ///
  /// In en, this message translates to:
  /// **'Projection for the Month'**
  String get projecaoMes;

  /// No description provided for @emptyDay.
  ///
  /// In en, this message translates to:
  /// **'No transactions \nfor this day'**
  String get emptyDay;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @dashboards.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get dashboards;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @myMonthNow.
  ///
  /// In en, this message translates to:
  /// **'My month so far'**
  String get myMonthNow;

  /// No description provided for @averageCostPerPurchase.
  ///
  /// In en, this message translates to:
  /// **'Average cost per purchase'**
  String get averageCostPerPurchase;

  /// No description provided for @mostExpensiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most expensive day of the month'**
  String get mostExpensiveDay;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @firstTenDays.
  ///
  /// In en, this message translates to:
  /// **'First ten days'**
  String get firstTenDays;

  /// No description provided for @secondTenDays.
  ///
  /// In en, this message translates to:
  /// **'Second ten days'**
  String get secondTenDays;

  /// No description provided for @thirdTenDays.
  ///
  /// In en, this message translates to:
  /// **'Third ten days'**
  String get thirdTenDays;

  /// No description provided for @currentMonthVsPrevious.
  ///
  /// In en, this message translates to:
  /// **'Current month / Previous month'**
  String get currentMonthVsPrevious;

  /// No description provided for @highestIncrease.
  ///
  /// In en, this message translates to:
  /// **'Highest increase'**
  String get highestIncrease;

  /// No description provided for @highestDrop.
  ///
  /// In en, this message translates to:
  /// **'Highest drop'**
  String get highestDrop;

  /// No description provided for @mostUsed.
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get mostUsed;

  /// No description provided for @dailyTransactions.
  ///
  /// In en, this message translates to:
  /// **'Daily transactions'**
  String get dailyTransactions;

  /// No description provided for @monthlyEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Monthly: every day'**
  String get monthlyEveryDay;

  /// No description provided for @weeklyEvery.
  ///
  /// In en, this message translates to:
  /// **'Weekly: every'**
  String get weeklyEvery;

  /// No description provided for @yearlyEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Yearly: every day'**
  String get yearlyEveryDay;

  /// No description provided for @weekdaysMondayToFriday.
  ///
  /// In en, this message translates to:
  /// **'Weekdays: from Monday to Friday'**
  String get weekdaysMondayToFriday;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @selectAnOption.
  ///
  /// In en, this message translates to:
  /// **'Select a repetition option'**
  String get selectAnOption;

  /// No description provided for @monthlyInsights.
  ///
  /// In en, this message translates to:
  /// **'Monthly insights'**
  String get monthlyInsights;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pietutorial.
  ///
  /// In en, this message translates to:
  /// **'Add your expenses so that we can organize them for you.'**
  String get pietutorial;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sing Up'**
  String get signup;

  /// No description provided for @signin.
  ///
  /// In en, this message translates to:
  /// **'Sing In'**
  String get signin;

  /// No description provided for @signout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signout;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? Sign up'**
  String get dontHaveAccount;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @contactus.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactus;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync data'**
  String get syncData;

  /// No description provided for @syncQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sync local data with the cloud?'**
  String get syncQuestion;

  /// No description provided for @loginWithGoogleToSyncData.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your Google account to sync your data'**
  String get loginWithGoogleToSyncData;

  /// No description provided for @secureCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Secure cloud backup'**
  String get secureCloudBackup;

  /// No description provided for @accessAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Access on all devices'**
  String get accessAcrossDevices;

  /// No description provided for @upgradeToProToSync.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to sign in\nand sync your data'**
  String get upgradeToProToSync;

  /// No description provided for @redirectingToUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to upgrade...'**
  String get redirectingToUpgrade;

  /// No description provided for @proFeature.
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get proFeature;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get budget;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @totalGoalForMonth.
  ///
  /// In en, this message translates to:
  /// **'Total budget for a month'**
  String get totalGoalForMonth;

  /// No description provided for @currentGoal.
  ///
  /// In en, this message translates to:
  /// **'Current Goal'**
  String get currentGoal;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get setGoal;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @transactionPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first transaction\nto have full control of your expenses'**
  String get transactionPlaceholderTitle;

  /// No description provided for @transactionPlaceholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your transactions will appear here'**
  String get transactionPlaceholderSubtitle;

  /// No description provided for @transactionPlaceholderRow1Title.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get transactionPlaceholderRow1Title;

  /// No description provided for @transactionPlaceholderRow1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the add tab to get started'**
  String get transactionPlaceholderRow1Subtitle;

  /// No description provided for @transactionPlaceholderRow2Title.
  ///
  /// In en, this message translates to:
  /// **'Fixed expenses'**
  String get transactionPlaceholderRow2Title;

  /// No description provided for @transactionPlaceholderRow3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up recurring expenses'**
  String get transactionPlaceholderRow3Subtitle;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addTransactionTitle;

  /// No description provided for @dateAndHour.
  ///
  /// In en, this message translates to:
  /// **'Date and Time'**
  String get dateAndHour;

  /// No description provided for @insertExpend.
  ///
  /// In en, this message translates to:
  /// **'Insert Expense'**
  String get insertExpend;

  /// No description provided for @addTransactionPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addTransactionPopupTitle;

  /// No description provided for @addTransactionPopupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amount spent'**
  String get addTransactionPopupSubtitle;

  /// No description provided for @automaticAddition.
  ///
  /// In en, this message translates to:
  /// **'Automatic Addition'**
  String get automaticAddition;

  /// No description provided for @suggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @selectAdditionType.
  ///
  /// In en, this message translates to:
  /// **'Select Addition Type'**
  String get selectAdditionType;

  /// No description provided for @selectAdditionTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how this expense will be added'**
  String get selectAdditionTypeDescription;

  /// No description provided for @automaticAdditionDescription.
  ///
  /// In en, this message translates to:
  /// **'Adds the expense automatically on the scheduled date'**
  String get automaticAdditionDescription;

  /// No description provided for @suggestionDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminds you to add the expense on the scheduled date'**
  String get suggestionDescription;

  /// No description provided for @cloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get cloudBackup;

  /// No description provided for @save30Percent.
  ///
  /// In en, this message translates to:
  /// **'Save 30%'**
  String get save30Percent;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
