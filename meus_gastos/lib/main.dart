import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/InsertTransactions.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onepref/onepref.dart';
import 'package:meus_gastos/controllers/Calendar/CustomCalendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchase.instance.isAvailable();
  MobileAds.instance.initialize();

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

  final GlobalKey<CustomCalendarState> calendarKey =
      GlobalKey<CustomCalendarState>();
  final GlobalKey<CustomCalendarState> calendarKey2 =
      GlobalKey<CustomCalendarState>();

  final exportButton = GlobalKey();
  final cardsExpense = GlobalKey();
  //mark - variables
final GlobalKey<DashboardScreenState> dashboardTab = GlobalKey<DashboardScreenState>();

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
      default:
        return DashboardScreen(
          key: ValueKey(index),
          isActive: selectedTab == 1,
        );
    }
  }
}
