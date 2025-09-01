import 'package:finance_tracker/models/account.dart';

extension AccountToMap on Account {
  Map<String, dynamic> toMap() => { 
    'id': id, 
    'name': name, 
    'balance': balance, 
    'parent_id': parentId,
  };
}

extension AccountFromMap on Map<String, dynamic> {
  Account fromMap() => Account(
    id: this['id'], 
    name: this["name"], 
    balance: this['balance'], 
    parentId: this['parent_id'],
  );
}

extension AccountListFilter on List<Account> {
  List<Account> filtered(bool Function(Account)? filterCallback) {
    if (filterCallback == null) {
      return this;
    }
    return where(filterCallback).toList();
  }
}
