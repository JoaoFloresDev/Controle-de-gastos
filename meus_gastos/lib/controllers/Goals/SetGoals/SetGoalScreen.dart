import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValueInputSection.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart'
    show ValorTextField;
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
              title: TranslateService.getTranslatedCategoryName(
                  context, widget.category.name),
              onCancelPressed: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCategoryIcon(),
                    const SizedBox(height: 16),
                    if (widget.initialValue > 0) ...[
                      _buildCurrentGoalInfo(),
                      const SizedBox(height: 20),
                    ] else
                      const SizedBox(height: 8),
                    _buildInputSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Hero(
      tag: 'category_${widget.category.id}',
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade900.withOpacity(0.8),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 1.5,
          ),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.category.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.savings_outlined,
              color: widget.category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.currentGoal,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslateService.formatCurrency(widget.initialValue, context),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.setGoal,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Expanded(child: SizedBox())
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade700,
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
        // Primary action button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.button,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                widget.addGoal(widget.category.id, valorController.numberValue);
                Navigator.of(context).pop();
              },
              child: const Center(
                child: Text(
                  "Atualizar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary action button (Clear/Reset)
        if (widget.initialValue > 0)
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              border: Border.all(
                color: Colors.grey.shade600,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  valorController.updateValue(0);
                },
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.clear,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
