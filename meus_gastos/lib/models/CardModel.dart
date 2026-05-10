import 'package:meus_gastos/models/CategoryModel.dart';

class CardModel {
  final String id;
  late double amount;
  final String description;
  final DateTime date;
  final CategoryModel category;
  final String idFixoControl;

  // updatedAt: timestamp da última modificação. Usado pelo SyncService para
  // resolver conflito entre local e remote (vence o mais recente).
  // deleted: tombstone para deleção. Hard-delete sumia em multi-device porque
  // o item ressuscitava do remote no próximo sync. Marcamos como true e o
  // merge propaga; UI filtra.
  DateTime updatedAt;
  bool deleted;

  CardModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    this.idFixoControl = '0',
    DateTime? updatedAt,
    this.deleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category.toJson(),
      'idFixoControl': idFixoControl,
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': deleted,
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
          : CategoryModel.fromJson(map['category']),
      idFixoControl:
          map.containsKey('idFixoControl') && map['idFixoControl'] != null
              ? map['idFixoControl'].toString()
              : '0',
      // Backward compat: dados antigos não tinham updatedAt; usa a data da
      // despesa como fallback. Isso garante que edições novas (com timestamp
      // atual) sempre vencem dados legados.
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.parse(map['date']),
      deleted: map['deleted'] ?? false,
    );
  }
}
