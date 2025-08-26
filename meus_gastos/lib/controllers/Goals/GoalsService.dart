import 'dart:convert';
import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardService.dart';
// import 'package:meus_gastos/services/firebase/SaveGoalsToClould.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsService {
  final String _budgetKey = "budgets";

  Future<List<GoalModel>> retrive() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? budgetsString = pref.getString(_budgetKey);
    // if (SaveGoalsToClould().userId != null) {
    //   return SaveGoalsToClould().getAllGoals();
    // } else {
      if (budgetsString != null) {
        List<dynamic> jsonList = jsonDecode(budgetsString);
        return jsonList
            .map((jsonItem) => GoalModel.fromJson(jsonItem))
            .toList();
      }
    // }
    return [];
  }

  

  Future<Map<String, double>> getGoals(List<CategoryModel> categories) async {
    Map<String, double> budgetsByCat = {
      for (var cat in categories) cat.id: 0.0,
    };

    List<GoalModel> budgets = await retrive();
    List<String> categoriesId = categories.map((cat) => cat.id).toList();

    

    if (budgets.isNotEmpty) {
      budgets.forEach((budg) {
        if (categoriesId.contains(budg.categoryId))
          budgetsByCat[budg.categoryId] = budg.value;
        else
          GoalsService().deleteMeta(budg.categoryId);
      });
    }
    return budgetsByCat;
  }

  Future<double> getTotalGoal() async {
    List<GoalModel> budgets = await retrive();
    double totalGoal = budgets.fold(0.0, (sum, meta) => sum + meta.value);
    return totalGoal;
  }

  Future<void> modifyMetas(
      List<GoalModel> Function(List<GoalModel> cards) modification) async {
    final List<GoalModel> metas = await retrive();
    final List<GoalModel> modifiedCards = modification(metas);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((meta) => meta.toJson()).toList());
    await prefs.setString(_budgetKey, encodedData);
  }

  Future<void> addMeta(String categoryId, double meta) async {
    List<GoalModel> budgets = await retrive();
    int index = budgets.indexWhere((bud) => bud.categoryId == categoryId);
    if (index != -1) {
      modifyMetas((metas) {
        metas[index] = GoalModel(categoryId: categoryId, value: meta);
        return metas;
      });
    } else {
      modifyMetas((metas) {
        metas.add(GoalModel(categoryId: categoryId, value: meta));
        return metas;
      });
    }
    // if (SaveGoalsToClould().userId != null)
    //   SaveGoalsToClould()
    //       .addGoalInClound(GoalModel(categoryId: categoryId, value: meta));
  }

  Future<void> deleteMeta(String categoryId) async {
    await modifyMetas((metas) {
      metas.removeWhere((meta) => meta.categoryId == categoryId);
      return metas;
    });
    // if (SaveGoalsToClould().userId != null)
    //   SaveGoalsToClould().deleteGoalInClound(categoryId);
  }

  Future<void> deleteAllGoalsOfaCategory(CategoryModel category) async {
    // deleta todas as metas com gasto zero no mes e categoria não avaliavel
    //
    List<GoalModel> budgets = await retrive();
    List<ProgressIndicatorModel> progress =
        await CardService().getProgressIndicatorsByMonth(DateTime.now());

    bool haveExpens = false;

    try {
      haveExpens = (progress
              .where((pg) => pg.category.id == category.id)
              .first
              .progress >
          0);
    } catch (e) {
      print("ERRO $e");
    }

    for (var budg in budgets) {
      if (budg.categoryId == category.id) {
        if (!haveExpens) deleteMeta(budg.categoryId);
        break;
      }
    }
  }
}
