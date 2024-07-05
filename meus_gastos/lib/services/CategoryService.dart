import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/CategoryModel.dart';

class CategoryService {
  static const String _categoriesKey = 'categories';
  static const String _isFirstAccessKey = 'isFirstAccess';

  Future<void> addCategory(CategoryModel category) async {
    print("add:");
    print(category.name);
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

    print("--getAllCategories");
    if (isFirstAccess) {
      await prefs.setBool(_isFirstAccessKey, false);
      List<CategoryModel> defaultCategories = [
        CategoryModel(
            id: 'Unknown',
            color: Colors.grey[800]!,
            icon: Icons.question_mark_rounded,
            name: 'Sem categoria'),
        CategoryModel(
            id: 'Shopping',
            color: Colors.green[900]!,
            icon: Icons.shopping_cart,
            name: 'Mercado'),
        CategoryModel(
            id: 'Restaurant',
            color: Colors.red[900]!,
            icon: Icons.restaurant,
            name: 'Alimentação'),
        CategoryModel(
            id: 'GasStation',
            color: Colors.blue[900]!,
            icon: Icons.local_gas_station,
            name: 'Transporte'),
        CategoryModel(
            id: 'Home',
            color: Colors.orange[900]!,
            icon: Icons.home,
            name: 'Moradia'),
        CategoryModel(
            id: 'ShoppingBasket',
            color: Colors.purple[900]!,
            icon: Icons.shopping_basket,
            name: 'Compras'),
        CategoryModel(
            id: 'Hospital',
            color: Colors.teal[900]!,
            icon: Icons.local_hospital,
            name: 'Saúde'),
        CategoryModel(
            id: 'Movie',
            color: Colors.deepPurple[900]!,
            icon: Icons.movie,
            name: 'Streaming'),
        CategoryModel(
            id: 'VideoGame',
            color: Colors.indigo[900]!,
            icon: Icons.videogame_asset,
            name: 'Games'),
        CategoryModel(
            id: 'Drink',
            color: Colors.cyan[900]!,
            icon: Icons.local_drink_outlined,
            name: 'Bebidas'),
        CategoryModel(
            id: 'AddCategory',
            color: Colors.cyan[300]!,
            icon: Icons.local_hospital,
            name: 'Add'),
      ];

      for (var category in defaultCategories) {
        await addCategory(category);
      }
    }

    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    return categories.map((category) {
      final Map<String, dynamic> categoryMap = jsonDecode(category);
      return CategoryModel.fromJson(categoryMap);
    }).toList();
  }

  Future<void> printAllCategories() async {
    final categories = await getAllCategories();
    categories.forEach((category) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}');
    });
  }
}
