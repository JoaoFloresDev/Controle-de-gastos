import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/CampoComMascara.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/HorizontalCircleList.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CriarGastosFixos extends StatefulWidget {
  @override
  State<CriarGastosFixos> createState() => _CriarGastosFixos();
}

class _CriarGastosFixos extends State<CriarGastosFixos> {
  late MoneyMaskedTextController valorController;
  late CampoComMascara dateController;
  final descricaoController = TextEditingController();
  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;

  final GlobalKey<HorizontalCircleListState> _horizontalCircleListKey =
      GlobalKey<HorizontalCircleListState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Atualiza o formato da data baseado nas configurações do usuário
    final locale = Localizations.localeOf(context);
    final currencySymbol = Translateservice.getCurrencySymbol(context);

    valorController = MoneyMaskedTextController(
      leftSymbol: currencySymbol,
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: 0.0,
    );

    dateController = CampoComMascara(
      currentDate: lastDateSelected,
      onCompletion: (DateTime dateTime) {
        setState(() {
          lastDateSelected = dateTime;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState(); // Necessário no initState
    print("Entrou");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background1,
        appBar: AppBar(
          backgroundColor: AppColors.background1,
          title: Text(
            'Criar Gastos Fixos',
            style: TextStyle(color: AppColors.label),
          ),
          iconTheme: IconThemeData(
            color: AppColors.label, // Cor da seta de voltar
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ValorTextField(controller: valorController),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: dateController,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  placeholder: AppLocalizations.of(context)!.description,
                  placeholderStyle:
                      TextStyle(color: CupertinoColors.white.withOpacity(0.5)),
                  style: const TextStyle(color: CupertinoColors.white),
                  controller: descricaoController,
                ),
                const SizedBox(height: 24),
                HorizontalCircleList(
                  key: _horizontalCircleListKey,
                  onItemSelected: (index) {
                    setState(() {
                      lastIndexSelected = index;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CupertinoButton(
                    color: CupertinoColors.systemBlue,
                    onPressed: () {
                      // Ação ao adicionar o gasto fixo
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gasto Fixo Adicionado!')),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.add,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
