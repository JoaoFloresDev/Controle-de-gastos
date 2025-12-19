import 'package:meus_gastos/models/CategoryModel.dart';

class FixedExpense {
  String id;
  String description;
  double price;
  DateTime date;
  CategoryModel category;
  String repetitionType='mensal';

  FixedExpense(
      {required this.description,
      required this.price,
      required this.date,
      required this.category,
      required this.id,
      required this.repetitionType});

  // Para salvar em SharedPreferences, converter em Map
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'price': price,
      'date': date.toIso8601String(),
      'category': category.toJson(),
      'id': id,
      'repetitionType': repetitionType,
    };
  }

  // Para ler de SharedPreferences, criar a partir de Map
  factory FixedExpense.fromJson(Map<String, dynamic> json) {
    return FixedExpense(
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      category: CategoryModel.fromJson(json['category']),
      id: json['id'],
      repetitionType: json['repetitionType'],
    );
  }

}
