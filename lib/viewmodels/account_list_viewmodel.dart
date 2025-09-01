import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/mappers/account_mapper.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountListViewmodel extends ChangeNotifier {
  AccountListViewmodel(this._repository) {
    _loadAccounts();
  }

  final AccountRepository _repository;
  List<Account> _accountList = [];
  bool Function(Account)? _filterCallback;
  bool isLoading = false;

  /// Getter
  List<Account> get accountList => _accountList.filtered(_filterCallback);

  /// Setter
  set filter(filterCallback) {
    _filterCallback = filterCallback;
    notifyListeners();
  }

  /// Loads account, called on viewmodel init.
  Future<void> _loadAccounts() async {
    _accountList = await _repository.getAllAccounts();
  }

  Future<void> insertAccount(Account account) async {
    try {
      isLoading = true;

      int id = await _repository.addAccount(account);
      final newAccount = account.copyWith(id: id);
      _accountList.add(newAccount);
      _accountList.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try {
      isLoading = true;
      await _repository.deleteAccount(accountId);
      _accountList.removeWhere((account) => account.id == accountId);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
