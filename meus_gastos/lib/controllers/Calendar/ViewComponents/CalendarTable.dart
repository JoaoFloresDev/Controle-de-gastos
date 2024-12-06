import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TableCalendar(
        locale: Localizations.localeOf(context).languageCode,
        focusedDay: focusedDay,
        firstDay: DateTime(2010),
        lastDay: DateTime(2100),
        rowHeight: 48,
        daysOfWeekHeight: 24,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.label,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            size: 38,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            size: 38,
          ),
          headerPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        calendarBuilders: CalendarBuilders(
          headerTitleBuilder: (context, day) {
            final formattedDate = toBeginningOfSentenceCase(
              DateFormat("MMMM 'de' yyyy",
                      Localizations.localeOf(context).languageCode)
                  .format(day),
            );
            return Center(
              child: Text(
                formattedDate ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.label,
                ),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            final expense =
                dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;
            return _buildDayCell(day, expense);
          },
          selectedBuilder: (context, day, focusedDay) {
            final expense =
                dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;
            return _buildDayCell(day, expense, selected: true);
          },
          todayBuilder: (context, day, focusedDay) {
            final expense =
                dailyExpenses[DateTime(day.year, day.month, day.day)] ?? 0.0;
            return _buildDayCell(day, expense, today: true);
          },
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day, double expense,
      {bool selected = false, bool today = false}) {
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? AppColors.buttonSelected
            : today
                ? AppColors.card
                : null,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.day.toString(),
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (expense > 0)
            Text(
              "${expense.toStringAsFixed(0)}",
              style: const TextStyle(
                color: AppColors.button,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
