import 'package:finance_tracker/models/transaction.dart';

extension TransactionToMap on Transaction {
  Map<String, dynamic> toMap() => { 
    'id': id, 
    'title': title, 
    'amount': amount, 
    'account_id': accountId,
    'date': date.toIso8601String(),
    'due_date': dueDate?.toIso8601String(),
    'transaction_category_id' : categoryId,
    'settled_date': settledDate
  };
}

extension TransactionFromMap on Map<String, dynamic> {
  Transaction fromMap() => Transaction(
    id: this['id'], 
    title: this["title"], 
    amount: this['amount'], 
    date: DateTime.parse(this['date']),
    dueDate: this['due_date'] != null ? DateTime.parse(this['due_date']) : null,
    accountId: this['account_id'],
    settledDate: this['settled_date'],
    categoryId: this['transaction_category_id'],
  );
}
