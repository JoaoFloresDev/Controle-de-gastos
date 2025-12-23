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
  final GlobalKey _valueKey = GlobalKey(); // MUDANÇA: Mover para o State

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
    return GestureDetector( // ADICIONADO: Previne que toques fora fechem o teclado
      onTap: () {
        // Não faz nada - previne propagação
      },
      child: Container(
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

              onCancelPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual, // ADICIONADO
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    _buildCategoryIcon(),
                    const SizedBox(height: 18),
                    _buildInputSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(context),
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
        width: 64,
        height: 64,
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

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.setGoal,
            style: const TextStyle(
              fontSize: 18,
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
            valueKey: _valueKey, // MUDANÇA: Usar a key do State
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
            color: AppColors.button
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

                  widget.initialValue > 0 ?
                  AppLocalizations.of(context)!.update : AppLocalizations.of(context)!.set,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.label,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),

        )
      ],
    );
  }
}