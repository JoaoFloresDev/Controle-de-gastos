import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/TotalSpentCarousel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Totalspentcarouselwidget extends StatefulWidget {
  final double totalGasto;
  final DateTime currentDate;
  Totalspentcarouselwidget(
      { Key? key,
        required this.currentDate, 
        required this.totalGasto}) : super(key: key);
  TotalspentcarouselwidgetState createState() =>
      TotalspentcarouselwidgetState();
}

class TotalspentcarouselwidgetState extends State<Totalspentcarouselwidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: SizedBox(
            height: 440,
            child: widget.totalGasto == 0
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.monthlyInsights,
                          style: const TextStyle(
                            color: AppColors.label,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign
                              .center, // Centraliza o texto dentro do widget
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .youWillBeAbleToUnderstandYourExpensesHere,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.label,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                : TotalSpentCarouselWithTitles(
                    key: ValueKey(widget.currentDate), currentDate: widget.currentDate)));
  }
}
