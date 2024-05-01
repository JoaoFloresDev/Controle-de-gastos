import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/models/CardModel.dart';
import 'package:uuid/uuid.dart';
import 'package:meus_gastos/widgets/Dashboards/LinearProgressIndicatorSection.dart';
import 'package:meus_gastos/enums/Category.dart';

class CardService {
  static const String _storageKey = 'cardModels';

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

  static Future<void> modifyCards(
      List<CardModel> modification(List<CardModel> cards)) async {
    final List<CardModel> cards = await retrieveCards();
    final List<CardModel> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  static Future<void> addCard(CardModel cardModel) async {
    await modifyCards((cards) {
      cards.add(cardModel);
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

  static Future<void> deleteAllCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<List<ProgressIndicatorModel>> getProgressIndicators() async {
    final List<CardModel> cards = await retrieveCards();
    final Map<String, double> totals = {};

    for (var card in cards) {
      totals[card.category] = (totals[card.category] ?? 0) + card.amount;
    }

    return totals.entries
        .map((entry) => ProgressIndicatorModel(
            title: CategoryInfo.getByCategoryString(entry.key.toString()).name,
            progress: entry.value,
            category: Category.values.firstWhere(
                (c) => c.toString().split('.').last == entry.key,
                orElse: () => Category.Unknown)))
        .toList();
  }

  static String generateUniqueId() {
    var uuid = Uuid();
    return uuid.v4();
  }
}
