import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:finance_tracker/repositories/transaction_category_repository.dart';
import 'package:finance_tracker/repositories/transaction_repository.dart';
import 'package:flutter/foundation.dart';

class TransactionFormViewmodel extends ChangeNotifier {
  TransactionFormViewmodel(
      {required TransactionRepository transactionRepository,
      required AccountRepository accountRepository,
      required TransactionCategoryRepository categoryRepository})
      : _transactionRepository = transactionRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository {
    _loadAccounts();
    _loadCategories();
    _accountRepository.addListener(() {
      _loadAccounts();
    });
    _categoryRepository.addListener(() {
      _loadCategories();
    });
  }

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final TransactionCategoryRepository _categoryRepository;

  bool Function(Transaction)? filter;
  List<Account> _accountList = [];
  List<TransactionCategory> _categories = [];

  // Values to listen to
  bool _isLoading = false;

  // Getters for private attributes
  bool get isLoading => _isLoading;
  List<Account> get accountList => _accountList;
  List<TransactionCategory> get categories => _categories;

  Future<void> _loadAccounts() async {
    _isLoading = true;
    notifyListeners();
    _accountList = await _accountRepository.getAllAccounts();
    _accountList.sort((a, b) => a.name.compareTo(b.name));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _transactionRepository.addTransaction(transaction);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();
    _categories = await _categoryRepository.getTransactionCategories();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertCategory(TransactionCategory category) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _categoryRepository.addTransactionCategory(category);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
