import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final Color color;
  final IconData icon;
  final String name;
  int frequency;

  CategoryModel({
    required this.id,
    required this.color,
    required this.icon,
    required this.name,
    this.frequency = 0,
  });

  // Converta de JSON para CategoryModel
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      color: Color(json['color']),
      icon: IconData(json['icon'],
          fontFamily: json[
              'fontFamily']), // Recupera o IconData com codePoint e fontFamily
      name: json['name'],
      frequency: json['frequency'],
    );
  }

  // Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color.value,
      'icon': icon.codePoint, // Armazena o codePoint do ícone
      'fontFamily': icon.fontFamily, // Armazena a fontFamily
      'name': name,
      'frequency': frequency,
    };
  }
}
