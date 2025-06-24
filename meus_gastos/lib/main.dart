import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';
import 'package:window_size/window_size.dart';
import 'package:meus_gastos/controllers/AddTransaction/AddTransactionController.dart';
import 'package:meus_gastos/controllers/Calendar/CustomCalendar.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreen.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/InsertTransactions.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
      theme: CupertinoThemeData(brightness: Brightness.light),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
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
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int selectedTab = 0;

  final calendarKey = GlobalKey<CustomCalendarState>();
  final dashboardKey = GlobalKey<DashboardScreenState>();

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

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.black,
        currentIndex: selectedTab,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.add_circled, size: 20),
            label: AppLocalizations.of(context)!.add,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.list_bullet, size: 20),
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
        onTap: (index) {
          setState(() => selectedTab = index);
          if (index == 2) {
            dashboardKey.currentState?.refreshData();
          }
          if (index == 3) {
            calendarKey.currentState?.refreshCalendar();
          }
        },
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return AddTransactionController(
              title: AppLocalizations.of(context)!.myExpenses,
              onAddClicked: () {},
              exportButton: exportButtonAT,
              cardsExpensKey: cardsExpenseAT,
              valueExpensKey: valueExpenseAT,
              dateKey: dateAT,
              descriptionKey: descriptionAT,
              categoriesKey: categoriesAT,
              addButtonKey: addButtonAT,
            );
          case 1:
            return InsertTransactions(
              title: AppLocalizations.of(context)!.myExpenses,
              onAddClicked: () {},
              exportButon: exportButton,
              cardsExpens: cardsExpense,
              valueExpens: valueExpense,
              date: date,
              description: description,
              categories: categories,
              addButon: addButton,
            );
          case 2:
            return DashboardScreen(key: dashboardKey, isActive: true);
          case 3:
            return CustomCalendar(
              key: calendarKey,
              onCalendarRefresh: () => calendarKey.currentState?.refreshCalendar(),
            );
          default:
            return Container();
        }
      },
    );
  }
}
