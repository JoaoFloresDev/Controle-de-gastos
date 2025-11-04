import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:uuid/uuid.dart';
import 'Components/categoryForm.dart';
import 'Components/categoriesList.dart';

class CategoryCreater extends StatefulWidget {
  final VoidCallback onCategoryAdded;

  const CategoryCreater({super.key, required this.onCategoryAdded});

  @override
  State<CategoryCreater> createState() => _CategoryCreaterState();
}

class _CategoryCreaterState extends State<CategoryCreater> with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late Color _currentColor;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _selectedIconIndex = 0;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _currentColor = _generateRandomColor();
    _loadCategories();
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
  Icons.fastfood, // Lanches rápidos
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
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  Future<void> _loadCategories() async {
    final categories = await CategoryService().getAllCategoriesAvaliable();
    setState(() {
      _categories = categories;
    });
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
    final allCategories = await CategoryService().getAllCategories();
    
    final withoutAddCategory = allCategories
        .where((cat) => cat.id != 'AddCategory')
        .toList();
    
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

    withoutAddCategory.add(newCategory);
    final newOrderedList = [...withoutAddCategory, addCategory];
    
    await CategoryService().saveOrderedCategories(newOrderedList);
    widget.onCategoryAdded();
    
    _nameController.clear();
    _hideKeyboard();
    
    setState(() {
      _currentColor = _generateRandomColor();
      _selectedIconIndex = 0;
      _categories = newOrderedList;
    });
  }

  Future<void> _reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final withoutAddCategory = _categories
        .where((cat) => cat.id != 'AddCategory')
        .toList();
    
    final addCategory = _categories.firstWhere(
      (cat) => cat.id == 'AddCategory',
      orElse: () => CategoryModel(
        id: 'AddCategory',
        color: AppColors.button,
        icon: Icons.add,
        name: 'AddCategory',
        frequency: 0,
      ),
    );
    
    final item = withoutAddCategory.removeAt(oldIndex);
    withoutAddCategory.insert(newIndex, item);
    
    final newOrderedList = [...withoutAddCategory, addCategory];
    
    setState(() {
      _categories = newOrderedList;
    });
    
    CategoryService().saveOrderedCategories(newOrderedList).then((_) {
      widget.onCategoryAdded();
    });
    
    HapticFeedback.mediumImpact();
  }

  Future<void> _onCategoryDeleted() async {
    widget.onCategoryAdded();
    final updatedCategories = await CategoryService().getAllCategoriesAvaliable();
    setState(() {
      _categories = updatedCategories;
    });
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
            onPressed: () => Navigator.pop(context),
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
        padding: const EdgeInsets.all(16),
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
              categories: _categories,
              onReorder: _reorderCategories,
              onCategoryDeleted: _onCategoryDeleted,
            ),
          ],
        ),
      ),
    );
  }
}