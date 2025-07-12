import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/MonthSelector.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Goalsscrean extends StatefulWidget {
  final String title;
  final GlobalKey goalKey;
  Goalsscrean({required this.title, required this.goalKey});
  GoalsscreanState createState() => GoalsscreanState();
}

class GoalsscreanState extends State<Goalsscrean> {
  bool _isPro = false;

  List<CategoryModel> categories = [];
  List<ProgressIndicatorModel> progressIndicators = [];
  DateTime currentDate = DateTime.now();
  bool is_loading = true;
  @override
  void initState() {
    // TODO: implement initState
    _checkUserProStatus();
    loadCategories(currentDate);
    super.initState();
  }

  //MARK: loadCategories
  void loadCategories(DateTime currentDate) async {
    setState(() {
      is_loading = true;
    });
    categories = await CategoryService().getAllCategories();
    progressIndicators =
        await CardService.getProgressIndicatorsByMonth(currentDate);
    setState(() {
      is_loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + delta);
      loadCategories(currentDate);
    });
  }

  Widget _buildMonthSelector() {
    return MonthSelector(
      currentDate: currentDate,
      onChangeMonth: _changeMonth,
    );
  }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    setState(() {
      _isPro = isYearlyPro || isMonthlyPro;
    });

    // int usageCount = prefs.getInt('usage_count') ?? 0;
    // usageCount += 1;
    // await prefs.setInt('usage_count', usageCount);

    // if (!_isPro && usageCount > 40 && usageCount % 4 == 0) {
    // _showProModal(context);
    // }
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: AppColors.background1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.goalKey,
      appBar: CupertinoNavigationBar(
        middle: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text(widget.title,
                style: const TextStyle(color: AppColors.label, fontSize: 20))),
        backgroundColor: AppColors.background1,
      ),
      body: GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            if (!_isPro &&
                !Platform.isMacOS) // Se o usuário não é PRO, mostra o banner
              Container(
                height: 60,
                width: double.infinity, // Largura total da tela
                alignment: Alignment.center, // Centraliza no eixo X
                child: const BannerAdconstruct(),
              ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _buildMonthSelector(),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text("${Translateservice.formatCurrency(0, context)}",
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.label,
                            )),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Text("0% gasto",
                            style: TextStyle(
                              fontSize: 20,
                              color: AppColors.labelPlaceholder,
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 30,
                      animation: true,
                      lineHeight: 10.0,
                      animationDuration: 1000,
                      percent: 0 / 100,
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      barRadius: const Radius.circular(12),
                      backgroundColor: AppColors.card2,
                      progressColor: AppColors.labelPlaceholder,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                          "Orçamento total para um mês: ${Translateservice.formatCurrency(8000, context)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.labelPlaceholder,
                          )),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
            if (is_loading) ...[
              _buildLoadingIndicator(),
            ] else ...[
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: categories.length - 1,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print(index);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            Translateservice.getTranslatedCategoryName(
                              context,
                              categories[index].name,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.labelPlaceholder,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              color: categories[index].color.withOpacity(0.2),
                            ),
                            width: 50,
                            height: 50,
                            child: Icon(
                              categories[index].icon,
                              color: categories[index].color,
                            ),
                          ),
                          if ((categories[index].meta == 0)) ...[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: AppColors.modalBackground
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0, right: 4),
                                child: Text(
                                  AppLocalizations.of(context)!.set,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.button,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(Translateservice.formatCurrency(
                                categories[index].meta, context)),
                          ]
                        ],
                      ),
                    );
                  },
                ),
              )
            ]
          ],
        ),
      ),
      backgroundColor: AppColors.background1,
    );
  }
}
