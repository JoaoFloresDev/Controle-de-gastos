import 'package:meus_gastos/enums/Category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'LinearProgressIndicatorSection.dart';
import 'DashboardCard.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  List<ProgressIndicatorModel> progressIndicators = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProgressIndicators();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Chamada quando a tela é mostrada novamente ao usuário
      _loadProgressIndicators();
    }
  }

  Future<void> _loadProgressIndicators() async {
    setState(() {
      isLoading =
          true; // Mostrar o indicador de carregamento enquanto os dados são carregados
    });
    progressIndicators = await CardService.getProgressIndicators();
    setState(() {
      isLoading = false; // Atualiza a interface após carregar os dados
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Dashboard Elegante"),
        backgroundColor: Colors.deepPurple.withAlpha(200),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    DashboardCard(), // Suponho que DashboardCard seja um widget existente no seu projeto
              ),
              if (isLoading)
                CircularProgressIndicator()
              else
                Column(
                  children: [
                    for (var progressIndicator in progressIndicators)
                      LinearProgressIndicatorSection(model: progressIndicator),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
