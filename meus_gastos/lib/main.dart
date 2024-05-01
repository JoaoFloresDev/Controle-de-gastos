import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:meus_gastos/widgets/Transactions/InsertTransactions.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'Scenes/InsertTransaction/InsertTransactions/widgets/HeaderCard.dart';
import 'Scenes/InsertTransaction/InsertTransactions/widgets/ListCard.dart';
import 'Scenes/InsertTransaction/InsertTransactions/models/CardModel.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/services/CardService.dart'
    as service;
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/InsertTransactionViewController.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/widgets/DetailScreen.dart';
=======
import 'package:meus_gastos/widgets/Transactions/InsertTransactions.dart';
import 'package:meus_gastos/widgets/Dashboards/Charts.dart';
>>>>>>> 3670368 (Refatoração)
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/chartsViewController.dart';
=======
import 'package:meus_gastos/widgets/Transactions/InsertTransactions.dart';
import 'package:meus_gastos/widgets/Dashboards/Charts.dart';
>>>>>>> 3dad007 (refatoração)

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.light,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Verde!',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Azul',
          ),
        ],
=======
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Transações',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
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
          Widget content;
          switch (index) {
            case 0:
              content = InsertTransactions(
                title: 'Meus Gastos',
                onAddClicked: () {},
              );
              break;
            default:
              content = DashboardScreen(isActive: selectedTab == 1);
              // content = BlueController();
              break;
          }
          return content;
        },
>>>>>>> 3670368 (Refatoração)
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const InsertTransactionViewController(
                title: 'Insert Transaction');
          default:
            return ChartsViewController();
        }
      },
    );
  }

  void _showCupertinoModalBottomSheet(BuildContext context, CardModel card) {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DetailScreen(
            card: card,
            onAddClicked: () {
              loadCards();
              setState(() {
                _showHeaderCard = false;
              });
            },
          ),
        );
      },
    );
  }
}

class GreenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Green Screen'),
      ),
      child: Container(color: Colors.green),
    );
  }
}

class BlueController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Text(
          'Blue Controller',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
