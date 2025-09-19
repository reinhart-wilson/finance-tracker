class TransactionsTable {
  // Table name
  static const String tableName = 'transactions';

  // Column names
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnAmount = 'amount';
  static const String columnDate = 'date';
  static const String columnDueDate = 'due_date';
  static const String columnSettledDate = 'settled_date';
  static const String columnAccountId = 'account_id';
  static const String columnTransactionCategoryId = 'transaction_category_id';

  // All column names in a list
  static const List<String> columns = [
    columnId,
    columnTitle,
    columnAmount,
    columnDate,
    columnDueDate,
    columnSettledDate,
    columnAccountId,
    columnTransactionCategoryId,
  ];

  /// Returns the SQL string to create the `transactions` table.
  static String toSql() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnDueDate TEXT,
        $columnSettledDate TEXT,
        $columnAccountId INTEGER NOT NULL,
        $columnTransactionCategoryId INTEGER
      )
    ''';
  }
}
