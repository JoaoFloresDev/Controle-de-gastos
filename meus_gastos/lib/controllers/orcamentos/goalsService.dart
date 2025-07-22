import 'dart:convert';

import 'package:meus_gastos/controllers/orcamentos/budgetModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meus_gastos/controllers/orcamentos/saveOrcamentosNaNuvem.dart';

class Goalsservice {
  final String _budgetKey =
      "budgets"; // chave para pegar as metas no sheredPreferences

  // MARK: Pega todas as metas do usuario
  Future<List<Budgetmodel>> retrive() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? budgetsString = pref.getString(_budgetKey);
    if(Saveorcamentosnanuvem().userId != null){
      return Saveorcamentosnanuvem().getAllBudgets();
    } else {
      if (budgetsString != null) {
        List<dynamic> jsonList = jsonDecode(budgetsString);
        return jsonList
            .map((jsonItem) => Budgetmodel.fromJson(jsonItem))
            .toList();
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

    List<String> categoriesId = categories.map((cat) => cat.id).toList();

    print(budgets.isNotEmpty);
    if (budgets.isNotEmpty) {
      budgets.forEach((budg) {
        if (categoriesId.contains(budg.categoryId))
          metas_por_cat[budg.categoryId] = budg.value;
        else
          Goalsservice().deleteMeta(budg.categoryId);
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
    int index = budgets.indexWhere((bud) => bud.categoryId == categoryId);
    if (index != -1) {
      modifyMetas((metas) {
        metas[index] = Budgetmodel(categoryId: categoryId, value: meta);
        return metas;
      });
    } else {
      modifyMetas((metas) {
        metas.add(Budgetmodel(categoryId: categoryId, value: meta));
        return metas;
      });
    }
    // Adicionar na nuvem
    if(Saveorcamentosnanuvem().userId != null)
      Saveorcamentosnanuvem()
        .addBudgetInClound(Budgetmodel(categoryId: categoryId, value: meta));
  }

  Future<void> deleteMeta(String categoryId) async {
    await modifyMetas((metas) {
      metas.removeWhere((meta) => meta.categoryId == categoryId);
      return metas;
    });
    // Deleta na nuvem
    if(Saveorcamentosnanuvem().userId != null)
      Saveorcamentosnanuvem().deleteBudgetInClound(categoryId);
  }
}
