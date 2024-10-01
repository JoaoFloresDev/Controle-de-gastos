import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/InsertTransactions.dart';
import 'package:meus_gastos/controllers/Dashboards/DashboardScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/app_tour_tutorial.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // MARK: - Build Method
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

  final exportButon = GlobalKey();
  final cardsExpens = GlobalKey();
  final dashboardTab = GlobalKey();
  final valueExpens = GlobalKey();
  final date = GlobalKey();
  final description = GlobalKey();
  final categories = GlobalKey();
  final addButon = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  void _initHearderCardInAppTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: addTargetsHearderCard(
        valueExpens: valueExpens,
        addButton: addButon,
        categories: categories,
      ),
      colorShadow: CupertinoColors.black,
      paddingFocus: 10,
      hideSkip: true,
      opacityShadow: 0.6,
      onClickOverlay: (TargetFocus target) {
        print("Overlay clicked for target: ${target.identify}");
        if (tutorialCoachMark.targets.indexOf(target) ==
            tutorialCoachMark.targets.length - 1) {
          tutorialCoachMark.skip(); // Pula se for o último
        }
      },
      onFinish: () {
        InAppSave.saveInsertTransationsStatus();
      },
    );
  }

  void _showInAppTour() {
    Future.delayed(const Duration(seconds: 2), () {
      InAppSave.getInsertTransactionsStatus().then((value) {
        if (value == false) {
          tutorialCoachMark.show(context: context);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initHearderCardInAppTour();
    _showInAppTour();
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.black38,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, size: 20),
            label: 'Transações',
          ),
          BottomNavigationBarItem(
            key: dashboardTab,
            icon: const Icon(CupertinoIcons.chart_bar, size: 20),
            label: 'Dashboard',
          ),
        ],
        onTap: (int index) {
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
    if (index == 1 && selectedTab == 1) {
      return DashboardScreen(
        key: UniqueKey(),
        isActive: true,
      );
    }

    switch (index) {
      case 0:
        return InsertTransactions(
          title: AppLocalizations.of(context)!.myExpenses,
          onAddClicked: () {},
          cardsExpens: cardsExpens,
          exportButon: exportButon,
          addButon: addButon,
          categories: categories,
          date: date,
          description: description,
          valueExpens: valueExpens,
        );
      default:
        return DashboardScreen(
          key: ValueKey(index),
          isActive: selectedTab == 1,
        );
    }
  }
}
