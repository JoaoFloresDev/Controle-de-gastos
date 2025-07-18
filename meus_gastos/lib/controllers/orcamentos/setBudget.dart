import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart'
    show ValorTextField;
import 'package:meus_gastos/controllers/orcamentos/goalsService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class Setbudget extends StatefulWidget {
  final CategoryModel category;
  final double initialValue;
  final VoidCallback loadCategories;
  final VoidCallback onChangeMeta;
  Setbudget(
      {required this.category,
      required this.initialValue,
      required this.loadCategories,
      required this.onChangeMeta});

  SetbudgetState createState() => SetbudgetState();
}

class SetbudgetState extends State<Setbudget> {
  late MoneyMaskedTextController valorController;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final currencySymbol = Translateservice.getCurrencySymbol(context);

    valorController = MoneyMaskedTextController(
      leftSymbol: currencySymbol,
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: widget.initialValue,
    );
  }

  void adicionar() {
    Goalsservice().addMeta(widget.category.id, valorController.numberValue);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background1,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomHeader(
                    title: Translateservice.getTranslatedCategoryName(
                        context, widget.category.name),
                    onCancelPressed: () {
                      // FocusScope.of(context).unfocus();
                      // Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: widget.category.color),
                        height: 60,
                        width: 60,
                        child: Icon(
                          widget.category.icon,
                          size: 50,
                          color: AppColors.background1,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          Expanded(child: SizedBox()),
                          Expanded(
                            child: ValorTextField(controller: valorController),
                          ),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double
                              .infinity, // Define a largura para ocupar toda a área disponível
                          child: CupertinoButton(
                            color: CupertinoColors.systemBlue,
                            onPressed: () {
                              adicionar();
                              widget.loadCategories();
                              widget.onChangeMeta();
                              // FocusScope.of(context).unfocus();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              AppLocalizations.of(context)!.update,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors
                                    .white, // Cor do texto definida como branca
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ))
                ])));
  }
}
