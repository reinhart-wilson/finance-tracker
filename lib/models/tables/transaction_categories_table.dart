class TransactionCategoriesTable {
  // Table name
  static const String tableName = 'transaction_categories';

  // Column names
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnIcon = 'icon';
  static const String columnColor = 'color';
  static const String columnDefaultAccountId = 'default_account_id';

  // All column names in a list
  static const List<String> columns = [
    columnId,
    columnName,
    columnIcon,
    columnColor,
    columnDefaultAccountId,
  ];

  /// Returns the SQL string to create the `transaction_categories` table.
  static String toSql() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnIcon TEXT,
        $columnColor TEXT,
        $columnDefaultAccountId INTEGER
      )
    ''';
  }
}
