import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

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
    final formattedDate =
        DateFormat('EEEE, d MMM', Localizations.localeOf(context).toString())
            .format(selectedDay ?? focusedDay)
            .capitalize();

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.only(left: 16, right: 16, top: 8),
          child: Divider(
          height: 1,
          thickness: 1,
          color: const Color.fromARGB(80, 142, 142, 147),
        ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.label,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "R\$ ${totalExpense.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.label,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
