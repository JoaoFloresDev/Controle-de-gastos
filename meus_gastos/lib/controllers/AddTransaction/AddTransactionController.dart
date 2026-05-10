import 'dart:io';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/FixedExpensesViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CardServiceRefatore.dart';
import 'package:provider/provider.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'UIComponents/Header/HeaderCard.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'UIComponents/VerticalCircleList.dart';
import 'UIComponents/CompactListCardRecorrent.dart';
import 'UIComponents/CustomSeparator.dart';
import 'UIComponents/InsertExpenseButton.dart';
import 'UIComponents/AddedExpenseToast.dart';
import 'HeaderWithGradientBackground.dart';

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
    required this.isActive,
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
  final bool isActive;

  @override
  State<AddTransactionController> createState() =>
      _AddTransactionControllerState();
}

//mark - state
class _AddTransactionControllerState extends State<AddTransactionController>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  //mark - refs
  final GlobalKey<HeaderCardState> _headerCardKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<VerticalCircleListState> _verticalCircleListKey =
      GlobalKey<VerticalCircleListState>();

  //mark - variables
  bool _keyboardVisible = false;
  double _headerHeight = 315;
  //mark - lifecycle
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Aguarda renderizar para medir a altura real do HeaderCard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadFixedCards();
      _updateHeaderHeight();
    });
  }

  @override
  void didUpdateWidget(covariant AddTransactionController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _loadFixedCards();
        _updateHeaderHeight();
      });
    }
  }

  List<CardModel> mockCards = [];

  // Future<void> _loadFixedCards() async {
  //   final fixedVM = context.read<FixedExpensesViewModel>();
  //   final transactionsVM = context.read<TransactionsViewModel>();

  //   fixedVM.filteredFixedCardsShow(
  //     transactionsVM.cardList,
  //     DateTime.now(),
  //   );
  // }

  void _updateHeaderHeight() {
    final box = _headerCardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.size.height != _headerHeight) {
      setState(() {
        _headerHeight = box.size.height;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //mark - observers
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final visible = bottomInset > 140.0;
    if (visible != _keyboardVisible) {
      setState(() => _keyboardVisible = visible);
    }
  }


  Future<void> _loadCards() async {
    // Apenas um placeholder para o setState ser chamado e a UI reconstruir, se necessário.
    setState(() {});
  }

  bool showRecorrentCard = true;
  //mark - build
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    // final fixedVM = context.watch<FixedExpensesViewModel>();
    // final fixedCards = fixedVM.listFixedExpenseAsNormalCard;
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
            if (!_keyboardVisible) ...[
              InsertExpenseButton(
                onPressed: () {
                  final header = _headerCardKey.currentState;
                  if (header != null) {
                    if (header.valorController.numberValue > 0) {
                      final list =
                          context.read<CategoryViewModel>().avaliebleCetegories;
                      final selectedCat = (list.isNotEmpty)
                          ? list[header.lastIndexSelected]
                          : CategoryModel(
                              id: 'Unknown',
                              color: Colors.blueAccent.withOpacity(0.8),
                              icon: Icons.question_mark_rounded,
                              name: 'Unknown',
                              frequency: 0,
                            );
                      AddedExpenseToast.show(
                        context: context,
                        amount: header.valorController.numberValue,
                        description: header.descricaoController.text,
                        categoryIconColor: selectedCat.color,
                        categoryIcon: selectedCat.icon,
                        category:
                            TranslateService.getTranslatedCategoryUsingModel(
                                context, selectedCat),
                      );
                      widget.onAddClicked();
                      context.read<TransactionsViewModel>().addCard(CardModel(
                            amount: header.valorController.numberValue,
                            description: header.descricaoController.text,
                            date: header.lastDateSelected,
                            category: selectedCat,
                            id: CardService().generateUniqueId(),
                          ));
                      header.valorController.updateValue(0);
                      header.updateDateTime();
                      header.descricaoController.clear();
                    } else {
                      showAddValueAlert(context);
                    }
                  }
                },
              ),
              Consumer<FixedExpensesViewModel>(
                  builder: (context, fixedCards, child) {
                List<CardModel> fcardsToShow = fixedCards
                    .listFilteredFixedCardsShow
                    .where((fcard) => !fcard.isAutomaticAddition)
                    .map((fcard) =>
                        fixedCards.fixedToNormalCard(fcard, fcard.date))
                    .toList();
                // fixedCards.filteredFixedCardsShow(
                //     context.read<TransactionsViewModel>().cardList,
                //     DateTime.now());
                return Column(children: [
                  fcardsToShow.isNotEmpty && showRecorrentCard
                      ? SizedBox(height: 0)
                      : SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: fcardsToShow.isNotEmpty && showRecorrentCard
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      height: fcardsToShow.isNotEmpty && showRecorrentCard
                          ? 104.0
                          : 0.0, // Altura estimada (Separador + Lista)
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomSeparator(),
                            HorizontalCompactCardList(
                              cards: fcardsToShow,
                              onTap: (card) => widget.onAddClicked(),
                              onAddClicked: (card) async {
                                await context
                                    .read<TransactionsViewModel>()
                                    .addCard(card);
                                await context
                                    .read<TransactionsViewModel>()
                                    .loadCards();
                                widget.onAddClicked();
                                _loadCards();
                                AddedExpenseToast.show(
                                  context: context,
                                  amount: card.amount,
                                  description: card.description,
                                  category: card.category.name,
                                  categoryIcon: card.category.icon,
                                  categoryIconColor: card.category.color,
                                );
                              },
                              onCardsEmpty: () {
                                print("aqui! recore");
                                // _loadFixedCards();
                                setState(() {
                                  fixedCards.filteredFixedCardsShow(
                                      context
                                          .read<TransactionsViewModel>()
                                          .cardList,
                                      DateTime.now());
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]);
              }),
            ],
          ],
        ),
      ),
    );
  }

  void showAddValueAlert(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 80,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.deletionButton,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.addExpenseAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove após 2.5 segundos
    Future.delayed(const Duration(milliseconds: 2500), () {
      overlayEntry.remove();
    });
  }

  Widget _buildHeader() {
    return HeaderWithGradientBackground(
      headerBuilder: (_) => HeaderCard(
        key: _headerCardKey,
        addButon: widget.addButtonKey,
        categories: widget.categoriesKey,
        date: widget.dateKey,
        description: widget.descriptionKey,
        valueExpens: widget.valueExpensKey,
        onAddClicked: widget.onAddClicked,
        onAddCategory: () {},
        // Add the required callback here
        onCategoriesLoaded: (loadedCategories) {
          // You can now use the 'loadedCategories' list in this parent widget's state if needed.
          // For example: setState(() => _myListOfCategories = loadedCategories));
          // _loadFixedCards();
          print('Categories have been loaded in the parent widget!');
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    final parentContext = context;
    final vm = context.watch<CategoryViewModel>();
    // Só bloqueia a UI quando não há nada em cache. Refreshes (sync/login)
    // mantêm a grade visível e atualizam ao concluir.
    if (vm.isLoading && vm.avaliebleCetegories.isEmpty) {
      return Column(
        children: [
          Expanded(child: SizedBox()),
          const CircularProgressIndicator(color: AppColors.button),
          Expanded(child: SizedBox()),
        ],
      );
    } else {
      return VerticalCircleList(
        key: _verticalCircleListKey,
        defaultdIndexCategory: 0,
        onCategoriesLoaded: (categories) {
          _headerCardKey.currentState?.onCategoriesLoaded(categories);
        },
        onItemSelected: (index) {
          _headerCardKey.currentState?.onCategorySelected(index);
        },
        onAddCategorySelected: () {
          showModalBottomSheet(
            context: parentContext,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (BuildContext modalContext) {
              return ChangeNotifierProvider.value(
                value: vm,
                child: Container(
                  height: MediaQuery.of(parentContext).size.height - 70,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: CategoryCreater(
                    onCategoryAdded: () {
                      setState(() {
                        vm.load();
                        _headerCardKey.currentState!.lastIndexSelected = 0;
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
}
