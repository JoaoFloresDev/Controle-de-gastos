import 'package:meus_gastos/gastos_fixos/intervalsControl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class Fixedexpensesservice {
  static Future<List<FixedExpense>> retrieveCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      return jsonList
          .map((jsonItem) => FixedExpense.fromJson(jsonItem))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return [];
  }

  // static Future<void> saveFixedExpense(FixedExpense expense) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Carregar lista de gastos fixos existentes
  //   List<String> expensesList = prefs.getStringList('fixed_expenses') ?? [];

  //   // Adicionar o novo gasto
  //   expensesList.add(jsonEncode(expense.toJson()));

  //   // Salvar de volta no SharedPreferences
  //   await prefs.setStringList('fixed_expenses', expensesList);
  // }

  static Future<List<FixedExpense>> getSortedFixedExpenses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      return jsonList
          .map((jsonItem) => FixedExpense.fromJson(jsonItem))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return [];
  }

  static Future<List<String>> getFixedExpenseIds() async {
    final List<String> fixedExpenseIds = [];
    final List<FixedExpense> listExpenses = await getSortedFixedExpenses();
    if (listExpenses != null) {
      for (var item in listExpenses) {
        fixedExpenseIds.add(item.id);
      }
    }
    return fixedExpenseIds;
  }

  // MARK: - Modify Cards
  static Future<void> modifyCards(
      List<FixedExpense> Function(List<FixedExpense> cards)
          modification) async {
    final List<FixedExpense> cards = await getSortedFixedExpenses();
    final List<FixedExpense> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString("fixed_expenses", encodedData);
  }

  // MARK: - Add, Delete, and Update Cards
  static Future<void> addCard(FixedExpense FixedExpense) async {
    await modifyCards((cards) {
      if (!(FixedExpense.price == 0)) cards.add(FixedExpense);
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

  static DateTime getCurrentWeekdayDate(DateTime referenceDate) {
    // Obtém o dia da semana da data de referência (1 = segunda-feira, 7 = domingo)
    int referenceWeekday = referenceDate.weekday;

    // Obtém o dia da semana de hoje
    DateTime today = DateTime.now();
    int todayWeekday = today.weekday;

    // Calcula a diferença entre os dias da semana
    int difference = referenceWeekday - todayWeekday;

    // Retorna a data do mesmo dia da semana da data de referência nesta semana
    return today.add(Duration(days: difference));
  }

  static CardModel Fixed_to_NormalCard(FixedExpense fixedCard) {
    int day = fixedCard.date.day;
    if (fixedCard.tipoRepeticao == 'semanal')
      day = getCurrentWeekdayDate(fixedCard.date).day;
    if ((fixedCard.tipoRepeticao == 'seg_sex') || fixedCard.tipoRepeticao == 'diario') day = DateTime.now().day;

    return CardModel(
        id: CardService.generateUniqueId(),
        amount: fixedCard.price,
        description: fixedCard.description,
        date: DateTime(DateTime.now().year, DateTime.now().month, day),
        category: fixedCard.category,
        idFixoControl: fixedCard.id);
  }

  static Future<List<CardModel>> MergeFixedWithNormal(
      List<FixedExpense> fixedCards, List<CardModel> normalCards) async {
    List<String> normalIds = await CardService.getNormalExpenseIds();
    for (var fcard in fixedCards) {
      if (!normalIds.contains(fcard.id)) {
        if (Intervalscontrol().IsapresentetionNecessary(fcard, normalCards)) {
          normalCards.add(Fixed_to_NormalCard(fcard));
        }
      }
    }
    return normalCards..sort((a, b) => a.date.compareTo(b.date));
  }
}
