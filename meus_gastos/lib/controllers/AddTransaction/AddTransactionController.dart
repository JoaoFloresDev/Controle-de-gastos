import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'HeaderCard.dart';
import 'VerticalCircleList.dart';
import 'CompactListCardRecorrent.dart';

class AddTransactionController extends StatefulWidget {
  const AddTransactionController({
    required this.onAddClicked,
    required this.title,
    required this.exportButton,
    required this.cardsExpensKey,
    required this.addButtonKey,
    required this.dateKey,
    required this.categoriesKey,
    required this.descriptionKey,
    required this.valueExpensKey,
    super.key,
  });

  final VoidCallback onAddClicked;
  final String title;
  final GlobalKey exportButton;
  final GlobalKey cardsExpensKey;
  final GlobalKey addButtonKey;
  final GlobalKey dateKey;
  final GlobalKey categoriesKey;
  final GlobalKey descriptionKey;
  final GlobalKey valueExpensKey;

  @override
  State<AddTransactionController> createState() => _AddTransactionControllerState();
}

class _AddTransactionControllerState extends State<AddTransactionController> with WidgetsBindingObserver {
  // MARK - Variables
  final GlobalKey<HeaderCardState> _headerCardKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<VerticalCircleListState> _verticalCircleListKey = GlobalKey();

  List<CardModel> _cardList = [];
  List<FixedExpense> _fixedCards = [];
  List<CardModel> _mergedList = [];

  bool _isPro = false;
  bool _keyboardVisible = false;

  // MARK - Lifecycle
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCards();
    _checkProStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // MARK - Observers
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final visible = bottomInset > 120.0;
    if (visible != _keyboardVisible) {
      setState(() => _keyboardVisible = visible);
    }
  }

  // MARK - Data Loading
  Future<void> _loadCards() async {
    _cardList = await service.CardService.retrieveCards();
    _fixedCards = await Fixedexpensesservice.getSortedFixedExpenses();
    _mergedList = await Fixedexpensesservice.MergeFixedWithNormal(_fixedCards, _cardList);
    setState(() {});
  }

  Future<void> _checkProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final yearly = prefs.getBool('yearly.pro') ?? false;
    final monthly = prefs.getBool('monthly.pro') ?? false;
    setState(() => _isPro = yearly || monthly);
    int count = prefs.getInt('usage_count') ?? 0;
    count++;
    await prefs.setInt('usage_count', count);
    if (!_isPro && count > 40 && count % 4 == 0) {
      // _showProModal();
    }
  }

  // MARK - Build
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.deferToChild,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background1,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCategoryList()),
            if (!_keyboardVisible) _buildInsertButton(),
            if (!_keyboardVisible) _buildSeparator(),
            if (!_keyboardVisible) _buildRecurringCard(),
          ],
        ),
      ),
    );
  }

  // MARK - UI Builders
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: CupertinoColors.black.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 5))],
          ),
        ),
        SafeArea(
          top: true,
          bottom: false,
          child: HeaderCard(
            key: _headerCardKey,
            addButon: widget.addButtonKey,
            categories: widget.categoriesKey,
            date: widget.dateKey,
            description: widget.descriptionKey,
            valueExpens: widget.valueExpensKey,
            onAddClicked: () async {
              widget.onAddClicked();
              await _loadCards();
            },
            onAddCategory: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) => Container(
                  height: MediaQuery.of(context).size.height - 70,
                  decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  child: Categorycreater(onCategoryAdded: () => _headerCardKey.currentState?.loadCategories()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return VerticalCircleList(
      key: _verticalCircleListKey,
      onItemSelected: (index) {
        final list = _verticalCircleListKey.currentState?.categorieList ?? [];
        if (list.isNotEmpty) {
          _headerCardKey.currentState?.lastIndexSelected = index;
          if (list[index].id == 'AddCategory') _verticalCircleListKey.currentState?.loadCategories();
        }
      },
      defaultdIndexCategory: 0,
    );
  }

  Widget _buildInsertButton() {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 12),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.button, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () => _headerCardKey.currentState?.adicionar(),
          child: Text('Insert Expense', style: TextStyle(color: AppColors.label, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Divider(thickness: 1),
    );
  }

  Widget _buildRecurringCard() {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 12),
      child: CompactListCardRecorrent(
        onTap: (card) => widget.onAddClicked(),
        card: CardModel(id: 'mock_id_1', amount: 123.45, description: 'Test purchase', date: DateTime.now(), category: CategoryModel(name: 'Food')),
        onAddClicked: _loadCards(),
      ),
    );
  }
}
