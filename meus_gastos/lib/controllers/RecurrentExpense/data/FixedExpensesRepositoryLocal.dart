import 'dart:convert';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/FixedExpensesViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixedExpensesRepositoryLocal {
  final String _keyFixedExpenses = 'fixed_expenses';

  Future<List<FixedExpense>> fetch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString(_keyFixedExpenses);
    List<FixedExpense> fc = [];

    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      fc = jsonList.map((jsonItem) => FixedExpense.fromJson(jsonItem)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    return fc;
  }

  Future<void> modifyCards(
      List<FixedExpense> Function(List<FixedExpense> cards)
          modification) async {
    final List<FixedExpense> cards = await fetch();
    final List<FixedExpense> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString(_keyFixedExpenses, encodedData);
  }

  Future<void> add(FixedExpense newCard) async {
    try {
      await modifyCards((cards) {
        if (!(newCard.price == 0)) {
          cards.add(newCard);
        }
        return cards;
      });
    } catch (e) {
      print("ERRO ao adicionar: $e");
    }
  }

  Future<void> update(FixedExpense newCard) async {
    try {
      await modifyCards((cards) {
        final int index = cards.indexWhere((card) => card.id == newCard.id);
        if (index != -1) {
          cards[index] = newCard;
        }
        return cards;
      });
    } catch (e) {
      print("ERRO AO UPDATE: ${e}");
    }
  }

  Future<void> delete(String id) async{
    try { 
      await modifyCards((cards) {
      cards.removeWhere((card) => card.id == id);
      return cards;
    });
    } catch (e) {
      print("Erro ao deletar: $e");
    }
  }

  Future<void> deleteAllCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFixedExpenses);
  }
}
