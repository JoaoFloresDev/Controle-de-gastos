import 'package:flutter/material.dart';

class CategoryModel {
  final int id; // nome
  final String name;
  final IconData icon; // icones
  CategoryModel(
      {required this.id, required this.icon, required this.name});
  
  

  CategoryModel.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        icon =map['icon'];
  
  Map<String, dynamic> toMap() {
    return{
      "id": this.id,
      "name": this.name,
      "icon":this.icon
    };
  }
}
