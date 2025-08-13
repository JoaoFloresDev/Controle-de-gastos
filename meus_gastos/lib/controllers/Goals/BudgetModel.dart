class BudgetModel {
  final String categoryId;
  final double value;

  BudgetModel({required this.categoryId, required this.value});

  factory BudgetModel.fromJson(dynamic json) {
    if (json is String) return BudgetModel(categoryId: json, value: 0);
    return BudgetModel(categoryId: json['categoryId'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'value': value,
    };
  }
}
