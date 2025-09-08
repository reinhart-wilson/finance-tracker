import 'package:finance_tracker/models/transaction/transaction_category.dart';

extension TransactionToMap on TransactionCategory {
  Map<String, dynamic> toMap() => { 
    'id': id, 
    'name': name, 
    'color': color,
    'default_account_id': defaultAccountId,
  };
}

extension TransactionFromMap on Map<String, dynamic> {
  TransactionCategory fromMap() => TransactionCategory(
    id: this['id'], 
    name: this["name"], 
    color: this['color'], 
    defaultAccountId: this['default_account_id'] 
  );
}
