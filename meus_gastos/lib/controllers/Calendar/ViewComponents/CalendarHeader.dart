import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime? selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, double> dailyExpenses;

  const CalendarHeader({
    Key? key,
    required this.selectedDay,
    required this.focusedDay,
    required this.dailyExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalExpense = dailyExpenses[DateTime(
          (selectedDay ?? focusedDay).year,
          (selectedDay ?? focusedDay).month,
          (selectedDay ?? focusedDay).day,
        )] ??
        0.0;
    final formattedDate = DateFormat('EEEE, d MMM', Localizations.localeOf(context).toString())
        .format(selectedDay ?? focusedDay);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
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
              fontWeight: FontWeight.bold,
              color: AppColors.button,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
