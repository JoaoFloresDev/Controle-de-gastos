import 'dart:convert';
import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardServiceRefatore.dart';
// import 'package:meus_gastos/services/firebase/SaveGoalsToClould.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsService {
  final String _budgetKey = "goal";

  Future<List<GoalModel>> retrive() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? goalString = pref.getString(_budgetKey);
    // if (SaveGoalsToClould().userId != null) {
    //   return SaveGoalsToClould().getAllGoals();
    // } else {
    if (goalString != null) {
      List<dynamic> jsonList = jsonDecode(goalString);
      return jsonList.map((jsonItem) => GoalModel.fromJson(jsonItem)).toList();
    }
    // }
    return [];
  }

  Future<Map<String, double>> getGoals(List<GoalModel> goals, List<CategoryModel> categories) async {
    Map<String, double> goalByCat = {
      for (var cat in categories) cat.id: 0.0,
    };

    List<String> categoriesId = categories.map((cat) => cat.id).toList();

    if (goals.isNotEmpty) {
      goals.forEach((budg) {
        if (categoriesId.contains(budg.categoryId))
          goalByCat[budg.categoryId] = budg.value;
        else
          deleteMeta(budg.categoryId);
      });
    }
    return goalByCat;
  }

  Future<double> getTotalGoal() async {
    List<GoalModel> goal = await retrive();
    double totalGoal = goal.fold(0.0, (sum, meta) => sum + meta.value);
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
    List<GoalModel> goal = await retrive();
    int index = goal.indexWhere((bud) => bud.categoryId == categoryId);
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

  Future<void> deleteAllGoalsOfaCategory(
      List<CardModel> cards, List<CategoryModel> categories, CategoryModel category) async {
    // deleta todas as metas com gasto zero no mes e categoria não avaliavel
    //
    List<GoalModel> goal = await retrive();

    List<CardModel> filteredCards = CardService().filterCardsOfMonth(cards, DateTime.now());

    List<ProgressIndicatorModel> progress =
        await CardService().getProgressIndicators(filteredCards, categories);

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

    for (var budg in goal) {
      if (budg.categoryId == category.id) {
        if (!haveExpens) deleteMeta(budg.categoryId);
        break;
      }
    }
  }
}
