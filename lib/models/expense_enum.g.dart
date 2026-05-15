// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_enum.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 1;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.food;
      case 1:
        return ExpenseCategory.transport;
      case 2:
        return ExpenseCategory.shopping;
      case 3:
        return ExpenseCategory.bills;
      case 4:
        return ExpenseCategory.health;
      case 5:
        return ExpenseCategory.entertainment;
      case 6:
        return ExpenseCategory.education;
      case 7:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.food;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.food:
        writer.writeByte(0);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(1);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(2);
        break;
      case ExpenseCategory.bills:
        writer.writeByte(3);
        break;
      case ExpenseCategory.health:
        writer.writeByte(4);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(5);
        break;
      case ExpenseCategory.education:
        writer.writeByte(6);
        break;
      case ExpenseCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentModeAdapter extends TypeAdapter<PaymentMode> {
  @override
  final int typeId = 2;

  @override
  PaymentMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMode.upi;
      case 1:
        return PaymentMode.cash;
      case 2:
        return PaymentMode.card;
      case 3:
        return PaymentMode.netBanking;
      default:
        return PaymentMode.upi;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMode obj) {
    switch (obj) {
      case PaymentMode.upi:
        writer.writeByte(0);
        break;
      case PaymentMode.cash:
        writer.writeByte(1);
        break;
      case PaymentMode.card:
        writer.writeByte(2);
        break;
      case PaymentMode.netBanking:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
