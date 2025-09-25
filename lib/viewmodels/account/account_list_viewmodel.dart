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
  final Map<int, double> _unsettledAmountByAccountId = {};
  bool Function(Account)? _filterCallback;
  bool _isLoading = false;

  double _totalBalance = 0;
  double _unsettledSum = 0;
  double _balanceGrowth = 0;

  /// Getters
  List<Account> get accountList => _filterCallback == null
      ? _accountList
      : _accountList.filtered(_filterCallback);
  bool get isLoading => _isLoading;
  double get totalBalance => _totalBalance;
  double get unsettledSum => _unsettledSum;
  double get projectedBalance => _totalBalance + unsettledSum;
  double get balanceGrowth => _balanceGrowth;
  Map<int, List<Account>> get childrenMap {
    final Map<int, List<Account>> childrenMap = {};
    for (final acc in _accountList) {
      if (acc.parentId != null) {
        childrenMap.putIfAbsent(acc.parentId!, () => []).add(acc);
      }
    }

    return childrenMap;
  }

  List<Account> get parentAccountList =>
      _accountList.where((acc) => acc.parentId == null).toList();

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
    final now = DateTime.now();
    await _loadUnsettledTransactionsSum(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999));
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
      final now = DateTime.now();
      final startDate = DateTime(
        now.year,
        now.month,
        1,
      );
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
      _unsettledSum = await _txnRepository.getUnsettledTransactionsSum(
          startDate: startDate, endDate: endDate);
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
      final endLastMonth = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
      final lastMonthSum = await _txnRepository.getSettledTransactionsSum(
          startDate: startLastMonth, endDate: endLastMonth);
      if (lastMonthSum == 0) {
        _balanceGrowth = _totalBalance == 0 ? 0 : 1;
      } else {
        _balanceGrowth = _totalBalance / lastMonthSum - 1;
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUnsettledTransactionsSum(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      for (var parentAccount
          in _accountList.where((account) => account.parentId == null)) {
        final parentId = parentAccount.id!;

        // Get the sum of parent's unsettled transactions
        final parentUnsettledAmount =
            await _txnRepository.getUnsettledTransactionsSum(
          accountIds: [parentId],
          startDate: startDate,
          endDate: endDate,
        );

        _unsettledAmountByAccountId[parentId] = parentUnsettledAmount;

        // Adds child account and their unsettled transactions total
        final childAccountsList =
            await _accountRepository.getChildAccounts(parentId);
        for (final account in childAccountsList) {
          final unsettledAmount =
              await _txnRepository.getUnsettledTransactionsSum(
            accountIds: [account.id!],
            startDate: startDate,
            endDate: endDate,
          );
          _unsettledAmountByAccountId[account.id!] = unsettledAmount;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  double? getUnsettledSumForId(int accountId) {
    return _unsettledAmountByAccountId[accountId];
  }
}
