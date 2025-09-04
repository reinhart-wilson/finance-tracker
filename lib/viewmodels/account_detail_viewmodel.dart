import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction.dart';
import 'package:finance_tracker/repositories/account_repository.dart';
import 'package:finance_tracker/repositories/transaction_repository.dart';
import 'package:flutter/foundation.dart';

class AccountDetailViewmodel extends ChangeNotifier {
  AccountDetailViewmodel({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
  })  : _transactionRepository = transactionRepository,
        _accountRepository = accountRepository {
    _transactionRepository.addListener(() {
      _loadAccountTransactions();
    });
  }

  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;

  Account? _parentAccount;
  double? _parentAccountUnsettled;
  List<Transaction> _settledTransactions = [];
  List<Transaction> _unsettledTransactions = [];
  final Map<Account, double> _unsettledAmountByAccount = {};
  bool _isLoading = false;

  // Getters
  double? get parentAccountUnsettled => _parentAccountUnsettled;
  List<Transaction> get settledTransactions => _settledTransactions;
  List<Transaction> get unsettledTransactions => _unsettledTransactions;
  Map<Account, double> get unsettledAmountByAccount =>
      Map.unmodifiable(_unsettledAmountByAccount);
  bool get isLoading => _isLoading;

  // Sets the id of the account the user wants to see.
  // Call this method to load all necessary details.
  set parentAccount(Account parentAccount) {
    _parentAccount = parentAccount;
    _loadAccountTransactions();
  }

  // Settled transactions loaded are from current month only.
  Future<void> _loadAccountTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      final parentId = _parentAccount!.id!;

      // Get the sum of unsettled transactions until the end of the month
      _parentAccountUnsettled =
          await _transactionRepository.getUnsettledTransactionsSum(
        accountId: parentId,
        endDate: lastDayOfMonth,
      );

      // Adds child account and their unsettled transactions total
      final childAccountsList =
          await _accountRepository.getChildAccounts(parentId);
      for (final account in childAccountsList) {
        final unsettledAmount =
            await _transactionRepository.getUnsettledTransactionsSum(
          accountId: account.id,
          endDate: lastDayOfMonth,
        );
        _unsettledAmountByAccount[account] = unsettledAmount;
      }

      // Get transactions
      _settledTransactions =
          await _transactionRepository.getSettledTransactions(
        startDate: firstDayOfMonth,
        endDate: lastDayOfMonth,
        accountId: parentId,
      );

      _unsettledTransactions =
          await _transactionRepository.getUnsettledTransactions(
        endDate: lastDayOfMonth,
        accountId: parentId,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
