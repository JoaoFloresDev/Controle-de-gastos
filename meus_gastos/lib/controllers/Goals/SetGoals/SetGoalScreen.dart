import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValueInputSection.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class SetGoalsScreen extends StatefulWidget {
  final CategoryModel category;
  final double initialValue;
  final Function(String newGoalCategoryId, double newGoalValue) addGoal;
  const SetGoalsScreen({
    super.key,
    required this.category,
    required this.initialValue,
    required this.addGoal,
  });

  @override
  SetSetGoalsState createState() => SetSetGoalsState();
}

class SetSetGoalsState extends State<SetGoalsScreen> {
  late MoneyMaskedTextController valorController;
  bool _controllerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_controllerInitialized) {
      final locale = Localizations.localeOf(context);
      final currencySymbol = TranslateService.getCurrencySymbol(context);

      valorController = MoneyMaskedTextController(
        leftSymbol: currencySymbol,
        decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
        initialValue: widget.initialValue,
      );

      _controllerInitialized = true;
    }
  }

  @override
  void dispose() {
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background1,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomHeader(
            title: TranslateService.getTranslatedCategoryName(
                context, widget.category.name),
            onCancelPressed: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  _buildCategoryIcon(),
                  const SizedBox(height: 16),
                  if (widget.initialValue > 0) ...[
                    _buildCurrentGoalInfo(),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 8),
                  _buildInputSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Hero(
      tag: 'category_${widget.category.id}',
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.card.withOpacity(0.5),
          border: Border.all(
            color: AppColors.label.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            widget.category.icon,
            size: 32,
            color: widget.category.color,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentGoalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.label.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.label.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.flag_outlined,
              color: AppColors.label.withOpacity(0.6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.currentGoal,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.labelPlaceholder.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslateService.formatCurrency(widget.initialValue, context),
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.label,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.setGoal,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.label.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: ValueInputSection(
            valueKey: GlobalKey(),
            controller: valorController,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botão principal
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.button,
            boxShadow: [
              BoxShadow(
                color: AppColors.button.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                widget.addGoal(widget.category.id, valorController.numberValue);
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.update,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (widget.initialValue > 0) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.transparent,
              border: Border.all(
                color: AppColors.label.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  valorController.updateValue(0);
                },
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.clear,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.labelPlaceholder.withOpacity(0.8),
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}