import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'ViewComponents/HeaderCard.dart';
import 'ViewComponents/ListCard.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/Transactions/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/Transactions/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/controllers/Transactions/exportExcel/exportExcelScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

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
  final GlobalKey<HeaderCardState> _headerCardKey = GlobalKey();
  bool _showHeaderCard = true;

  // Variáveis para In-App Purchase
  final String yearlyProId = 'yearly.pro'; // Seu ID de produto para assinatura
  bool _available = true;
  bool _isLoading = false;
  bool _isPro = false;

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    InAppPurchase.instance.purchaseStream.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });

    // Verifica e processa compras pendentes
    _verifyPastPurchases();

    // Carrega os cartões iniciais
    loadCards();
  }

  Future<void> _verifyPastPurchases() async {
    // Inicia o processo de restauração de compras
    InAppPurchase.instance.restorePurchases();
  }

void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
  for (var purchase in purchases) {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        // Exibir um indicador de carregamento, se necessário
        break;
      case PurchaseStatus.purchased:
        // Atualizar o estado do aplicativo para mostrar que o usuário é PRO
        setState(() {
          _isPro = true;
        });
        // Finalizar a compra para removê-la da fila de transações pendentes
        InAppPurchase.instance.completePurchase(purchase);
        break;
      case PurchaseStatus.error:
        // Tratar o erro e completar a compra
        print('Erro na compra: ${purchase.error}');
        InAppPurchase.instance.completePurchase(purchase);
        break;
      case PurchaseStatus.restored:
        // Atualizar o estado do aplicativo para mostrar que o usuário é PRO
        setState(() {
          _isPro = true;
        });
        // Finalizar a compra restaurada
        InAppPurchase.instance.completePurchase(purchase);
        break;
      default:
        // Caso padrão, se necessário
        break;
    }
  }

  // Após processar todas as compras, redefinir o estado de carregamento
  setState(() {
    _isLoading = false;
  });
}


  // MARK: - Load Cards
  Future<void> loadCards() async {
    var cards = await service.CardService.retrieveCards();
    setState(() {
      cardList = cards;
    });
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CupertinoNavigationBar(
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
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              if (!_isPro) // Se o usuário não é PRO, mostra o banner
                Container(
                  height: 60, // Altura do banner
                  width: 468, // Largura do banner
                  alignment: Alignment.center,
                  child: BannerAdconstruct(), // Widget do banner
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
              if (cardList.isNotEmpty)
                Expanded(
                  key: widget.cardsExpens,
                  child: ListView.builder(
                    itemCount: cardList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListCard(
                          onTap: (card) {
                            widget.onAddClicked();
                            _showCupertinoModalBottomSheet(context, card);
                          },
                          card: cardList[cardList.length - index - 1],
                        ),
                      );
                    },
                  ),
                ),
              if (cardList.isEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 80), // Espaçamento acima do ícone
                        Icon(
                          Icons.inbox,
                          color: AppColors.card,
                          size: 60,
                        ),
                        const SizedBox(height: 16), // Espaçamento entre ícone e texto
                        Text(
                          AppLocalizations.of(context)!.addNewTransactions,
                          style: TextStyle(color: AppColors.label, fontSize: 16),
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

  void _showProModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.5,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Upgrade to PRO",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Desfrute de recursos exclusivos com o PRO.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                CupertinoButton.filled(
                  onPressed: _isLoading
                      ? null
                      : () {
                          _buySubscription();
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Upgrade Now"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _buySubscription() async {
    if (_isLoading) return; // Evita múltiplas chamadas
    setState(() {
      _isLoading = true;
    });

    // Verifica se a API está disponível
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() {
        _available = false;
        _isLoading = false;
      });
      return;
    }

    // Consulta os detalhes do produto
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails({yearlyProId});

    // Verifica se houve erro na consulta ou se o produto não foi encontrado
    if (response.error != null || response.notFoundIDs.isNotEmpty) {
      setState(() {
        _available = false;
        _isLoading = false;
      });
      return;
    }

    // Se encontrou o produto, inicia a compra
    if (response.productDetails.isNotEmpty) {
      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: productDetails);

      // Inicia o processo de compra
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Caso não encontre o produto, mostra uma mensagem de erro
      setState(() {
        _available = false;
        _isLoading = false;
      });
    }
  }
}
