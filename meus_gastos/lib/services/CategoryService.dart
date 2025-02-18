import 'dart:convert';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
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
  }

//mark - Delete Category
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

//mark - Get All Positive Categories
Future<List<CategoryModel>> getAllPositiveCategories() async {
      final prefs = await SharedPreferences.getInstance();
    bool isFirstAccess = prefs.getBool(_isFirstAccessKey) ?? true;
    if (isFirstAccess) {
      await prefs.setBool(_isFirstAccessKey, false);
      for (var category in defaultCategories) {
        await addCategory(category);
      }
    }
    
  List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
  List<CategoryModel> aux = categories.map((category) {
    final Map<String, dynamic> categoryMap = jsonDecode(category);
    return CategoryModel.fromJson(categoryMap);
  }).toList();
  aux = aux.where((cat) => cat.available).toList();
  aux.sort((a, b) => b.frequency.compareTo(a.frequency));
  return aux;
}

final List<CategoryModel> defaultCategories = [
  CategoryModel(
    id: 'Unknown',
    color: Colors.blueAccent.withOpacity(0.8),
    icon: Icons.question_mark_rounded,
    name: 'Unknown',
    frequency: 0,
  ),
  CategoryModel(
    id: 'Shopping',
    color: Colors.greenAccent.withOpacity(0.8),
    icon: Icons.shopping_cart,
    name: 'Shopping',
    frequency: 0,
  ),
  CategoryModel(
    id: 'Restaurant',
    color: Colors.indigo.withOpacity(0.8),
    icon: Icons.restaurant,
    name: 'Restaurant',
    frequency: 0,
  ),
  CategoryModel(
    id: 'GasStation',
    color: Colors.amberAccent.withOpacity(0.8),
    icon: Icons.local_gas_station,
    name: 'GasStation',
    frequency: 0,
  ),
  CategoryModel(
    id: 'Home',
    color: Colors.teal.withOpacity(0.8),
    icon: Icons.home,
    name: 'Home',
    frequency: 0,
  ),
  CategoryModel(
    id: 'ShoppingBasket',
    color: Colors.pinkAccent.withOpacity(0.8),
    icon: Icons.shopping_basket,
    name: 'ShoppingBasket',
    frequency: 0,
  ),
  CategoryModel(
    id: 'Hospital',
    color: Colors.tealAccent.withOpacity(0.8),
    icon: Icons.local_hospital,
    name: 'Hospital',
    frequency: 0,
  ),
  CategoryModel(
    id: 'Movie',
    color: Colors.deepPurpleAccent.withOpacity(0.8),
    icon: Icons.movie,
    name: 'Movie',
    frequency: 0,
  ),
  CategoryModel(
    id: 'VideoGame',
    color: Colors.brown.withOpacity(0.8),
    icon: Icons.videogame_asset,
    name: 'VideoGame',
    frequency: 0,
  ),
  CategoryModel(
    id: 'Drink',
    color: Colors.cyanAccent.withOpacity(0.8),
    icon: Icons.local_drink_outlined,
    name: 'Drink',
    frequency: 0,
  ),
  CategoryModel(
    id: 'CreditCard',
    color: Colors.limeAccent.withOpacity(0.8),
    icon: Icons.credit_card,
    name: 'CreditCard',
    frequency: 0,
  ),
  CategoryModel(
    id: 'Phone',
    color: Colors.deepOrangeAccent.withOpacity(0.8),
    icon: Icons.phone,
    name: 'Phone',
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
    }

    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    List<CategoryModel> aux = categories.map((category) {
      final Map<String, dynamic> categoryMap = jsonDecode(category);
      return CategoryModel.fromJson(categoryMap);
    }).toList();
    aux.sort((a, b) => b.frequency.compareTo(a.frequency));
    return aux;
  }

  Future<void> printAllCategories() async {
    final categories = await getAllCategories();
    for (var category in categories) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    }
  }

  static Future<void> incrementCategoryFrequency(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    List<Map<String, dynamic>> categoryMaps = categories.map((category) {
      return jsonDecode(category) as Map<String, dynamic>;
    }).toList();

    final int index =
        categoryMaps.indexWhere((category) => category['id'] == categoryId);
    CategoryModel? categoryHighFrequency =
        await CategoryService.getCategoryWithHighestFrequency();
    if ((index != -1) &&
        categoryHighFrequency != null &&
        categoryHighFrequency.id.isNotEmpty) {
      categoryMaps[index]['frequency'] = categoryHighFrequency.frequency + 1;
      // print("DADADAD${categoryMaps[index]['frequency']}");


      List<String> updatedCategories = categoryMaps.map((categoryMap) {
        return jsonEncode(categoryMap);
      }).toList();
      
      await prefs.setStringList(_categoriesKey, updatedCategories);
    }
  }

  // MARK: - Category with Highest Frequency
  static Future<CategoryModel?> getCategoryWithHighestFrequency() async {
    final List<CategoryModel> categorys = await CategoryService().getAllCategories();
    final Map<String, int> frequencyMap = {};

    for (var cat in categorys) {
      frequencyMap[cat.id] = (cat.frequency ?? 0);
    }

    if (frequencyMap.isEmpty) {
      return null;
    }

    final String highestFrequencyCategoryId =
        frequencyMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;


    final List<CategoryModel> categories =
        await CategoryService().getAllCategories();

    return categories.firstWhere(
      (category) => category.id == highestFrequencyCategoryId,
      orElse: () => CategoryModel(
        id: '',
        name: 'Unknown',
        icon: Icons.help,
        color: AppColors.buttonDeselected,
        frequency: 0,
      ),
    );
  }
}
