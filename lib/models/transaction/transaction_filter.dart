class TransactionFilter {
  TransactionFilter({this.startDate, this.endDate, this.accountId,
      this.transactionType, this.categoryId, this.loadPreviouslyUnsettled = true});

  DateTime? startDate;
  DateTime? endDate;
  int? accountId;
  String? transactionType; // 'credit', 'debit', atau null (semua)
  int? categoryId;
  bool loadPreviouslyUnsettled = true;
}
