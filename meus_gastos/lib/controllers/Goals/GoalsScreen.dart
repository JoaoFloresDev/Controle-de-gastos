import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/controllers/Dashboards/ViewComponents/LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/controllers/Goals/GoalsService.dart';
import 'package:meus_gastos/controllers/Goals/SetGoals/SetBudgetScreen.dart';
import 'package:meus_gastos/controllers/Goals/SetGoals/SetBudgetScreen.dart';
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

class GoalsscreanState extends State<Goalsscrean> with TickerProviderStateMixin {
  //MARK: - Variables
  bool _isPro = false;
  late AnimationController _animationController;

  List<CategoryModel> categories = [];
  List<ProgressIndicatorModel> progressIndicators = [];
  DateTime currentDate = DateTime.now();
  Map<String, double> metas_por_categoria = {};
  Map<String, double> gastosPorCategoria = {};
  bool is_loading = true;
  double totalGasto = 0;
  double orcamentoTotal = 0;
  String formattedDate = "";

  //MARK: - Life Cycle
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _checkUserProStatus();
    loadCategoriesGoals();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  

@override
Widget build(BuildContext context) {
  final DateFormat format =
      DateFormat('MMMM yyyy', Localizations.localeOf(context).toString());
  formattedDate = format.format(currentDate);
  formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

  return Scaffold(
    appBar: _buildAppBar(),
    body: GestureDetector(
      onTap: () {},
      child: ListView(
        children: [
          if (!_isPro && !Platform.isMacOS) _buildAdBanner(),
          _buildHeaderSection(),
          if (is_loading)
            _buildLoadingIndicator()
          else
            _buildCategoryGrid(),
        ],
      ),
    ),
    backgroundColor: AppColors.background1,
  );
}

  //MARK: - Load Data
  Future<void> loadCategoriesGoals() async {
    setState(() {
      is_loading = true;
    });
    categories = await CategoryService().getAllCategories();
    print(categories.length);
    progressIndicators =
        await CardService.getProgressIndicatorsByMonth(currentDate);
    gastosPorCategoria = {
      for (var item in progressIndicators) item.category.id: item.progress
    };
    totalGasto = progressIndicators.fold(
        0.0, (sum, indicator) => sum + indicator.progress);
    orcamentoTotal = await GoalsService().getTotalBudget();
    metas_por_categoria = await GoalsService().getBudgets();
    
    setState(() {
      is_loading = false;
    });
    _animationController.forward();
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

//MARK: - Components
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.button,
                AppColors.button.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.button.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }

PreferredSizeWidget _buildAppBar() {
  return CupertinoNavigationBar(
    backgroundColor: AppColors.background1,
    middle: Text(
      widget.title,
      style: const TextStyle(color: AppColors.label, fontSize: 20),
    ),
  );
}

Widget _buildAdBanner() {
  return Container(
    height: 60,
    width: double.infinity,
    alignment: Alignment.center,
    child: const BannerAdconstruct()
  );
}
Widget _buildHeaderSection() {
  final progressPercentage = orcamentoTotal == 0 
      ? (totalGasto > 0 ? 100 : 0)
      : (totalGasto / orcamentoTotal * 100).clamp(0, 100);
  
  final isOverBudget = totalGasto > orcamentoTotal && orcamentoTotal > 0;
  
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 20, 16, 6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.card.withOpacity(0.7),
          AppColors.card.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.label.withOpacity(0.06),
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 4, right: 4),
      child: Column(
        children: [
          // Data e percentual
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
      child:
          Row(
            children: [
             Text(
                  formattedDate,
                  style: TextStyle(
                    color: AppColors.label,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              const Spacer(),
            ],
          ),
          ),
          const SizedBox(height: 16),
          
          // Valor gasto
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
      child:
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Translateservice.formatCurrency(totalGasto, context),
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.label,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 14),
                            Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.deletionButton.withOpacity(0.1)
                      : AppColors.labelPlaceholder.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${progressPercentage.round()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget
                        ? AppColors.deletionButton
                        : AppColors.labelSecondary,
                  ),
                ),
              ),
            ],
          ),
          ),
          const SizedBox(height: 14),
          
          // Barra de progresso
LinearPercentIndicator(
  animation: true,
  animationDuration: 1000,
  lineHeight: 10.0,
  percent: orcamentoTotal == 0
      ? (totalGasto > 0 ? 1 : 0)
      : (totalGasto / orcamentoTotal).clamp(0.0, 1.0),
  barRadius: const Radius.circular(8),
  linearStrokeCap: LinearStrokeCap.roundAll,
  backgroundColor: Colors.grey.withOpacity(0.2),
  progressColor: isOverBudget
      ? AppColors.deletionButton
      : AppColors.button,
),
          const SizedBox(height: 12),
          
          // Orçamento total
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
      child:
          Row(
            children: [
              Text(
                "${AppLocalizations.of(context)!.totalBudgetForMonth}:",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.labelPlaceholder,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                Translateservice.formatCurrency(orcamentoTotal, context),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),),
        ],
      ),
    ),
  );
}

Widget _buildCategoryGrid() {
  return AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(0, 30 * (1 - _animationController.value)),
        child: Opacity(
          opacity: _animationController.value,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                mainAxisExtent: 200,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length - 1,
              itemBuilder: (context, index) {
                final category = categories[index];
                final spent = gastosPorCategoria[category.id] ?? 0;
                final budget = metas_por_categoria[category.id] ?? 0;
                final isOverBudget = spent > budget && budget > 0;

                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: SetGoalsScreen(
                            category: category,
                            initialValue: budget,
                            loadCategories: () {
                              setState(() {
                                loadCategoriesGoals();
                              });
                            },
                            onChangeMeta: widget.onChangeMeta,
                          ),
                        );
                      },
                    );
                  },
                  child: _buildCategoryCard(category, spent, budget, isOverBudget),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildCategoryCard(CategoryModel category, double spent, double budget, bool isOverBudget) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    padding: const EdgeInsets.only(top: 12, bottom: 12, left: 8, right: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.card.withOpacity(0.4),
          AppColors.card.withOpacity(0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isOverBudget
            ? AppColors.deletionButton.withOpacity(0.3)
            : AppColors.label.withOpacity(0.12),
        width: 1.5,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          Translateservice.getTranslatedCategoryName(context, category.name),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.label,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 8),
        CircularPercentIndicator(
          radius: 35.0,
          lineWidth: 6.0,
          animation: true,
          animationDuration: 1200,
          percent: (spent > budget && budget > 0)
              ? 1
              : budget > 0
                  ? (spent / budget).clamp(0.0, 1.0)
                  : 0,
          center: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.color,
                  category.color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: category.color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                category.icon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: isOverBudget
              ? AppColors.deletionButton.withOpacity(0.9)
              : category.color.withOpacity(0.9),
          backgroundColor: AppColors.card,
        ),
        const SizedBox(height: 12),
        if (budget == 0 && spent == 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.button,
                  AppColors.button.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context)!.set,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Column(
            children: [
              Text(
                Translateservice.formatCurrency(spent, context),
                style: TextStyle(
                  color: isOverBudget
                      ? AppColors.deletionButton
                      : AppColors.button,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Translateservice.formatCurrency(budget, context),
                style: const TextStyle(
                  color: AppColors.labelPlaceholder,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

}