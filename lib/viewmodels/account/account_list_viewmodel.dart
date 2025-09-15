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
        _txnRepository = txnRepository {
    _loadAccounts();
    _getAccountsBalanceSum();
    _getUnsettledSum();
    _getBalanceGrowth();
    _accountRepository.addListener(() {
      _loadAccounts(); //
      _getAccountsBalanceSum();
      _getUnsettledSum();
      _getBalanceGrowth();
    });
    _txnRepository.addListener(() {
      _loadAccounts();
      _getAccountsBalanceSum();
      _getUnsettledSum();
      _getBalanceGrowth();
    });
  }

  final AccountRepository _accountRepository;
  final TransactionRepository _txnRepository;
  List<Account> _accountList = [];
  bool Function(Account)? _filterCallback;
  bool _isLoading = false;

  double _totalBalance = 0;
  double _unsettledSum = 0;
  double _balanceGrowth = 0;

  /// Getters
  List<Account> get accountList => _accountList;
  bool get isLoading => _isLoading;
  double get totalBalance => _totalBalance;
  double get unsettledSum => _unsettledSum;
  double get projectedBalance => _totalBalance + unsettledSum;
  double get balanceGrowth => _balanceGrowth;

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
      await _accountRepository.addAccount(account);
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

  Future<void> _getAccountsBalanceSum() async {
    try {
      _isLoading = true;
      notifyListeners();
      _totalBalance = await _accountRepository.getTotalBalance();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getUnsettledSum() async {
    try {
      _isLoading = true;
      notifyListeners();
      _unsettledSum = await _txnRepository.getUnsettledTransactionsSum();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getBalanceGrowth() async {
    // Last month
    try {
      _isLoading = true;
      notifyListeners();
      final now = DateTime.now();
      final startLastMonth = DateTime(
        now.year,
        now.month - 1,
        1,
      );
      final endLastMonth = DateTime(now.year, now.month, 0, 23, 59, 999);
      final lastMonthSum = await _txnRepository.getSettledTransactionsSum(
          startDate: startLastMonth, endDate: endLastMonth);
      _balanceGrowth = lastMonthSum == 0 ? 1 : _totalBalance / lastMonthSum - 1;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
