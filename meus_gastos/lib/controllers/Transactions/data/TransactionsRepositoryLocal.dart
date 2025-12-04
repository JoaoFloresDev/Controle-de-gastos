import 'dart:convert';

import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/ITransactionsRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionsRepositoryLocal implements ITransactionsRepository {

  static const String _storageKey = 'cardModels';

  Future<void> _modifyCards(
      List<CardModel> Function(List<CardModel> cards) modification) async {
    final List<CardModel> cards = await retrieve();
    final List<CardModel> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  @override
  Future<void> addCard(CardModel cardModel) async {
    await _modifyCards((cards) {
      cards.add(cardModel);
      return cards;
    });
  }
  @override
  Future<void> deleteCard(CardModel card) async {
    String id = card.id;
    await _modifyCards((cards) {
      cards.removeWhere((card) => card.id == id);
      return cards;
    });
  }

  @override
  Future<List<CardModel>> retrieve() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString(_storageKey);
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      return jsonList.map((jsonItem) => CardModel.fromJson(jsonItem)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return [];
  }

  @override
  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    String id = oldCard.id;
    await _modifyCards((cards) {
      final int index = cards.indexWhere((card) => card.id == id);
      if (index != -1) {
        cards[index] = newCard;
      }
      // if (SaveExpensOnCloud().userId != null) {
      //   SaveExpensOnCloud().deleteDate(cards[index]);
      //   SaveExpensOnCloud().addNewDate(newCard);
      // }
      return cards;
    });
  }

  // MARK: - Delete All Cards
  static Future<void> deleteAllCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await prefs.remove(_storageKey);
    print("Delet result = $result");
  }

}