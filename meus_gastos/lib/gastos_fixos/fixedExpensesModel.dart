import 'package:meus_gastos/models/CategoryModel.dart';

class FixedExpense {
  String id;
  String description;
  double price;
  int day;
  CategoryModel category;

  FixedExpense(
      {required this.description,
      required this.price,
      required this.day,
      required this.category,
      required this.id,
      });

  // Para salvar em SharedPreferences, converter em Map
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'price': price,
      'day': day,
      'category': category,
      'id': id,
    };
  }

  // Para ler de SharedPreferences, criar a partir de Map
  factory FixedExpense.fromJson(Map<String, dynamic> json) {
    return FixedExpense(
      description: json['description'],
      price: json['price'],
      day: json['day'],
      category: CategoryModel.fromJson(json['category']),
      id: json['id'],
    );
  }
}
