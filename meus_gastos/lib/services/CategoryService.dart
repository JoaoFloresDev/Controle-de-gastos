import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/saveExpensOnCloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CategoryModel.dart';

class CategoryService {
  static const String _categoriesKey = 'categories';
  static const String _isFirstAccessKey = 'isFirstAccess';

  Future<void> addCategory(CategoryModel category) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Usuário logado: adiciona ao Firestore
    await FirebaseFirestore.instance
        .collection(user.uid)
        .doc('Categories')
        .collection('categoryList')
        .doc(category.id)
        .set(category.toJson());
  } else {
    // Usuário offline: adiciona ao SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
    categories.add(jsonEncode(category.toJson()));
    await prefs.setStringList(_categoriesKey, categories);
  }
}

//MARK: - Delete Category
  Future<void> deleteCategory(String id) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Usuário logado: atualiza a categoria no Firestore (marca como indisponível)
      final docRef = FirebaseFirestore.instance
          .collection(user.uid)
          .doc('Categories')
          .collection('categoryList')
          .doc(id);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({'available': false});
      }
    } else {
      // Usuário offline: atualiza localmente via SharedPreferences
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
  }
  // Future<List<CategoryModel>> getAllCategories() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool isFirstAccess = prefs.getBool(_isFirstAccessKey) ?? true;
  //   if (isFirstAccess) {
  //     await prefs.setBool(_isFirstAccessKey, false);
  //     for (var category in defaultCategories) {
  //       await addCategory(category);
  //     }
  //   }

  //   List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
  //   List<CategoryModel> aux = categories.map((category) {
  //     final Map<String, dynamic> categoryMap = jsonDecode(category);
  //     return CategoryModel.fromJson(categoryMap);
  //   }).toList();
  //   aux.sort((a, b) => b.frequency.compareTo(a.frequency));
  //   return aux;
  // }

//mark - Get All Positive Categories
  // Future<List<CategoryModel>> getAllCategories() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool isFirstAccess = prefs.getBool(_isFirstAccessKey) ?? true;
  //   if (isFirstAccess) {
  //     await prefs.setBool(_isFirstAccessKey, false);
  //     for (var category in defaultCategories) {
  //       await addCategory(category);
  //     }
  //   }

  //   List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
  //   List<CategoryModel> aux = categories.map((category) {
  //     final Map<String, dynamic> categoryMap = jsonDecode(category);
  //     return CategoryModel.fromJson(categoryMap);
  //   }).toList();
  //   aux = aux.where((cat) => cat.available).toList();
  //   aux.sort((a, b) => b.frequency.compareTo(a.frequency));
  //   return aux;
  // }

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
    User? user = FirebaseAuth.instance.currentUser;
    print("AQUIIIIII");
    if (user != null) {
      // Usuário está logado - verificamos o Firestore
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection(user.uid)
          .doc('Categories')
          .collection('categoryList')
          .get();
      print("AQUIIIIII");
      if (snapshot.docs.isEmpty) {
        // Primeiro acesso na nuvem
        for (var category in defaultCategories) {
          await SaveExpensOnCloud().addNewCategory(category);
        }
        return defaultCategories..sort((a, b) => b.frequency.compareTo(a.frequency));
      } else {
        // Categorias já existem
        List<CategoryModel> cloudCategories = snapshot.docs
            .map((doc) =>
                CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.frequency.compareTo(a.frequency));
        cloudCategories =
            cloudCategories.where((cat) => cat.available).toList();

        return cloudCategories;
      }
    } else {
      // Usuário não logado - usamos SharedPreferences
      bool isFirstAccess = prefs.getBool(_isFirstAccessKey) ?? true;
      if (isFirstAccess) {
        await prefs.setBool(_isFirstAccessKey, false);
        for (var category in defaultCategories) {
          await addCategory(
              category); // Supondo que essa função salva localmente
        }
        return defaultCategories..sort((a, b) => b.frequency.compareTo(a.frequency));
      } else {
        List<String> categories = prefs.getStringList(_categoriesKey) ?? [];
        List<CategoryModel> aux = categories.map((category) {
          final Map<String, dynamic> categoryMap = jsonDecode(category);
          return CategoryModel.fromJson(categoryMap);
        }).toList();
        aux = aux.where((cat) => cat.available).toList();
        aux.sort((a, b) => b.frequency.compareTo(a.frequency));
        return aux;
      }
    }
  }

  Future<void> printAllCategories() async {
    final categories = await getAllCategories();
    for (var category in categories) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    }
  }

  Future<void> incrementCategoryFrequency(String categoryId) async {
    User? user = FirebaseAuth.instance.currentUser;
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

      if (user != null) {
        // Usuário logado: atualiza no Firestore
        await FirebaseFirestore.instance
            .collection(user.uid)
            .doc('Categories')
            .collection('categoryList')
            .doc(updatedCategory.id)
            .set(updatedCategory.toJson());
      } else {
        // Usuário offline: atualiza no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        allCategories[index] = updatedCategory;

        List<String> updatedList = allCategories
            .map((category) => jsonEncode(category.toJson()))
            .toList();
        await prefs.setStringList(_categoriesKey, updatedList);
      }
    }
  }

  // MARK: - Category with Highest Frequency
  static Future<CategoryModel?> getCategoryWithHighestFrequency() async {
    User? user = FirebaseAuth.instance.currentUser;

    List<CategoryModel> categories = [];

    if (user != null) {
      // Busca do Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection(user.uid)
          .doc('Categories')
          .collection('categoryList')
          .get();

      categories = snapshot.docs.map((doc) {
        return CategoryModel.fromJson(doc.data());
      }).toList();
    } else {
      // Busca do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final List<String> categoriesStringList =
          prefs.getStringList(_categoriesKey) ?? [];

      categories = categoriesStringList.map((categoryString) {
        return CategoryModel.fromJson(jsonDecode(categoryString));
      }).toList();
    }

    if (categories.isEmpty) return null;

    // Encontra a categoria com maior frequência
    CategoryModel highestFrequencyCategory = categories.reduce((a, b) {
      final aFreq = a.frequency ?? 0;
      final bFreq = b.frequency ?? 0;
      return aFreq > bFreq ? a : b;
    });

    return highestFrequencyCategory;
  }
}
