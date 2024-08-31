import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/ProgressIndicatorModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LinearProgressIndicatorSection extends StatelessWidget {
  final ProgressIndicatorModel model;
  final double totalAmount;

  const LinearProgressIndicatorSection({
    Key? key,
    required this.model,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(Translateservice.getTranslatedCategoryName(context, model.title),
              style: const TextStyle(
                  color: AppColors.label,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.topRight,
            children: [
              LinearPercentIndicator(
                width: MediaQuery.of(context).size.width - 30,
                animation: true,
                lineHeight: 30.0,
                animationDuration: 1000,
                percent: model.progress / totalAmount,
                center: Text(
                  model.progress.toStringAsFixed(0),
                  style: const TextStyle(
                      color: AppColors.label,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                barRadius: const Radius.circular(12),
                backgroundColor: model.color.withOpacity(0.2),
                progressColor: model.color,
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                    color: AppColors.label,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
