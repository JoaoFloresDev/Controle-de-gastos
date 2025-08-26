// import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/controllers/gastos_fixos/intervalsControl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
// import 'package:meus_gastos/services/firebase/saveExpensOnCloud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class Fixedexpensesservice {
  // static Future<void> saveFixedExpense(FixedExpense expense) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Carregar lista de gastos fixos existentes
  //   List<String> expensesList = prefs.getStringList('fixed_expenses') ?? [];

  //   // Adicionar o novo gasto
  //   expensesList.add(jsonEncode(expense.toJson()));

  //   // Salvar de volta no SharedPreferences
  //   await prefs.setStringList('fixed_expenses', expensesList);
  // }
  // MARK: getSortedFixedExpenses
  static Future<List<FixedExpense>> getSortedFixedExpenses() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    List<FixedExpense> fc = [];
    // User? user = FirebaseAuth.instance.currentUser;

    // if (user == null) {
      if (cardsString != null) {
        final List<dynamic> jsonList = json.decode(cardsString);
        fc = jsonList
            .map((jsonItem) => FixedExpense.fromJson(jsonItem))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      }
    // } else {
      // fc = await SaveExpensOnCloud().fetchCardsFixedCards()
      //   ..sort((a, b) => b.date.compareTo(a.date));
    // }
    // print("metodo antigo:${fc.length} firebase${fixedCardList.length}");
    return fc;
    // }
    // return [];
  }

  static Future<List<FixedExpense>> getSortedFixedExpensesToSync() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cardsString = prefs.getString('fixed_expenses');
    List<FixedExpense> fc = [];
    if (cardsString != null) {
      final List<dynamic> jsonList = json.decode(cardsString);
      fc = jsonList.map((jsonItem) => FixedExpense.fromJson(jsonItem)).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return fc;
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
    // User? user = FirebaseAuth.instance.currentUser;
    // print("$user");
    // if(SaveExpensOnCloud().userId != null)
    //   SaveExpensOnCloud().addNewDateFixedCards(FixedExpense);
    // else
      await modifyCards((cards) {
        if (!(FixedExpense.price == 0)) {
          cards.add(FixedExpense);
        }
        return cards;
      });
  }

  static Future<void> deleteCard(String id) async {
    // if (SaveExpensOnCloud().userId != null) {
    //   List<FixedExpense> cardsf = await getSortedFixedExpenses();
    //   SaveExpensOnCloud()
    //       .deleteDateFixedCards(cardsf.firstWhere((card) => card.id == id));
    // } else {
      await modifyCards((cards) {
        cards.removeWhere((card) => card.id == id);
        return cards;
      });
    // }
  }

  static Future<void> deleteAllCards() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("fixed_expenses");
  }

  static Future<void> updateCard(String id, FixedExpense newCard) async {
    await modifyCards((cards) {
      final int index = cards.indexWhere((card) => card.id == id);
      if (index != -1) {
        // if (SaveExpensOnCloud().userId != null) {
        //   SaveExpensOnCloud().deleteDateFixedCards(cards[index]);
        //   SaveExpensOnCloud().addNewDateFixedCards(newCard);
        // } else {
          cards[index] = newCard;
        // }
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

  static Future<List<FixedExpense>> filteredFixedCardsShow(
      List<FixedExpense> fixedCards, DateTime currentDate) async {
    List<CardModel> normalCards = await CardService.retrieveCards();
    currentDate = DateTime.now();

    // printCardsInfo();

    return fixedCards.where((fcard) {
      DateTime verificationDate = currentDate;
      bool isCurrentBeforeCardTime = false;
      // Se for diário, ajusta a data do fcard conforme o horário atual
      if (fcard.tipoRepeticao == 'diario') {
        isCurrentBeforeCardTime = currentDate.hour < fcard.date.hour ||
            (currentDate.hour == fcard.date.hour &&
                currentDate.minute < fcard.date.minute);
        // print("${fcard.tipoRepeticao} : $isCurrentBeforeCardTime ");
        if (isCurrentBeforeCardTime) {
          // print("AJJ");
          // Altera a data do fcard para ontem mantendo hora/minuto
          final yesterday = currentDate.subtract(const Duration(days: 1));
          fcard.date = DateTime(
            yesterday.year,
            yesterday.month,
            yesterday.day,
            fcard.date.hour,
            fcard.date.minute,
          );
          verificationDate = yesterday;
        } else {
          fcard.date = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            fcard.date.hour,
            fcard.date.minute,
          );
        }
      } else {
        fcard.date = DateTime(
          fcard.date.year,
          fcard.date.month,
          fcard.date.day,
          fcard.date.hour,
          fcard.date.minute,
        );
      }
      final shouldShow = Intervalscontrol()
              .IsapresentetionNecessary(fcard, normalCards, verificationDate) &&
          currentDate.isAfter(fcard.date);
      // && (verificationDate.hour > fcard.date.hour ||
      //     (verificationDate.hour == fcard.date.hour &&
      //         verificationDate.minute >= fcard.date.minute));
      // print(shouldShow);
      return shouldShow;
    }).toList();
  }

  static Future<List<CardModel>> mergeFixedWithNormal(
      List<FixedExpense> fixedCards,
      List<CardModel> normalCards,
      DateTime currentDate) async {
    final filteredFixedCards =
        await filteredFixedCardsShow(fixedCards, currentDate);

    for (var fcard in filteredFixedCards) {
      normalCards.add(Fixed_to_NormalCard(fcard, currentDate));
    }

    return normalCards;
  }

  static CardModel Fixed_to_NormalCard(
      FixedExpense fixedCard, DateTime currentDate) {
    int day = fixedCard.date.day;
    int hour = fixedCard.date.hour;
    int min = fixedCard.date.minute;

    // Apenas semanal precisa de ajuste específico
    if (fixedCard.tipoRepeticao == 'semanal') {
      day = getCurrentWeekdayDate(fixedCard.date).day;
    }

    // Para diário ou seg_sex, usa o dia já contido em fixedCard.date
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
    List<FixedExpense> cards =
        await Fixedexpensesservice.getSortedFixedExpenses();
    for (var card in cards) {
      print('ID: ${card.id}');
      print('Description: ${card.description}');
      print('Price: \$${card.price.toStringAsFixed(2)}');
      print('Date: ${card.date.toLocal()}');
      print('Category: ${card.category}');
      print('Tipo de Repetição: ${card.tipoRepeticao}');
      print('---------------------------');
    }
  }

  static Future<void> deleteAllCardsFixedsWithThisCategory(
      CategoryModel category) async {
    List<FixedExpense> fcards = await getSortedFixedExpenses();
    for (var fc in fcards) {
      if (fc.category.id == category.id) {
        print("AJHHH");
        await deleteCard(fc.id);
        break;
      }
    }
  }
}
