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
      theme: CupertinoThemeData(brightness: Brightness.dark),
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

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int selectedTab = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: IndexedStack(
        index: selectedTab,
        children: [
          AddTransactionController(
            title: AppLocalizations.of(context)!.myExpenses,
            onAddClicked: () {},
            exportButton: exportButtonAT,
            cardsExpensKey: cardsExpenseAT,
            valueExpensKey: valueExpenseAT,
            dateKey: dateAT,
            descriptionKey: descriptionAT,
            categoriesKey: categoriesAT,
            addButtonKey: addButtonAT,
          ),
          InsertTransactions(
            title: AppLocalizations.of(context)!.myExpenses,
            onAddClicked: () {},
            exportButon: exportButton,
            cardsExpens: cardsExpense,
            valueExpens: valueExpense,
            date: date,
            description: description,
            categories: categories,
            addButon: addButton,
          ),
          DashboardScreen(key: dashboardKey, isActive: true),
          CustomCalendar(
            key: calendarKey,
            onCalendarRefresh: () => calendarKey.currentState?.refreshCalendar(),
          ),
        ],
      ),
      bottomNavigationBar: _buildElegantTabBar(),
    );
  }

Widget _buildElegantTabBar() {
  final bottomPadding = MediaQuery.of(context).padding.bottom;
  final tabBarHeight = 70 + bottomPadding;

  return Container(
    height: tabBarHeight,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1C1C1E),
          const Color.fromARGB(255, 35, 35, 37),
          const Color(0xFF1C1C1E),
        ],
        stops: const [0.0, 0.5, 1.0],
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
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 2, top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: _buildTabItem(
                    icon: [
                      CupertinoIcons.add_circled_solid,
                      CupertinoIcons.list_bullet,
                      CupertinoIcons.chart_bar_fill,
                      CupertinoIcons.calendar,
                    ][i],
                    label: [
                      AppLocalizations.of(context)!.add,
                      AppLocalizations.of(context)!.transactions,
                      AppLocalizations.of(context)!.dashboards,
                      AppLocalizations.of(context)!.calendar,
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
    behavior: HitTestBehavior.opaque, // <- ESSENCIAL: toda área vira "clicável"
    onTap: () {
      setState(() => selectedTab = index);
      if (index == 2) dashboardKey.currentState?.refreshData();
      if (index == 3) calendarKey.currentState?.refreshCalendar();
      HapticFeedback.lightImpact();
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 20),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Icon(
            icon,
            size: isSelected ? 26 : 22,
            color: isSelected
                ? Colors.white
                : const Color(0xFF8E8E93),
          ),
        ),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isSelected ? 11 : 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : const Color(0xFF8E8E93),
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