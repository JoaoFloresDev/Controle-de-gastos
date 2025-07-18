import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCardRecorrent.dart';
import 'package:meus_gastos/controllers/orcamentos/goalsScrean.dart';
import 'package:meus_gastos/gastos_fixos/CardDetails/DetailScreenMainScrean.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/ListCardFixeds.dart';
import 'package:meus_gastos/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/TotalSpentCarousel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/controllers/exportExcel/exportExcelScreen.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/InsertTransactions.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onepref/onepref.dart';
import 'package:meus_gastos/controllers/Calendar/CustomCalendar.dart';
import 'firebase_options.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_core/firebase_core.dart';

import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // inapp
  InAppPurchase.instance.isAvailable();
  // Ads
  MobileAds.instance.initialize();

  if (Platform.isMacOS) {
    setWindowMinSize(const Size(800, 800));
  }
  // onepref
  await OnePref.init();
  // inicializa firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Habilitar cache offline para Firestore
  firestore.FirebaseFirestore.instance.settings = const firestore.Settings(
    persistenceEnabled: true, // Ativa o cache offline
  );
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);

  // Define persistência da sessão do usuário
  // await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('es', ''),
        Locale('pt', ''),
      ],
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedTab = 0;
  final bool seeGoalScrean = true;
  final GlobalKey<CustomCalendarState> calendarKey =
      GlobalKey<CustomCalendarState>();
  final GlobalKey<CustomCalendarState> calendarKey2 =
      GlobalKey<CustomCalendarState>();

  final GlobalKey<GoalsscreanState> goalKey = GlobalKey<GoalsscreanState>();

  final exportButton = GlobalKey();
  final cardsExpense = GlobalKey();
  //mark - variables
  //mark - variables
  final GlobalKey<DashboardScreenState> dashboardTab =
      GlobalKey<DashboardScreenState>();

  final valueExpense = GlobalKey();
  final date = GlobalKey();
  final description = GlobalKey();
  final categories = GlobalKey();
  final addButton = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.black,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.home, size: 20),
            label: AppLocalizations.of(context)!.transactions,
          ),
          BottomNavigationBarItem(
            // key: dashboardTab,
            icon: const Icon(CupertinoIcons.chart_bar, size: 20),
            label: AppLocalizations.of(context)!.dashboards,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.calendar, size: 20),
            label: AppLocalizations.of(context)!.calendar,
          ),
          if (seeGoalScrean)
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.graph_circle, size: 20),
              label: AppLocalizations.of(context)!.budget,
            ),
        ],
        onTap: (int index) {
          if (index == 1) {
            if (selectedTab != index) {
              dashboardTab.currentState?.refreshData();
            }
          }

          if (index == 2) {
            calendarKey.currentState?.refreshCalendar();
          }

          if (index == 3) {
            goalKey.currentState?.refreshBudgets();
          }

          setState(() {
            selectedTab = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: _buildTabContent(index),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return InsertTransactions(
          title: AppLocalizations.of(context)!.myExpenses,
          onAddClicked: () {},
          cardsExpens: cardsExpense,
          exportButon: exportButton,
          addButon: addButton,
          categories: categories,
          date: date,
          description: description,
          valueExpens: valueExpense,
        );
      case 1:
        // dashboardTab.currentState?.inicializeDashboard();
        return DashboardScreen(
          key: dashboardTab,
          isActive: true,
        );
      case 2:
        return CustomCalendar(
          key: calendarKey,
          onCalendarRefresh: () {
            calendarKey.currentState?.refreshCalendar();
          },
        );
      case 3:
        if (seeGoalScrean) {
          return Goalsscrean(
              key: goalKey,
              title: AppLocalizations.of(context)!.budget,
              onChangeMeta: () {
                setState(() {
                  goalKey.currentState?.refreshBudgets();
                });
              });
        } else {
          return Container();
        }
      default:
        // dashboardTab.currentState?.inicializeDashboard();
        return DashboardScreen(
          key: dashboardTab,
          isActive: selectedTab == 1,
        );
    }
  }
}
