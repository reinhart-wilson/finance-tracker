import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/models/transaction/transaction_category.dart';

class TransactionFilter {
  TransactionFilter({this.startDate, this.endDate, this.accounts,
      this.transactionType, this.categories, this.loadPreviouslyUnsettled = true, this.completion});

  DateTime? startDate;
  DateTime? endDate;
  List<Account>? accounts;
  String? transactionType; // 'credit', 'debit', atau null (semua)
  List<TransactionCategory>? categories;
  bool loadPreviouslyUnsettled = true;
  String? completion; // 'settled', 'unsettled', atau null
}
