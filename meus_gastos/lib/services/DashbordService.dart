import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';

class WeekInterval {
  final DateTime start;
  final DateTime end;

  WeekInterval(this.start, this.end);

  @override
  String toString() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return 'Início: ${formatter.format(start)}, Fim: ${formatter.format(end)}';
  }
}

class Dashbordservice {
  static List<WeekInterval> getLast5WeeksIntervals(DateTime currentDate) {
    List<WeekInterval> intervals = [];
    DateTime today = DateTime.now();
    if (currentDate.month == today.month) {
      currentDate = DateTime(currentDate.year, currentDate.month, today.day);
    } else {
      currentDate = DateTime(currentDate.year, currentDate.month,
          DateTime(currentDate.year, currentDate.month + 1, 0).day);
    }
    // Encontrar a última segunda-feira
    DateTime lastMonday = currentDate
        .subtract(Duration(days: currentDate.weekday - DateTime.monday));

    // Iterar pelas últimas 5 semanas
    for (int i = 4; i >= 0; i--) {
      DateTime startOfWeek = lastMonday.subtract(Duration(days: 7 * i));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
      intervals.add(WeekInterval(startOfWeek, endOfWeek));
    }

    return intervals;
  }

  static Future<List<ProgressIndicatorModel>> getProgressIndicatorsByWeek(
      DateTime start, DateTime end) async {
    final List<CardModel> cards = await CardService.retrieveCards();
    final Map<String, double> totals = {};

    final List<CardModel> filteredCards = cards
        .where((card) =>
            card.date.isAfter(start) &&
            card.date.isBefore(end.add(const Duration(days: 1))))
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
            title: categoryMap[entry.key]?.name ?? 'Unknown',
            progress: entry.value,
            category: categoryMap[entry.key]!,
            color: categoryMap[entry.key]?.color ?? Colors.grey))
        .toList();

    progressIndicators.sort((a, b) => b.progress.compareTo(a.progress));
    return progressIndicators;
  }

  static Future<List<List<ProgressIndicatorModel>>>
      getLast5WeeksProgressIndicators(DateTime currentDate) async {
    List<WeekInterval> intervals = getLast5WeeksIntervals(currentDate);
    List<List<ProgressIndicatorModel>> progressIndicatorsList = [];

    for (var interval in intervals) {
      List<ProgressIndicatorModel> weeklyProgressIndicators =
          await getProgressIndicatorsByWeek(interval.start, interval.end);
      progressIndicatorsList.add(weeklyProgressIndicators);
    }

    return progressIndicatorsList;
  }

  static List<CategoryModel> extractCategories(
      List<List<ProgressIndicatorModel>> progressIndicatorsList) {
    Set<CategoryModel> categoriesSet = {};

    for (var progressIndicators in progressIndicatorsList) {
      for (var progressIndicator in progressIndicators) {
          categoriesSet.add(progressIndicator.category);
      }
    }

    return categoriesSet.toList();
  }
}
