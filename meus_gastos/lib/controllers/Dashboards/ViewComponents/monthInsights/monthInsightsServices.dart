import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/CategoryService.dart';

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

  static Future<double> monthExpenses(DateTime currentDate) async {
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> cardsOfThisMonth = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    if (currentDate.month == DateTime.now().month) {
      List<CardModel> filteredCards = cards.where((card) {
        return card.date != null &&
            card.date.month == DateTime.now().month &&
            card.date.day <= DateTime.now().day;
      }).toList();
    }
    double totalAmountThisMonth =
        cardsOfThisMonth.fold(0.0, (sum, card) => sum + card.amount);

    return totalAmountThisMonth;
  }

  static double dailyAverage(
      DateTime currentDate, double totalAmountThisMonth) {
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

  static Future<double> getFixedExpenses(DateTime currentDate) async {
    List<String> fixedIds = await Fixedexpensesservice.getFixedExpenseIds();
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> cardsOfThisMonth = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    List<CardModel> filteredCards = cardsOfThisMonth
        .where((card) => fixedIds.contains(card.idFixoControl))
        .toList();
    double totalFixedAmountThisMonth =
        filteredCards.fold(0.0, (sum, card) => sum + card.amount);
    return totalFixedAmountThisMonth;
  }

  static Future<double> getBusinessDaysExpenses(DateTime currentDate) async {
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> cardsOfThisMonth = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    List<CardModel> filteredCards = cardsOfThisMonth
        .where((card) => (card.date.weekday >= 1) && (card.date.weekday <= 5))
        .toList();
    double totalFixedAmountThisMonth =
        filteredCards.fold(0.0, (sum, card) => sum + card.amount);
    return totalFixedAmountThisMonth;
  }

  static int calcularDiasUteisNoMes(DateTime data) {
    // Lista de feriados ou inicializa vazia caso não fornecida

    int ano = data.year;
    int mes = data.month;

    // Total de dias no mês
    int totalDiasNoMes = DateUtils.getDaysInMonth(ano, mes);

    // Variável para contar os dias úteis
    int diasUteis = 0;

    for (int dia = 1; dia <= totalDiasNoMes; dia++) {
      DateTime dataAtual = DateTime(ano, mes, dia);

      // Verifica se é um dia útil (não sábado, domingo ou feriado)
      if (dataAtual.weekday != DateTime.saturday &&
          dataAtual.weekday != DateTime.sunday) {
        diasUteis++;
      }
    }

    // Se for o mês atual, conta apenas os dias úteis que já passaram até hoje
    DateTime hoje = DateTime.now();
    if (ano == hoje.year && mes == hoje.month) {
      int diasUteisPassados = 0;
      for (int dia = 1; dia <= hoje.day; dia++) {
        DateTime dataAtual = DateTime(ano, mes, dia);
        if (dataAtual.weekday != DateTime.saturday &&
            dataAtual.weekday != DateTime.sunday) {
          diasUteisPassados++;
        }
      }
      return diasUteisPassados;
    }

    return diasUteis;
  }

  static double dailyAverageBusinessDays(
      DateTime currentDate, totalAmountThisMonth) {
    // double totalAmountThisMonth = await getBusinessDaysExpenses(currentDate);
    int manyBusinessDays = calcularDiasUteisNoMes(currentDate);
    print("AAAAAAAAA${manyBusinessDays}");
    return (totalAmountThisMonth / manyBusinessDays);
  }

  static Future<double> getWeekendExpenses(DateTime currentDate) async {
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> cardsOfThisMonth = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    List<CardModel> filteredCards = cardsOfThisMonth
        .where((card) => (card.date.weekday == DateTime.saturday ||
            card.date.weekday == DateTime.sunday))
        .toList();
    double totalFixedAmountThisMonth =
        filteredCards.fold(0.0, (sum, card) => sum + card.amount);
    return totalFixedAmountThisMonth;
  }

  static int calcularFinsDeSemanaNoMes(DateTime data) {
    int ano = data.year;
    int mes = data.month;

    int totalDiasNoMes = DateUtils.getDaysInMonth(ano, mes);

    int finsDeSemana = 0;

    for (int dia = 1; dia <= totalDiasNoMes; dia++) {
      DateTime dataAtual = DateTime(ano, mes, dia);
      if (dataAtual.weekday == DateTime.saturday ||
          dataAtual.weekday == DateTime.sunday) {
        finsDeSemana++;
      }
    }

    DateTime hoje = DateTime.now();
    if (ano == hoje.year && mes == hoje.month) {
      int finsDeSemanaPassados = 0;
      for (int dia = 1; dia <= hoje.day; dia++) {
        DateTime dataAtual = DateTime(ano, mes, dia);
        if (dataAtual.weekday == DateTime.saturday ||
            dataAtual.weekday == DateTime.sunday) {
          finsDeSemanaPassados++;
        }
      }
      return finsDeSemanaPassados;
    }

    return finsDeSemana;
  }

  static double dailyAverageWeekendDays(
      DateTime currentDate, double totalAmountThisMonth) {
    int manyWeekendDays = calcularFinsDeSemanaNoMes(currentDate);
    return (totalAmountThisMonth / manyWeekendDays);
  }

  static Future<List<CardModel>> getVariavelCards(DateTime currentDate) async {
    List<String> fixedIds = await Fixedexpensesservice.getFixedExpenseIds();
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> cardsOfThisMonth = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    List<CardModel> filteredCards = cardsOfThisMonth
        .where((card) => !(fixedIds.contains(card.idFixoControl)))
        .toList();
    return filteredCards;
  }

  static Map<String, double> separarGastosPorDiaSemana(List<CardModel> cards) {
    Map<int, String> diasSemana = {
      DateTime.monday: 'Segunda-feira',
      DateTime.tuesday: 'Terça-feira',
      DateTime.wednesday: 'Quarta-feira',
      DateTime.thursday: 'Quinta-feira',
      DateTime.friday: 'Sexta-feira',
      DateTime.saturday: 'Sábado',
      DateTime.sunday: 'Domingo',
    };

    Map<String, double> gastosPorDia = {
      'Segunda-feira': 0.0,
      'Terça-feira': 0.0,
      'Quarta-feira': 0.0,
      'Quinta-feira': 0.0,
      'Sexta-feira': 0.0,
      'Sábado': 0.0,
      'Domingo': 0.0,
    };

    for (var card in cards) {
      String diaSemana = diasSemana[card.date.weekday] ?? '';
      if (gastosPorDia.containsKey(diaSemana)) {
        gastosPorDia[diaSemana] = gastosPorDia[diaSemana]! + card.amount;
      }
    }

    return gastosPorDia;
  }

  static Future<List<MapEntry<String, double>>> doisDiasComMaiorGasto(
      DateTime currentDate) async {
    List<CardModel> cards = await getVariavelCards(currentDate);
    Map<String, double> gastosPorDia = separarGastosPorDiaSemana(cards);
    List<MapEntry<String, double>> entradasOrdenadas = gastosPorDia.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    print(entradasOrdenadas[0].value);
    return entradasOrdenadas.take(2).toList();
  }

  static Future<double> avaregeCostPerPurchase(DateTime currentDate) async {
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> filteredCards = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    double monthExpensesvar = await monthExpenses(currentDate);
    return monthExpensesvar / filteredCards.length;
  }

  static Future<double> avareCardsByDay(DateTime currentDate) async {
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> filteredCards = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    int numberOfDays = daysInCurrentMonth(currentDate);
    return filteredCards.length / numberOfDays;
  }

  static Future<Map<int, double>> dayWithHigerExpense(
      DateTime currentDate) async {
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> filteredCards = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    final Map<int, double> gastosPorDia = {};

    for (var gasto in filteredCards) {
      final dia = gasto.date.day;
      gastosPorDia[dia] = (gastosPorDia[dia] ?? 0) + gasto.amount;
    }

    int diaComMaiorGasto = 0;
    double maiorGasto = 0;

    gastosPorDia.forEach((dia, total) {
      if (total > maiorGasto) {
        maiorGasto = total;
        diaComMaiorGasto = dia;
      }
    });

    return {diaComMaiorGasto: maiorGasto};
  }

  static Future<List<double>> expensesInDezenas(DateTime currentDate) async {
    int ultimoDiaMes = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    List<CardModel> cards = await CardService.retrieveCards();
    List<CardModel> filteredCards = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    double firstTenDays = filteredCards
        .where((card) => (card.date.day >= 1) && (card.date.day <= 10))
        .toList()
        .fold(0.0, (sum, card) => sum + card.amount);
    double secontTendays = filteredCards
        .where((card) => (card.date.day > 10) && (card.date.day <= 20))
        .toList()
        .fold(0.0, (sum, card) => sum + card.amount);
    double tirthTenDays = filteredCards
        .where(
            (card) => (card.date.day > 20) && (card.date.day <= ultimoDiaMes))
        .toList()
        .fold(0.0, (sum, card) => sum + card.amount);
    return [firstTenDays, secontTendays, tirthTenDays];
  }

  // Projection for the month

  // static double projectionGeneralForTheMonth(DateTime currenteDate) {
  //   // pega a media de gastos gerais e multiplica pela quantidade de dias do mês
  //   double gastosDoMes = await monthExpenses(currenteDate);
  //   double media_diaria = dailyAverage();
  //   return 0.0;
  // }

  // current month / previous month

  static DateTime diminuirUmMes(DateTime data) {
    int novoAno = data.year;
    int novoMes = data.month - 1;

    if (novoMes < 1) {
      novoMes = 12;
      novoAno -= 1;
    }

    // Retorna uma nova data com o dia ajustado automaticamente
    return DateTime(novoAno, novoMes, data.day);
  }

  static Future<Map<String, double>> resumeMonth(DateTime currentDate) async {
    double generalCust = await monthExpenses(currentDate);
    double fixedCust = await getFixedExpenses(currentDate);
    List<CardModel> variableCards = await getVariavelCards(currentDate);

    double variableCust =
        variableCards.fold(0.0, (sum, card) => sum + card.amount);

    double weekendsCust = await getWeekendExpenses(currentDate);
    double businessDaysCust = await getBusinessDaysExpenses(currentDate);

    return {
      'general': generalCust,
      'fixed': fixedCust,
      'variable': variableCust,
      'weekends': weekendsCust,
      'businessDays': businessDaysCust
    };
  }

  static Future<Map<String, double>> HigestExpenseByCategory(
      DateTime currentDate) async {
    final List<CardModel> cards = await CardService.retrieveCards();
    final Map<String, double> totals = {};
    for (var card in cards) {
      totals[card.category.id] = (totals[card.category.id] ?? 0) + card.amount;
    }

    String categoriaMaiorGasto = '';
    double maiorGasto = 0;

    totals.forEach((categoria, total) {
      if (total > maiorGasto) {
        maiorGasto = total;
        categoriaMaiorGasto = categoria;
      }
    });
    return {categoriaMaiorGasto: maiorGasto};
  }

  static Future<Map<String, double>> lowestExpenseByCategory(
      DateTime currentDate) async {
    final List<CardModel> cards = await CardService.retrieveCards();
    final Map<String, double> totals = {};

    // Calcula os totais por categoria
    for (var card in cards) {
      totals[card.category.id] = (totals[card.category.id] ?? 0) + card.amount;
    }

    String categoriaMenorGasto = '';
    double menorGasto = double.infinity;

    // Encontra a categoria com maior e menor gasto
    totals.forEach((categoria, total) {
      if (total < menorGasto) {
        menorGasto = total;
        categoriaMenorGasto = categoria;
      }
    });
    return {
      categoriaMenorGasto: menorGasto,
    };
  }

  static Future<Map<String, int>> mostFrequentCategoryByMonth(
      DateTime currentDate) async {
    final List<CardModel> cards = await CardService.retrieveCards();

    // Filtra os cartões do mês atual
    final List<CardModel> currentMonthCards = cards.where((card) {
      return card.date.year == currentDate.year &&
          card.date.month == currentDate.month;
    }).toList();

    // Contador de frequência por categoria
    final Map<String, int> frequency = {};

    for (var card in currentMonthCards) {
      frequency[card.category.id] = (frequency[card.category.id] ?? 0) + 1;
    }

    String categoriaMaisFrequente = '';
    int maiorFrequencia = 0;

    // Encontra a categoria com maior frequência
    frequency.forEach((categoria, count) {
      if (count > maiorFrequencia) {
        maiorFrequencia = count;
        categoriaMaisFrequente = categoria;
      }
    });

    return {
      categoriaMaisFrequente: maiorFrequencia,
    };
  }
}
