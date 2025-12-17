import 'dart:convert';
import 'package:meus_gastos/controllers/CategoryCreater/data/CategoryRepositoryLocal.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/CategoryRepositoryRemote.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepositoryLocal.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepositoryRemote.dart';
import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepositoryLocal.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepositoryRemote.dart';
import 'package:meus_gastos/controllers/gastos_fixos/data/FixedExpensesRepositoryLocal.dart';
import 'package:meus_gastos/controllers/gastos_fixos/data/FixedExpensesRepositoryRemote.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  Future<void> syncData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Carrega os dados locais
    List<FixedExpense> localFixedExpenses =
        await FixedExpensesRepositoryLocal().fetch();
    List<CardModel> localNormalExpenses =
        await TransactionsRepositoryLocal().retrieve();
    List<GoalModel> localGoals = await GoalsRepositoryLocal().fetchGoals();
    List<CategoryModel> localCategegories =
        await CategoryRepositoryLocal().getAllCategories();
  
    // 2. Baixa os dados do Firebase
    List<FixedExpense> remoteFixedExpenses =
        await FixedExpensesRepositoryRemote(userId: userId).fetch();
    List<CardModel> remoteNormalExpenses =
        await TransactionsRepositoryRemote(userId: userId).retrieve();
    List<GoalModel> remoteGoals =
        await GoalsRepositoryRemote(userId: userId).fetchGoals();
    List<CategoryModel> remoteCategories =
        await CategoryRepositoryRemote(userId: userId).getAllCategories();
      
    // 3. Processa sincronização
    print(localFixedExpenses.length);
    for (FixedExpense card in remoteFixedExpenses) {
      print("Fixeds ${card.category.name} ${card.price}");
    }
    List<FixedExpense> updatedFixedExpenses =
        _mergeFixedData(localFixedExpenses, remoteFixedExpenses);

    List<CardModel> updatedNormalExpenses =
        _mergeData(localNormalExpenses, remoteNormalExpenses);
    if (updatedNormalExpenses != remoteNormalExpenses) print("Deu certo");
    print("object");
    // 4. Salva as mudanças localmente
    await _saveExpensesToLocal(prefs, updatedFixedExpenses, 'fixed_expenses');
    await _saveExpensesToLocal(prefs, updatedNormalExpenses, 'normal_expenses');

    // 5. Envia para o Firebase os dados locais que ainda não estão lá
    await _syncToFirebaseFixed(userId, updatedFixedExpenses, 'fixedCards');
    await _syncToFirebaseNormalExpenses(
      userId, updatedNormalExpenses, 'NormalCards');

    List<GoalModel> updatedGoals = _mergeGoalData(localGoals, remoteGoals);
    await _syncToFirebaseGoals(userId, updatedGoals, 'goals');

    List<CategoryModel> updatedCategories = _mergeCategoryData(localCategegories, remoteCategories);
    await _syncToFirebaseCategories(userId, updatedCategories, 'categories');
  }

  // Compara e mergeia os dados
  List<CardModel> _mergeData(List<CardModel> local, List<CardModel> remote) {
    Map<String, CardModel> merged = {
      for (var e in remote) e.id: e, // Firebase tem prioridade
    };

    for (var e in local) {
      merged.putIfAbsent(
          e.id, () => e); // Adiciona apenas se não existir no Firebase
    }
    merged.values.toList().forEach((card) => print("${card.id}"));
    return merged.values.toList();
  }

  List<FixedExpense> _mergeFixedData(
      List<FixedExpense> local, List<FixedExpense> remote) {
    Map<String, FixedExpense> merged = {
      for (var e in remote) e.id: e, // Firebase tem prioridade
    };

    for (var e in local) {
      merged.putIfAbsent(
          e.id, () => e); // Adiciona apenas se não existir no Firebase
    }

    return merged.values.toList();
  }

  List<GoalModel> _mergeGoalData(
      List<GoalModel> local, List<GoalModel> remote) {
    Map<String, GoalModel> merged = {
      for (var e in remote) e.categoryId: e, // Firebase tem prioridade
    };

    for (var e in local) {
      merged.putIfAbsent(
          e.categoryId, () => e); // Adiciona apenas se não existir no Firebase
    }

    return merged.values.toList();
  }

  List<CategoryModel> _mergeCategoryData(
      List<CategoryModel> local, List<CategoryModel> remote) {
    Map<String, CategoryModel> merged = {
      for (var e in remote) e.id: e, // Firebase tem prioridade
    };

    for (var e in local) {
      merged.putIfAbsent(
          e.id, () => e); // Adiciona apenas se não existir no Firebase
    }

    return merged.values.toList();
  }

  // Salva os dados localmente
  Future<void> _saveExpensesToLocal(
      SharedPreferences prefs, List<dynamic> expenses, String key) async {
    String jsonString = json.encode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(key, jsonString);
  }

  // Envia os dados locais para o Firebase
  Future<void> _syncToFirebaseNormalExpenses(
      String userId, List<CardModel> expenses, String collection) async {
    for (var expense in expenses) {
      await TransactionsRepositoryRemote(userId: userId).addCard(expense);
      print("${expense.amount}");
    }
  }

  // Envia os dados locais para o Firebase
  Future<void> _syncToFirebaseFixed(
      String userId, List<FixedExpense> expenses, String collection) async {
    for (var expense in expenses) {
      await FixedExpensesRepositoryRemote(userId: userId).add(expense);
      print("${expense.price}");
    }
  }

  Future<void> _syncToFirebaseGoals(
      String userId, List<GoalModel> goals, String collection) async {
    for (var goal in goals) {
      await GoalsRepositoryRemote(userId: userId).addGoal(goal);
      print("${goal.value}");
    }
  }

  Future<void> _syncToFirebaseCategories(
      String userId, List<CategoryModel> categories, String collection) async {
    for (var category in categories) {
      await CategoryRepositoryRemote(userId: userId).addCategory(category);
      print("${category.name}");
    }
  }
}
