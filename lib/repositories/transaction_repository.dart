import 'dart:async';

import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/services/local_data_service.dart';
import 'package:finance_tracker/models/mappers/transaction_mapper.dart';
import 'package:flutter/foundation.dart';

class TransactionRepository with ChangeNotifier {
  TransactionRepository({required localDataService})
      : _localDataService = localDataService;

  final LocalDataService _localDataService;

  Future<List<Transaction>> getSettledTransactions({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    List<int>? categoryId,
    String? transactionType, // 'credit', 'debit', atau null (semua)
  }) async {
    final transactions = await _localDataService.fetchSettledTransactions(
        startDate: startDate,
        endDate: endDate,
        accountIds: accountIds,
        transactionType: transactionType,
        categoryId: categoryId);
    return transactions.map((transaction) => transaction.fromMap()).toList();
  }

  Future<List<Transaction>> getUnsettledTransactions({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    List<int>? categoryId,
    String? transactionType,
  }) async {
    final transactions = await _localDataService.fetchUnsettledTransactions(
        startDate: startDate,
        endDate: endDate,
        accountIds: accountIds,
        transactionType: transactionType,
        categoryId: categoryId);
    return transactions.map((transaction) => transaction.fromMap()).toList();
  }

  Future<double> getSettledTransactionsSum({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    List<int>? categoryId,
    String? transactionType,
  }) async {
    final sum = await _localDataService.getSettledTransactionSum(
        startDate: startDate,
        endDate: endDate,
        accountIds: accountIds,
        transactionType: transactionType,
        categoryId: categoryId);
    return sum;
  }

  Future<double> getUnsettledTransactionsSum({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    List<int>? categoryId,
    String? transactionType,
  }) async {
    final sum = await _localDataService.getUnsettledTransactionSum(
        startDate: startDate,
        endDate: endDate,
        accountIds: accountIds,
        transactionType: transactionType,
        categoryId: categoryId);
    return sum;
  }

  Future<int> addTransaction(Transaction transaction) async {
    try {
      final transactionMap = transaction.toMap();
      transactionMap.remove('category');
      int id = await _localDataService.insertTransaction(transactionMap);
      notifyListeners();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _localDataService.deleteTransaction(transactionId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markTransactionAsSettled(Transaction tx) async {
    try {
      if (tx.id == null) throw Exception('Transaction id not found');
      await _localDataService.markTransactionAsSettled(tx.id!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<int, Map<String, dynamic>>> getUnsettledPerAccount(Transaction tx) async {
    try {
      if (tx.id == null) throw Exception('Transaction id not found');
      final rawList = await _localDataService.fetchUnsettledSumPerAccount();

      final Map<int, Map<String, dynamic>> resultMap = {
        for (var row in rawList)
          row['account_id'] as int: {
            'name': row['name'],
            'total_unsettled': row['total_unsettled'] as double,
          }
      };
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }
}
