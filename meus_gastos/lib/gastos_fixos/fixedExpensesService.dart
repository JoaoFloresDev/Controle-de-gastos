import 'package:meus_gastos/models/CardModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class Fixedexpensesservice {
  // Recupera todos os gastos fixos
  static Future<List<FixedExpense>> retrieveCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      return jsonList
          .map((jsonItem) => FixedExpense.fromJson(jsonItem))
          .toList()
        ..sort((a, b) => a.day.compareTo(b.day));
    }
    return [];
  }

  // Retorna os gastos fixos ordenados por dia
  static Future<List<FixedExpense>> getSortedFixedExpenses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      return jsonList
          .map((jsonItem) => FixedExpense.fromJson(jsonItem))
          .toList()
        ..sort((a, b) => a.day.compareTo(b.day));
    }
    return [];
  }

  // Retorna apenas os IDs dos gastos fixos
  static Future<List<String>> getFixedExpenseIds() async {
    final List<FixedExpense> listExpenses = await getSortedFixedExpenses();
    return listExpenses.map((item) => item.id).toList();
  }

  // MARK: - Modifica os gastos fixos
  static Future<void> modifyCards(
      List<FixedExpense> Function(List<FixedExpense> cards) modification) async {
    final List<FixedExpense> cards = await getSortedFixedExpenses();
    final List<FixedExpense> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString("fixed_expenses", encodedData);
  }

  // MARK: - Adicionar, Deletar e Atualizar Gastos Fixos
  static Future<void> addCard(FixedExpense fixedExpense) async {
    await modifyCards((cards) {
      if (fixedExpense.price != 0) cards.add(fixedExpense);
      return cards;
    });
  }

  static Future<void> deleteCard(String id) async {
    await modifyCards((cards) {
      cards.removeWhere((card) => card.id == id);
      return cards;
    });
  }

  static Future<void> updateCard(String id, FixedExpense newCard) async {
    await modifyCards((cards) {
      final int index = cards.indexWhere((card) => card.id == id);
      if (index != -1) {
        cards[index] = newCard;
      }
      return cards;
    });
  }

  // Converte um gasto fixo para um cartão normal
  static CardModel fixedToNormalCard(FixedExpense fixedCard) {
    return CardModel(
      id: fixedCard.id,
      amount: fixedCard.price,
      description: fixedCard.description,
      date: DateTime(DateTime.now().year, DateTime.now().month, fixedCard.day),
      category: fixedCard.category,
    );
  }

  // Mescla os gastos fixos com os normais, respeitando a lógica de recorrência
  static Future<List<CardModel>> mergeFixedWithNormal(
      List<FixedExpense> fixedCards, List<CardModel> normalCards) async {
    List<String> normalIds = await CardService.getNormalExpenseIds();
    for (var fcard in fixedCards) {
      if (!normalIds.contains(fcard.id)) {
        if (shouldAddRecurringExpense(fcard)) {
          normalCards.add(fixedToNormalCard(fcard));
        }
      }
    }
    return normalCards..sort((a, b) => a.date.compareTo(b.date));
  }

  // Verifica se um gasto fixo deve ser adicionado com base na lógica de recorrência
  static bool shouldAddRecurringExpense(FixedExpense expense) {
    DateTime now = DateTime.now();
    DateTime expenseDate = DateTime(now.year, now.month, expense.day);
    return false;
    // switch (expense.recurrence) {
    //   case RecurrenceType.daily:
    //     return true;
    //   case RecurrenceType.weekly:
    //     return now.weekday == expenseDate.weekday;
    //   case RecurrenceType.monthly:
    //     return now.day == expenseDate.day;
    //   case RecurrenceType.yearly:
    //     return now.month == expenseDate.month && now.day == expenseDate.day;
    //   case RecurrenceType.weekdays:
    //     return now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;
    //   case RecurrenceType.none:
    //   default:
    //     return now.day == expense.day;
    // }
  }
}
