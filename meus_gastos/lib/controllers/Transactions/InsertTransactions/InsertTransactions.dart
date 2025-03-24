import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCardRecorrent.dart';
import 'package:meus_gastos/controllers/cadastro_login/logout.dart';
import 'package:meus_gastos/controllers/cadastro_login/login.dart';
import 'package:meus_gastos/gastos_fixos/CardDetails/DetailScreenMainScrean.dart';
import 'package:meus_gastos/services/saveExpensOnCloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/ListCard.dart';
import 'package:meus_gastos/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'ViewComponents/HeaderCard.dart';
import 'ViewComponents/ListCard.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import '../../Purchase/ProModal.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InsertTransactions extends StatefulWidget {
  const InsertTransactions({
    required this.onAddClicked,
    super.key,
    required this.title,
    required this.exportButon,
    required this.cardsExpens,
    required this.addButon,
    required this.date,
    required this.categories,
    required this.description,
    required this.valueExpens,
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
  final bool _isLoading = false;
  bool _isPro = false;
  List<String> fixedExpenseIds = [];
  List<String> normalExpenseIds = [];
  List<String> IdsFixosControlList = [];

  late InAppPurchase _inAppPurchase;
  late Stream<List<PurchaseDetails>> _subscription;

  // Conjunto para armazenar os IDs dos produtos comprados
  Set<String> purchasedProductIds = {};
  bool? isLogin;
  User? user;

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    loadCards();
    // _initInAppPurchase();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // O usuário está logado
      print("Usuário logado: ${user?.email}");
      isLogin = true;
    } else {
      // O usuário não está logado
      print("Usuário deslogado.");
      isLogin = false;
    }
    _checkUserProStatus();
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   setState(() async {
  //     user = await FirebaseAuth.instance.currentUser;
  //   });
  //   if (user != null) {
  //     // O usuário está logado
  //     print("Usuário logado: ${user?.email}");
  //   } else {
  //     // O usuário não está logado
  //     print("Usuário deslogado.");
  //   }
  // }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    setState(() {
      _isPro = isYearlyPro || isMonthlyPro;
    });

    int usageCount = prefs.getInt('usage_count') ?? 0;
    usageCount += 1;
    await prefs.setInt('usage_count', usageCount);

    if (!_isPro && usageCount > 40 && usageCount % 4 == 0) {
      _showProModal(context);
    }
  }

  void _deliverProduct(PurchaseDetails purchase) {
    purchasedProductIds.add(purchase.productID);
  }

  // MARK: - Load Cards
  Future<void> loadCards() async {
    var cards = await service.CardService.retrieveCards();
    var fcard = await Fixedexpensesservice.getSortedFixedExpenses();
    _loadFixedExpenseIds();
    cardList = cards;
    fixedCards = fcard;
    mergeCardList =
        await Fixedexpensesservice.MergeFixedWithNormal(fixedCards, cardList);
    setState(() {});
  }

  Future<void> _loadFixedExpenseIds() async {
    final Fixedids = await Fixedexpensesservice.getFixedExpenseIds();
    final normalids = await service.CardService.getNormalExpenseIds();
    final fixedsControlIds =
        await service.CardService().getIdFixoControlList(cardList);
    setState(() {
      fixedExpenseIds = Fixedids;
      normalExpenseIds = normalids;
      IdsFixosControlList = fixedsControlIds;
    });
  }

  // Exibe o ProModal
  void _showProModal(BuildContext context) async {
    if (Platform.isIOS) {
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
    if (Platform.isAndroid) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return ProModalAndroid(
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
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CupertinoNavigationBar(
          leading: GestureDetector(
            onTap: () {
              _showCupertinoModalBottomFixedExpenses(context);
            },
            child: const Icon(Icons.repeat, size: 24, color: AppColors.label),
          ),
          middle: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text(
              widget.title,
              style: const TextStyle(color: AppColors.label, fontSize: 20),
            ),
          ),
          backgroundColor: AppColors.background1,
          trailing: Row(
            mainAxisSize: MainAxisSize
                .min, // Garante que o Row ocupe apenas o espaço necessário
            children: [
              GestureDetector(
                onTap: () {
                  if (isLogin!)
                    _singOutScreen();
                  else
                    _singInScreen();
                  print("Entrou");
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      right: 8.0), // Espaçamento entre os textos
                  child: Text(
                    "${isLogin! ? "Perfil" : "Login"}",
                    style: TextStyle(
                      color: isLogin!
                          ? AppColors.labelPlaceholder
                          : AppColors.button,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showProModal(context); // Chamando o modal de assinatura
                },
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    color: AppColors.label,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              if (!_isPro &&
                  !Platform.isMacOS) // Se o usuário não é PRO, mostra o banner
                Container(
                  height: 60,
                  width: double.infinity, // Largura total da tela
                  alignment: Alignment.center, // Centraliza no eixo X
                  child: const BannerAdconstruct(),
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
                    onAddClicked: () async {
                      widget.onAddClicked();
                      await loadCards();
                      setState(() {});
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
                        final card =
                            mergeCardList[mergeCardList.length - index - 1];
                        if (card.amount == 0) return SizedBox();
                        if (normalExpenseIds.contains(card.id)) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListCard(
                              onTap: (card) {
                                widget.onAddClicked();
                                _showCupertinoModalBottomSheet(context, card);
                              },
                              card: mergeCardList[mergeCardList.length - index - 1],
                              background: AppColors.card,
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListCardRecorrent(
                            onTap: (card) {
                              widget.onAddClicked();
                              // _showCupertinoModalBottomSheet_Fixed(
                              //     context, card);
                            },
                            card: mergeCardList[mergeCardList.length - index - 1],
                            onAddClicked: loadCards(),
                          ),
                        );
                      }),
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
                        const SizedBox(height: 20),
                        const Icon(
                          Icons.inbox,
                          color: AppColors.card,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.addNewTransactions,
                          style: const TextStyle(
                              color: AppColors.label, fontSize: 16),
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
          height: MediaQuery.of(context).size.height - 150,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: DetailScreen(
            card: card,
            onAddClicked: () {
              setState(() {
                loadCards();
              });
            },
          ),
        );
      },
    );
  }

  _showCupertinoModalBottomSheet_Fixed(BuildContext context, CardModel card) {
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
          child: DetailScreenFixedExpenses(
              card: fixedCards
                  .firstWhere((fcard) => fcard.id == card.idFixoControl),
              onAddClicked: () {
                setState(() {
                  loadCards();
                });
              },
              onDeleteClicked: (FixedExpense cardFix) async {
                // adicionar gasto falso
                await fakeExpens(cardFix);

                setState(() {
                  loadCards();
                });
              }),
        );
      },
    );
  }

  Future<void> fakeExpens(FixedExpense cardFix) async {
    cardFix.price = 0;
    var car = Fixedexpensesservice.Fixed_to_NormalCard(cardFix);
    await service.CardService.addCard(car);
    SaveExpensOnCloud().addNewDate(car);
  }

  void _showCupertinoModalBottomFixedExpenses(BuildContext context) {
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
          child: CriarGastosFixos(
            onAddPressedBack: () {
              setState(() {
                loadCards();
              });
            },
          ),
        );
      },
    );
  }

  void _singInScreen() {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height / 1.5,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: singInScreen(updateUser: () {
              Navigator.of(context).pop();
              setState(() {
                isLogin = true;
              });
              print(isLogin);
            }));
      },
    );
  }

  void _singOutScreen() {
    FocusScope.of(context).unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: MediaQuery.of(context).size.height / 1.5,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Logout(updateUser: () {
              Navigator.of(context).pop();
              setState(() {
                isLogin = false;
              });

              print(isLogin);
            },
            loadcards: loadCards,));
      },
    );
  }
}
