import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

class CalendarTable extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, double> dailyExpenses;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarTable({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.dailyExpenses,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: Localizations.localeOf(context).languageCode,
      focusedDay: focusedDay,
      firstDay: DateTime(2010),
      lastDay: DateTime(2100),
      rowHeight: 50,
      daysOfWeekHeight: 30,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarStyle: CalendarStyle(
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
          final expense = dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;
          return _buildDayCell(day, expense);
        },
        selectedBuilder: (context, day, focusedDay) {
          final expense = dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;
          return _buildDayCell(day, expense, selected: true);
        },
        todayBuilder: (context, day, focusedDay) {
          final expense = dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;
          return _buildDayCell(day, expense, today: true);
        },
      ),
    );
  }

  Widget _buildDayCell(DateTime day, double expense, {bool selected = false, bool today = false}) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? AppColors.buttonSelected
            : today
                ? AppColors.card
                : null,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 70, minHeight: 70),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.day.toString(),
            style: const TextStyle(
              color: AppColors.label,
              fontWeight: FontWeight.bold,
            ),
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
  }
}
