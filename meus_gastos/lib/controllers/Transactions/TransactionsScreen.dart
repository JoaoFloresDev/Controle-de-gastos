import 'dart:io';
import 'package:meus_gastos/ViewsModelsGerais/addCardViewModel.dart';
import 'package:meus_gastos/controllers/Login/Authentication.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/ViewComponents/ListCardRecorrent.dart';
import 'package:meus_gastos/controllers/ads_review/BannerAdFactory.dart';
import 'package:meus_gastos/services/ProManeger.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/RecurrentExpenseScreen.dart';
import 'ViewComponents/ListCard.dart';
import '../../models/CardModel.dart';
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class TransactionsScrean extends StatefulWidget {
  const TransactionsScrean(
      {required this.onAddClicked,
      super.key,
      required this.title,
      required this.isActive,
      required this.cardEvents,
      required this.auth});
  final Authentication auth;
  final VoidCallback onAddClicked;
  final String title;

  final CardEvents cardEvents;

  final bool isActive;

  @override
  State<TransactionsScrean> createState() => _TransactionsScreanState();
}

class _TransactionsScreanState extends State<TransactionsScrean> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime currentDate;

  final bool _isLoading = false;

  Set<String> purchasedProductIds = {};
  bool? isLogin;
  String? userId;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    print("Usuário deslogado.");
    isLogin = false;
  }

@override
void didUpdateWidget(covariant TransactionsScrean oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.isActive && !oldWidget.isActive) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TransactionsViewModel>(context, listen: false).loadCards();
        // Adicione esta linha para notificar o header
        widget.cardEvents.notifyCardAdded();
      }
    });
  }
}

  void _showProModal(BuildContext context) async {
    ProManeger proViewModel = ProManeger();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return ProModal(
            isLoading: _isLoading,
            onSubscriptionPurchased: () {
              proViewModel.checkUserProStatus();
              if (mounted) {
                setState(() {});
              }
            },
          );
        } else {
          return ProModalAndroid(
            isLoading: _isLoading,
            onSubscriptionPurchased: () {
              proViewModel.checkUserProStatus();
              if (mounted) {
                setState(() {});
              }
            },
          );
        }
      },
    );
  }

  Widget _cardListBuild(TransactionsViewModel viewModel) {
    // Combine fixedCards e cardList em uma única lista de widgets
    final allCards = <Widget>[];

    for (var fcard in viewModel.fixedCards) {
      var card = viewModel.Fixed_to_NormalCard(fcard);

      allCards.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: ListCardRecorrent(
            onTap: (card) {
              widget.onAddClicked();
            },
            card: card,
            onAddClicked: viewModel.loadCards(),
          ),
        ),
      );
    }
    for (var card in viewModel.cardList.reversed) {
      allCards.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
          child: ListCard(
            onTap: (card) {
              widget.onAddClicked();
              _cardDetails(context, card, viewModel);
            },

            card: card,
            background: AppColors.card,
          ),
        ),
      );
    }

    // Retorna uma única ListView
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 70),
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: allCards.length,
        itemBuilder: (context, index) => allCards[index],
      ),
    );
  }

  Widget _empityListCardBuild() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
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
                    color: AppColors.label.withOpacity(0.08)
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.label,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

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
                fontSize: 18,
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.label.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.label,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .transactionPlaceholderRow1Title,
                              style: const TextStyle(
                                color: AppColors.label,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!
                                  .transactionPlaceholderRow1Subtitle,
                              style: TextStyle(
                                color: AppColors.label.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.label.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.repeat,
                          color: AppColors.label,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .transactionPlaceholderRow2Title,
                              style: const TextStyle(
                                color: AppColors.label,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!
                                  .transactionPlaceholderRow3Subtitle,
                              style: TextStyle(
                                color: AppColors.label.withOpacity(0.8),
                                fontSize: 16,
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
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Consumer<TransactionsViewModel>(
          builder: (context, viewModel, child) => GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              children: [
                BannerAdFactory().build(),
                const SizedBox(height: 8),
                if ((viewModel.cardList.isNotEmpty) ||
                    (viewModel.fixedCards.isNotEmpty)) ...[
                  _cardListBuild(viewModel),
                ] else ...[
                  _empityListCardBuild(),
                ]
              ],
            ),
          ),
        ),
        backgroundColor: AppColors.background1,
      ),
    );
  }

  void _cardDetails(BuildContext context, CardModel card, TransactionsViewModel viewModel) {
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
                viewModel.loadCards();
              });
            },
            onDelete: (card) {
              viewModel.deleteCard(card);
            },
          ),
        );
      },
    );
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
          child: RecurrentExpenseScreen(
            onAddPressedBack: () {
              setState(() {
                widget.cardEvents.notifyCardAdded();
              });
            },
          ),
        );
      },
    );
  }
}
