import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCardRecorrent.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'HeaderCard.dart';
import 'VerticalCircleList.dart';

class AddTransactionController extends StatefulWidget {
  const AddTransactionController({
    required this.onAddClicked,
    required this.title,
    required this.exportButon,
    required this.cardsExpens,
    required this.addButon,
    required this.date,
    required this.categories,
    required this.description,
    required this.valueExpens,
    super.key,
  });

  final VoidCallback onAddClicked;
  final String title;
  final GlobalKey exportButon;
  final GlobalKey cardsExpens;
  final GlobalKey valueExpens;
  final GlobalKey date;
  final GlobalKey description;
  final GlobalKey categories;
  final GlobalKey addButon;

  @override
  State<AddTransactionController> createState() => _AddTransactionControllerState();
}

class _AddTransactionControllerState extends State<AddTransactionController> {
  final GlobalKey<HeaderCardState> _headerCardKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<VerticalCircleListState> _verticalCircleListKey = GlobalKey();

  List<CardModel> cardList = [];
  List<FixedExpense> fixedCards = [];
  List<CardModel> mergeCardList = [];

  final String yearlyProId = 'yearly.pro';
  final String monthlyProId = 'monthly.pro';
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    loadCards();
    _checkUserProStatus();
  }

  Future<void> loadCards() async {
    cardList = await service.CardService.retrieveCards();
    fixedCards = await Fixedexpensesservice.getSortedFixedExpenses();
    mergeCardList = await Fixedexpensesservice.MergeFixedWithNormal(fixedCards, cardList);
    setState(() {});
  }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isYearly = prefs.getBool(yearlyProId) ?? false;
    final isMonthly = prefs.getBool(monthlyProId) ?? false;

    setState(() {
      _isPro = isYearly || isMonthly;
    });

    int usageCount = prefs.getInt('usage_count') ?? 0;
    usageCount++;
    await prefs.setInt('usage_count', usageCount);

    if (!_isPro && usageCount > 40 && usageCount % 4 == 0) {
      _showProModal();
    }
  }

  void _showProModal() {
    if (Platform.isIOS || Platform.isMacOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => ProModal(
          isLoading: false,
          onSubscriptionPurchased: () => setState(() => _isPro = true),
        ),
      );
    } else if (Platform.isAndroid) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => ProModalAndroid(
          isLoading: false,
          onSubscriptionPurchased: () => setState(() => _isPro = true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // A SOLUÇÃO: Ter apenas UM GestureDetector envolvendo o Scaffold é a abordagem
    // mais limpa e eficaz, como visto no seu exemplo que funciona.
    return GestureDetector(
      // onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background1,
        // resizeToAvoidBottomInset deve ser false quando se usa SingleChildScrollView
        // para evitar que o Flutter tente redimensionar duas vezes.
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: HeaderCard(
                  key: _headerCardKey,
                  addButon: widget.addButon,
                  categories: widget.categories,
                  date: widget.date,
                  description: widget.description,
                  valueExpens: widget.valueExpens,
                  onAddClicked: () async {
                    widget.onAddClicked();
                    await loadCards();
                  },
                  onAddCategory: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (_) => Container(
                        height: MediaQuery.of(context).size.height - 70,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Categorycreater(
                          onCategoryAdded: () {
                            _headerCardKey.currentState?.loadCategories();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCategoryList(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                // Ação do botão principal
                // Note que o HeaderCard tem seu próprio botão de adicionar.
                // Talvez você queira chamar o mesmo método aqui.
                _headerCardKey.currentState?.adicionar();
                await loadCards();
              },
              child: const Text(
                'Inserir Despesa',
                style: TextStyle(
                  color: AppColors.label,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      key: widget.categories,
      height: 250,
      child: VerticalCircleList(
        key: _verticalCircleListKey,
        onItemSelected: (index) {
          final list = _verticalCircleListKey.currentState?.categorieList ?? [];
          if (list.isNotEmpty && list[index].id == 'AddCategory') {
            _verticalCircleListKey.currentState?.loadCategories();
          }
        },
        defaultdIndexCategory: 0,
      ),
    );
  }

  void _showCupertinoModalBottomFixedExpenses() {
    // FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height - 70,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CriarGastosFixos(
          onAddPressedBack: () => loadCards(),
        ),
      ),
    );
  }
}