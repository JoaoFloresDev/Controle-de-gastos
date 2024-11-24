import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class CustomCalendar extends StatefulWidget {
  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CardModel> _transactions = [];
  Map<DateTime, double> _dailyExpenses = {};

  @override
  void initState() {
    super.initState();
    _calculateDailyExpenses();
    _loadTransactionsForDay(_focusedDay);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Calendário",
          style: TextStyle(
            color: AppColors.label,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: Localizations.localeOf(context).languageCode,
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
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
              leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.label),
              rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.label),
              decoration: const BoxDecoration(
                color: AppColors.card,
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final expense = _dailyExpenses[DateTime(
                      day.year,
                      day.month,
                      day.day,
                    )] ??
                    0.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.day.toString(),
                      style: const TextStyle(color: AppColors.label),
                    ),
                    if (expense > 0)
                      Text(
                        "R\$ ${expense.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final expense = _dailyExpenses[DateTime(
                      day.year,
                      day.month,
                      day.day,
                    )] ??
                    0.0;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
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
                          "R\$ ${expense.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                final expense = _dailyExpenses[DateTime(
                      day.year,
                      day.month,
                      day.day,
                    )] ??
                    0.0;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.buttonSelected,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
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
                          "R\$ ${expense.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.red,
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
                            // Lógica ao tocar no card
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
    );
  }
}
