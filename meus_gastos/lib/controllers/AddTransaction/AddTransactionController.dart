import 'dart:io';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCardRecorrent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'UIComponents/Header/HeaderCard.dart';
import 'UIComponents/VerticalCircleList.dart';
import 'UIComponents/CompactListCardRecorrent.dart';
import 'UIComponents/KeyboardDoneToolbar.dart';
import 'UIComponents/CustomSeparator.dart';
import 'UIComponents/InsertExpenseButton.dart';
import 'UIComponents/AddedExpenseToast.dart';

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
  final GlobalKey _headerGradientKey = GlobalKey();

  //mark - variables
  bool _keyboardVisible = false;
  double _headerHeight = 315; // valor inicial de fallback

  // <<-- 1. VARIÁVEL DE ESTADO PARA CONTROLAR A VISIBILIDADE DA LISTA
  // bool _showRecurrentCards = true;

  //mark - lifecycle
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //mark - lifecycle

    super.initState();
    _loadFixedCards();

    WidgetsBinding.instance.addObserver(this);
    // Aguarda renderizar para medir a altura real do HeaderCard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeaderHeight();
    });
  }

  List<CardModel> mockCards = [];
  Future<void> _loadFixedCards() async {
    var fcard = await Fixedexpensesservice.getSortedFixedExpenses();
    final fixedCards = fcard
        .map((item) => Fixedexpensesservice.Fixed_to_NormalCard(item))
        .toList();
    setState(() {
      mockCards = fixedCards;
    });
  }

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

  void _showAddedAnimation() {
    final header = _headerCardKey.currentState;
    if (header == null) return;
    final list = _verticalCircleListKey.currentState?.categorieList;
    final catName = (list != null && list.isNotEmpty)
        ? list[header.lastIndexSelected].name
        : '—';
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    late OverlayEntry entry;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInQuart,
    ));
    final fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );
    final scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
    entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: scale,
              child: FadeTransition(
                opacity: fade,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(minHeight: 85),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2A2A2A),
                          const Color(0xFF1F1F1F),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Despesa Adicionada',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'R\$ ${header.valorController.numberValue.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      header.descricaoController.text.isNotEmpty
                                          ? header.descricaoController.text
                                          : 'Sem descrição',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white54,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    catName,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            await controller.reverse();
                            entry.remove();
                            controller.dispose();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.xmark,
                              color: Colors.white54,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
    controller.forward();
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      HapticFeedback.lightImpact();
    }
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (controller.isCompleted) {
        await controller.reverse();
        entry.remove();
        controller.dispose();
      }
    });
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
                  print("aaaa");
                  if (header != null) {
                    final list =
                        _verticalCircleListKey.currentState?.categorieList;
                    final selectedCat = (list != null && list.isNotEmpty)
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
                          Translateservice.getTranslatedCategoryUsingModel(
                              context, selectedCat),
                    );
                    header.adicionar();
                    widget.onAddClicked();
                    header.valorController.updateValue(0);
                    header.descricaoController.clear();
                  }
                },
              ),
              mockCards.isNotEmpty && showRecorrentCard
                  ? SizedBox(height: 0)
                  : SizedBox(height: 16),
              AnimatedOpacity(
                opacity: mockCards.isNotEmpty && showRecorrentCard ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  height: mockCards.isNotEmpty && showRecorrentCard
                      ? 104.0
                      : 0.0, // Altura estimada (Separador + Lista)
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomSeparator(),
                        HorizontalCompactCardList(
                          cards: mockCards,
                          onTap: (card) => widget.onAddClicked(),
                          onAddClicked: _loadCards,
                          onCardsEmpty: () {
                            print("aqui! recore");
                            setState(() {
                              // if (mockCards.isEmpty) {
                              //     showRecorrentCard = false;
                              // }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              KeyboardDoneToolbar(
                onDone: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _headerCardKey.currentState?.adicionar();
                },
              ),
            ],
          ],
        ),
      ),
    );
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
          print('Categories have been loaded in the parent widget!');
        },
      ),
    );
  }

  Widget _buildCategoryList() {
    return VerticalCircleList(
      key: _verticalCircleListKey,
      defaultdIndexCategory: 0,

      // Connect the VerticalCircleList's output to the HeaderCard's input method.
      onCategoriesLoaded: (categories) {
        _headerCardKey.currentState?.onCategoriesLoaded(categories);
      },

      // Connect the item selection event to the HeaderCard's handler method.
      onItemSelected: (index) {
        _headerCardKey.currentState?.onCategorySelected(index);
      },

      onAddCategorySelected: () {
        print("AHHHHH");
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height - 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Categorycreater(
                onCategoryAdded: () {
                  setState(() {
                    _verticalCircleListKey.currentState?.loadCategories();
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}

// <<-- WIDGET AUXILIAR QUE ESTAVA NO SEU CÓDIGO ORIGINAL
class HeaderWithGradientBackground extends StatefulWidget {
  final Widget Function(GlobalKey headerKey) headerBuilder;
  const HeaderWithGradientBackground({required this.headerBuilder, super.key});
  @override
  State<HeaderWithGradientBackground> createState() =>
      _HeaderWithGradientBackgroundState();
}

class _HeaderWithGradientBackgroundState
    extends State<HeaderWithGradientBackground> {
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 315;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  @override
  void didUpdateWidget(covariant HeaderWithGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  void _updateHeight() {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final newHeight = box?.size.height ?? _headerHeight;
    if (newHeight != _headerHeight) {
      setState(() {
        _headerHeight = newHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sempre agenda a checagem pós-build para capturar updates dinâmicos
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
    // Obtém o padding do SafeArea
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double topPadding = mediaQuery.padding.top;

    // Altura total = SafeArea top + altura do header
    final double totalHeight = topPadding + _headerHeight;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: totalHeight, // Usa a altura total calculada
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: true,
          bottom: false,
          child: widget.headerBuilder(_headerKey),
        ),
      ],
    );
  }
}
