import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';

class CustomCalendar extends StatefulWidget {
  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CardModel> _transactions = [];
  Map<DateTime, double> _dailyExpenses = {}; // Inicialização segura
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _initializeCalendarData();
  }

  Future<void> _initializeCalendarData() async {
    await _calculateDailyExpenses();
    await _loadTransactionsForDay(_focusedDay);
    await _checkUserProStatus();
  }

  Future<void> _calculateDailyExpenses() async {
    final allTransactions = await CardService.retrieveCards();
    final Map<DateTime, double> expenses = {};

    for (var transaction in allTransactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      expenses[day] = (expenses[day] ?? 0) + transaction.amount;
    }

    setState(() {
      _dailyExpenses = expenses;
    });
  }

  Future<void> _loadTransactionsForDay(DateTime day) async {
    final allTransactions = await CardService.retrieveCards();
    final transactionsForDay = allTransactions
        .where((card) =>
            card.date.year == day.year &&
            card.date.month == day.month &&
            card.date.day == day.day)
        .toList();

    final dailyTotal = transactionsForDay.fold(0.0, (sum, item) => sum + item.amount);

    setState(() {
      _transactions = transactionsForDay;
      _dailyExpenses[day] = dailyTotal;
    });
  }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    setState(() {
      _isPro = isYearlyPro || isMonthlyPro;
    });
  }

  void refreshCalendar() {
    _calculateDailyExpenses();
    _loadTransactionsForDay(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    final double totalExpense = _dailyExpenses[_selectedDay ?? _focusedDay] ?? 0.0;
    final String formattedDate = DateFormat('EEEE, d MMM', Localizations.localeOf(context).toString())
        .format(_selectedDay ?? _focusedDay);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background1,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Calendário",
          style: TextStyle(color: AppColors.label, fontSize: 16),
        ),
        backgroundColor: AppColors.background1,
      ),
      child: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              locale: Localizations.localeOf(context).languageCode,
              focusedDay: _focusedDay,
              firstDay: DateTime(2010),
              lastDay: DateTime(2100),
              rowHeight: 60,
              daysOfWeekHeight: 30,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadTransactionsForDay(selectedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.button,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.buttonSelected,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: AppColors.labelSecondary),
                defaultTextStyle: const TextStyle(color: AppColors.label),
                outsideTextStyle: const TextStyle(color: AppColors.labelPlaceholder),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.label,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left),
                rightChevronIcon: const Icon(Icons.chevron_right),
                headerPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final expense = _dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.day.toString(),
                        style: const TextStyle(color: AppColors.label),
                      ),
                      if (expense > 0)
                        Text(
                          "${expense.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: AppColors.button,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  final expense = _dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      minHeight: 50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.day.toString(),
                          style: const TextStyle(color: AppColors.label),
                        ),
                        if (expense > 0)
                          Text(
                            "${expense.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: AppColors.button,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final expense = _dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.buttonSelected,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 60,
                      minHeight: 60,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.day.toString(),
                          style: const TextStyle(color: AppColors.label),
                        ),
                        if (expense > 0)
                          Text(
                            "${expense.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: AppColors.button,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.label,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "R\$ ${totalExpense.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.button,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _transactions.isEmpty
                  ? Center(
                      child: Text(
                        "Nenhuma transação para este dia",
                        style: const TextStyle(
                          color: AppColors.labelPlaceholder,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ListCard(
                            card: transaction,
                            onTap: (selectedCard) {
                              print("Card selecionado: ${selectedCard.description}");
                            },
                            background: AppColors.card,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
