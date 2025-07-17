import 'package:meus_gastos/models/CategoryModel.dart';

class Budgetmodel {
  final String categoryId;
  final double value;

  Budgetmodel({required this.categoryId, required this.value});

  factory Budgetmodel.fromJson(dynamic json) {
    if (json is String) return Budgetmodel(categoryId: json, value: 0);
    return Budgetmodel(categoryId: json['categoryId'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'value': value,
    };
  }
}
