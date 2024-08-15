import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MonthSelector extends StatelessWidget {
  final DateTime currentDate;
  final Function(int) onChangeMonth;

  MonthSelector(
      {Key? key, required this.currentDate, required this.onChangeMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat format = DateFormat(
        'MMMM yyyy', Localizations.localeOf(context).toString());

    String formattedDate = format.format(currentDate);
    formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Container(
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: 40),
            onPressed: () => onChangeMonth(-1),
          ),
          Text(
            formattedDate,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, size: 40),
            onPressed: () => onChangeMonth(1),
          ),
        ],
      ),
    );
  }
}
