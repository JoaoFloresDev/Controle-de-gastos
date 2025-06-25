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

//mark - controller
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
  final GlobalKey<VerticalCircleListState> _verticalCircleListKey = GlobalKey();

  //mark - variables
  bool _keyboardVisible = false;

  //mark - lifecycle
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  //mark - helpers
  void _printCurrentSelection() {
    final header = _headerCardKey.currentState;
    if (header == null) return;
    debugPrint('Amount: ${header.valorController.numberValue}');
    debugPrint('Description: ${header.descricaoController.text}');
    final list = _verticalCircleListKey.currentState?.categorieList;
    final catName =
        (list != null && list.isNotEmpty) ? list[header.lastIndexSelected].name : '—';
    debugPrint('Category: $catName');
  }

void _showAddedAnimation() {
  final header = _headerCardKey.currentState;
  if (header == null) return;
  final list = _verticalCircleListKey.currentState?.categorieList;
  final catName =
      (list != null && list.isNotEmpty) ? list[header.lastIndexSelected].name : '—';

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
    curve: Curves.easeInOutCubic
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
                      // Conteúdo expandido
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
                      // Botão de fechar opcional
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
  
  // Vibração tátil para feedback
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
    setState(() {});
  }

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
    if (header != null) {
      final list = _verticalCircleListKey.currentState?.categorieList;
      final catName = (list != null && list.isNotEmpty)
          ? list[header.lastIndexSelected].name
          : '—';

      AddedExpenseToast.show(
        context: context,
        amount: header.valorController.numberValue,
        description: header.descricaoController.text,
        category: catName,
      );

      header.adicionar();
      widget.onAddClicked();
    }
  },
),

              const CustomSeparator(),
              HorizontalCompactCardList(
                cards: [
                  CardModel(
                    id: 'mock1',
                    amount: 123.45,
                    description: 'Test purchase',
                    date: DateTime.now(),
                    category: CategoryModel(name: 'Food'),
                  ),
                  CardModel(
                    id: 'mock2',
                    amount: 99.99,
                    description: 'Another test',
                    date: DateTime.now(),
                    category: CategoryModel(name: 'Transport'),
                  ),
                  CardModel(
                    id: 'mock3',
                    amount: 42.00,
                    description: 'More tests',
                    date: DateTime.now(),
                    category: CategoryModel(name: 'Health'),
                  ),
                ],
                onTap: (card) => widget.onAddClicked(),
                onAddClicked: _loadCards(),
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

  //mark - widgets
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 315,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
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
            onAddClicked: widget.onAddClicked,
            onAddCategory: () {},
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
          if (list[index].id == 'AddCategory') {
            _verticalCircleListKey.currentState?.loadCategories();
          }
        }
      },
      defaultdIndexCategory: 0,
    );
  }
}