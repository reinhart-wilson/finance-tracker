import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/mappers/account_mapper.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:finance_tracker/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AccountListViewmodel extends ChangeNotifier {
  AccountListViewmodel(
      {required AccountRepository accountRepository,
      required TransactionRepository txnRepository})
      : _accountRepository = accountRepository,
      _txnRepository = txnRepository{
    _loadAccounts();
    _accountRepository.addListener(() {
      _loadAccounts(); // atau refresh data
    });
    _txnRepository.addListener((){
      _loadAccounts();
    });
  }

  final AccountRepository _accountRepository;
  final TransactionRepository _txnRepository;
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
    _accountList = await _accountRepository.getAllAccounts();
    _accountList.sort((a, b) => a.name.compareTo(b.name));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertAccount(Account account) async {
    try {
      _isLoading = true;

      notifyListeners();
      int id = await _accountRepository.addAccount(account);
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
      await _accountRepository.deleteAccount(accountId);
      _accountList.removeWhere((account) => account.id == accountId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
