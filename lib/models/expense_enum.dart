
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
 part 'expense_enum.g.dart';


@HiveType(typeId: 1)
enum ExpenseCategory {
  @HiveField(0) food,
  @HiveField(1) transport,
  @HiveField(2) shopping,
  @HiveField(3) bills,
  @HiveField(4) health,
  @HiveField(5) entertainment,
  @HiveField(6) education,
  @HiveField(7) other,
}

@HiveType(typeId: 2)
enum PaymentMode {
  @HiveField(0) upi,
  @HiveField(1) cash,
  @HiveField(2) card,
  @HiveField(3) netBanking,
}

// keep all your extensions below unchanged


extension ExpenseCategoryExt on ExpenseCategory {
  String get label => name[0].toUpperCase() + name.substring(1);
  String get emoji {
    switch (this) {
      case ExpenseCategory.food:          return '🍛';
      case ExpenseCategory.transport:     return '🚗';
      case ExpenseCategory.shopping:      return '🛍️';
      case ExpenseCategory.bills:         return '💡';
      case ExpenseCategory.health:        return '💊';
      case ExpenseCategory.entertainment: return '🎬';
      case ExpenseCategory.education:     return '📚';
      case ExpenseCategory.other:         return '📦';
    }
  }
  Color get color {
    switch (this) {
      case ExpenseCategory.food:          return Colors.cyanAccent;
      case ExpenseCategory.transport:     return Colors.purpleAccent;
      case ExpenseCategory.shopping:      return Colors.amberAccent;
      case ExpenseCategory.bills:         return Colors.redAccent;
      case ExpenseCategory.health:        return Colors.greenAccent;
      case ExpenseCategory.entertainment: return Colors.orangeAccent;
      case ExpenseCategory.education:     return Colors.indigoAccent;
      case ExpenseCategory.other:         return Colors.grey;
    }
  }
}

extension PaymentModeExt on PaymentMode {
  String get label {
    switch (this) {
      case PaymentMode.upi:        return 'UPI';
      case PaymentMode.cash:       return 'Cash';
      case PaymentMode.card:       return 'Card';
      case PaymentMode.netBanking: return 'Net Banking';
    }
  }
  IconData get icon {
    switch (this) {
      case PaymentMode.upi:        return Icons.qr_code;
      case PaymentMode.cash:       return Icons.money;
      case PaymentMode.card:       return Icons.credit_card;
      case PaymentMode.netBanking: return Icons.account_balance;
    }
  }
}
