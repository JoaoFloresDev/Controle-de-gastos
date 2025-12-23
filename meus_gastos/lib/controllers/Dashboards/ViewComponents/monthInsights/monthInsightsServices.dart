import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/models/CardModel.dart';

class Monthinsightsservices {
  Future<List<Map<String, dynamic>>> calculateDistributionByTens(
      DateTime month, List<CardModel> cards) async {
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final int firstTenDays = (daysInMonth / 3).ceil();
    final int secondTenDays = (daysInMonth / 3 * 2).ceil();

    double firstTenSum = 0.0;
    double secondTenSum = 0.0;
    double thirdTenSum = 0.0;
    double totalSpent = 0.0;

    final List<CardModel> filteredCards = cards.where((card) {
      return card.date.year == month.year && card.date.month == month.month;
    }).toList();

    for (var card in filteredCards) {
      final int day = card.date.day;
      totalSpent += card.amount;

      if (day <= firstTenDays) {
        firstTenSum += card.amount;
      } else if (day <= secondTenDays) {
        secondTenSum += card.amount;
      } else {
        thirdTenSum += card.amount;
      }
    }

    final double firstTenPercentage =
        totalSpent > 0 ? (firstTenSum / totalSpent) * 100 : 0.0;
    final double secondTenPercentage =
        totalSpent > 0 ? (secondTenSum / totalSpent) * 100 : 0.0;
    final double thirdTenPercentage =
        totalSpent > 0 ? (thirdTenSum / totalSpent) * 100 : 0.0;

    return [
      {
        "title": "1ª dezena",
        "amount": firstTenSum,
        "percentage": firstTenPercentage,
      },
      {
        "title": "2ª dezena",
        "amount": secondTenSum,
        "percentage": secondTenPercentage,
      },
      {
        "title": "3ª dezena",
        "amount": thirdTenSum,
        "percentage": thirdTenPercentage,
      }
    ];
  }

  int daysInCurrentMonth(DateTime date) {
    // Obtém o próximo mês, ajustando o ano se necessário
    int nextMonth = date.month == 12 ? 1 : date.month + 1;
    int nextYear = date.month == 12 ? date.year + 1 : date.year;

    // Cria uma data no dia 1 do próximo mês e subtrai 1 dia
    DateTime firstDayNextMonth = DateTime(nextYear, nextMonth, 1);
    DateTime lastDayCurrentMonth =
        firstDayNextMonth.subtract(Duration(days: 1));

    return lastDayCurrentMonth.day; // Retorna o número do dia
  }

  Future<double> monthExpenses(
      DateTime currentDate, List<CardModel> cards) async {
    List<CardModel> cardsOfThisMonth = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    double totalAmountThisMonth =
        cardsOfThisMonth.fold(0.0, (sum, card) => sum + card.amount);

    return totalAmountThisMonth;
  }

  double dailyAverage(DateTime currentDate, double totalAmountThisMonth) {
    int manyDays = 30;
    if (currentDate.month == DateTime.now().month &&
        currentDate.year == DateTime.now().year) {
      manyDays = DateTime.now().day;
    } else {
      manyDays = daysInCurrentMonth(currentDate);
    }
    // print("AAAAAAAAA${manyDays}");
    return (totalAmountThisMonth / manyDays);
  }

  Future<double> getFixedExpenses(DateTime currentDate, List<CardModel> cards,
      List<String> fixedIds) async {
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

  Future<double> getBusinessDaysExpenses(
      DateTime currentDate, List<CardModel> cards) async {
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

  int calcularDiasUteisNoMes(DateTime data) {
    int ano = data.year;
    int mes = data.month;

    int totalDiasNoMes = DateUtils.getDaysInMonth(ano, mes);

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

  int calcularDiasUteisNoMesAteAgora(DateTime data) {
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
      if (dia <= data.day &&
          dataAtual.weekday != DateTime.saturday &&
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

  double dailyAverageBusinessDays(DateTime currentDate, totalAmountThisMonth) {
    int manyBusinessDays = calcularDiasUteisNoMes(currentDate);
    return (totalAmountThisMonth / manyBusinessDays);
  }

  Future<double> getWeekendExpenses(
      DateTime currentDate, List<CardModel> cards) async {
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

  int calcularFinsDeSemanaNoMes(DateTime data) {
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

  double dailyAverageWeekendDays(
      DateTime currentDate, double totalAmountThisMonth) {
    int manyWeekendDays = calcularFinsDeSemanaNoMes(currentDate);
    return (totalAmountThisMonth / manyWeekendDays);
  }

  Future<List<CardModel>> getVariavelCards(DateTime currentDate,
      List<CardModel> cards, List<String> fixedIds) async {
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

  Map<String, double> separarGastosPorDiaSemana(List<CardModel> cards) {
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

  Future<List<MapEntry<String, double>>> doisDiasComMaiorGasto(
      DateTime currentDate,
      List<CardModel> cardList,
      List<String> fixedIds) async {
    List<CardModel> cards =
        await getVariavelCards(currentDate, cardList, fixedIds);
    Map<String, double> gastosPorDia = separarGastosPorDiaSemana(cards);
    List<MapEntry<String, double>> entradasOrdenadas = gastosPorDia.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // print(entradasOrdenadas[0].value);
    return entradasOrdenadas.take(2).toList();
  }

  Future<double> avaregeCostPerPurchase(
      DateTime currentDate, List<CardModel> cards) async {
    List<CardModel> filteredCards = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    double monthExpensesvar = await monthExpenses(currentDate, cards);
    return monthExpensesvar / filteredCards.length;
  }

  Future<double> avareCardsByDay(
      DateTime currentDate, List<CardModel> cards) async {
    List<CardModel> filteredCards = cards
        .where((card) =>
            (card.date.month == currentDate.month) &&
            (currentDate.year == card.date.year))
        .toList();
    int numberOfDays = daysInCurrentMonth(currentDate);
    return filteredCards.length / numberOfDays;
  }

  Future<Map<int, double>> dayWithHigerExpense(
      DateTime currentDate, List<CardModel> cards) async {
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

  Future<List<double>> expensesInDezenas(
      DateTime currentDate, List<CardModel> cards) async {
    int ultimoDiaMes = DateTime(currentDate.year, currentDate.month + 1, 0).day;
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

  DateTime diminuirUmMes(DateTime data) {
    int novoAno = data.year;
    int novoMes = data.month - 1;

    if (novoMes < 1) {
      novoMes = 12;
      novoAno -= 1;
    }

    return DateTime(novoAno, novoMes, data.day);
  }

  Future<Map<String, double>> resumeMonth(DateTime currentDate,
      List<CardModel> cards, List<String> fixedIds) async {
    double generalCust = await monthExpenses(currentDate, cards);
    double fixedCust = await getFixedExpenses(currentDate, cards, fixedIds);
    List<CardModel> variableCards =
        await getVariavelCards(currentDate, cards, fixedIds);

    double variableCust =
        variableCards.fold(0.0, (sum, card) => sum + card.amount);

    double weekendsCust = await getWeekendExpenses(currentDate, cards);
    double businessDaysCust = await getBusinessDaysExpenses(currentDate, cards);

    return {
      'general': generalCust,
      'fixed': fixedCust,
      'variable': variableCust,
      'weekends': weekendsCust,
      'businessDays': businessDaysCust
    };
  }

  Future<Map<String, double>> expenseByCategoryOfCurrentMonth(
      DateTime currentDate, List<CardModel> cards) async {
    final List<CardModel> currentMonthCards = cards.where((card) {
      return card.date.year == currentDate.year &&
          card.date.month == currentDate.month;
    }).toList();
    final Map<String, double> totalsOfCurrentMonths = {};
    for (var card in currentMonthCards) {
      totalsOfCurrentMonths[card.category.id] =
          (totalsOfCurrentMonths[card.category.id] ?? 0) + card.amount;
    }
    return totalsOfCurrentMonths;
  }

  Future<Map<String, double>> expenseByCategoryOfPreviousMonth(
      DateTime currentDate, List<CardModel> cards) async {
    final List<CardModel> currentMonthCards = cards.where((card) {
      return card.date.year == currentDate.year &&
          card.date.month == (currentDate.month - 1);
    }).toList();
    final Map<String, double> totalsOfCurrentMonths = {};
    for (var card in currentMonthCards) {
      totalsOfCurrentMonths[card.category.id] =
          (totalsOfCurrentMonths[card.category.id] ?? 0) + card.amount;
    }
    return totalsOfCurrentMonths;
  }

  Future<Map<String, double>> diferencesExpenseByCategory(
      DateTime currentDate, List<CardModel> cards) async {
    final List<CardModel> currentMonthCards = cards.where((card) {
      return card.date.year == currentDate.year &&
          card.date.month == currentDate.month;
    }).toList();
    final Map<String, double> totalsOfCurrentMonths = {};
    for (var card in currentMonthCards) {
      totalsOfCurrentMonths[card.category.id] =
          (totalsOfCurrentMonths[card.category.id] ?? 0) + card.amount;
    }

    final List<CardModel> previousMonthCards = cards.where((card) {
      return card.date.year == diminuirUmMes(currentDate).year &&
          card.date.month == diminuirUmMes(currentDate).month;
    }).toList();
    final Map<String, double> totalsOfPreviousMonths = {};
    for (var card in previousMonthCards) {
      totalsOfPreviousMonths[card.category.id] =
          (totalsOfPreviousMonths[card.category.id] ?? 0) + card.amount;
    }

    final Map<String, double> differencesByCategory = {};

    // Comparando os totais de cada categoria entre os meses
    for (var categoryId in totalsOfCurrentMonths.keys) {
      final double currentMonthTotal = totalsOfCurrentMonths[categoryId] ?? 0;
      final double previousMonthTotal = totalsOfPreviousMonths[categoryId] ?? 0;

      // Calculando a diferença entre o mês atual e o mês anterior
      final double difference = currentMonthTotal - previousMonthTotal;

      // Armazenando a diferença no mapa
      differencesByCategory[categoryId] = difference;
    }
    for (var categoryId in totalsOfPreviousMonths.keys) {
      final double currentMonthTotal = totalsOfCurrentMonths[categoryId] ?? 0;
      final double previousMonthTotal = totalsOfPreviousMonths[categoryId] ?? 0;

      // Calculando a diferença entre o mês atual e o mês anterior
      final double difference = currentMonthTotal - previousMonthTotal;
      // print(difference);

      // Armazenando a diferença no mapa
      differencesByCategory[categoryId] = difference;
    }

    // Retornando o mapa com as diferenças de gastos por categoria
    return differencesByCategory;
  }

  Future<Map<String, double>> highestIncreaseCategory(
      Map<String, double> differencesByCategory, List<CardModel> cards) async {
    String categoryHighestIncrease = '';
    double expenseHighestIncrease = 0.0;

    for (var entry in differencesByCategory.entries) {
      if (entry.value > expenseHighestIncrease) {
        categoryHighestIncrease = entry.key;
        expenseHighestIncrease = entry.value;
      }
    }

    return {categoryHighestIncrease: expenseHighestIncrease};
  }

  Future<Map<String, double>> highestDropCategory(
      Map<String, double> differencesByCategory, List<CardModel> cards) async {
    String categoryHighestDrop = '-';
    double expenseHighestDrop = 0.0;

    for (var entry in differencesByCategory.entries) {
      if (entry.value < expenseHighestDrop) {
        categoryHighestDrop = entry.key;
        expenseHighestDrop = entry.value;
      }
    }

    return {categoryHighestDrop: expenseHighestDrop};
  }

  Future<Map<String, int>> mostFrequentCategoryByMonth(
      DateTime currentDate, List<CardModel> cards) async {
    final List<CardModel> currentMonthCards = cards.where((card) {
      return card.date.year == currentDate.year &&
          card.date.month == currentDate.month;
    }).toList();

    final Map<String, int> frequency = {};

    for (var card in currentMonthCards) {
      frequency[card.category.id] = (frequency[card.category.id] ?? 0) + 1;
    }

    String categoriaMaisFrequente = '';
    int maiorFrequencia = 0;
    int count_general = 0;
    frequency.forEach((categoria, count) {
      if (count > maiorFrequencia) {
        maiorFrequencia = count;
        categoriaMaisFrequente = categoria;
      }
      count_general = count_general + count;
    });
    return {
      categoriaMaisFrequente:
          (((maiorFrequencia) / (count_general == 0 ? 1 : count_general)) *
                  100)
              .round(),
    };
  }

  int countWeekDaysInMonth(DateTime date) {
    final int targetWeekday = date
        .weekday; // Dia da semana da data fornecida (1 = segunda, 7 = domingo)
    final int totalDaysInMonth =
        DateTime(date.year, date.month + 1, 0).day; // Último dia do mês

    int count = 0;

    // Itera sobre todos os dias do mês
    for (int day = 1; day <= totalDaysInMonth; day++) {
      final currentDay = DateTime(date.year, date.month, day);
      if (currentDay.weekday == targetWeekday && date.day >= day) {
        count++;
      }
    }

    return count;
  }

  Future<double> projectionFixedForTheMonth(
      DateTime currentDate,
      List<CardModel> cards,
      List<FixedExpense> fixedCards,
      List<String> fixedIds) async {
    double totalExpenseFixed = 0.0;

    if ((currentDate.month < DateTime.now().month &&
            currentDate.year == DateTime.now().year) ||
        (currentDate.year < DateTime.now().year)) {
      return getFixedExpenses(currentDate, cards, fixedIds);
    }
    totalExpenseFixed = await getFixedExpenses(currentDate, cards, fixedIds);
    for (var card in fixedCards) {
      switch (card.repetitionType) {
        case ('mensal'):
          if (currentDate.day >= card.date.day) {
            totalExpenseFixed = totalExpenseFixed + card.price;
          }
          break;
        case ('semanal'):
          totalExpenseFixed = totalExpenseFixed +
              card.price * countWeekDaysInMonth(currentDate);
          break;
        case ('anual'):
          if (card.date.month == currentDate.month) {
            totalExpenseFixed = totalExpenseFixed + card.price;
          }
          break;
        case ('seg_sex'):
          totalExpenseFixed = totalExpenseFixed +
              card.price *
                  (calcularDiasUteisNoMes(currentDate) -
                      calcularDiasUteisNoMesAteAgora(currentDate));
          break;
        case ('diario'):
          totalExpenseFixed = totalExpenseFixed +
              card.price * (daysInCurrentMonth(currentDate) - currentDate.day);
          break;
        default:
          if (currentDate.day >= card.date.day) {
            totalExpenseFixed = totalExpenseFixed + card.price;
          }
          break;
      }
    }
    return totalExpenseFixed;
  }
}
