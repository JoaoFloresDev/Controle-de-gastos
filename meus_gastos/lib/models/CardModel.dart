import 'package:meus_gastos/models/CategoryModel.dart';

class CardModel {
  final String id;
  late double amount;
  final String description;
  final DateTime date;
  final CategoryModel category;
  final String idFixoControl;

  CardModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    this.idFixoControl = '0',
  });

  // Converte o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(), // Formato ISO 8601 para a data
      'category': category.toJson(), // Converte a categoria para JSON
      'idFixoControl': idFixoControl,
    };
  }

  // Construtor para criar o modelo a partir de JSON
  factory CardModel.fromJson(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      category: map['category'] is String
          ? CategoryModel(name: map['category']) // Para dados antigos
          : CategoryModel.fromJson(map['category']), // Para dados novos
      idFixoControl:
          map.containsKey('idFixoControl') && map['idFixoControl'] != null
              ? map['idFixoControl'].toString()
              : '0',
    );
  }
}
