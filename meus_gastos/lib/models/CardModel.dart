import 'package:meus_gastos/models/CategoryModel.dart';

class CardModel {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final CategoryModel category;

  CardModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category.toJson(), // Convert category to JSON
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      category: map['category'] is String
          ? CategoryModel(name: map['category']) // Para dados antigos
          : CategoryModel.fromJson(map['category']), // Para dados novos
    );
  }
}
