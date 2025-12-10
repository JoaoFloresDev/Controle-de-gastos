import 'package:meus_gastos/controllers/gastos_fixos/UI/intervalsControl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class FixedExpensesService {
 
  Future<List<FixedExpense>> getSortedFixedExpensesToSync() async {
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

  Future<List<String>> getFixedExpenseIds(List<FixedExpense> listExpenses) async {
    final List<String> fixedExpenseIds = [];
    if (listExpenses != null) {
      for (var item in listExpenses) {
        fixedExpenseIds.add(item.id);
      }
    }
    return fixedExpenseIds;
  }

 

  DateTime getCurrentWeekdayDate(DateTime referenceDate) {
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

  Future<List<FixedExpense>> filteredFixedCardsShow(
      List<FixedExpense> fixedCards, DateTime currentDate) async {
    // ERRADO
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

  CardModel fixedToNormalCard(
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

  Future<void> printCardsInfo(List<FixedExpense> cards) async {
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
}
