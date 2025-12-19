import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

class FixedExpense {
  String id;
  String description;
  double price;
  DateTime date;
  CategoryModel category;
  String repetitionType = 'monthly';
  String? additionType;

  FixedExpense({
    required this.description,
    required this.price,
    required this.date,
    required this.category,
    required this.id,
    required this.repetitionType,
    this.additionType,
  });

  Map<String, dynamic> toJson() {
    print("toJson");
    print(additionType);
    return {
      'description': description,
      'price': price,
      'date': date.toIso8601String(),
      'category': category.toJson(),
      'id': id,
      'repetitionType': repetitionType,
      'additionType': additionType ?? 'suggestion',
    };
  }

  factory FixedExpense.fromJson(Map<String, dynamic> json) {
    return FixedExpense(
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      category: CategoryModel.fromJson(json['category']),
      id: json['id'],
      repetitionType: json['repetitionType'] ?? json['repetitionType'] ?? 'monthly',
      additionType: json['additionType'] ?? json['tipoAdicao'] ?? 'suggestion',
    );
  }

  // CORREÇÃO AQUI: os getters agora usam o mesmo valor padrão
  bool get isAutomaticAddition => (additionType ?? 'suggestion') == 'automatic';
  bool get isSuggestion => (additionType ?? 'suggestion') == 'suggestion';
}