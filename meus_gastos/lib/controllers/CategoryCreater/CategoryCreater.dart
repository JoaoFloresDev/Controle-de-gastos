import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'Components/categoryForm.dart';
import 'Components/categoriesList.dart';

class CategoryCreater extends StatefulWidget {
  final VoidCallback onCategoryAdded;
  const CategoryCreater({
    super.key,
    required this.onCategoryAdded,
  });

  @override
  State<CategoryCreater> createState() => _CategoryCreaterState();
}

class _CategoryCreaterState extends State<CategoryCreater>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late Color _currentColor;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _selectedIconIndex = 0;
  List<CategoryModel> _categories = [];

  // Lista de cores pré-definidas (mesma do ColorGridSelector)
  static const List<Color> _predefinedColors = [
    Color(0xFFE63946),
    Color(0xFFFF6B6B),
    Color(0xFFFF8B94),
    Color(0xFFFF69B4),
    Color(0xFFE91E63),
    Color(0xFFFFA07A),
    Color(0xFFFF7F50),
    Color(0xFFFF5722),
    Color(0xFFFF9800),
    Color(0xFFFF6F00),
    Color(0xFFFFB74D),
    Color(0xFFFFD93D),
    Color(0xFFFFC93C),
    Color(0xFFFFC107),
    Color(0xFFF9A825),
    Color(0xFFFFEB3B),
    Color(0xFFFFEE58),
    Color(0xFFFFF176),
    Color(0xFFFFE082),
    Color(0xFFFFD54F),
    Color(0xFFCDDC39),
    Color(0xFFAED581),
    Color(0xFF66BB6A),
    Color(0xFF4CAF50),
    Color(0xFF6BCB77),
    Color(0xFF2E7D32),
    Color(0xFF26A69A),
    Color(0xFF009688),
    Color(0xFF00ACC1),
    Color(0xFF0288D1),
    Color(0xFF2196F3),
    Color(0xFF1976D2),
    Color(0xFF1565C0),
    Color(0xFF3F51B5),
    Color(0xFF5C6BC0),
    Color(0xFF673AB7),
    Color(0xFF9C27B0),
    Color(0xFFAB47BC),
    Color(0xFFBA68C8),
    Color(0xFFB565D8),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _currentColor = _generateRandomColor();
    // _loadCategories();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  final List<IconData> accountIcons = [
    Icons.directions_car, // Transporte
    Icons.home, // Moradia
    Icons.electrical_services, // Utilidades
    Icons.healing, // Saúde
    Icons.shopping_cart, // Compras
    Icons.local_dining, // Restaurantes
    Icons.movie, // Entretenimento
    Icons.school, // Educação
    Icons.fitness_center, // Atividades físicas
    Icons.local_bar, // Bebidas / Lazer
    Icons.pets, // Pets
    Icons.flight, // Viagens
    Icons.credit_card, // Finanças / Cartão
    Icons.monetization_on, // Investimentos
    Icons.savings, // Poupança
    Icons.attach_money, // Outras despesas financeiras
    Icons.account_balance_wallet, // Gestão de contas
    Icons.card_travel, // Transporte de longa distância
    Icons.local_florist, // Hobbies / Presentes
    Icons.fastfood, //  Lanches rápidos
    Icons.free_breakfast, // Café / Desjejum
    Icons.bike_scooter, // Mobilidade alternativa
    Icons.wifi, // Internet / Telecomunicações
    Icons.phone_android, // Telefonia

    Icons.build, // Manutenção / Reparos
    Icons.local_offer, // Promoções / Ofertas
    Icons.pie_chart, // Distribuição de gastos (Categoria Geral)
    Icons.restaurant, // Alimentação
    Icons.local_grocery_store, // Supermercado
  ];

  Color _generateRandomColor() {
    // Seleciona uma cor aleatória da lista de cores pré-definidas
    return _predefinedColors[Random().nextInt(_predefinedColors.length)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _addCategory() async {
    final allCategories = context.read<CategoryViewModel>().categories;

    final withoutAddCategory =
        allCategories.where((cat) => cat.id != 'AddCategory').toList();

    final addCategory = allCategories.firstWhere(
      (cat) => cat.id == 'AddCategory',
      orElse: () => CategoryModel(
        id: 'AddCategory',
        color: AppColors.button,
        icon: Icons.add,
        name: 'AddCategory',
        frequency: 0,
      ),
    );

    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      color: _currentColor,
      icon: accountIcons[_selectedIconIndex],
      name: _nameController.text,
      frequency: 0,
    );

    // Adiciona a nova categoria NO TOPO da lista (índice 0)

    context.read<CategoryViewModel>().add(newCategory);

    withoutAddCategory.insert(0, newCategory);
    final newOrderedList = [...withoutAddCategory, addCategory];

    await context
        .read<CategoryViewModel>()
        .saveOrderedCategories(newOrderedList);
    widget.onCategoryAdded();

    _nameController.clear();
    _hideKeyboard();

    setState(() {
      _currentColor = _generateRandomColor();
      _selectedIconIndex = 0;
    });
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final catVM = context.read<CategoryViewModel>();

    // Cria uma NOVA lista (importante para o Flutter detectar mudança)
    final List<CategoryModel> reorderedList =
        List<CategoryModel>.from(catVM.avaliebleCetegories);

    // Move o item
    final item = reorderedList.removeAt(oldIndex);
    reorderedList.insert(newIndex, item);

    // Atualiza IMEDIATAMENTE na UI (síncrono)
    catVM.updateCategoriesOrder(reorderedList);

    // Salva no Firebase em background (assíncrono)
    catVM.saveOrderedCategoriesToFirebase(reorderedList);
  }

  // Future<void> _reorderCategories(int oldIndex, int newIndex) async {
  //   if (newIndex > oldIndex) {
  //     newIndex -= 1;
  //   }

  //   final categories = List<CategoryModel>.from(
  //     context.read<CategoryViewModel>().categories,
  //   );

  //   final withoutAddCategory =
  //       categories.where((cat) => cat.id != 'AddCategory').toList();

  //   final addCategory = _categories.firstWhere(
  //     (cat) => cat.id == 'AddCategory',
  //     orElse: () => CategoryModel(
  //       id: 'AddCategory',
  //       color: AppColors.button,
  //       icon: Icons.add,
  //       name: 'AddCategory',
  //       frequency: 0,
  //     ),
  //   );

  //   final item = withoutAddCategory.removeAt(oldIndex);
  //   withoutAddCategory.insert(newIndex, item);

  //   final newOrderedList = [...withoutAddCategory, addCategory];

  //   Future.microtask(() {
  //     context.read<CategoryViewModel>().saveOrderedCategories(newOrderedList);
  //   }).then((_) {
  //     widget.onCategoryAdded();
  //   });

  //   HapticFeedback.mediumImpact();
  // }

  Future<void> _onCategoryDeleted(String categoryId) async {
    widget.onCategoryAdded();
    context.read<CategoryViewModel>().delete(categoryId);
    // final updatedCategories =
    //     await context.read<CategoryViewModel>().getAllCategoriesAvaliable();
    // setState(() {
    //   _categories = updatedCategories;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background1,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 0,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: Colors.white54,
              size: 24,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.createCategory,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryForm(
              nameController: _nameController,
              selectedColor: _currentColor,
              selectedIconIndex: _selectedIconIndex,
              onIconSelected: (index) {
                setState(() {
                  _selectedIconIndex = index;
                });
              },
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                });
              },
              onSubmit: _addCategory,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            CategoriesList(
                categories:
                    context.watch<CategoryViewModel>().avaliebleCetegories,
                onReorder: onReorder,
                onCategoryDeleted: _onCategoryDeleted),
          ],
        ),
      ),
    );
  }
}
