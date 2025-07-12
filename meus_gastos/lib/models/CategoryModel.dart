import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final Color color;
  final IconData icon;
  final String name;
  int frequency;
  bool available;
  double meta; 

  //mark - Constructor
  CategoryModel({
    this.id = '',
    this.color = Colors.grey,
    this.icon = Icons.category,
    required this.name,
    this.frequency = 0,
    this.available = true,
    this.meta = 0
  });

  //mark - From JSON
  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) {
      return CategoryModel(
        name: json,
      );
    }
    return CategoryModel(
      id: json['id'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: json['fontFamily']),
      name: json['name'],
      frequency: json['frequency'] ?? 0,
      available: json['available'] ?? true,
      meta: json['meta'] ?? 0
    );
  }

  //mark - To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color.value,
      'icon': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'name': name,
      'frequency': frequency,
      'available': available,
      'meta': meta ?? 0,
    };
  }
}
