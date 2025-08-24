class GoalModel {
  final String categoryId;
  final double value;

  GoalModel({required this.categoryId, required this.value});

  factory GoalModel.fromJson(dynamic json) {
    if (json is String) return GoalModel(categoryId: json, value: 0);
    return GoalModel(categoryId: json['categoryId'], value: json['value']);
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'value': value,
    };
  }
}
