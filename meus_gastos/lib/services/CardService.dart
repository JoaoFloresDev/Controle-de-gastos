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
    return [];
  }

  // MARK: - Modify Cards
  static Future<void> modifyCards(
      List<CardModel> Function(List<CardModel> cards) modification) async {
    final List<CardModel> cards = await retrieveCards();
    final List<CardModel> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  // MARK: - Add, Delete, and Update Cards
  static Future<void> addCard(CardModel cardModel) async {
    await modifyCards((cards) {
      if (!(cardModel.amount == 0)) cards.add(cardModel);
      return cards;
    });
  }

  static Future<void> deleteCard(String id) async {
    await modifyCards((cards) {
      cards.removeWhere((card) => card.id == id);
      return cards;
    });
  }

  static Future<void> updateCard(String id, CardModel newCard) async {
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
    await prefs.remove(_storageKey);
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

  static Future<List<ProgressIndicatorModel>> getProgressIndicatorsByMonth(
      DateTime month) async {
    final List<CardModel> cards = await retrieveCards();
    if (cards.isEmpty) return [];
    final Map<String, double> totals = {};

    final List<CardModel> filteredCards = cards
        .where((card) =>
            card.date.year == month.year && card.date.month == month.month)
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

  // MARK: - Category with Highest Frequency
  static Future<CategoryModel?> getCategoryWithHighestFrequency() async {
    final List<CardModel> cards = await retrieveCards();
    final Map<String, int> frequencyMap = {};

    for (var card in cards) {
      frequencyMap[card.category.id] =
          (frequencyMap[card.category.id] ?? 0) + 1;
    }

    if (frequencyMap.isEmpty) {
      return null;
    }

    final String highestFrequencyCategoryId =
        frequencyMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final List<CategoryModel> categories =
        await CategoryService().getAllCategories();

    return categories.firstWhere(
      (category) => category.id == highestFrequencyCategoryId,
      orElse: () => CategoryModel(
        id: '',
        name: 'Unknown',
        icon: Icons.help,
        color: AppColors.buttonDeselected,
        frequency: 0,
      ),
    );
  }

  static Future<List<String>> getNormalExpenseIds() async {
    final List<String> normalExpenseIds = [];
    final List<CardModel> listExpenses = await retrieveCards();
    for (var item in listExpenses) {
      normalExpenseIds.add(item.id);
    }
    return normalExpenseIds;
  }
}
