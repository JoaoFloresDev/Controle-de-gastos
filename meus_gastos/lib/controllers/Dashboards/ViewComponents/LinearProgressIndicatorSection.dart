import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LinearProgressIndicatorSection extends StatelessWidget {
  final ProgressIndicatorModel model;
  final double totalAmount;

  const LinearProgressIndicatorSection({
    super.key,
    required this.model,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (model.progress / totalAmount * 100).clamp(0, 100);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: model.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    TranslateService.getTranslatedCategoryName(context, model.title),
                    style: const TextStyle(
                      color: AppColors.label,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          Text(
            model.progress.toStringAsFixed(0),
            style: const TextStyle(
              color: AppColors.label,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 64,
              animation: true,
              lineHeight: 8.0,
              animationDuration: 800,
              percent: (model.progress / totalAmount).clamp(0, 1),
              padding: EdgeInsets.zero,
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: model.color.withOpacity(0.15),
              progressColor: model.color,
            ),
          ),
          const SizedBox(height: 8),
          // Text(
          //   model.progress.toStringAsFixed(0),
          //   style: const TextStyle(
          //     color: AppColors.label,
          //     fontSize: 13,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
        ],
      ),
    );
  }
}
