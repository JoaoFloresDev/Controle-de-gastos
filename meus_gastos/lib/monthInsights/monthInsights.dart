import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/monthInsights/monthInsightsServices.dart';

class MonthInsights extends StatefulWidget {
  final DateTime currentDate;

  MonthInsights({required this.currentDate});

  @override
  _MonthInsightsState createState() => _MonthInsightsState();
}

class _MonthInsightsState extends State<MonthInsights> {
  double avaregeDaily = 0.0;

  @override
  void initState() {
    super.initState();
    getValues();
  }

  Future<void> getValues() async {
    await CardService.retrieveCards();
    var aux = await Monthinsightsservices.dailyAverage(widget.currentDate);
    setState(() {
      avaregeDaily = aux;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("$avaregeDaily");

    // TODO: implement build
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${AppLocalizations.of(context)!.mediaDiaria}",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.label,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: Text("${AppLocalizations.of(context)!.geral}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            "${Translateservice.formatCurrency(avaregeDaily, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                color: AppColors.line, // Cor da linha
                thickness: 1, // Espessura da linha
              ),
              Row(
                children: [
                  Expanded(
                      child: Text("${AppLocalizations.of(context)!.custoFixo}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child:
                          Text("${AppLocalizations.of(context)!.custoVariavel}",
                              style: TextStyle(
                                color: AppColors.line,
                              ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                color: AppColors.line, // Cor da linha
                thickness: 1, // Espessura da linha
              ),
              Row(
                children: [
                  Expanded(
                      child: Text("${AppLocalizations.of(context)!.diasUteis}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Text(
                          "${AppLocalizations.of(context)!.finaisDeSemana}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Text(
                "${AppLocalizations.of(context)!.diasMaiorCustoVariavel}",
                style: TextStyle(
                    color: AppColors.label,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "${AppLocalizations.of(context)!.projecaoMes}",
                style: TextStyle(
                    color: AppColors.label,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                      child: Text("${AppLocalizations.of(context)!.geral}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                color: AppColors.line, // Cor da linha
                thickness: 1, // Espessura da linha
              ),
              Row(
                children: [
                  Expanded(
                      child: Text("${AppLocalizations.of(context)!.custoFixo}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child:
                          Text("${AppLocalizations.of(context)!.custoVariavel}",
                              style: TextStyle(
                                color: AppColors.line,
                              ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                color: AppColors.line, // Cor da linha
                thickness: 1, // Espessura da linha
              ),
              Row(
                children: [
                  Expanded(
                      child: Text("${AppLocalizations.of(context)!.diasUteis}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Text(
                          "${AppLocalizations.of(context)!.finaisDeSemana}",
                          style: TextStyle(
                            color: AppColors.line,
                          ))),
                  Expanded(child: Container()),
                  Expanded(
                    child: Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0.0, context)}",
                            style: TextStyle(
                              color: AppColors.line,
                            )),
                        SizedBox(width: 4),
                        Text("${0}%",
                            style: TextStyle(
                              color: AppColors.line,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
