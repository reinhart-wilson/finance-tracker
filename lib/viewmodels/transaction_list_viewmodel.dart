import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/models/transaction_filter.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:finance_tracker/repositories/transaction_repository.dart';
import 'package:flutter/foundation.dart';

class TransactionListViewmodel extends ChangeNotifier {
  TransactionListViewmodel(
      {required TransactionRepository txRepository,
      required AccountRepository accountRepository})
      : _txRepository = txRepository,
        _accountRepository = accountRepository {
    _loadAccounts();
    // By default loads all transactions settled in the current month or
    // still due up to current month.
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    _filter = TransactionFilter(
        startDate: firstDayOfMonth,
        endDate: lastDayOfMonth,
        loadPreviouslyUnsettled: true);
    _loadTransactions();

    _txRepository.addListener((){
      _loadTransactions();
    });
    _accountRepository.addListener((){
      _loadAccounts();
    });
  }

  final TransactionRepository _txRepository;
  final AccountRepository _accountRepository;

  // Values to listen to
  bool _isLoading = false;
  List<Transaction> _settledTransactions = [];
  List<Transaction> _unsettledTransactions = [];
  List<Transaction> _filteredTransactions = [];
  List<Account> _accounts = [];
  late TransactionFilter _filter;
  double _settledSum = 0.0;
  double _unsettledSum = 0.0;
  String _keyword = '';

  double get settledSum => _settledSum;
  double get unsettledSum => _unsettledSum;
  bool get isLoading => _isLoading;
  List<Transaction> get settledTransactions => _settledTransactions;
  List<Transaction> get unsettledTransactions => _unsettledTransactions;
  List<Transaction> get filteredTransactions => _keyword.isEmpty
      ? [..._settledTransactions, ..._unsettledTransactions]
      : _filteredTransactions;

  Future<void> _loadAccounts() async {
    _accounts = await _accountRepository.getAllAccounts();
  }

  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settledTransactions = await _txRepository.getSettledTransactions(
          startDate: _filter.startDate,
          endDate: _filter.endDate,
          accountId: _filter.accountId,
          transactionType: _filter.transactionType,
          categoryId: _filter.categoryId);
      _unsettledTransactions = await _txRepository.getUnsettledTransactions(
          startDate: _filter.loadPreviouslyUnsettled ? null : _filter.startDate,
          endDate: _filter.endDate,
          accountId: _filter.accountId,
          transactionType: _filter.transactionType,
          categoryId: _filter.categoryId);
      _settledSum = await _txRepository.getSettledTransactionsSum(
          startDate: _filter.startDate,
          endDate: _filter.endDate,
          accountId: _filter.accountId,
          transactionType: _filter.transactionType,
          categoryId: _filter.categoryId);
      _unsettledSum = await _txRepository.getUnsettledTransactionsSum(
          startDate: _filter.loadPreviouslyUnsettled ? null : _filter.startDate,
          endDate: _filter.endDate,
          accountId: _filter.accountId,
          transactionType: _filter.transactionType,
          categoryId: _filter.categoryId);
      _applySearch();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchTransaction(String keyword) {
    _keyword = keyword;
    _applySearch();
  }

  void filterTransaction(TransactionFilter filter) {
    _filter = filter;
    _loadTransactions();
  }

  void _applySearch() {
    if (_keyword.isEmpty) {
      _filteredTransactions = [
        ..._settledTransactions,
        ..._unsettledTransactions
      ];
    } else {
      final all = [..._settledTransactions, ..._unsettledTransactions];
      _filteredTransactions = all.where((tx) {
        return tx.title.toLowerCase().contains(_keyword.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  String accountNameOfId(int accountId) {
    final account = _accounts.where((a) => a.id == accountId).firstOrNull;
    return account?.name ?? 'Unknown';
  }
}
