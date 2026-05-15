import 'package:hive/hive.dart';
import 'expense_enum.dart';

 // hive will generate this file
 part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final ExpenseCategory category;

  @HiveField(5)
  final PaymentMode paymentMode;

  @HiveField(6)
  final String notes;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.paymentMode,
    this.notes = '',
  });

 // keep your existing copyWith unchanged

  Expense copyWith({
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    PaymentMode? paymentMode,
    String? notes,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      paymentMode: paymentMode ?? this.paymentMode,
      notes: notes ?? this.notes,
    );
  }
}