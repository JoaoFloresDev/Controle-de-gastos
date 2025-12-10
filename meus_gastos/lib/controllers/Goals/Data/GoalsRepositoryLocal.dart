import 'dart:convert';

import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsRepositoryLocal {
  final String _budgetKey = "budgets";
  
  Future<List<GoalModel>> fetchGoals() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? budgetsString = pref.getString(_budgetKey);
    // if (SaveGoalsToClould().userId != null) {
    //   return SaveGoalsToClould().getAllGoals();
    // } else {
    if (budgetsString != null) {
      List<dynamic> jsonList = jsonDecode(budgetsString);
      return jsonList.map((jsonItem) => GoalModel.fromJson(jsonItem)).toList();
    }
    // }
    return [];
  }

  Future<void> modifyGoal(
      List<GoalModel> Function(List<GoalModel> cards) modification) async {
    final List<GoalModel> goal = await fetchGoals();
    final List<GoalModel> modifiedCards = modification(goal);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((meta) => meta.toJson()).toList());
    await prefs.setString(_budgetKey, encodedData);
  }

  Future<void> addGoal(GoalModel newGoal) async {
    List<GoalModel> budgets = await fetchGoals();
    int index = budgets.indexWhere((bud) => bud.categoryId == newGoal.categoryId);
    if (index != -1) {
      modifyGoal((goal) {
        goal[index] = newGoal;
        return goal;
      });
    } else {
      modifyGoal((goal) {
        goal.add(newGoal);
        return goal;
      });
    }
  }

  Future<void> deleteGoal(String categoryId) async {
    await modifyGoal((goal) {
      goal.removeWhere((meta) => meta.categoryId == categoryId);
      return goal;
    });
  }

}
