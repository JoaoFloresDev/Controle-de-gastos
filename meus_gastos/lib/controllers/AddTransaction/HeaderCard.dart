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
import '../Transactions/InsertTransactions/ViewComponents/ValorTextField.dart';
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
      leftSymbol: currencySymbol,
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
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2D2D2D),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildCompactForm(),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Novo Gasto',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              DateFormat('dd/MM HH:mm').format(lastDateSelected),
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.calendar,
              color: CupertinoColors.activeBlue,
              size: 16,
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
          const SizedBox(height: 12),
          // Campo de Descrição
          _buildDescriptionField(),
          const SizedBox(height: 12),
          // Categorias
          _buildCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildValueFieldWithQuickButtons() {
    final quickValues = [5, 10, 20, 50];
    
    return Container(
      key: widget.valueExpens,
      padding: const EdgeInsets.all(12),
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
          ValorTextField(controller: valorController),
          const SizedBox(height: 8),
          // Botões de valores rápidos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: quickValues.map((value) {
              return _buildQuickValueButton(value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickValueButton(int value) {
    return GestureDetector(
      onTap: () {
        valorController.updateValue(value.toDouble());
        if (Platform.isIOS) {
          HapticFeedback.lightImpact();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CupertinoColors.systemGreen.withOpacity(0.3),
          ),
        ),
        child: Text(
          '+$value',
          style: const TextStyle(
            color: CupertinoColors.systemGreen,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      key: widget.description,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _buildCategoriesSection() {
    return Container(
      key: widget.categories,
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Categoria',
              style: TextStyle(
                color: CupertinoColors.white.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: CupertinoButton(
        key: widget.addButon,
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(14),
        onPressed: adicionar,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add_circled_solid,
              color: CupertinoColors.white,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Adicionar',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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