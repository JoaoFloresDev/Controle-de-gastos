import 'dart:io';
import 'dart:ui' show PlatformDispatcher;
import 'package:meus_gastos/AppProviders.dart';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Goals/GoalsFactory.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/Settings/SettingsScreen.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsFactory.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'controllers/Dashboards/DashboardsFactory.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:meus_gastos/services/firebase/FirebaseServiceSingleton.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meus_gastos/services/AnalyticsService.dart';
import 'package:meus_gastos/controllers/Onboarding/OnboardingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meus_gastos/services/widget/WidgetBridge.dart';
import 'package:meus_gastos/services/widget/WidgetSyncHost.dart';


import 'package:window_size/window_size.dart';
import 'package:meus_gastos/controllers/AddTransaction/AddTransactionController.dart';
import 'package:meus_gastos/controllers/Calendar/CustomCalendarScreen.dart';

import 'package:provider/provider.dart';

// ignore_for_file: unused_import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  // inapp
  InAppPurchase.instance.isAvailable();
  if (Platform.isMacOS) {
    setWindowMinSize(const Size(800, 800));
  }
  // inicializa firebase
  await FirebaseService().init();
  if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  // inicializa a ponte com o widget nativo de adição rápida (App Group)
  await WidgetBridge.init();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding =
      prefs.getBool(OnboardingScreen.hasSeenKey) ?? false;
  runApp(
    MyApp(showOnboarding: !hasSeenOnboarding),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, this.showOnboarding = false});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
        Locale('es'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
        Locale('de'),
        Locale('fr'),
        Locale('it'),
        Locale('tr'),
        Locale('ar'),
        Locale('id'),
      ],
      home: RootGate(showOnboarding: showOnboarding),
    );
  }
}

class RootGate extends StatefulWidget {
  final bool showOnboarding;

  const RootGate({super.key, required this.showOnboarding});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  late bool _showOnboarding = widget.showOnboarding;

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onFinish: () => setState(() => _showOnboarding = false),
      );
    }
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int selectedTab = 0;
  final bool seeGoalScrean = true;
  late AnimationController _animationController;

  final calendarKey = GlobalKey<CustomCalendarState>();

  final goalKey = GlobalKey(debugLabel: "goalScreen");

  final exportButtonAT = GlobalKey(debugLabel: 'exportButtonAT');
  final cardsExpenseAT = GlobalKey(debugLabel: 'cardsExpenseAT');
  final valueExpenseAT = GlobalKey(debugLabel: 'valueExpenseAT');
  final dateAT = GlobalKey(debugLabel: 'dateAT');
  final descriptionAT = GlobalKey(debugLabel: 'descriptionAT');
  final categoriesAT = GlobalKey(debugLabel: 'categoriesAT');
  final addButtonAT = GlobalKey(debugLabel: 'addButtonAT');

  final exportButton = GlobalKey(debugLabel: 'exportButton');
  final cardsExpense = GlobalKey(debugLabel: 'cardsExpense');
  final valueExpense = GlobalKey(debugLabel: 'valueExpense');
  final date = GlobalKey(debugLabel: 'date');
  final description = GlobalKey(debugLabel: 'description');
  final categories = GlobalKey(debugLabel: 'categories');
  final addButton = GlobalKey(debugLabel: 'addButton');

  final cardEvents = CardEvents();



  static const _tabScreenNames = [
    'add_transaction',
    'transactions',
    'dashboards',
    'goals',
    'settings',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    AnalyticsService().logScreen(_tabScreenNames[0]);
  }

  void _onTabSelected(int index) {
    if (index == selectedTab) return;
    setState(() => selectedTab = index);
    if (index >= 0 && index < _tabScreenNames.length) {
      AnalyticsService().logScreen(_tabScreenNames[index]);
    }
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //mark - variables
  //mark - variables

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ProManeger()..checkUserProStatus()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()..init()),
        ChangeNotifierProvider(create: (_)=> SyncViewModel())
      ],
      child: Builder(builder: (context) {
        return AppProviders(
          child: WidgetSyncHost(
          child: Scaffold(
            backgroundColor: const Color(0xFF0D1117),
            body: IndexedStack(
              index: selectedTab,
              children: [
                AddTransactionController(
                  isActive: selectedTab == 0,
                  title: AppLocalizations.of(context)!.myExpenses,
                  onAddClicked: () {
                    cardEvents.notifyCardAdded();
                  },
                  exportButton: exportButtonAT,
                  cardsExpensKey: cardsExpenseAT,
                  valueExpensKey: valueExpenseAT,
                  dateKey: dateAT,
                  descriptionKey: descriptionAT,
                  categoriesKey: categoriesAT,
                  addButtonKey: addButtonAT,
                ),
                TransactionsFactory(
                    cardEvents: cardEvents, isActivate: selectedTab == 1),
                DashboardsFactory(isActivate: selectedTab == 2),

                GoalsFactory(
                  // key: goalKey,
                  title: AppLocalizations.of(context)!.budget,
                ),
                
                SettingsScreenCompact()
              ],
            ),
            bottomNavigationBar: _buildElegantTabBar(),
          ),
          ),
        );
      }),
    );
  }

  Widget _buildElegantTabBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final tabBarHeight = 70 + bottomPadding;

    return Container(
      height: tabBarHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C1C1E),
            Color.fromARGB(255, 35, 35, 37),
            Color(0xFF1C1C1E),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        border: Border.all(
          color: const Color(0xFF3A3A3C).withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: const Color(0xFF3A3A3C).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, bottom: 2, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < 5; i++)
                  Expanded(
                    child: _buildTabItem(
                      icon: [
                        CupertinoIcons.add_circled_solid,
                        CupertinoIcons.list_bullet,
                        CupertinoIcons.chart_bar_fill,
                        CupertinoIcons.chart_pie_fill,
                        // CupertinoIcons.calendar,
                        CupertinoIcons.settings
                      ][i],
                      label: [
                        AppLocalizations.of(context)!.add,
                        AppLocalizations.of(context)!.transactions,
                        AppLocalizations.of(context)!.dashboards,
                        AppLocalizations.of(context)!.budget,
                        // AppLocalizations.of(context)!.calendar,
                        AppLocalizations.of(context)!.settings
                      ][i],
                      index: i,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque, // <- ESSENCIAL: toda área vira "clicável"
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 20),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Icon(
              icon,
              size: isSelected ? 26 : 22,
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
