import 'package:finance_tracker/models/transaction_category.dart';
import 'package:finance_tracker/services/local_data_service.dart';
import 'package:finance_tracker/models/mappers/transaction_category_mapper.dart';
import 'package:flutter/foundation.dart';

class TransactionCategoryRepository with ChangeNotifier{
  TransactionCategoryRepository({required localDataService})
      : _localDataService = localDataService;

  final LocalDataService _localDataService;

  Future<List<TransactionCategory>> getTransactionCategories() async {
    final categories = await _localDataService.fetchAllTransactionCategories();
    return categories.map((category) => category.fromMap()).toList();
  }

  Future<int> addTransactionCategory(TransactionCategory category) async {
    try {
      int id =
          await _localDataService.insertTransactionCategory(category.toMap());
      notifyListeners();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransactionCategory(int categoryId) async {
    try {
      await _localDataService.deleteTransactionCategory(categoryId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
