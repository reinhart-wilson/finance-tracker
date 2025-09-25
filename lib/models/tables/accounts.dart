class AccountsTable {
  // Table name
  static const String tableName = 'accounts';

  // Column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnBalance = 'balance';
  static const String columnParentId = 'parent_id';

  // All column names in a list
  static const List<String> columns = [
    columnId,
    columnName,
    columnBalance,
    columnParentId,
  ];

  /// Returns the SQL string to create the `transaction_categories` table.
  static String toSql() {
    return '''
        CREATE TABLE accounts(
          $columnId INTEGER PRIMARY KEY,
          $columnName TEXT NOT NULL,
          $columnBalance REAL NOT NULL,
          $columnParentId INTEGER
        );
      ''';
  }
}
