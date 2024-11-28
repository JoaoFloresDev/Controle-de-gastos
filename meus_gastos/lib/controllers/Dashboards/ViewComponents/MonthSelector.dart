import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final DateTime currentDate;
  final Function(int) onChangeMonth;

  const MonthSelector(
      {super.key, required this.currentDate, required this.onChangeMonth});

  @override
  Widget build(BuildContext context) {
    final DateFormat format =
        DateFormat('MMMM yyyy', Localizations.localeOf(context).toString());

    String formattedDate = format.format(currentDate);
    formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Container(
      width: 300,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centraliza no eixo Y
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 40),
            onPressed: () => onChangeMonth(-1),
            padding: EdgeInsets.zero, // Remove espaçamentos extras
          ),
          Expanded(
            child: Center(
              child: Text(
                formattedDate,
                style: const TextStyle(
                  color: AppColors.label,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 40),
            onPressed: () => onChangeMonth(1),
            padding: EdgeInsets.zero, // Remove espaçamentos extras
          ),
        ],
      ),
    );
  }
}
