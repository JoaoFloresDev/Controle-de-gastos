// Arquivo completo do widget InsertTransactions com UI moderna e refinada, atualizado com nova tab AddTransaction

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/AddTransaction/AddTransactionController.dart';
import 'package:meus_gastos/controllers/Calendar/CustomCalendar.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreen.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/InsertTransactions.dart';
import 'package:onepref/onepref.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchase.instance.isAvailable();
  MobileAds.instance.initialize();

  if (Platform.isMacOS) {
    setWindowMinSize(const Size(800, 800));
  }

  await OnePref.init();
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

  final GlobalKey<CustomCalendarState> calendarKey = GlobalKey<CustomCalendarState>();
  final GlobalKey<DashboardScreenState> dashboardTab = GlobalKey<DashboardScreenState>();

  final exportButton = GlobalKey(debugLabel: "exportButton");
  final cardsExpense = GlobalKey(debugLabel: "cardsExpense");
  final valueExpense = GlobalKey(debugLabel: "valueExpense");
  final date = GlobalKey(debugLabel: "date");
  final description = GlobalKey(debugLabel: "description");
  final categories = GlobalKey(debugLabel: "categories");
  final addButton = GlobalKey(debugLabel: "addButton");

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.black,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.add_circled, size: 20),
            label: AppLocalizations.of(context)!.add,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.home, size: 20),
            label: AppLocalizations.of(context)!.transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chart_bar, size: 20),
            label: AppLocalizations.of(context)!.dashboards,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.calendar, size: 20),
            label: AppLocalizations.of(context)!.calendar,
          ),
        ],
        onTap: (int index) {
          setState(() {
            selectedTab = index;
          });

          if (index == 2) {
            dashboardTab.currentState?.refreshData();
          }
          if (index == 3) {
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
        return AddTransactionController(
          title: AppLocalizations.of(context)!.myExpenses,
          onAddClicked: () {},
          cardsExpens: GlobalKey(debugLabel: "cardsExpenseAT"),
          exportButon: GlobalKey(debugLabel: "exportButtonAT"),
          addButon: GlobalKey(debugLabel: "addButtonAT"),
          categories: GlobalKey(debugLabel: "categoriesAT"),
          date: GlobalKey(debugLabel: "dateAT"),
          description: GlobalKey(debugLabel: "descriptionAT"),
          valueExpens: GlobalKey(debugLabel: "valueExpenseAT"),
        );
      case 1:
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
      case 2:
        return DashboardScreen(
          key: dashboardTab,
          isActive: true,
        );
      case 3:
        return CustomCalendar(
          key: calendarKey,
          onCalendarRefresh: () {
            calendarKey.currentState?.refreshCalendar();
          },
        );
      default:
        return Container();
    }
  }
}
