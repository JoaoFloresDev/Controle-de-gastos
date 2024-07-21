import 'package:flutter/material.dart';

class YearSelector extends StatelessWidget {
  final DateTime currentDate;
  final Function(int) onChangeYear;

  YearSelector({Key? key, required this.currentDate, required this.onChangeYear}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedYear = currentDate.year.toString();

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
            onPressed: () => onChangeYear(-1),
          ),
          Text(
            formattedYear,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, size: 40),
            onPressed: () => onChangeYear(1),
          ),
        ],
      ),
    );
  }
}