import 'package:meus_gastos/controllers/CardDetails/ViewComponents/CampoComMascara.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/designSystem/Components/CustomHeader.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/UI/HorizontalCircleList.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import '../CardDetailsScene/DetailScreen.dart';
import 'ListCardFixeds.dart';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/Header/ValorTextField.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'RepetitionMenu.dart';
import 'AdditionTypeSelector.dart';

class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.valorFieldKey,
    required this.valorController,
    required this.descricaoController,
    required this.selectedDate,
    required this.repetitionType,
    required this.tipoAdicao,
    required this.icons_list_recorrent,
    required this.lastIndexSelected_category,
    required this.onDateChanged,
    required this.onRepetitionChanged,
    required this.onAdditionTypeChanged,
    required this.onCategoryChanged,
    required this.onAddPressed,
  });

  final GlobalKey<ValorTextFieldState> valorFieldKey;
  final MoneyMaskedTextController valorController;
  final TextEditingController descricaoController;
  final DateTime selectedDate;
  final String repetitionType;
  final String tipoAdicao;
  final List<CategoryModel> icons_list_recorrent;
  final int lastIndexSelected_category;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onRepetitionChanged;
  final ValueChanged<String> onAdditionTypeChanged;
  final ValueChanged<int> onCategoryChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: 0.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ValorTextField(
                  key: valorFieldKey,
                  controller: valorController,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CampoComMascara(
                  currentDate: selectedDate,
                  onCompletion: onDateChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.white,
                ),
              ),
            ),
            placeholder: AppLocalizations.of(context)!.description,
            placeholderStyle: TextStyle(
                color: CupertinoColors.white.withOpacity(0.5)),
            style: const TextStyle(color: CupertinoColors.white),
            controller: descricaoController,
          ),
          const SizedBox(height: 20),
          HorizontalCircleList(
            onItemSelected: onCategoryChanged,
            icons_list_recorrent: icons_list_recorrent,
            defaultIndexCategory: lastIndexSelected_category,
          ),
          const SizedBox(height: 18),
          RepetitionMenu(
            referenceDate: selectedDate,
            onRepetitionSelected: onRepetitionChanged,
            defaultRepetition: repetitionType,
          ),
          const SizedBox(height: 10),
          AdditionTypeSelector(
            selectedType: tipoAdicao,
            onTypeSelected: onAdditionTypeChanged,
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.button,
                onPressed: onAddPressed,
                child: Text(
                  AppLocalizations.of(context)!.add,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.label),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}