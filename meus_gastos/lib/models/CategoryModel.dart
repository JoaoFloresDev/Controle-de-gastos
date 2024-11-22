import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final Color color;
  final IconData icon;
  final String name;
  int frequency;

  CategoryModel({
    this.id = '', // Valor padrão para o ID na estrutura antiga
    this.color = Colors.grey, // Cor padrão para estrutura antiga
    this.icon = Icons.category, // Ícone padrão para estrutura antiga
    required this.name,
    this.frequency = 0,
  });

  // Converte de JSON para CategoryModel
  factory CategoryModel.fromJson(dynamic json) {
    // Verifica se json é uma String (estrutura antiga)
    if (json is String) {
      return CategoryModel(
        name: json, // Usa o valor da string como o nome da categoria
      );
    }
    
    // Se for um Map, usa a estrutura nova
    return CategoryModel(
      id: json['id'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: json['fontFamily']),
      name: json['name'],
      frequency: json['frequency'] ?? 0,
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
