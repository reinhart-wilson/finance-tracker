import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/mappers/account_mapper.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountListViewmodel extends ChangeNotifier {
  AccountListViewmodel({required AccountRepository repository})
      : _repository = repository {
    _loadAccounts();
    _repository.addListener(() {
      _loadAccounts(); // atau refresh data
    });
  }

  final AccountRepository _repository;
  List<Account> _accountList = [];
  bool Function(Account)? _filterCallback;
  bool _isLoading = false;

  /// Getter
  List<Account> get accountList => _accountList.filtered(_filterCallback);
  bool get isLoading => _isLoading;

  /// Setter
  set filter(filterCallback) {
    _filterCallback = filterCallback;
  }

  /// Loads account, called on viewmodel init.
  Future<void> _loadAccounts() async {
    _isLoading = true;
    notifyListeners();
    _accountList = await _repository.getAllAccounts();
    _accountList.sort((a, b) => a.name.compareTo(b.name));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertAccount(Account account) async {
    try {
      _isLoading = true;

      notifyListeners();
      int id = await _repository.addAccount(account);
      final newAccount = account.copyWith(id: id);
      _accountList.add(newAccount);
      _accountList.sort((a, b) => a.name.compareTo(b.name));

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.deleteAccount(accountId);
      _accountList.removeWhere((account) => account.id == accountId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
