import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meus_gastos/controllers/settings/settings.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/InsertTransactions.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onepref/onepref.dart';
import 'package:meus_gastos/controllers/Calendar/CustomCalendar.dart';
import 'firebase_options.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // inapp
  InAppPurchase.instance.isAvailable();
  // Ads
  MobileAds.instance.initialize();
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

  final GlobalKey<CustomCalendarState> calendarKey =
      GlobalKey<CustomCalendarState>();
  final GlobalKey<CustomCalendarState> calendarKey2 =
      GlobalKey<CustomCalendarState>();

  final exportButton = GlobalKey();
  final cardsExpense = GlobalKey();
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
        backgroundColor: Colors.black38,
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
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.ellipsis, size: 20),
            label: AppLocalizations.of(context)!.other,
          ),
        ],
        onTap: (int index) {
          setState(() {
            selectedTab = index;
          });

          if (index == 1) {
            dashboardTab.currentState?.refreshData();
          }

          if (index == 2) {
            calendarKey.currentState?.refreshCalendar();
          }
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
        dashboardTab.currentState?.inicializeDashboard();
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
        return Settings();
      default:
        // dashboardTab.currentState?.inicializeDashboard();
        return DashboardScreen(
          key: ValueKey(index),
          isActive: selectedTab == 1,
        );
    }
  }
}
