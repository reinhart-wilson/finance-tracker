import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:finance_tracker/repositories/transaction_category_repository.dart';
import 'package:finance_tracker/repositories/transaction_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TransactionCategoryViewmodel extends ChangeNotifier {
  TransactionCategoryViewmodel(
      {required TransactionCategoryRepository categoryRepository,
      required AccountRepository accountRepository,
      required TransactionRepository txRepository})
      : _categoryRepository = categoryRepository,
        _accountRepository = accountRepository,
        _txRepository = txRepository{
    _loadAccounts();
    _loadCategories();
    _accountRepository.addListener(() {
      _loadAccounts();
    });
    _categoryRepository.addListener(() {
      _loadCategories();
    });
  }

  final TransactionCategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;
  final TransactionRepository _txRepository;


  bool _isLoading = false;
  List<Account> _accounts = [];
  List<TransactionCategory> _categories = [];

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  List<TransactionCategory> get categories => _categories;

  Future<void> _loadAccounts() async {
    _isLoading = true;
    notifyListeners();
    _accounts = await _accountRepository.getAllAccounts();
    _isLoading = false;
    notifyListeners();
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

  Future<void> deleteCategory(TransactionCategory category,
      {nullCategory = false}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _categoryRepository.deleteTransactionCategory(category.id!,
          nullCategory: nullCategory);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editCategory(TransactionCategory category) async {
    await _categoryRepository.editTransactionCategory(category);
  }

  Future<void> migrateCategory(
    int oldCategoryId,
    int newCategoryId,
  ) async {
    await _txRepository.changeTransactionCategory(
        oldCategoryId, newCategoryId);
    notifyListeners();
  }
}
