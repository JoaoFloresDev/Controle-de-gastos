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
import 'package:meus_gastos/services/RatingGate.dart';
import 'package:meus_gastos/controllers/Onboarding/OnboardingScreen.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meus_gastos/services/widget/WidgetBridge.dart';
import 'package:meus_gastos/services/widget/WidgetSyncHost.dart';
import 'package:meus_gastos/designSystem/Desktop/DesktopSidebar.dart';
import 'package:meus_gastos/designSystem/Desktop/DesktopShortcuts.dart';


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
    // Matches MainFlutterWindow.minSize; below this the sidebar and the charts
    // start clipping.
    setWindowMinSize(const Size(940, 640));
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
  // inicializa a ponte com o widget nativo de adição rápida (App Group).
  // Nunca pode derrubar o boot: plugin ausente na plataforma = app sem widget,
  // não app sem tela.
  try {
    await WidgetBridge.init();
  } catch (_) {}
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
      navigatorKey: RatingGate.navigatorKey,
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
        Locale('ru'),
        Locale('hi'),
        Locale('nl'),
        Locale('pl'),
        Locale('vi'),
        Locale('th'),
        Locale('ms'),
        Locale('sv'),
        Locale('da'),
        Locale('nb'),
        Locale('fi'),
        Locale('uk'),
        Locale('el'),
        Locale('he'),
        Locale('cs'),
        Locale('hu'),
        Locale('ro'),
        Locale('sk'),
        Locale('hr'),
        Locale('ca'),
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
  // MARK: - Navigation

  /// Onboarding -> paywall -> home, every step a forward horizontal push.
  void _finishOnboarding() {
    if (!mounted) return;
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (routeContext) => ProModal(
          isLoading: false,
          onSubscriptionPurchased: () => _goHome(routeContext),
          onClose: () => _goHome(routeContext),
        ),
      ),
    );
  }

  void _goHome(BuildContext routeContext) {
    Navigator.of(routeContext).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const MyHomePage()),
      (route) => false,
    );
  }

  // MARK: - Build

  @override
  Widget build(BuildContext context) {
    if (widget.showOnboarding) {
      return OnboardingScreen(onFinish: _finishOnboarding);
    }
    return const MyHomePage();
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

  static const List<IconData> _tabIcons = [
    CupertinoIcons.add_circled_solid,
    CupertinoIcons.list_bullet,
    CupertinoIcons.chart_bar_fill,
    CupertinoIcons.chart_pie_fill,
    CupertinoIcons.settings,
  ];

  /// Ceiling for the content column on desktop.
  static const double _desktopContentMaxWidth = 1120;

  bool get _isDesktop => Platform.isMacOS;

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
    if (!_isDesktop) HapticFeedback.lightImpact();
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
            child: _isDesktop ? _buildDesktopShell(context) : _buildMobileShell(context),
          ),
        );
      }),
    );
  }

  // MARK: - Shells

  /// Phone/tablet layout: content plus the bottom tab bar.
  Widget _buildMobileShell(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: _buildContent(context),
      bottomNavigationBar: _buildElegantTabBar(),
    );
  }

  /// macOS layout: sidebar on the left, content column on the right, and the
  /// keyboard bindings a desktop app is expected to answer to.
  Widget _buildDesktopShell(BuildContext context) {
    return DesktopShortcuts(
      onSelectTab: _onTabSelected,
      addTabIndex: 0,
      settingsTabIndex: _tabScreenNames.length - 1,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DesktopSidebar(
              title: AppLocalizations.of(context)!.myExpenses,
              selectedIndex: selectedTab,
              onSelected: _onTabSelected,
              items: _desktopNavItems(context),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Without a ceiling the phone-derived layouts stretch across
                  // the whole display and every row becomes a hairline. The
                  // size stays TIGHT on both axes — a loose Center would let
                  // the IndexedStack collapse to its intrinsic height.
                  final double width = constraints.maxWidth > _desktopContentMaxWidth
                      ? _desktopContentMaxWidth
                      : constraints.maxWidth;
                  return Center(
                    child: SizedBox(
                      width: width,
                      height: constraints.maxHeight,
                      child: _buildContent(context),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DesktopNavItem> _desktopNavItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.add,
      l10n.transactions,
      l10n.dashboards,
      l10n.budget,
      l10n.settings,
    ];
    return [
      for (var i = 0; i < _tabIcons.length; i++)
        DesktopNavItem(
          icon: _tabIcons[i],
          label: labels[i],
          shortcut: '\u2318${i + 1}',
        ),
    ];
  }

  // MARK: - Content

  Widget _buildContent(BuildContext context) {
    return IndexedStack(
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
          title: AppLocalizations.of(context)!.budget,
        ),
        SettingsScreenCompact()
      ],
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
                      icon: _tabIcons[i],
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
              fontSize: 10,
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
