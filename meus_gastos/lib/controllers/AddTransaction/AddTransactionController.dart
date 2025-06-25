import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'Header/HeaderCard.dart';
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

  bool _keyboardVisible = false;

  // MARK - Lifecycle
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

  // MARK - Observers
  @override
  void didChangeMetrics() {
    // Sua lógica existente para detectar o teclado. Perfeito!
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final visible = bottomInset > 140.0;
    if (visible != _keyboardVisible) {
      setState(() => _keyboardVisible = visible);
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
            
            // Lógica de exibição modificada
            if (!_keyboardVisible) ...[
              _buildInsertButton(),
              _buildSeparator(),
              // _buildRecurringCard(),
                 HorizontalCompactCardList(
     cards: [
      CardModel(id: 'mock_id_1', amount: 123.45, description: 'Test purchase', date: DateTime.now(), category: CategoryModel(name: 'Food')),
      CardModel(id: 'mock_id_1', amount: 123.45, description: 'Test purchase', date: DateTime.now(), category: CategoryModel(name: 'Food')),
      CardModel(id: 'mock_id_1', amount: 123.45, description: 'Test purchase', date: DateTime.now(), category: CategoryModel(name: 'Food'))
     ],
     onTap: (card) => widget.onAddClicked(),
     onAddClicked: _loadCards(),
),
            ] else ...[
              // ADICIONADO: Mostra a toolbar quando o teclado está visível
              _buildKeyboardToolbar(),
            ]
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
          height: 315,
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
            },
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
          if (list[index].id == 'AddCategory') _verticalCircleListKey.currentState?.loadCategories();
        }
      },
      defaultdIndexCategory: 0,
    );
  }

  // ADICIONADO: Widget que constrói a toolbar do teclado
  Widget _buildKeyboardToolbar() {
    return Container(
      height: 54.0,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background1, // Cor que combina com seu app
        border: Border(
          top: BorderSide(color: Colors.white24, width: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 24.0),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: AppColors.label,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsertButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 12),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.button,
            foregroundColor: AppColors.label,
            elevation: 8,
            shadowColor: AppColors.button.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.white.withOpacity(0.1);
                }
                return null;
              },
            ),
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            _headerCardKey.currentState?.adicionar();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Insert Expense',
                style: TextStyle(
                  color: AppColors.label,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.withOpacity(0.1),
                    Colors.grey.withOpacity(0.5),
                    Colors.grey.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCards() async {
    setState(() {});
  }
}