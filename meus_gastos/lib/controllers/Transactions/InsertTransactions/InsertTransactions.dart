import 'dart:io';
import 'package:meus_gastos/controllers/AddTransaction/UIComponents/VerticalCircleList.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCardRecorrent.dart';
import 'package:meus_gastos/controllers/cadastro_login/logout.dart';
import 'package:meus_gastos/controllers/cadastro_login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import '../../AddTransaction/UIComponents/Header/HeaderCard.dart';
import 'ViewComponents/ListCard.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
// import 'package:meus_gastos/services/firebase/saveExpensOnCloud.dart';
// import 'package:meus_gastos/services/firebase/syncService.dart';

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
    required this.isActive,
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
  final bool isActive;

  @override
  State<InsertTransactions> createState() => _InsertTransactionsState();
}

class _InsertTransactionsState extends State<InsertTransactions> {
  List<CardModel> cardList = [];
  List<FixedExpense> fixedCards = [];
  List<CardModel> mergeCardList = [];
  final GlobalKey<HeaderCardState> _headerCardKey = GlobalKey();
  final GlobalKey<VerticalCircleListState> _verticalCircleListKey =
      GlobalKey<VerticalCircleListState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime currentDate;

  bool _showHeaderCard = true;

  final String yearlyProId = 'yearly.pro';
  final String monthlyProId = 'monthly.pro';
  final bool _isLoading = false;
  bool _isPro = false;
  List<String> fixedExpenseIds = [];
  List<String> normalExpenseIds = [];
  List<String> IdsFixosControlList = [];

  Set<String> purchasedProductIds = {};
  bool? isLogin;
  String? userId;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    loadCards();
    // _initInAppPurchase();
    // userId = SaveExpensOnCloud().userId ?? null;
    // if (userId != null) {
    //   // O usuário está logado
    //   print("Usuário logado: ${userId}");
    //   isLogin = true;
    // } else {
      // O usuário não está logado
      print("Usuário deslogado.");
      isLogin = false;
    // }
    _checkUserProStatus();
  }

  @override
  void didUpdateWidget(covariant InsertTransactions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      loadCards();
    }
  }

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
      // _showProModal(context);
    }
  }

  Future<void> loadCards() async {
    var cards = await service.CardService.retrieveCards();
    var fcard = await Fixedexpensesservice.getSortedFixedExpenses();
    await _loadFixedExpenseIds();
    cardList = cards;
    fixedCards = fcard;
    // cardList.forEach((card) => print("${card.id}: ${card.amount}"));
    mergeCardList =
        await Fixedexpensesservice.mergeFixedWithNormal(fixedCards, cardList, currentDate);
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

  void _showProModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return ProModal(
            isLoading: _isLoading,
            onSubscriptionPurchased: () {
              setState(() {
                _isPro = true;
              });
            },
          );
        } else {
          return ProModalAndroid(
            isLoading: _isLoading,
            onSubscriptionPurchased: () {
              setState(() {
                _isPro = true;
              });
            },
          );
        }
      },
    );
  }

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
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                _showProModal(context);
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
            if (!_isPro && !Platform.isMacOS)
              Container(
                height: 60,
                width: double.infinity,
                alignment: Alignment.center,
                child: const BannerAdconstruct(),
              ),
            const SizedBox(height: 8),
            // Lista de cards
            if (mergeCardList.isNotEmpty)
              Expanded(
                key: widget.cardsExpens,
                child: ListView.builder(
                    itemCount: mergeCardList.length,
                    itemBuilder: (context, index) {
                      final card =
                          mergeCardList[mergeCardList.length - index - 1];
                      if (card.amount == 0) return const SizedBox();
                      if (normalExpenseIds.contains(card.id)) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: ListCard(
                            onTap: (card) {
                              widget.onAddClicked();
                              _showCupertinoModalBottomSheet(context, card);
                            },
                            card: mergeCardList[
                                mergeCardList.length - index - 1],
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
                          },
                          card:
                              mergeCardList[mergeCardList.length - index - 1],
                          onAddClicked: loadCards(),
                        ),
                      );
                    }),
              ),
            // Estado vazio melhorado
            if (cardList.isEmpty && fixedCards.isEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.button.withOpacity(0.1),
                                AppColors.button.withOpacity(0.05),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.button.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: AppColors.button,
                            size: 38,
                          ),
                        ),
                        
                        const SizedBox(height: 18),
                        
                        // Título principal
                        Text(
                          AppLocalizations.of(context)!.transactionPlaceholderSubtitle,
                          style: const TextStyle(
                            color: AppColors.label,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Subtítulo explicativo
                        Text(
                          // AppLocalizations.of(context)!.emptyStateSubtitle ?? 
                          AppLocalizations.of(context)!.transactionPlaceholderTitle,
                          style: TextStyle(
                            color: AppColors.label.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.button.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.button,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.transactionPlaceholderRow1Title,
                                          style: const TextStyle(
                                            color: AppColors.label,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.transactionPlaceholderRow1Subtitle,
                                          style: TextStyle(
                                            color: AppColors.label.withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.button.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.repeat,
                                      color: AppColors.button,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.transactionPlaceholderRow2Title,
                                          style: const TextStyle(
                                            color: AppColors.label,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.transactionPlaceholderRow3Subtitle,
                                          style: TextStyle(
                                            color: AppColors.label.withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
      backgroundColor: AppColors.background1,
    ),
  );
}

  void _showCupertinoModalBottomSheet(BuildContext context, CardModel card) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height - 70,
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

  Future<void> fakeExpens(FixedExpense cardFix) async {
    cardFix.price = 0;
    var car = Fixedexpensesservice.Fixed_to_NormalCard(cardFix, currentDate);
    await service.CardService().addCard(car);
    // SaveExpensOnCloud().addNewDate(car);
  }

  void _showCupertinoModalBottomFixedExpenses(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height - 70,
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
    // FocusScope.of(context).unfocus();
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (BuildContext context) {
    //     return Container(
    //         height: MediaQuery.of(context).size.height / 1.8,
    //         decoration: const BoxDecoration(
    //           borderRadius: BorderRadius.only(
    //             topLeft: Radius.circular(20),
    //             topRight: Radius.circular(20),
    //           ),
    //         ),
    //         child: singInScreen(
    //           updateUser: () async {
    //             setState(() {
    //               isLogin = true;
    //             });
    //             print(isLogin);
    //             Navigator.of(context).pop();

    //             // SyncService().syncData(user!.uid);

    //             await sincroniza_primeiro_acesso();
    //             setState(() {
    //               loadCards();
    //               _verticalCircleListKey.currentState?.loadCategories();
    //             });
    //           },
    //           loadcards: loadCards,
    //           isPro: _isPro,
    //           showProModal: (context) {
    //             _showProModal(context);
    //           },
    //         ));
    //   },
    // );
  }

  void _singOutScreen() {
    // FocusScope.of(context).unfocus();
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (BuildContext context) {
    //     return Container(
    //         height: MediaQuery.of(context).size.height / 2.0,
    //         decoration: const BoxDecoration(
    //           borderRadius: BorderRadius.only(
    //             topLeft: Radius.circular(20),
    //             topRight: Radius.circular(20),
    //           ),
    //         ),
    //         child: Logout(
    //           updateUser: () async {
    //             setState(() {
    //               isLogin = false;
    //             });
    //             await service.CardService.deleteAllCards();

    //             await Fixedexpensesservice.deleteAllCards();
    //             print("APAGOU");
    //             print(isLogin);
    //             setState(() {
    //               loadCards();
    //               _verticalCircleListKey.currentState?.loadCategories();
    //             });
    //             Navigator.of(context).pop();
    //           },
    //           loadcards: loadCards,
    //           isPro: _isPro,
    //           showProModal: (context) {
    //             _showProModal(context);
    //           },
    //         ));
    //   },
    // );
  }

  Future<bool> isFirstLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('synced_$userId') != true;
  }

  Future<void> sincroniza_primeiro_acesso() async {
    if (userId == null) {
      // Trate o caso em que o user não está disponível
      return;
    }
    bool prim = await isFirstLogin(userId!);
    if (prim) {
      showDialog(
        context: context,
        barrierDismissible: false, // Impede fechamento acidental
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.background1,
          elevation: 8,
          contentPadding: EdgeInsets.zero,
          content: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com ícone
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.label.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.1),
                              Colors.blue.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.sync,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.syncData,
                        style: const TextStyle(
                          color: AppColors.label,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Conteúdo
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.syncQuestion,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.label.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Benefícios da sincronização
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 20,
                                  color: Colors.blue.withOpacity(0.7),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .secureCloudBackup,
                                    style: TextStyle(
                                      color: AppColors.label.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.devices,
                                  size: 20,
                                  color: Colors.blue.withOpacity(0.7),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .accessAcrossDevices,
                                    style: TextStyle(
                                      color: AppColors.label.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botões de ação
                      Row(
                        children: [
                          // Botão "Agora não"
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool('synced_${userId}', true);
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.notNow,
                                style: TextStyle(
                                  color: AppColors.label.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Botão "Sincronizar"
                          Expanded(
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                bool isLoading = false;

                                return ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          setState(() {
                                            isLoading = true;
                                          });

                                          try {
                                            // await SyncService()
                                            //     .syncData(userId!);
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.setBool(
                                                'synced_${userId}', true);
                                            Navigator.pop(context);

                                            // Mostrar feedback de sucesso
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                        'Dados sincronizados com sucesso!'),
                                                  ],
                                                ),
                                                backgroundColor: Colors.green,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            setState(() {
                                              isLoading = false;
                                            });

                                            // Mostrar erro
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.error,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                        'Erro ao sincronizar. Tente novamente.'),
                                                  ],
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.sync,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .sync,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
