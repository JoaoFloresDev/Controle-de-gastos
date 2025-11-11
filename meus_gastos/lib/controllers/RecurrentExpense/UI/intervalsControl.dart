/* aqui será desenvolvido o controle dos intervalos 
01 - Mensal: todo mês, se o dia atual for maior que o definido, aparece gasto fixo
02 - Semanal: Toda semana aparece o gasto fixo, a partir de segunda
03 - Anual: Se o dia/mês for maior que o definido no gasto fixo,  
*/

//Mensal
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class Intervalscontrol {
  List<CardModel> filterCardsByDateMonth(List<CardModel> cards, int givenDay) {
    DateTime now = DateTime.now();
    // Filtra os cards
    return cards.where((card) {
      // Verifica se a data do card está no mesmo mês e ano que o atual
      bool isSameMonth =
          card.date.year == now.year && card.date.month == now.month;

      // Verifica se o dia do card é maior ou igual ao dado
      bool isAfterGivenDay = card.date.day >= givenDay;

      // Retorna true se ambas as condições forem atendidas
      return isSameMonth && isAfterGivenDay;
    }).toList();
  }

  bool mensalInterval(FixedExpense gastoFixo, List<CardModel> cards) {
    List<CardModel> filteredCard =
        filterCardsByDateMonth(cards, gastoFixo.date.day);
    List<String> IdsFixosControlList =
        CardService().getIdFixoControlList(filteredCard);
    if (!(IdsFixosControlList.contains(gastoFixo.id))) {
      return true;
    }
    return false;
  }

  List<CardModel> filteredByWeek(List<CardModel> cards) {
    // Define os limites da semana atual
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Calcula o início (segunda-feira) da semana atual
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    // Calcula o final (domingo) da semana atual
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    // print("${startOfWeek.subtract(Duration(seconds: 1))} - ${endOfWeek.day}");
    // Filtra os cartões
    return cards.where((card) {
      // Verifica se a data do cartão está entre a segunda e o domingo da semana atual
      return card.date.isAfter(startOfWeek.subtract(Duration(seconds: 1))) &&
          card.date.isBefore(endOfWeek.add(Duration(days: 1)));
    }).toList();
  }

  bool weekInterval(FixedExpense gastoFixo, List<CardModel> cards) {
    List<CardModel> filteredCard = filteredByWeek(cards);
    List<String> IdsFixosControlList =
        CardService().getIdFixoControlList(filteredCard);

    if (!(IdsFixosControlList.contains(gastoFixo.id))) {
      return true;
    }
    return false;
  }

  List<CardModel> filterCardsByYear(
      List<CardModel> cards, FixedExpense gastoFixo) {
    // Ano de referência
    int referenceYear = gastoFixo.date.year;

    // Data de referência
    DateTime referenceDate = gastoFixo.date;

    // Filtra os cartões
    return cards.where((card) {
      // Verifica se o cartão está no mesmo ano
      bool isInSameYear = card.date.year == referenceYear;

      // Verifica se o cartão está depois da data de referência
      bool isAfterReferenceDate = card.date.isAfter(referenceDate);

      return isInSameYear && isAfterReferenceDate;
    }).toList();
  }

  bool yearInterval(FixedExpense gastoFixo, List<CardModel> cards) {
    List<CardModel> filteredCard = filterCardsByYear(cards, gastoFixo);
    List<String> IdsFixosControlList =
        CardService().getIdFixoControlList(filteredCard);
    if (!(IdsFixosControlList.contains(gastoFixo.id))) {
      return true;
    }
    return false;
  }

  bool isWeekday() {
    // Obtém o número do dia da semana atual (1 = segunda-feira, 7 = domingo)
    int todayWeekday = DateTime.now().weekday;

    // Retorna true se for um dia útil (segunda a sexta)
    return todayWeekday >= 1 && todayWeekday <= 5;
  }

  bool semanalInterval(FixedExpense gastoFixo, List<CardModel> cards) {
    List<CardModel> filteredCard = filterByToday(cards, gastoFixo.date, DateTime.now());
    List<String> IdsFixosControlList =
        CardService().getIdFixoControlList(filteredCard);
    if (!(IdsFixosControlList.contains(gastoFixo.id)) && (isWeekday())) {
      return true;
    }
    return false;
  }

  List<CardModel> filterByToday(List<CardModel> cards, DateTime fixDate, DateTime currentDate) {
    // Obtém a data de hoje (apenas ano, mês e dia)
    DateTime today = currentDate;
    DateTime todayStart = DateTime(
        today.year, today.month, today.day, fixDate.hour, fixDate.minute);
    DateTime todayEnd = todayStart.add(Duration(days: 1));

    // Filtra os itens cuja data está entre o início e o fim do dia de hoje
    List<CardModel> filteredCards = cards.where((card) {
      DateTime itemDate = card.date;
      // print("${card.date}: ${itemDate.isAfter(todayStart.subtract(Duration(milliseconds: 1))) &&
      //     itemDate.isBefore(todayEnd)}");
      return itemDate.isAfter(todayStart.subtract(Duration(milliseconds: 1))) &&
          itemDate.isBefore(todayEnd);
    }).toList();
    
    return filteredCards;
  }

  bool diaryInterval(FixedExpense gastoFixo, List<CardModel> cards, DateTime currentDate) {
    List<CardModel> filteredCard = filterByToday(cards, gastoFixo.date, currentDate);
    List<String> IdsFixosControlList =
        CardService().getIdFixoControlList(filteredCard);
    if (!(IdsFixosControlList.contains(gastoFixo.id)) ) {
      return true;
    }
    return false;
  }

  bool IsapresentetionNecessary(FixedExpense gastoFixo, List<CardModel> cards, DateTime currentDate) {
    switch (gastoFixo.tipoRepeticao) {
      case 'mensal':
        // verifica se o dia do mês é maior que o gastoFixo.date.day e se não existe o gasto ainda
        return mensalInterval(gastoFixo, cards);
      case 'semanal':
        // verifica se o dia da semana é maior que o gastoFixo.date.day.ofsemana e se o gasto ainda não existe
        return weekInterval(gastoFixo, cards);
      case 'anual':
        // verifica se dia/mês > gastoFixo.date.dia/mês e se ainda não existe o gasto
        return yearInterval(gastoFixo, cards);
      case 'seg_sex':
        // verifica se está em um dia da semana e se não tem o gasto fixo no dia
        return semanalInterval(gastoFixo, cards);
      case 'diario':
        // verifica se no dia atual não tem o gasto fixo.
        return diaryInterval(gastoFixo, cards, currentDate);
      default:
        // mensal
        return mensalInterval(gastoFixo, cards);
    }
  }
}
