import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction.dart';
import 'package:finance_tracker/models/transaction/transaction_filter.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:finance_tracker/repositories/transaction_repository.dart';
import 'package:finance_tracker/utils/date_calculator.dart';
import 'package:flutter/foundation.dart';

class AccountDetailViewmodel extends ChangeNotifier {
  AccountDetailViewmodel({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
  })  : _transactionRepository = transactionRepository,
        _accountRepository = accountRepository {
    _transactionRepository.addListener(() {
      _loadSettledTransactions(
          startDate: _settledStartDate, endDate: _settledEndDate);
      _loadUnsettledTransactions(
          startDate: _dueStartDate, endDate: _dueEndDate);
    });
  }

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;

  Account? _parentAccount;
  double? _parentAccountUnsettled;
  double? _parentAccountSettled;
  List<Transaction> _settledTransactions = [];
  List<Transaction> _unsettledTransactions = [];
  final Map<int, double> _unsettledAmountByAccountId = {};
  bool _isLoading = true;
  DateTime? _settledStartDate;
  DateTime? _settledEndDate;
  DateTime? _dueStartDate;
  DateTime? _dueEndDate;

  List<Account> _childAccountsList = [];

  // Getters
  Account? get parentAccount => _parentAccount;
  double? get parentAccountUnsettled => _parentAccountUnsettled;
  double? get parentAccountSettled => _parentAccountSettled;
  List<Transaction> get settledTransactions => _settledTransactions;
  List<Transaction> get unsettledTransactions => _unsettledTransactions;
  Map<int, double> get unsettledAmountByAccountId =>
      Map.unmodifiable(_unsettledAmountByAccountId);
  List<Account> get childAccountList => _childAccountsList;
  bool get isLoading => _isLoading;

  // Sets the id of the account the user wants to see.
  // Call this method to load all necessary details.
  Future<void> loadAccountInfo(Account parentAccount) async {
    _isLoading = true;
    notifyListeners();
    final now = DateTime.now();
    _dueEndDate = _settledEndDate = getLastDateOfMonth();
    _settledStartDate = getFirstDateOfMonth();
    try {
      _parentAccount = (parentAccount);
      await _loadSettledTransactions(
          startDate: _settledStartDate, endDate: _settledEndDate);
      await _loadUnsettledTransactions(endDate: _dueEndDate);
    } catch (e) {
      rethrow;
    }
    _isLoading = false;
    notifyListeners();
  }

  void applyUnsettledFilter({DateTime? startDate, DateTime? endDate}) async {
    _dueStartDate = startDate;
    _dueEndDate = endDate;
    try {
      await _loadUnsettledTransactions(endDate: endDate, startDate: startDate);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
    // finally {
    //   _isLoading = false;
    //   notifyListeners();
    // }
  }

  // Settled transactions loaded are from current month only.
  Future<void> _loadSettledTransactions(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      _parentAccount =
          await _accountRepository.getSingleAccount(_parentAccount!);
      final parentId = _parentAccount!.id!;

      // Get the sum of settled transactions until the end of the month
      _parentAccountSettled = await _transactionRepository
          .getSettledTransactionsSum(
              accountIds: [parentId], endDate: endDate, startDate: startDate);

      // Get transactions
      _settledTransactions =
          await _transactionRepository.getSettledTransactions(
        startDate: startDate,
        endDate: endDate,
        accountIds: [parentId],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadUnsettledTransactions(
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      final parentId = _parentAccount!.id!;

      // Get the sum of parent's unsettled transactions
      _parentAccountUnsettled =
          await _transactionRepository.getUnsettledTransactionsSum(
        accountIds: [parentId],
        startDate: startDate,
        endDate: endDate,
      );

      // Adds child account and their unsettled transactions total
      _childAccountsList = await _accountRepository.getChildAccounts(parentId);
      for (final account in _childAccountsList) {
        final unsettledAmount =
            await _transactionRepository.getUnsettledTransactionsSum(
          accountIds: [account.id!],
          startDate: startDate,
          endDate: endDate,
        );
        _unsettledAmountByAccountId[account.id!] = unsettledAmount;
      }

      _unsettledTransactions =
          await _transactionRepository.getUnsettledTransactions(
        startDate: startDate,
        endDate: endDate,
        accountIds: [parentId],
      );
    } catch (e) {
      rethrow;
    }
  }

  void applySettledFilter({DateTime? startDate, DateTime? endDate}) async {
    _settledStartDate = startDate;
    _settledEndDate = endDate;
    try {
      await _loadSettledTransactions(endDate: endDate, startDate: startDate);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  String accountNameOfId(int accountId) {
    final account = accountId == _parentAccount?.id
        ? _parentAccount!
        : _childAccountsList.where((a) => a.id == accountId).firstOrNull;
    return account?.name ?? 'Unknown';
  }

  Future<void> deleteTransaction(Transaction tx) async {
    try {
      if (tx.id == null) throw Exception('Transaction no found');
      await _transactionRepository.deleteTransaction(tx.id!);
      await _loadUnsettledTransactions(
          startDate: _dueStartDate, endDate: _dueEndDate);
      await _loadSettledTransactions(
          startDate: _settledStartDate, endDate: _settledEndDate);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markTransactionAsSettled(Transaction tx) async {
    try {
      await _transactionRepository.markTransactionAsSettled(tx);
      await _loadUnsettledTransactions(
          startDate: _dueStartDate, endDate: _dueEndDate);
      await _loadSettledTransactions(
          startDate: _settledStartDate, endDate: _settledEndDate);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
