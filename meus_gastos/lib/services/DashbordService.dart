import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:flutter/material.dart';

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
    DateTime lastMonday = currentDate
        .subtract(Duration(days: currentDate.weekday - DateTime.monday));

    for (int i = 4; i >= 0; i--) {
      DateTime startOfWeek = lastMonday.subtract(Duration(days: 7 * i));
      DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
      intervals.add(WeekInterval(startOfWeek, endOfWeek));
    }

    return intervals;
  }

  static Future<List<ProgressIndicatorModel>> getProgressIndicatorsByWeek(
      DateTime start, DateTime end) async {
    final List<CardModel> cards = await CardService.retrieveCards();
    if (cards.isEmpty) return [];
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
      for (var category in categories) category.id: category,
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
                    icon: Icons.help),
            color: categoryMap[entry.key]?.color ?? AppColors.buttonDeselected))
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
      Map<String, CategoryModel> uniqueCategories = {};

    for (var progressIndicators in progressIndicatorsList) {
      for (var progressIndicator in progressIndicators) {
        uniqueCategories[progressIndicator.category.id] = progressIndicator.category;
      }
    }

  return uniqueCategories.values.toList();
  }

  static Future<List<List<ProgressIndicatorModel>>>
      getDailyProgressIndicatorsByWeek(DateTime start, DateTime end) async {
    final List<CardModel> cards = await CardService.retrieveCards();
    if (cards.isEmpty) return [];

    final List<CardModel> filteredCards = cards.where((card) {
      return card.date.isAfter(start) &&
          card.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    Map<String, Map<int, double>> dailyTotals = {};

    for (var card in filteredCards) {
      String categoryId = card.category.id;
      int dayOfWeek = card.date.weekday;

      if (!dailyTotals.containsKey(categoryId)) {
        dailyTotals[categoryId] = {for (int i = 1; i <= 7; i++) i: 0.0};
      }

      dailyTotals[categoryId]![dayOfWeek] =
          (dailyTotals[categoryId]![dayOfWeek] ?? 0) + card.amount;
    }

    final List<CategoryModel> categories =
        await CategoryService().getAllCategories();
    final Map<String, CategoryModel> categoryMap = {
      for (var category in categories) category.id: category,
    };

    List<List<ProgressIndicatorModel>> weeklyData = List.generate(7, (_) => []);

    dailyTotals.forEach((categoryId, dayTotals) {
      CategoryModel category = categoryMap[categoryId] ??
          CategoryModel(
              id: categoryId,
              name: 'Unknown',
              color: AppColors.buttonDeselected,
              icon: Icons.device_unknown);

      for (int i = 1; i <= 7; i++) {
        double progress = dayTotals[i] ?? 0.0;

        weeklyData[i - 1].add(ProgressIndicatorModel(
          title: category.name,
          progress: progress,
          category: category,
          color: category.color,
        ));
      }
    });

    for (var dailyProgress in weeklyData) {
      dailyProgress.sort((a, b) => b.progress.compareTo(a.progress));
    }

    return weeklyData;
  }

  static Future<List<List<List<ProgressIndicatorModel>>>>
      getProgressIndicatorsOfDaysForLast5Weeks(DateTime currentDate) async {
    List<WeekInterval> intervals = getLast5WeeksIntervals(currentDate);

    List<Future<List<List<ProgressIndicatorModel>>>> futures = [];

    for (var interval in intervals) {
      futures
          .add(getDailyProgressIndicatorsByWeek(interval.start, interval.end));
    }

    return await Future.wait(futures);
  }
}
