import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:uuid/uuid.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';

class CardService {

  

  // MARK: - Progress Indicators
  Future<List<ProgressIndicatorModel>> getProgressIndicators(List<CardModel> cards, List<CategoryModel> categories) async {
    if (cards.isEmpty) return [];
    final Map<String, double> totals = {};

    for (var card in cards) {
      totals[card.category.id] = (totals[card.category.id] ?? 0) + card.amount;
    }

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

  static Future<List<double>> getTotalExpensesByMonth(DateTime year, List<CardModel> cards) async {
    final List<double> monthlyTotals = List.generate(12, (index) => 0.0);

    final List<CardModel> filteredCards =
        cards.where((card) => card.date.year == year.year).toList();

    for (var card in filteredCards) {
      int monthIndex = card.date.month - 1; // Ajuste para índice zero
      monthlyTotals[monthIndex] += card.amount;
    }

    return monthlyTotals;
  }

  static Future<double> getTotalExpenses(DateTime year, List<CardModel> cards) async {
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

  static Future<List<String>> getNormalExpenseIds(List<CardModel> cards) async {
    final List<String> normalExpenseIds = [];
    for (var item in cards) {
      normalExpenseIds.add(item.id);
    }
    return normalExpenseIds;
  }

  List<String> getIdFixoControlList(List<CardModel> cards) {
    return cards.map((card) => card.idFixoControl).toList();
  }

  List<CardModel> filterCardsOfMonth(List<CardModel> cards, DateTime currentDate) {
    return cards
        .where((card) =>
            card.date.year == currentDate.year &&
            card.date.month == currentDate.month &&
            card.amount != 0)
        .toList();
  }
}
