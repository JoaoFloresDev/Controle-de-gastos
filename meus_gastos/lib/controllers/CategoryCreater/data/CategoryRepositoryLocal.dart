import 'dart:convert';
import 'package:meus_gastos/controllers/CategoryCreater/data/ICategoryRepository.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryRepositoryLocal implements ICategoryRepository {
  static const String _categoriesKey = 'categories';
  static const String _isFirstAccessKey = 'isFirstAccess';

  @override
  Future<void> addCategory(CategoryModel category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    categories.add(jsonEncode(category.toJson()));
    await prefs.setStringList(_categoriesKey, categories);
    // }
  }

  @override
  Future<void> deleteCategory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];

    List<String> updatedCategories = categories.map((category) {
      final Map<String, dynamic> categoryMap = jsonDecode(category);
      if (categoryMap['id'] == id) {
        categoryMap['available'] = false;
      }
      return jsonEncode(categoryMap);
    }).toList();

    await prefs.setStringList(_categoriesKey, updatedCategories);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];

    List<String> updatedCategories = categories.map((cat) {
      final Map<String, dynamic> categoryMap = jsonDecode(cat);
      if (categoryMap['id'] == category.id) {
        return jsonEncode(category.toJson());
      }
      return cat;
    }).toList();

    await prefs.setStringList(_categoriesKey, updatedCategories);
    // }
  }

  // Salva a ordem completa das categorias
  @override
  Future<void> saveOrderedCategories(List<CategoryModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categoriesJson = categories
        .map((category) => jsonEncode(category.toJson()))
        .toList();
    await prefs.setStringList(_categoriesKey, categoriesJson);
  }

  final List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'Shopping',
      color: const Color(0xFF00E676), // Verde neon
      icon: Icons.shopping_cart,
      name: 'Shopping',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Home',
      color: const Color(0xFF7C4DFF), // Roxo
      icon: Icons.home,
      name: 'Home',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Transport',
      color: const Color(0xFF2979FF), // Azul
      icon: Icons.directions_car_outlined,
      name: 'Transport',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Restaurant',
      color: const Color(0xFFB39DDB), // Lavanda
      icon: Icons.restaurant,
      name: 'Restaurant',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Hospital',
      color: const Color(0xFFFF1744), // Vermelho
      icon: Icons.local_hospital,
      name: 'Hospital',
      frequency: 0,
    ),
    CategoryModel(
      id: 'GasStation',
      color: const Color(0xFFFFD700), // Dourado
      icon: Icons.local_gas_station,
      name: 'GasStation',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Drink',
      color: const Color(0xFFFF6E40), // Laranja
      icon: Icons.local_drink_outlined,
      name: 'Drink',
      frequency: 0,
    ),
    CategoryModel(
      id: 'ShoppingBasket',
      color: const Color(0xFF00E5FF), // Ciano
      icon: Icons.shopping_basket,
      name: 'ShoppingBasket',
      frequency: 0,
    ),
    CategoryModel(
      id: 'CreditCard',
      color: const Color(0xFFFF4081), // Rosa
      icon: Icons.credit_card,
      name: 'Credit Card',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Education',
      color: const Color(0xFFD4A574), // Bege
      icon: Icons.school_outlined,
      name: 'Education',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Phone',
      color: const Color(0xFF00BFA5), // Turquesa
      icon: Icons.phone,
      name: 'Phone',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Movie',
      color: const Color(0xFFAB47BC), // Roxo vibrante
      icon: Icons.movie,
      name: 'Movie',
      frequency: 0,
    ),
    CategoryModel(
      id: 'VideoGame',
      color: const Color(0xFFD500F9), // Magenta
      icon: Icons.videogame_asset,
      name: 'VideoGame',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Unknown',
      color: const Color(0xFF9E9E9E), // Cinza
      icon: Icons.question_mark_rounded,
      name: 'Unknown',
      frequency: 0,
    ),
    CategoryModel(
      id: 'AddCategory',
      color: AppColors.button,
      icon: Icons.add,
      name: 'AddCategory',
      frequency: 0,
    ),
  ];

  Future<List<CategoryModel>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();

    bool isFirstAccess = prefs.getBool(_isFirstAccessKey) ?? true;
    if (isFirstAccess) {
      await prefs.setBool(_isFirstAccessKey, false);
      for (var category in defaultCategories) {
        await addCategory(category);
      }
      return defaultCategories;
    } else {
      List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
      List<CategoryModel> aux = categories.map((category) {
        final Map<String, dynamic> categoryMap = jsonDecode(category);
        return CategoryModel.fromJson(categoryMap);
      }).toList();
      return aux;
    }
  }

  Future<void> printAllCategories() async {
    final categories = await getAllCategories();
    for (var category in categories) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    }
  }


}
