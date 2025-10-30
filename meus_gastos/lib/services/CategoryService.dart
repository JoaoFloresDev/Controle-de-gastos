import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
// import 'package:meus_gastos/services/firebase/saveExpensOnCloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CategoryModel.dart';

class CategoryService {
  static const String _categoriesKey = 'categories';
  static const String _isFirstAccessKey = 'isFirstAccess';

  Future<void> addCategory(CategoryModel category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    categories.add(jsonEncode(category.toJson()));
    await prefs.setStringList(_categoriesKey, categories);
    // }
  }

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
    // }
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
      color: const Color(0xFF7C4DFF), // Amarelo vibrante
      icon: Icons.home,
      name: 'Home',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Transport',
      color: const Color(0xFF2979FF), // Púrpura profundo
      icon: Icons.directions_car_outlined,
      name: 'Transport',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Restaurant',
      color: const Color(0xFFB39DDB), // Laranja intenso
      icon: Icons.restaurant,
      name: 'Restaurant',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Hospital',
      color: const Color(0xFFFF1744), // Rosa pink vibrante
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
      color: const Color(0xFFFF6E40), // Magenta neon
      icon: Icons.local_drink_outlined,
      name: 'Drink',
      frequency: 0,
    ),
    CategoryModel(
      id: 'ShoppingBasket',
      color: const Color(0xFF00E5FF), // Ciano elétrico
      icon: Icons.shopping_basket,
      name: 'ShoppingBasket',
      frequency: 0,
    ),
        CategoryModel(
      id: 'CreditCard',
      color: const Color(0xFFFF4081), // Azul ciano
      icon: Icons.credit_card,
      name: 'Credit Card',
      frequency: 0,
    ),
        CategoryModel(
      id: 'Education',
      color: const Color(0xFFD4A574), // Verde menta brilhante
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
      color: const Color(0xFFD500F9), // Laranja coral
      icon: Icons.videogame_asset,
      name: 'VideoGame',
      frequency: 0,
    ),
    CategoryModel(
      id: 'Unknown',
      color: const Color(0xFF9E9E9E), // Cinza neutro
      icon: Icons.question_mark_rounded,
      name: 'Unknown',
      frequency: 0,
    ),
    CategoryModel(
      id: 'AddCategory',
      color: AppColors.button,
      icon: Icons.add,
      name: 'AddCategory',
      frequency: -10,
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
      return defaultCategories
        ..sort((a, b) => b.frequency.compareTo(a.frequency));
    } else {
      List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
      List<CategoryModel> aux = categories.map((category) {
        final Map<String, dynamic> categoryMap = jsonDecode(category);
        return CategoryModel.fromJson(categoryMap);
      }).toList();
      aux.sort((a, b) => b.frequency.compareTo(a.frequency));
      return aux;
    }
    // }
  }

  Future<List<CategoryModel>> getAllCategoriesAvaliable() async {
    List<CategoryModel> categories = await getAllCategories();
    categories = categories.where((cat) => cat.available).toList();
    return categories;
  }

  Future<void> printAllCategories() async {
    final categories = await getAllCategories();
    for (var category in categories) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    }
  }

  Future<void> incrementCategoryFrequency(String categoryId) async {
    List<CategoryModel> allCategories = await getAllCategories();

    final int index = allCategories.indexWhere((c) => c.id == categoryId);

    if (index != -1) {
      CategoryModel oldCategory = allCategories[index];
      int currentFreq = oldCategory.frequency ?? 0;

      CategoryModel updatedCategory = CategoryModel(
        id: oldCategory.id,
        name: oldCategory.name,
        icon: oldCategory.icon,
        color: oldCategory.color,
        frequency: currentFreq + 1,
      );
      final prefs = await SharedPreferences.getInstance();
      allCategories[index] = updatedCategory;

      List<String> updatedList = allCategories
          .map((category) => jsonEncode(category.toJson()))
          .toList();
      await prefs.setStringList(_categoriesKey, updatedList);
    }
  }

  Future<CategoryModel?> getCategoryWithHighestFrequency() async {

    List<CategoryModel> categories = await getAllCategories();

    if (categories.isEmpty) return null;

    CategoryModel highestFrequencyCategory = categories.reduce((a, b) {
      final aFreq = a.frequency ?? 0;
      final bFreq = b.frequency ?? 0;
      return aFreq > bFreq ? a : b;
    });

    return highestFrequencyCategory;
  }
}
