
// import 'package:meus_gastos/designSystem/ImplDS.dart';
// import 'package:meus_gastos/services/TranslateService.dart';
// import 'package:meus_gastos/l10n/app_localizations.dart';

// class Totalspentcarouselwidget extends StatefulWidget {
//   final double totalGasto;
//   final DateTime currentDate;
//   Totalspentcarouselwidget(
//       {Key? key, required this.currentDate, required this.totalGasto})
//       : super(key: key);
//   TotalspentcarouselwidgetState createState() =>
//       TotalspentcarouselwidgetState();
// }

// class TotalspentcarouselwidgetState extends State<Totalspentcarouselwidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
//         child: SizedBox(
//             height: 440,
//             child: widget.totalGasto == 0
//                 ? Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           AppColors.card.withOpacity(0.9),
//                           AppColors.card2.withOpacity(0.8)
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           offset: const Offset(0, 8),
//                           blurRadius: 16,
//                           spreadRadius: 0,
//                         ),
//                       ],
//                     ),
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: AppColors.button.withOpacity(0.15),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.insights_outlined,
//                             size: 48,
//                             color: AppColors.button,
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           AppLocalizations.of(context)!.monthlyInsights,
//                           style: const TextStyle(
//                             color: AppColors.label,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: -0.5,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           AppLocalizations.of(context)!
//                               .youWillBeAbleToUnderstandYourExpensesHere,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.label.withOpacity(0.8),
//                             fontSize: 15,
//                             height: 1.4,
//                           ),
//                           textAlign: TextAlign.center,
//                         )
//                       ],
//                     ),
//                   )
//                 : TotalSpentCarouselWithTitles(
//                     key: ValueKey(widget.currentDate),
//                     currentDate: widget.currentDate)));
//   }
// }
