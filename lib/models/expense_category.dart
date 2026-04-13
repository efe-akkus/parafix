import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isBuiltIn = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isBuiltIn;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'color': color.toARGB32(),
      'isBuiltIn': isBuiltIn,
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] as int),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
    );
  }
}
