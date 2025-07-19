import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/saveExpensOnCloud.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:uuid/uuid.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CategoryService.dart';

class CardService {
  static const String _storageKey = 'cardModels';

// MARK: - Distribuição por Dezenas
  static Future<List<Map<String, dynamic>>> calculateDistributionByTens(
      DateTime month) async {
    final List<CardModel> cards = await CardService.retrieveCards();

    // Número de dias no mês
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Define os intervalos das dezenas
    final int firstTenDays = (daysInMonth / 3).ceil();
    final int secondTenDays = (daysInMonth / 3 * 2).ceil();

    double firstTenSum = 0.0;
    double secondTenSum = 0.0;
    double thirdTenSum = 0.0;
    double totalSpent = 0.0;

    // Filtra os cartões do mês
    final List<CardModel> filteredCards = cards.where((card) {
      return card.date.year == month.year && card.date.month == month.month;
    }).toList();

    // Calcula os gastos por intervalo de dias
    for (var card in filteredCards) {
      final int day = card.date.day;
      totalSpent += card.amount;

      if (day <= firstTenDays) {
        firstTenSum += card.amount;
      } else if (day <= secondTenDays) {
        secondTenSum += card.amount;
      } else {
        thirdTenSum += card.amount;
      }
    }

    // Calcula as porcentagens
    final double firstTenPercentage =
        totalSpent > 0 ? (firstTenSum / totalSpent) * 100 : 0.0;
    final double secondTenPercentage =
        totalSpent > 0 ? (secondTenSum / totalSpent) * 100 : 0.0;
    final double thirdTenPercentage =
        totalSpent > 0 ? (thirdTenSum / totalSpent) * 100 : 0.0;

    return [
      {
        "title": "1ª dezena",
        "amount": firstTenSum,
        "percentage": firstTenPercentage,
      },
      {
        "title": "2ª dezena",
        "amount": secondTenSum,
        "percentage": secondTenPercentage,
      },
      {
        "title": "3ª dezena",
        "amount": thirdTenSum,
        "percentage": thirdTenPercentage,
      }
    ];
  }

  // MARK: - Retrieve Cards
  static Future<List<CardModel>> retrieveCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString(_storageKey);
    if (SaveExpensOnCloud().userId != null) {
      // print(user.displayName);
      List<CardModel> cardList = await SaveExpensOnCloud().fetchCards()
        ..sort((a, b) => a.date.compareTo(b.date));
      return cardList;
    } else {
      if (cardsString != null) {
        final List<dynamic> jsonList = json.decode(cardsString);
        return jsonList.map((jsonItem) => CardModel.fromJson(jsonItem)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
      }
    }
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
      cards.add(cardModel);
      return cards;
    });
    if(SaveExpensOnCloud().userId != null)
      SaveExpensOnCloud().addNewDate(cardModel);
  }

  static Future<void> deleteCard(String id) async {
    await modifyCards((cards) {
      cards.removeWhere((card) => card.id == id);
      return cards;
    });
    List<CardModel> cards = await retrieveCards();
    if(SaveExpensOnCloud().userId != null)
      SaveExpensOnCloud().deleteDate(cards.firstWhere((card) => card.id == id));
  }

  static Future<void> updateCard(String id, CardModel newCard) async {
    await modifyCards((cards) {
      final int index = cards.indexWhere((card) => card.id == id);
      if (index != -1) {
        cards[index] = newCard;
      }
      if(SaveExpensOnCloud().userId != null){
          SaveExpensOnCloud().deleteDate(cards[index]);
          SaveExpensOnCloud().addNewDate(newCard);
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

  static Future<List<ProgressIndicatorModel>> getProgressIndicatorsByMonth(
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
