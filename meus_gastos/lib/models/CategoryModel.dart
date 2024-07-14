import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final Color color;
  final IconData icon;
  final String name;
  final int frequency;

  CategoryModel({
    required this.id,
    required this.color,
    required this.icon,
    required this.name,
    required this.frequency});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color.value,
      'icon': icon.codePoint,
      'name': name,
      'frequency': frequency
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      name: json['name'],
      frequency: json['frequency']
    );
  }
}
