import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/controllers/orcamentos/budgetModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Goalsservice {
  String _budgetKey = "budgets";
  Future<List<Budgetmodel>> retrive() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? budgetsString = pref.getString(_budgetKey);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // pegar os dados do firebase
    } else {
      if (budgetsString != null) {
        List<dynamic> jsonList = jsonDecode(budgetsString);
        return jsonList.map((jsonItem) => Budgetmodel.fromJson(jsonItem)).toList();

      }
    }
    return [];
  }

  Future<Map<String, double>> getBudgets() async {
    List<CategoryModel> categories = await CategoryService().getAllCategories();
    // gera um mapa com todas metas zeradas
    Map<String, double> metas_por_cat = {
      for (var cat in categories) cat.id: 0.0,
    };

    List<Budgetmodel> budgets = await retrive();
    print(budgets.isNotEmpty);
    if (budgets.isNotEmpty) {
      budgets.forEach((budg) {
        metas_por_cat[budg.categoryId] = budg.value;
      });
    }
    return metas_por_cat;
  }

  Future<double> getTotalBudget() async {
    List<Budgetmodel> budgets = await retrive();
    double totalBudget = budgets.fold(0.0, (sum, meta) => sum + meta.value);
    return totalBudget;
  }

  Future<void> modifyMetas(
      List<Budgetmodel> Function(List<Budgetmodel> cards) modification) async {
    final List<Budgetmodel> metas = await retrive();
    print('Antes da modificação: ${metas.map((m) => m.toJson())}');

    final List<Budgetmodel> modifiedCards = modification(metas);
    print('Depois da modificação: ${modifiedCards.map((m) => m.toJson())}');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((meta) => meta.toJson()).toList());
    bool result = await prefs.setString(_budgetKey, encodedData);
    print("$result");
  }

  Future<void> addMeta(String categoryId, double meta) async {
    List<Budgetmodel> budgets = await retrive();
    Budgetmodel removido = budgets.firstWhere(
      (bud) => bud.categoryId == categoryId,
      orElse: () => Budgetmodel(categoryId: '', value: 0),
    );
    if (removido != null) {
      deleteMeta(removido.categoryId);
    }
    modifyMetas((metas) {
      metas.add(Budgetmodel(categoryId: categoryId, value: meta));
      return metas;
    });
  }

  Future<void> deleteMeta(String categoryId) async {
    await modifyMetas((metas) {
      metas.removeWhere((meta) => meta.categoryId == categoryId);
      return metas;
    });
  }
}
