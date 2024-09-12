import 'dart:convert';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CategoryModel.dart';

class CategoryService {
  static const String _categoriesKey = 'categories';
  static const String _isFirstAccessKey = 'isFirstAccess';
  static int maior_valor_frequency = 0;

  Future<void> addCategory(CategoryModel category) async {
    category.frequency = maior_valor_frequency + 1;
    maior_valor_frequency = category.frequency;
    print(category.frequency);
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

  Future<void> updateFrequencyCategory(CategoryModel category) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    List<CategoryModel> aux = categories.map((category) {
      final Map<String, dynamic> categoryMap = jsonDecode(category);
      return CategoryModel.fromJson(categoryMap);
    }).toList();

    // update the frequency of category with Id forneced
    for (var cat in aux) {
      if (cat.id == category.id) {
        cat.frequency++;
        if (cat.frequency > maior_valor_frequency) {
          maior_valor_frequency = cat.frequency;
        }
        break;
      }
    }

    // Serialize the updated data and save it to shared preferences.
    List<String> updatedCategories =
        aux.map((category) => jsonEncode(category.toJson())).toList();
    await prefs.setStringList(_categoriesKey, updatedCategories);
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstAccess = prefs.getBool(_isFirstAccessKey) ?? true;
    if (isFirstAccess) {
      await prefs.setBool(_isFirstAccessKey, false);
      List<CategoryModel> defaultCategories = [
        CategoryModel(
            id: 'Unknown',
            color: Colors.black54,
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
            id: 'AddCategory',
            color: Colors.cyan[300]!,
            icon: Icons.add,
            name: 'addCategory',
            frequency: -1),
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
    aux.sort((a, b) => a.frequency.compareTo(b.frequency));
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
    if (index != -1) {
      categoryMaps[index]['frequency'] =
          (categoryMaps[index]['frequency'] ?? 0) + 1;

      List<String> updatedCategories = categoryMaps.map((categoryMap) {
        return jsonEncode(categoryMap);
      }).toList();

      await prefs.setStringList(_categoriesKey, updatedCategories);
    }
  }
}
