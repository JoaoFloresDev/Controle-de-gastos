import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/controllers/orcamentos/goalsService.dart';
import 'package:meus_gastos/controllers/orcamentos/setBudget.dart';
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
    loadCategories();
  }

  //MARK: loadCategories
  Future<void> loadCategories() async {
    setState(() {
      is_loading = true;
    });
    categories = await CategoryService().getAllCategories();
    // gasto por categoria
    progressIndicators =
        await CardService.getProgressIndicatorsByMonth(currentDate);
    var _gastosPorCategoria = {
      for (var item in progressIndicators) item.category.id: item.progress
    };
    var _totalGasto = progressIndicators.fold(
        0.0, (sum, indicator) => sum + indicator.progress);
    var _orcamentoTotal = await Goalsservice().getTotalBudget();
    // metas por categoria
    var _metas_por_categoria = await Goalsservice().getBudgets();
    // metas_por_categoria.forEach((met, value) {
    //   print("${met} : ${value}");
    // });
    categories.forEach((category) {
      final meta = metas_por_categoria[category.id];
      print('Meta da categoria ${category.name}: ${meta ?? "sem meta"}');
    });
    print("++++++++${orcamentoTotal}");
    setState(() {
      gastosPorCategoria = _gastosPorCategoria;
      orcamentoTotal = _orcamentoTotal;
      metas_por_categoria = _metas_por_categoria;
      totalGasto = _totalGasto;
      is_loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chama sempre que voltar para a tela
    loadCategories();
  }

  Future<void> refreshBudgets() async {
    await loadCategories();
    setState(() {});
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
                          "${orcamentoTotal == 0 ? 0 : (totalGasto / orcamentoTotal * 100).round()}% gasto",
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
                        ? 0
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
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
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
                              child: Setbudget(
                                  category: categories[index],
                                  initialValue: (metas_por_categoria[
                                          categories[index].id] ??
                                      0),
                                  loadCategories: () async {
                                    await loadCategories();
                                    setState(() {});
                                  }, 
                                  onChangeMeta: widget.onChangeMeta,),
                                  
                            );
                          });
                    },
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
                              width: 40,
                              height: 40,
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
                                    ? AppColors.deletionButton
                                    : categories[index].color,
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
                                padding:
                                    const EdgeInsets.only(left: 4.0, right: 4),
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
                  );
                },
              )
            ]
          ],
        ),
      ),
      backgroundColor: AppColors.background1,
    );
  }
}
