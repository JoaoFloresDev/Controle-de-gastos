import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/models/CardModel.dart';
import 'package:uuid/uuid.dart';

class CardService {
  static const String _storageKey = 'cardModels';

  static Future<List<CardModel>> retrieveCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString(_storageKey);
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      final List<CardModel> cards =
          jsonList.map((jsonItem) => CardModel.fromJson(jsonItem)).toList();
      cards.sort((a, b) => a.date.compareTo(b.date)); // Ordenar por data
      return cards;
    } else {
      return [];
    }
  }

  static Future<void> addCard(CardModel cardModel) async {
    final List<CardModel> cards = await retrieveCards();
    cards.add(cardModel);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(cards.map((card) => card.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  static Future<void> deleteAllCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<void> printAllCards() async {
    final List<CardModel> cards = await retrieveCards();
    if (cards.isNotEmpty) {
      for (var card in cards) {
        print(
            'Amount: ${card.amount}, Description: ${card.description}, Date: ${card.date}');
      }
    } else {
      print('Não há elementos salvos.');
    }
  }

  static String generateUniqueId() {
    var uuid = Uuid();
    return uuid.v4();
  }

  static Future<void> deleteCard(String id) async {
    final List<CardModel> cards = await retrieveCards();
    cards.removeWhere((card) => card.id == id);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(cards.map((card) => card.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  static Future<void> updateCard(String id, CardModel newCard) async {
    final List<CardModel> cards = await retrieveCards();
    final int index = cards.indexWhere((card) => card.id == id);
    if (index != -1) {
      cards.removeAt(index);
      cards.insert(index, newCard);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String encodedData =
          json.encode(cards.map((card) => card.toJson()).toList());
      await prefs.setString(_storageKey, encodedData);
    }
  }

  static Future<double> getTotalSpentByCategory(String category) async {
    final List<CardModel> cards = await retrieveCards();
    double totalSpent = 0;
    for (var card in cards) {
      if (card.category == category) {
        totalSpent += card.amount;
      }
    }
    return totalSpent;
  }
}
