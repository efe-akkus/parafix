import 'expense_category.dart';

class MonthlyPayment {
  const MonthlyPayment({
    required this.id,
    required this.title,
    required this.amount,
    required this.billingDay,
    required this.category,
    this.note,
    this.isActive = true,
  }) : assert(billingDay >= 1 && billingDay <= 31);

  final String id;
  final String title;
  final double amount;
  final int billingDay;
  final ExpenseCategory category;
  final String? note;
  final bool isActive;

  MonthlyPayment copyWith({
    String? id,
    String? title,
    double? amount,
    int? billingDay,
    ExpenseCategory? category,
    String? note,
    bool? isActive,
  }) {
    return MonthlyPayment(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      billingDay: billingDay ?? this.billingDay,
      category: category ?? this.category,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'billingDay': billingDay,
      'categoryId': category.id,
      'note': note,
      'isActive': isActive,
    };
  }

  factory MonthlyPayment.fromJson(
    Map<String, dynamic> json, {
    required ExpenseCategory Function(String categoryId) resolveCategory,
  }) {
    return MonthlyPayment(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      billingDay: json['billingDay'] as int,
      category: resolveCategory(json['categoryId'] as String),
      note: json['note'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
