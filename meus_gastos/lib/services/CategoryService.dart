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

  Future<void> deleteCategory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    categories.removeWhere((category) {
      final Map<String, dynamic> categoryMap = jsonDecode(category);
      return categoryMap['id'] == id;
    });
    await prefs.setStringList(_categoriesKey, categories);
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstAccess = prefs.getBool(_isFirstAccessKey) ?? true;
    if (isFirstAccess) {
      await prefs.setBool(_isFirstAccessKey, false);
      List<CategoryModel> defaultCategories = [
        CategoryModel(
            id: 'Unknown',
            color: const Color.fromARGB(255, 183, 128, 0),
            icon: Icons.question_mark_rounded,
            name: 'Unknown',
            frequency: 0),
        CategoryModel(
            id: 'Shopping',
            color: Colors.green[900]!,
            icon: Icons.shopping_cart,
            name: 'Shopping',
            frequency: 0),
        CategoryModel(
            id: 'Restaurant',
            color: Colors.red[900]!,
            icon: Icons.restaurant,
            name: 'Restaurant',
            frequency: 0),
        CategoryModel(
            id: 'GasStation',
            color: Colors.blue[900]!,
            icon: Icons.local_gas_station,
            name: 'GasStation',
            frequency: 0),
        CategoryModel(
            id: 'Home',
            color: Colors.orange[900]!,
            icon: Icons.home,
            name: 'Home',
            frequency: 0),
        CategoryModel(
            id: 'ShoppingBasket',
            color: Colors.purple[900]!,
            icon: Icons.shopping_basket,
            name: 'ShoppingBasket',
            frequency: 0),
        CategoryModel(
            id: 'Hospital',
            color: Colors.teal[900]!,
            icon: Icons.local_hospital,
            name: 'Hospital',
            frequency: 0),
        CategoryModel(
            id: 'Movie',
            color: Colors.deepPurple[900]!,
            icon: Icons.movie,
            name: 'Movie',
            frequency: 0),
        CategoryModel(
            id: 'VideoGame',
            color: Colors.indigo[900]!,
            icon: Icons.videogame_asset,
            name: 'VideoGame',
            frequency: 0),
        CategoryModel(
            id: 'Drink',
            color: Colors.cyan[900]!,
            icon: Icons.local_drink_outlined,
            name: 'Drink',
            frequency: 0),
        CategoryModel(
            id: 'Water',
            color: Colors.blue,
            icon: Icons.water_drop,
            name: 'Water',
            frequency: 0),
        CategoryModel(
            id: 'Light',
            color: Colors.yellow,
            icon: Icons.lightbulb,
            name: 'Light',
            frequency: 0),
        CategoryModel(
            id: 'Wifi',
            color: Colors.purple,
            icon: Icons.wifi,
            name: 'Wifi',
            frequency: 0),
        CategoryModel(
            id: 'Phone',
            color: Colors.pink,
            icon: Icons.phone,
            name: 'Phone',
            frequency: 0),
        CategoryModel(
            id: 'CreditCard',
            color: Colors.teal,
            icon: Icons.credit_card,
            name: 'Credit Card',
            frequency: 0),
        CategoryModel(
            id: 'AddCategory',
            color: Colors.cyan[300]!,
            icon: Icons.add,
            name: 'AddCategory',
            frequency: -10),
      ];

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
    categories.forEach((category) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    });
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
