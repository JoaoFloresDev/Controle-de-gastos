import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'ValorTextField.dart';
import '../Transactions/InsertTransactions/ViewComponents/CampoComMascara.dart';
import '../Transactions/InsertTransactions/ViewComponents/CustomButton.dart';
import 'VerticalCircleList.dart';

class HeaderCard extends StatefulWidget {
  final VoidCallback onAddClicked;
  final VoidCallback onAddCategory;
  final GlobalKey valueExpens;
  final GlobalKey date;
  final GlobalKey description;
  final GlobalKey categories;
  final GlobalKey addButon;

  const HeaderCard({
    required this.onAddClicked,
    required this.onAddCategory,
    required super.key,
    required this.valueExpens,
    required this.date,
    required this.description,
    required this.categories,
    required this.addButon,
  });

  @override
  HeaderCardState createState() => HeaderCardState();
}

class HeaderCardState extends State<HeaderCard> with TickerProviderStateMixin {
  late final MoneyMaskedTextController valorController;
  late final CampoComMascara dateController;
  final descricaoController = TextEditingController();
  final GlobalKey<VerticalCircleListState> _verticalCircleListKey = GlobalKey();
  DateTime lastDateSelected = DateTime.now();
  int lastIndexSelected = 0;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _fadeController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verticalCircleListKey.currentState?.loadCategories();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final currencySymbol = Translateservice.getCurrencySymbol(context);

    valorController = MoneyMaskedTextController(
      leftSymbol: '$currencySymbol ',
      decimalSeparator: locale.languageCode == 'pt' ? ',' : '.',
      initialValue: 0.0,
    );

    dateController = CampoComMascara(
      currentDate: lastDateSelected,
      onCompletion: (dateTime) => lastDateSelected = dateTime,
    );
  }

  Future<void> loadCategories() async {
    _verticalCircleListKey.currentState?.loadCategories();
  }

  void adicionar() async {
    if (Platform.isIOS) {
      HapticFeedback.mediumImpact();
    }
    
    final categories = _verticalCircleListKey.currentState?.categorieList ?? [];
    final selectedCategory = categories[lastIndexSelected];

    final newCard = CardModel(
      amount: valorController.numberValue,
      description: descricaoController.text,
      date: lastDateSelected,
      category: selectedCategory,
      id: CardService.generateUniqueId(),
    );

    if (newCard.amount > 0) {
      CardService.addCard(newCard);
      await CategoryService.incrementCategoryFrequency(selectedCategory.id);
    }

    setState(() {
      valorController.updateValue(0.0);
      descricaoController.clear();
      _verticalCircleListKey.currentState?.loadCategories();
    });

    Future.delayed(const Duration(milliseconds: 200), widget.onAddClicked);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildCompactForm(),
          ],
        ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 20, bottom: 8, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Registrar Gasto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
            ),
          ),
          _buildDateSelector(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _showDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.activeBlue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.activeBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm  dd/MM').format(lastDateSelected),
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Campo de Valor com Botões Rápidos
          _buildValueFieldWithQuickButtons(),
          const SizedBox(height: 8),
          _buildDescriptionField(),
          const SizedBox(height: 12)
        ],
      ),
    );
  }

Widget _buildValueFieldWithQuickButtons() {
  final positiveValues = [5, 10, 20, 50, 100, 200];
  final negativeValues = [-5, -10, -20, -50, -100, -200];
  
  return Container(
    key: widget.valueExpens,
    // padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CupertinoColors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: CupertinoColors.white.withOpacity(0.1),
      ),
    ),
    child: Column(
      children: [
        // Campo de valor
        Container(
          child: ValorTextField(controller: valorController),
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 0),
        ),
        const SizedBox(height: 16),
        
        // Botões de valores positivos
        _buildQuickButtonsRow(
          title: 'Adicionar',
          values: positiveValues,
          isPositive: true,
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

Widget _buildQuickButtonsRow({
  required String title,
  required List<int> values,
  required bool isPositive,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 55,
        child: ListView.separated(
          // MUDANÇA: Adiciona um padding horizontal de 8px.
          // Isso cria o espaço no início e no fim da lista.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: values.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final value = values[index];
            return _buildQuickValueButton(value, isPositive);
          },
        ),
      ),
    ],
  );
}

Widget _buildQuickValueButton(int value, bool isPositive) {
  final absValue = value.abs();
  final currentValue = valorController.numberValue;
  
  return GestureDetector(
    onTap: () {
      if (isPositive) {
        valorController.updateValue(currentValue + absValue);
      } else {
        final newValue = (currentValue - absValue).clamp(0.0, double.infinity);
        valorController.updateValue(newValue);
      }
      
      if (Platform.isIOS) {
        HapticFeedback.lightImpact();
      }
    },
    child: Container(
      width: 66,
      height: 44,
      decoration: BoxDecoration(
        color: isPositive 
          ? CupertinoColors.systemGreen.withOpacity(0.15)
          : CupertinoColors.systemRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
            ? CupertinoColors.systemGreen.withOpacity(0.3)
            : CupertinoColors.systemRed.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isPositive ? '+' : '-',
            style: TextStyle(
              color: isPositive 
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemRed,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$absValue',
            style: TextStyle(
              color: isPositive 
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemRed,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildDescriptionField() {
    return Container(
      key: widget.description,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.1),
        ),
      ),
      child: CupertinoTextField(
        decoration: const BoxDecoration(),
        placeholder: AppLocalizations.of(context)!.description,
        placeholderStyle: TextStyle(
          color: CupertinoColors.white.withOpacity(0.5),
          fontSize: 16,
        ),
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 16,
        ),
        controller: descricaoController,
        textCapitalization: TextCapitalization.sentences,
        maxLines: 1,
      ),
    );
  }

  Future<void> _showDatePicker() async {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    }
    
    await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const Text(
                    'Data e Hora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: lastDateSelected,
                onDateTimeChanged: (newDate) {
                  setState(() {
                    lastDateSelected = newDate;
                  });
                },
                mode: CupertinoDatePickerMode.dateAndTime,
                use24hFormat: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}