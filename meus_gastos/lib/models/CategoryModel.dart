import 'package:meus_gastos/designSystem/exportDS.dart';

class CategoryModel {
  final String id;
  final Color color;
  final IconData icon;
  final String name;
  int frequency;

  CategoryModel(
      {required this.id,
      required this.color,
      required this.icon,
      required this.name,
      this.frequency = 0});

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
        frequency: json['frequency']);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
