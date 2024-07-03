import 'package:flutter/material.dart';

class ChartsViewController extends StatefulWidget {
  @override
  _ChartsViewControllerState createState() => _ChartsViewControllerState();
}

class _ChartsViewControllerState extends State<ChartsViewController> {
  int _selectedIndex = 0;
  String _selectedMonth = 'Abril';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Meu relatório',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ToggleButtons(
              children: <Widget>[
                Text('Todas categorias'),
                Text('Dias'),
                Text('Último mês'),
              ],
              onPressed: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              isSelected: List.generate(3, (index) => index == _selectedIndex),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: <Widget>[
                  CategoryProgress(
                    key: Key('category_progress'),
                    category: 'Moradia',
                    progress: 0.8,
                    budget: 1000,
                    spent: 800,
                  ),
                  CategoryProgress(
                    key: Key('category_progress'),
                    category: 'Moradia',
                    progress: 0.8,
                    budget: 1000,
                    spent: 800,
                  ),
                  // Add more categories here
                ],
              ),
            ),
            Card(
              child: ListTile(
                leading: Text(
                  'R\$ 10,00',
                  style: TextStyle(fontSize: 24),
                ),
                title: Text('Compras da semana no mercado'),
                trailing: Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProgress extends StatelessWidget {
  final String category;
  final double progress;
  final int budget;
  final int spent;

  const CategoryProgress({
    required Key key,
    required this.category,
    required this.progress,
    required this.budget,
    required this.spent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                category,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '$spent/$budget',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }
}
