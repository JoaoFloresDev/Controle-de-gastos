import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Goals/GoalsViewModel.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/controllers/Goals/SetGoals/SetGoalScreen.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class Goalsscrean extends StatefulWidget {
  final String title;
  const Goalsscrean({super.key, required this.title});
  @override
  GoalsscreanState createState() => GoalsscreanState();
}

class GoalsscreanState extends State<Goalsscrean>
    with TickerProviderStateMixin {
  //MARK: - Variables
  late AnimationController _animationController;

  //MARK: - Life Cycle
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsViewModel>().init();
    });

    _animationController.forward();
  }

  Future<void> refreshGoals() async {
    context.read<GoalsViewModel>().init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GoalsViewModel>();
    return Scaffold(
      appBar: _buildAppBar(),
      body: GestureDetector(
        onTap: () {},
        child: ListView(
          children: [
            _buildAdBanner(),
            _buildHeaderSection(),
            if (viewModel.isLoading)
              _buildLoadingIndicator()
            else
              _buildCategoryGrid(viewModel),
          ],
        ),
      ),
      backgroundColor: AppColors.background1,
    );
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
    return const BannerAdconstruct();
  }

  Widget _buildHeaderSection() {
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
        child: Consumer<GoalsViewModel>(builder: (context, viewModel, child) {
          viewModel.formatDate(context);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      viewModel.formattedDate,
                      style: const TextStyle(
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Translateservice.formatCurrency(
                          viewModel.totalExpenses, context),
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.label,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: viewModel.totalExpenseIsOverGoal()
                            ? AppColors.deletionButton.withOpacity(0.1)
                            : AppColors.labelPlaceholder.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${viewModel.totalProgressPercent.round()}%",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: viewModel.totalExpenseIsOverGoal()
                              ? AppColors.deletionButton
                              : AppColors.labelSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              LinearPercentIndicator(
                animation: true,
                animationDuration: 1000,
                lineHeight: 10.0,
                percent: viewModel.totalProgressPercent / 100,
                barRadius: const Radius.circular(8),
                linearStrokeCap: LinearStrokeCap.roundAll,
                backgroundColor: Colors.grey.withOpacity(0.2),
                progressColor: viewModel.totalExpenseIsOverGoal()
                    ? AppColors.deletionButton
                    : AppColors.button,
              ),
              const SizedBox(height: 12),

              // Orçamento total
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.totalGoalForMonth}:",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.labelPlaceholder,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Translateservice.formatCurrency(
                          viewModel.totalGoal, context),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryGrid(GoalsViewModel viewModel) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (viewModel.isLoading) return const LoadingContainer();
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _animationController.value)),
          child: Opacity(
              opacity: _animationController.value,
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildGrid(viewModel))),
        );
      },
    );
  }

  Widget _buildGrid(GoalsViewModel viewModelParent) {
    return Consumer<GoalsViewModel>(
      builder: (context, viewModel, child) => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: 200,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final spent =
              viewModel.expensByCategoryOfCurrentMonth[category.id] ?? 0;
          final goal = viewModel.goalsByCategory[category.id] ?? 0;
          final isOverGoal = spent > goal;

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
                      initialValue: goal,
                      addGoal: (newGoalCategoryId, newGoalValue) {
                        viewModel.addGoal(newGoalCategoryId, newGoalValue);
                      },
                    ),
                  );
                },
              );
            },
            child: _buildCategoryCard(category, spent, goal, isOverGoal),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
      CategoryModel category, double spent, double goal, bool isOverGoal) {
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
          color: isOverGoal
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
            percent: (spent > goal)
                ? 1
                : goal > 0
                    ? (spent / goal).clamp(0.0, 1.0)
                    : 0,
            center: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 24,
                ),
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: isOverGoal
                ? AppColors.deletionButton.withOpacity(0.9)
                : category.color.withOpacity(0.9),
            backgroundColor: AppColors.card,
          ),
          const SizedBox(height: 12),
          if (goal == 0 && spent == 0)
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
                    color: isOverGoal
                        ? AppColors.deletionButton
                        : AppColors.button,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Translateservice.formatCurrency(goal, context),
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
