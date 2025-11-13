import 'package:meus_gastos/controllers/RecurrentExpense/UI/IntervalsControl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class FixedExpensesService {
  static Future<List<FixedExpense>> getSortedFixedExpenses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    List<FixedExpense> fixedCards = [];
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      fixedCards = jsonList
          .map((jsonItem) => FixedExpense.fromJson(jsonItem))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    return fixedCards;
  }

  static Future<List<FixedExpense>> getSortedFixedExpensesToSync() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    List<FixedExpense> fixedCards = [];
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      fixedCards = jsonList
          .map((jsonItem) => FixedExpense.fromJson(jsonItem))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return fixedCards;
  }

  static Future<List<String>> getFixedExpenseIds() async {
    final List<String> fixedExpenseIds = [];
    final List<FixedExpense> listExpenses = await getSortedFixedExpenses();
    for (var item in listExpenses) {
      fixedExpenseIds.add(item.id);
    }
    return fixedExpenseIds;
  }

  static Future<void> modifyCards(
      List<FixedExpense> Function(List<FixedExpense> cards) modification) async {
    final List<FixedExpense> cards = await getSortedFixedExpenses();
    final List<FixedExpense> modifiedCards = modification(cards);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(modifiedCards.map((card) => card.toJson()).toList());
    await prefs.setString("fixed_expenses", encodedData);
  }

  static Future<void> addCard(FixedExpense fixedExpense) async {
    await modifyCards((cards) {
      if (!(fixedExpense.price == 0)) {
        cards.add(fixedExpense);
      }
      return cards;
    });
  }

  static Future<void> deleteCard(String id) async {
    await modifyCards((cards) {
      cards.removeWhere((card) => card.id == id);
      return cards;
    });
  }

  static Future<void> deleteAllCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("fixed_expenses");
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
    int referenceWeekday = referenceDate.weekday;
    DateTime today = DateTime.now();
    int todayWeekday = today.weekday;
    int difference = referenceWeekday - todayWeekday;
    return today.add(Duration(days: difference));
  }

  static Future<List<FixedExpense>> filteredFixedCardsShow(
      List<FixedExpense> fixedCards, DateTime currentDate) async {
    List<CardModel> normalCards = await CardService.retrieveCards();
    currentDate = DateTime.now();

    return fixedCards.where((fixedCard) {
      DateTime verificationDate = currentDate;
      bool isCurrentBeforeCardTime = false;

      if (fixedCard.repetitionType == 'daily') {
        isCurrentBeforeCardTime = currentDate.hour < fixedCard.date.hour ||
            (currentDate.hour == fixedCard.date.hour &&
                currentDate.minute < fixedCard.date.minute);

        if (isCurrentBeforeCardTime) {
          final yesterday = currentDate.subtract(const Duration(days: 1));
          fixedCard.date = DateTime(
            yesterday.year,
            yesterday.month,
            yesterday.day,
            fixedCard.date.hour,
            fixedCard.date.minute,
          );
          verificationDate = yesterday;
        } else {
          fixedCard.date = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            fixedCard.date.hour,
            fixedCard.date.minute,
          );
        }
      } else {
        fixedCard.date = DateTime(
          fixedCard.date.year,
          fixedCard.date.month,
          fixedCard.date.day,
          fixedCard.date.hour,
          fixedCard.date.minute,
        );
      }

      final shouldShow = Intervalscontrol().IsapresentetionNecessary(
              fixedCard, normalCards, verificationDate) &&
          currentDate.isAfter(fixedCard.date);
      return shouldShow;
    }).toList();
  }

  static Future<List<CardModel>> mergeFixedWithNormal(
      List<FixedExpense> fixedCards,
      List<CardModel> normalCards,
      DateTime currentDate) async {
    final filteredFixedCards =
        await filteredFixedCardsShow(fixedCards, currentDate);

    for (var fixedCard in filteredFixedCards) {
      if (fixedCard.isAutomaticAddition) {
        normalCards.add(fixedToNormalCard(fixedCard, currentDate));
      }
    }

    return normalCards;
  }

  static Future<List<FixedExpense>> getSuggestedExpenses(
      DateTime currentDate) async {
    final fixedCards = await getSortedFixedExpenses();
    final filteredCards = await filteredFixedCardsShow(fixedCards, currentDate);

    return filteredCards.where((fixedCard) => fixedCard.isSuggestion).toList();
  }

  static CardModel fixedToNormalCard(
      FixedExpense fixedCard, DateTime currentDate) {
    int day = fixedCard.date.day;
    int hour = fixedCard.date.hour;
    int min = fixedCard.date.minute;

    if (fixedCard.repetitionType == 'weekly') {
      day = getCurrentWeekdayDate(fixedCard.date).day;
    }

    return CardModel(
      id: CardService.generateUniqueId(),
      amount: fixedCard.price,
      description: fixedCard.description,
      date: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        day,
        hour,
        min,
      ),
      category: fixedCard.category,
      idFixoControl: fixedCard.id,
    );
  }

  static Future<void> printCardsInfo() async {
    List<FixedExpense> cards = await FixedExpensesService.getSortedFixedExpenses();
    for (var card in cards) {
      print('ID: ${card.id}');
      print('Description: ${card.description}');
      print('Price: \$${card.price.toStringAsFixed(2)}');
      print('Date: ${card.date.toLocal()}');
      print('Category: ${card.category}');
      print('Repetition Type: ${card.repetitionType}');
      print('Addition Type: ${card.additionType ?? 'suggestion'}');
      print('---------------------------');
    }
  }

  static Future<void> deleteAllCardsFixedsWithThisCategory(
      CategoryModel category) async {
    List<FixedExpense> fixedCards = await getSortedFixedExpenses();
    for (var fixedCard in fixedCards) {
      if (fixedCard.category.id == category.id) {
        await deleteCard(fixedCard.id);
        break;
      }
    }
  }
}