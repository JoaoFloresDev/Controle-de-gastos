import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/controllers/orcamentos/goalsService.dart';
import 'package:meus_gastos/controllers/orcamentos/setBudget.dart';
import 'package:meus_gastos/controllers/orcamentos/teste.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Goalsscrean extends StatefulWidget {
  final String title;
  final VoidCallback onChangeMeta;
  Goalsscrean({Key? key, required this.title, required this.onChangeMeta})
      : super(key: key);
  GoalsscreanState createState() => GoalsscreanState();
}

class GoalsscreanState extends State<Goalsscrean> {
  bool _isPro = false;

  List<CategoryModel> categories = [];
  List<ProgressIndicatorModel> progressIndicators = [];
  DateTime currentDate = DateTime.now();
  Map<String, double> metas_por_categoria = {};
  Map<String, double> gastosPorCategoria = {};
  bool is_loading = true;
  double totalGasto = 0;
  double orcamentoTotal = 0;
  String formattedDate = "";
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    _checkUserProStatus();
    loadCategoriesGoals();
  }

  //MARK: loadCategoriesGoals
  Future<void> loadCategoriesGoals() async {
    setState(() {
      is_loading = true;
    });
    categories = await CategoryService().getAllCategories();
    progressIndicators =
        await CardService.getProgressIndicatorsByMonth(currentDate);
    // gasto por categoria
    gastosPorCategoria = {
      for (var item in progressIndicators) item.category.id: item.progress
    };
    totalGasto = progressIndicators.fold(
        0.0, (sum, indicator) => sum + indicator.progress);
    orcamentoTotal = await Goalsservice().getTotalBudget();
    // metas por categoria
    metas_por_categoria = await Goalsservice().getBudgets();

    // categories.forEach((category) {
    //   final meta = metas_por_categoria[category.id];
    //   print('Meta da categoria ${category.name}: ${meta ?? "sem meta"}');
    // });
    // print("++++++++${orcamentoTotal}");
    setState(() {
      is_loading = false;
    });
  }

  Future<void> refreshBudgets() async {
    setState(() {
      loadCategoriesGoals();
    });
  }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    setState(() {
      _isPro = isYearlyPro || isMonthlyPro;
    });
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: AppColors.background1);
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat format =
        DateFormat('MMMM yyyy', Localizations.localeOf(context).toString());
    formattedDate = format.format(currentDate);
    formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text(widget.title,
                style: const TextStyle(color: AppColors.label, fontSize: 20))),
        backgroundColor: AppColors.background1,
      ),
      body: GestureDetector(
        onTap: () {},
        child: ListView(
          children: [
            if (!_isPro &&
                !Platform.isMacOS) // Se o usuário não é PRO, mostra o banner
              Container(
                height: 60,
                width: double.infinity, // Largura total da tela
                alignment: Alignment.center, // Centraliza no eixo X
                child: const BannerAdconstruct(),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.label,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Text(
                          "${Translateservice.formatCurrency(totalGasto, context)}",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.label,
                          )),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Text(
                          "${orcamentoTotal == 0 ? '-' : (totalGasto / orcamentoTotal * 100).round()}% gasto",
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
                    percent: orcamentoTotal == 0
                        ? totalGasto > 0
                            ? 1
                            : 0
                        : (totalGasto / orcamentoTotal) > 1
                            ? 1
                            : (totalGasto / orcamentoTotal),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    barRadius: const Radius.circular(12),
                    backgroundColor: AppColors.card2,
                    progressColor: totalGasto > orcamentoTotal
                        ? AppColors.deletionButton
                        : AppColors.button,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                        "${AppLocalizations.of(context)!.totalBudgetForMonth}: ${Translateservice.formatCurrency(orcamentoTotal, context)}",
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
            if (is_loading) ...[
              _buildLoadingIndicator(),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: categories.length - 1,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print(index);
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                height: MediaQuery.of(context).size.height * 0.9,
                                child: SetbudgetTeste(
                                  category: categories[index],
                                  initialValue: (metas_por_categoria[
                                          categories[index].id] ??
                                      0),
                                  loadCategories: () {
                                    setState(() {
                                      loadCategoriesGoals();
                                    });
                                  },
                                  onChangeMeta: widget.onChangeMeta,
                                ),
                              );
                            });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.black.withOpacity(0.3),
                          // color: AppColors.background1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:(gastosPorCategoria[categories[index].id] ??
                                                0) >
                                            (metas_por_categoria[
                                                    categories[index].id] ??
                                                1)
                                        ? AppColors.deletionButton.withOpacity(0.12)
                                        : AppColors.label.withOpacity(0.12),
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
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
                              CircularPercentIndicator(
                                radius: 40.0,
                                lineWidth: 5.0,
                                animation: true,
                                percent: (gastosPorCategoria[
                                                categories[index].id] ??
                                            0) >
                                        (metas_por_categoria[
                                                categories[index].id] ??
                                            1)
                                    ? 1
                                    : (gastosPorCategoria[categories[index].id] ??
                                            0) /
                                        (metas_por_categoria[
                                                categories[index].id] ??
                                            1),
                                center: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    // color:
                                    //     categories[index].color.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      categories[index].icon,
                                      color: categories[index].color,
                                    ),
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor:
                                    (gastosPorCategoria[categories[index].id] ??
                                                0) >
                                            (metas_por_categoria[
                                                    categories[index].id] ??
                                                1)
                                        ? AppColors.deletionButton.withOpacity(0.9)
                                        : categories[index].color.withOpacity(0.9),
                                backgroundColor: AppColors.card,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              if (((metas_por_categoria[categories[index].id] ??
                                          0) ==
                                      0) &&
                                  ((gastosPorCategoria[categories[index].id] ??
                                          0) ==
                                      0)) ...[
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: AppColors.modalBackground),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0, right: 4),
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
                                Column(
                                  children: [
                                    Text(
                                      Translateservice.formatCurrency(
                                          (gastosPorCategoria[
                                                  categories[index].id] ??
                                              0),
                                          context),
                                      style: TextStyle(
                                          color: (gastosPorCategoria[
                                                          categories[index].id] ??
                                                      0) >
                                                  (metas_por_categoria[
                                                          categories[index].id] ??
                                                      0)
                                              ? AppColors.deletionButton
                                              : AppColors.button,
                                          fontSize: 12),
                                    ),
                                    Text(
                                        Translateservice.formatCurrency(
                                            (metas_por_categoria[
                                                    categories[index].id] ??
                                                0),
                                            context),
                                        style: const TextStyle(
                                            color: AppColors.label, fontSize: 12))
                                  ],
                                )
                              ]
                            ],
                          ),
                        ),
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
