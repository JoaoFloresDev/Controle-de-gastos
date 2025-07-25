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

  bool _controllerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Só inicializa o controller uma vez
    if (!_controllerInitialized) {
      final locale = Localizations.localeOf(context);
      final currencySymbol = Translateservice.getCurrencySymbol(context);

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Category Icon with animation
                    _buildCategoryIcon(),

                    const SizedBox(height: 32),

                    // Current budget info (if exists)
                    if (widget.initialValue > 0) _buildCurrentBudgetInfo(),

                    const SizedBox(height: 24),

                    // Input section
                    _buildInputSection(context),

                    const SizedBox(height: 40),

                    // Action buttons
                    _buildActionButtons(context),

                    const SizedBox(height: 24),
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
          color: widget.category.color.withOpacity(0.1),
          border: Border.all(
            color: widget.category.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.category.color,
            boxShadow: [
              BoxShadow(
                color: widget.category.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.category.icon,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBudgetInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.currentBudget ??
                      'Orçamento Atual',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  Translateservice.formatCurrency(widget.initialValue, context),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade800,
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

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.setBudget ?? 'Definir Orçamento',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.label,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: AppColors.background1,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  Icons.attach_money,
                  color: widget.category.color,
                  size: 24,
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  child: ValorTextField(controller: valorController),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Quick amount buttons
        _buildQuickAmountButtons(),
      ],
    );
  }

  Widget _buildQuickAmountButtons() {
    final List<double> quickAmounts = [100, 250, 500, 1000];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickAmounts.map((amount) {
        return GestureDetector(
          onTap: () {
            setState(() {
              valorController.updateValue(amount);
            });

            // valorController.text = (amount * 100).toString();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.category.color.withOpacity(0.3),
              ),
            ),
            child: Text(
              'R\$ ${amount.toInt().toString()}',
              style: TextStyle(
                color: widget.category.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
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
            gradient: LinearGradient(
              colors: [
                widget.category.color,
                widget.category.color.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.category.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                adicionar();
                widget.loadCategories();
                widget.onChangeMeta();
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.update,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary action button (Clear/Reset)
        if (widget.initialValue > 0)
          Container(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                valorController.clear();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.clear ?? 'Limpar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
