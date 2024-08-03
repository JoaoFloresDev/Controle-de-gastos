import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/widgets/Transactions/InsertTransactions/InsertTransactions.dart';
import 'package:meus_gastos/widgets/Dashboards/DashboardScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
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

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.black38,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home, size: 20),
              label: 'Transações',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar, size: 20),
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
          if (index == 1 && selectedTab == 1) {
            return DashboardScreen(
              key: UniqueKey(),
              isActive: true,
            );
          }

          switch (index) {
            case 0:
              return InsertTransactions(
                title: 'Meus Gastos',
                onAddClicked: () {},
              );
            default:
              return DashboardScreen(
                key: ValueKey(index),
                isActive: selectedTab == 1,
              );
          }
        },
      ),
    );
  }
}
