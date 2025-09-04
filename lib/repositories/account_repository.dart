import 'dart:async';

import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/services/local_data_service.dart';
import 'package:finance_tracker/models/mappers/account_mapper.dart';
import 'package:flutter/foundation.dart';

class AccountRepository with ChangeNotifier {
  AccountRepository({required localDataService})
      : _localDataService = localDataService;

  final LocalDataService _localDataService;

  Future<List<Account>> getAllAccounts() async {
    final accountMaps = await _localDataService.fetchAccounts();
    return accountMaps.map((accountMap) => accountMap.fromMap()).toList();
  }

  Future<int> addAccount(Account account) async {
    try {
      int id = await _localDataService.insertAccount(account.toMap());
      notifyListeners();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try {
      await _localDataService.deleteAccount(accountId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Account>> getChildAccounts(int parentId) async {
    final childAccounts = await _localDataService.fetchAccounts(parentId: parentId);
    return childAccounts.map((account) => account.fromMap()).toList();
  }
}
