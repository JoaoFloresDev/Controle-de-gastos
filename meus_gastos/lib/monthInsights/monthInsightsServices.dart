import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class Monthinsightsservices {
  static int daysInCurrentMonth(DateTime date) {
    // Obtém o próximo mês, ajustando o ano se necessário
    int nextMonth = date.month == 12 ? 1 : date.month + 1;
    int nextYear = date.month == 12 ? date.year + 1 : date.year;

    // Cria uma data no dia 1 do próximo mês e subtrai 1 dia
    DateTime firstDayNextMonth = DateTime(nextYear, nextMonth, 1);
    DateTime lastDayCurrentMonth =
        firstDayNextMonth.subtract(Duration(days: 1));

    return lastDayCurrentMonth.day; // Retorna o número do dia
  }

  static Future<double> dailyAverage(DateTime currentDate) async {
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> cardsOfThisMonth =
        cards.where((card) => card.date.month == currentDate.month).toList();
    if (currentDate.month == DateTime.now().month) {
      List<CardModel> filteredCards = cards.where((card) {
        return card.date != null &&
            card.date.month == DateTime.now().month &&
            card.date.day <= DateTime.now().day;
      }).toList();
    }
    double totalAmountThisMonth =
        cardsOfThisMonth.fold(0.0, (sum, card) => sum + card.amount);
    print("AAAAAAAAA${totalAmountThisMonth}");
    int manyDays = 30;
    if (currentDate.month == DateTime.now().month) {
      manyDays = DateTime.now().day;
    } else {
      manyDays = daysInCurrentMonth(currentDate);
    }
    print("AAAAAAAAA${manyDays}");
    return (totalAmountThisMonth / manyDays);
  }
}
