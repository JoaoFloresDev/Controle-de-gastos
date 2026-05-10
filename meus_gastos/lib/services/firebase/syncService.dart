import 'dart:convert';
import 'package:meus_gastos/controllers/CategoryCreater/data/CategoryRepositoryLocal.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/CategoryRepositoryRemote.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepositoryLocal.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepositoryRemote.dart';
import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepositoryLocal.dart';
import 'package:meus_gastos/controllers/Transactions/data/TransactionsRepositoryRemote.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/data/FixedExpensesRepositoryLocal.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/data/FixedExpensesRepositoryRemote.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  // Storage keys (espelham as constantes privadas dos repos locais).
  static const String _normalCardsKey = 'cardModels';
  static const String _fixedExpensesKey = 'fixed_expenses';
  static const String _goalsKey = 'budgets';
  static const String _categoriesKey = 'categories';

  Future<void> syncData(String userId) async {
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
    List<FixedExpense> updatedFixedExpenses =
        _mergeFixedData(localFixedExpenses, remoteFixedExpenses);
    List<CardModel> updatedNormalExpenses =
        _mergeData(localNormalExpenses, remoteNormalExpenses);
    List<GoalModel> updatedGoals = _mergeGoalData(localGoals, remoteGoals);
    // Categoria sintética "AddCategory" é o botão "+" da grade — não deve ir
    // pro remote nem ser tratada como dado real no merge.
    List<CategoryModel> updatedCategories = _mergeCategoryData(
      localCategegories.where((c) => c.id != 'AddCategory').toList(),
      remoteCategories.where((c) => c.id != 'AddCategory').toList(),
    );

    // 4. Persiste o resultado mergeado no LOCAL — antes só subia pro remote,
    // o que fazia o usuário perder no logout tudo que veio do Firebase.
    final prefs = await SharedPreferences.getInstance();
    await _saveToLocal(prefs, _normalCardsKey, updatedNormalExpenses);
    await _saveToLocal(prefs, _fixedExpensesKey, updatedFixedExpenses);
    await _saveToLocal(prefs, _goalsKey, updatedGoals);
    await _saveCategoriesToLocal(prefs, updatedCategories, localCategegories);

    // 5. Envia para o Firebase os dados que ainda não estão lá
    await _syncToFirebaseFixed(userId, updatedFixedExpenses, 'fixedCards');
    await _syncToFirebaseNormalExpenses(
        userId, updatedNormalExpenses, 'NormalCards');
    await _syncToFirebaseGoals(userId, updatedGoals, 'goals');
    await _syncToFirebaseCategories(userId, updatedCategories, 'categories');
  }

  Future<void> _saveToLocal(
      SharedPreferences prefs, String key, List<dynamic> items) async {
    final String encoded =
        json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  // Categorias usam setStringList (uma string JSON por item), não setString.
  // Reanexa o item "AddCategory" do local para preservar o botão "+" da UI.
  Future<void> _saveCategoriesToLocal(
      SharedPreferences prefs,
      List<CategoryModel> merged,
      List<CategoryModel> local) async {
    final addCategory = local.where((c) => c.id == 'AddCategory').toList();
    final all = [...merged, ...addCategory];
    final List<String> encoded =
        all.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_categoriesKey, encoded);
  }

  // Merge resolve conflito por updatedAt — o mais recente vence. Antes era
  // "remote sempre vence + local só se não existir no remote", o que
  // (a) descartava silenciosamente edições locais mais recentes e (b) deixava
  // tombstones de deleção do device A perderem para versões antigas do B.
  // Tombstones (deleted=true) seguem no merged: a UI filtra no retrieve(),
  // mas o sync precisa propagá-los para os outros devices.
  List<CardModel> _mergeData(List<CardModel> local, List<CardModel> remote) {
    final Map<String, CardModel> merged = {};
    for (final e in [...local, ...remote]) {
      final existing = merged[e.id];
      if (existing == null || e.updatedAt.isAfter(existing.updatedAt)) {
        merged[e.id] = e;
      }
    }
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

  // Envia os dados locais para o Firebase
  Future<void> _syncToFirebaseNormalExpenses(
      String userId, List<CardModel> expenses, String collection) async {
    for (var expense in expenses) {
      await TransactionsRepositoryRemote(userId: userId).addCard(expense);
    }
  }

  // Envia os dados locais para o Firebase
  Future<void> _syncToFirebaseFixed(
      String userId, List<FixedExpense> expenses, String collection) async {
    for (var expense in expenses) {
      await FixedExpensesRepositoryRemote(userId: userId).add(expense);
    }
  }

  Future<void> _syncToFirebaseGoals(
      String userId, List<GoalModel> goals, String collection) async {
    for (var goal in goals) {
      await GoalsRepositoryRemote(userId: userId).addGoal(goal);
    }
  }

  Future<void> _syncToFirebaseCategories(
      String userId, List<CategoryModel> categories, String collection) async {
    for (var category in categories) {
      await CategoryRepositoryRemote(userId: userId).addCategory(category);
    }
  }
}
