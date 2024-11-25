import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'CalendarTable.dart';
import 'CalendarHeader.dart';
import 'CalendarTransactions.dart';

class CustomCalendar extends StatefulWidget {
  final VoidCallback onCalendarRefresh;

  const CustomCalendar({Key? key, required this.onCalendarRefresh}) : super(key: key);

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CardModel> _transactions = [];
  Map<DateTime, double> _dailyExpenses = {};

  @override
  void initState() {
    super.initState();
    _initializeCalendarData();
  }

  Future<void> _initializeCalendarData() async {
    await _calculateDailyExpenses();
    await _loadTransactionsForDay(_focusedDay);
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

    setState(() {
      _transactions = transactionsForDay;
    });
  }

  void refreshCalendar() {
    _initializeCalendarData();
  }

  @override
  Widget build(BuildContext context) {
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
            CalendarTable(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              dailyExpenses: _dailyExpenses,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadTransactionsForDay(selectedDay);
              },
            ),
            CalendarHeader(
              selectedDay: _selectedDay,
              focusedDay: _focusedDay,
              dailyExpenses: _dailyExpenses,
            ),
            Expanded(
              child: TransactionList(
                transactions: _transactions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
