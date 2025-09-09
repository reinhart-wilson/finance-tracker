import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/models/transaction/transaction_filter.dart';
import 'package:finance_tracker/repositories/repositories.dart';
import 'package:flutter/foundation.dart';

class TransactionListViewmodel extends ChangeNotifier {
  TransactionListViewmodel(
      {required TransactionRepository txRepository,
      required AccountRepository accountRepository,
      required TransactionCategoryRepository categoryRepository})
      : _txRepository = txRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository {
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
    _loadCategories();

    _txRepository.addListener((){
      _loadTransactions();
    });
    _accountRepository.addListener((){
      _loadAccounts();
    });
  }

  final TransactionRepository _txRepository;
  final AccountRepository _accountRepository;
  final TransactionCategoryRepository _categoryRepository;

  // Values to listen to
  bool _isLoading = false;
  List<Transaction> _settledTransactions = [];
  List<Transaction> _unsettledTransactions = [];
  List<Transaction> _filteredTransactions = [];
  List<Account> _accounts = [];
  List<TransactionCategory> _categories = [];
  late TransactionFilter _filter;
  double _settledSum = 0.0;
  double _unsettledSum = 0.0;
  String _keyword = '';

  double get settledSum => _settledSum;
  double get unsettledSum => _unsettledSum;
  bool get isLoading => _isLoading;
  List<Account> get accounts => _accounts;
  List<Transaction> get filteredTransactions => _keyword.isEmpty
      ? [..._settledTransactions, ..._unsettledTransactions]
      : _filteredTransactions;
  List<TransactionCategory> get categories => _categories;

  Future<void> _loadAccounts() async {
    _isLoading = true;
    notifyListeners();
    _accounts = await _accountRepository.getAllAccounts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    final List<int>? accountIds = _filter.accounts?.map((account) => account.id! ).toList();
    final List<int>? categoryIds = _filter.categories?.map((category) => category.id! ).toList();
    debugPrint(categoryIds.toString());
    try {
      _settledTransactions = await _txRepository.getSettledTransactions(
          startDate: _filter.startDate,
          endDate: _filter.endDate,
          accountIds: accountIds,
          transactionType: _filter.transactionType,
          categoryId: categoryIds);
      _unsettledTransactions = await _txRepository.getUnsettledTransactions(
          startDate: _filter.loadPreviouslyUnsettled ? null : _filter.startDate,
          endDate: _filter.endDate,
          accountIds: accountIds,
          transactionType: _filter.transactionType,
          categoryId: categoryIds);
      _settledSum = await _txRepository.getSettledTransactionsSum(
          startDate: _filter.startDate,
          endDate: _filter.endDate,
          accountIds: accountIds,
          transactionType: _filter.transactionType,
          categoryId: categoryIds);
      _unsettledSum = await _txRepository.getUnsettledTransactionsSum(
          startDate: _filter.loadPreviouslyUnsettled ? null : _filter.startDate,
          endDate: _filter.endDate,
          accountIds: accountIds,
          transactionType: _filter.transactionType,
          categoryId: categoryIds);
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
  
    Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();
    _categories = await _categoryRepository.getTransactionCategories();
    _isLoading = false;
    notifyListeners();
  }
}
