import 'expense_category.dart';

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': category.id,
      'note': note,
    };
  }

  factory ExpenseEntry.fromJson(
    Map<String, dynamic> json, {
    required ExpenseCategory Function(String categoryId) resolveCategory,
  }) {
    return ExpenseEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: resolveCategory(json['categoryId'] as String),
      note: json['note'] as String?,
    );
  }
}
