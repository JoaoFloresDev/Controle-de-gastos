import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:uuid/uuid.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';

class CardService {
  static const String _storageKey = 'cardModels';

  // MARK: - Retrieve Cards
  static Future<List<CardModel>> retrieveCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString(_storageKey);
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      return jsonList.map((jsonItem) => CardModel.fromJson(jsonItem)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    // }
    return [];
  }

  static Future<List<CardModel>> retrieveCardsToSync() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString(_storageKey);
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      return jsonList.map((jsonItem) => CardModel.fromJson(jsonItem)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return [];
  }

  // MARK: - Modify Cards
  Future<void> modifyCards(
      List<CardModel> Function(List<CardModel> cards) modification) async {
    final List<CardModel> cards = await retrieveCards();
    final List<CardModel> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  // MARK: - Add, Delete, and Update Cards
  Future<void> addCard(CardModel cardModel) async {
    await modifyCards((cards) {
      cards.add(cardModel);
      return cards;
    });
    // if (SaveExpensOnCloud().userId != null)
    //   SaveExpensOnCloud().addNewDate(cardModel);
  }

  Future<void> deleteCard(CardModel card) async {
    String id = card.id;
    await modifyCards((cards) {
      cards.removeWhere((card) => card.id == id);
      return cards;
    });
    // }
  }

  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    String id = oldCard.id;
    await modifyCards((cards) {
      final int index = cards.indexWhere((card) => card.id == id);
      if (index != -1) {
        cards[index] = newCard;
      }
      return cards;
    });
  }

  // MARK: - Delete All Cards
  static Future<void> deleteAllCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await prefs.remove(_storageKey);
    print("Delet result = $result");
  }

  // MARK: - Progress Indicators
  static Future<List<ProgressIndicatorModel>> getProgressIndicators() async {
    final List<CardModel> cards = await retrieveCards();
    final Map<String, double> totals = {};

    for (var card in cards) {
      totals[card.category.id] = (totals[card.category.id] ?? 0) + card.amount;
    }

    final List<CategoryModel> categories =
        await CategoryService().getAllCategories();
    final Map<String, CategoryModel> categoryMap = {
      for (var category in categories) category.id: category
    };

    final List<ProgressIndicatorModel> progressIndicators = totals.entries
        .map((entry) => ProgressIndicatorModel(
            title: categoryMap[entry.key]?.name ?? 'Unknown',
            progress: entry.value,
            category: categoryMap[entry.key] ??
                CategoryModel(
                  id: entry.key,
                  name: 'Unknown',
                  color: Colors.grey,
                  icon: Icons.help,
                ),
            color: categoryMap[entry.key]?.color ?? Colors.grey))
        .toList();

    progressIndicators.sort((a, b) => b.progress.compareTo(a.progress));

    return progressIndicators;
  }

  Future<List<ProgressIndicatorModel>> getProgressIndicatorsByMonth(
      DateTime month) async {
    final List<CardModel> cards = await retrieveCards();
    if (cards.isEmpty) return [];
    final Map<String, double> totals = {};

    final List<CardModel> filteredCards = cards
        .where((card) =>
            card.date.year == month.year &&
            card.date.month == month.month &&
            card.amount != 0)
        .toList();

    for (var card in filteredCards) {
      totals[card.category.id] = (totals[card.category.id] ?? 0) + card.amount;
    }

    final List<CategoryModel> categories =
        await CategoryService().getAllCategories();
    final Map<String, CategoryModel> categoryMap = {
      for (var category in categories) category.id: category
    };

    final List<ProgressIndicatorModel> progressIndicators = totals.entries
        .map((entry) => ProgressIndicatorModel(
            title: categoryMap[entry.key]?.name ?? entry.key,
            progress: entry.value,
            category: categoryMap[entry.key] ??
                CategoryModel(
                  id: entry.key,
                  name: entry.key,
                  color: Colors.grey,
                  icon: Icons.help,
                ),
            color: categoryMap[entry.key]?.color ?? Colors.grey))
        .toList();

    progressIndicators.sort((a, b) => b.progress.compareTo(a.progress));

    return progressIndicators;
  }

  // MARK: - Daily Expenses by Month
  static Future<List<double>> getDailyExpensesByMonth(DateTime month) async {
    final List<CardModel> cards = await retrieveCards();

    // Inicializa a lista com 0.0 para todos os dias do mês
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final List<double> dailyExpenses = List.generate(daysInMonth, (_) => 0.0);

    // Filtra os cartões que pertencem ao mês especificado
    final List<CardModel> filteredCards = cards.where((card) {
      return card.date.year == month.year && card.date.month == month.month;
    }).toList();

    // Adiciona os gastos ao dia correspondente
    for (var card in filteredCards) {
      final int dayIndex = card.date.day - 1; // Ajusta para índice zero
      dailyExpenses[dayIndex] += card.amount;
    }

    return dailyExpenses;
  }

  static Future<List<double>> getTotalExpensesByMonth(DateTime year) async {
    final List<CardModel> cards = await retrieveCards();
    final List<double> monthlyTotals = List.generate(12, (index) => 0.0);

    final List<CardModel> filteredCards =
        cards.where((card) => card.date.year == year.year).toList();

    for (var card in filteredCards) {
      int monthIndex = card.date.month - 1; // Ajuste para índice zero
      monthlyTotals[monthIndex] += card.amount;
    }

    return monthlyTotals;
  }

  static Future<double> getTotalExpenses(DateTime year) async {
    final List<CardModel> cards = await retrieveCards();
    double totalExpenses = 0.0;

    for (var card in cards) {
      totalExpenses += card.amount;
    }

    return totalExpenses;
  }

  // MARK: - Utility
  static String generateUniqueId() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  static Future<List<String>> getNormalExpenseIds() async {
    final List<String> normalExpenseIds = [];
    final List<CardModel> listExpenses = await retrieveCards();
    for (var item in listExpenses) {
      normalExpenseIds.add(item.id);
    }
    return normalExpenseIds;
  }

  List<String> getIdFixoControlList(List<CardModel> cards) {
    return cards.map((card) => card.idFixoControl).toList();
  }
}
