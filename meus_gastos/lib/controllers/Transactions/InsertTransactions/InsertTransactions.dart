import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/comprarPro/Buyscreen.dart';
import 'package:meus_gastos/controllers/Transactions/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/ListCard.dart';
import 'package:meus_gastos/gastos_fixos/criar_gastosFixos.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'ViewComponents/HeaderCard.dart';
import 'ViewComponents/ListCard.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/Transactions/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/Transactions/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import '../../../controllers/Transactions/Purchase/ProModal.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// import 'package:meus_gastos/widgets/Transactions/CategoryCreater/CategoryCreater.dart';
// import 'package:meus_gastos/widgets/ads_review/constructReview.dart';
// import 'package:meus_gastos/widgets/ads_review/bannerAdconstruct.dart';
// import 'package:meus_gastos/widgets/Transactions/exportExcel/exportExcelScreen.dart';

class InsertTransactions extends StatefulWidget {
  const InsertTransactions({
    required this.onAddClicked,
    Key? key,
    required this.title,
    required this.exportButon,
    required this.cardsExpens,
    required this.addButon,
    required this.date,
    required this.categories,
    required this.description,
    required this.valueExpens,
  }) : super(key: key);

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
  State<InsertTransactions> createState() => _InsertTransactionsState();
}

class _InsertTransactionsState extends State<InsertTransactions> {
  List<CardModel> cardList = [];
  List<FixedExpense> fixedCards = [];
  List<CardModel> mergeCardList = [];
  final GlobalKey<HeaderCardState> _headerCardKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showHeaderCard = true;

  // Variáveis para In-App Purchase
  final String yearlyProId = 'yearly.pro';
  final String monthlyProId = 'monthly.pro';
  bool _isLoading = false;
  bool _isPro = false;

  late InAppPurchase _inAppPurchase;
  late Stream<List<PurchaseDetails>> _subscription;

  // Conjunto para armazenar os IDs dos produtos comprados
  Set<String> purchasedProductIds = {};

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    loadCards();
    // _initInAppPurchase();
    _checkUserProStatus();
  }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    setState(() {
      _isPro = isYearlyPro || isMonthlyPro;
    });
  }

  void _deliverProduct(PurchaseDetails purchase) {
    purchasedProductIds.add(purchase.productID);
  }

  // MARK: - Load Cards
  Future<void> loadCards() async {
    var cards = await service.CardService.retrieveCards();
    var fcard = await Fixedexpensesservice.getSortedFixedExpenses();
    setState(() async {
      cardList = cards;
      fixedCards = fcard;
      mergeCardList =
          await Fixedexpensesservice.MergeFixedWithNormal(fixedCards, cardList);
      print(mergeCardList.first.amount);
    });
  }

  // Exibe o ProModal
  void _showProModal(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ProModal(
          isLoading: _isLoading,
          onSubscriptionPurchased: () {
            setState(() {
              _isPro = true;
            });
          },
        );
      },
    );
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CupertinoNavigationBar(
          // leading: GestureDetector(
          //   onTap: () {
          //     _scaffoldKey.currentState?.openDrawer(); // Abre o menu lateral
          //   },
          //   child: Icon(CupertinoIcons.bars, size: 24),
          // ),
          middle: Text(
            widget.title,
            style: const TextStyle(color: AppColors.label, fontSize: 16),
          ),
          backgroundColor: AppColors.background1,
          trailing: GestureDetector(
            onTap: () {
              _showProModal(context); // Chamando o modal de assinatura
            },
            child: const Text(
              "PRO",
              style: TextStyle(
                  color: AppColors.label,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppColors.background1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.background1,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: AppColors.label,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text(
                  'Início',
                  style: TextStyle(color: AppColors.label),
                ),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  // não vai a lugar nenhum pois já está no inicio
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_invitation_rounded),
                title: Text(
                  'Adicionar Gastos Fixos',
                  style: TextStyle(color: AppColors.label),
                ),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  print("Entrou");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CriarGastosFixos()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.payment_rounded),
                title: Text(
                  'Retirar os anuncios',
                  style: TextStyle(color: AppColors.label),
                ),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  _showProModal(context); // Chamando o modal de assinatura
                },
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              if (!_isPro && !Platform.isMacOS) // Se o usuário não é PRO, mostra o banner
                Container(
                  height: 60,
                  width: 468,
                  alignment: Alignment.center,
                  child: BannerAdconstruct(),
                ),
              if (_showHeaderCard) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: HeaderCard(
                    addButon: widget.addButon,
                    categories: widget.categories,
                    date: widget.date,
                    description: widget.description,
                    valueExpens: widget.valueExpens,
                    key: _headerCardKey,
                    onAddClicked: () {
                      widget.onAddClicked();
                      setState(() async {
                        await loadCards();
                        await Constructreview.checkAndRequestReview();
                      });
                    },
                    onAddCategory: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.of(context).size.height / 1.1,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Categorycreater(
                              onCategoryAdded: () {
                                setState(() {
                                  _headerCardKey.currentState?.loadCategories();
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width - 100,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showHeaderCard = !_showHeaderCard;
                      });
                    },
                    icon: Icon(
                      _showHeaderCard
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                    ),
                  ),
                ],
              ),
              if (mergeCardList.isNotEmpty)
                Expanded(
                  key: widget.cardsExpens,
                  child: ListView.builder(
                    itemCount: mergeCardList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListCard(
                          onTap: (card) {
                            if(mergeCardList[cardList.length - index - 1].category.name != 'Recorrente') {
                            widget.onAddClicked();
                            _showCupertinoModalBottomSheet(context, card);
                            }
                          },
                          card: mergeCardList[cardList.length - index - 1],
                        ),
                      );
                    },
                  ),
                ),
              if (cardList.isEmpty && fixedCards.isEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Icon(
                          Icons.inbox,
                          color: AppColors.card,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.addNewTransactions,
                          style:
                              TextStyle(color: AppColors.label, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
      ),
    );
  }

  // MARK: - Show Cupertino Modal Bottom Sheet
  void _showCupertinoModalBottomSheet(BuildContext context, CardModel card) {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.05,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DetailScreen(
            card: card,
            onAddClicked: () {
              loadCards();
              setState(() {});
            },
          ),
        );
      },
    );
  }
}
