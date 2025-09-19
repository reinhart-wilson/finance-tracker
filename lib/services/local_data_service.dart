import 'dart:async';
import 'package:finance_tracker/models/tables/transaction_categories_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDataService {
  // Singleton pattern
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;

  LocalDataService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // TODO: add FK Constraints

        // Create accounts table first (parent table)
        await db.execute('''
        CREATE TABLE accounts(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          balance REAL NOT NULL,
          parent_id INTEGER
        );
      ''');

        // Create transaction type table
        await db.execute('''
        CREATE TABLE transaction_categories(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT,
          color TEXT,
          default_account_id INTEGER
        );
      ''');

        // Create transactions table
        await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          due_date TEXT ,
          settled_date TEXT,
          account_id INTEGER NOT NULL,
          transaction_category_id INTEGER 
        );
      ''');
      },
    );
  }

  // ===========================================================================
  // Transaction-Related methods
  // ===========================================================================

  Future<double> getSettledTransactionSum({
    List<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType, // 'debit', 'credit', atau null
    List<int>? categoryId,
    DatabaseExecutor? txn,
  }) async {
    final db = txn ?? await database;

    // Start building the SQL and parameters
    String sql = 'SELECT SUM(amount) AS total FROM transactions t';
    List<String> conditions = [];
    List<dynamic> args = [];

    // Filter account
    if (accountIds != null && accountIds.isNotEmpty) {
      List<int> childrenAccountIds = [];
      for (final accountId in accountIds) {
        childrenAccountIds
            .addAll(await _getAccountIdsIncludingChildren(accountId, txn: txn));
      }
      accountIds.addAll(childrenAccountIds.toSet());
      final placeholders = List.filled(accountIds.length, '?').join(',');
      conditions.add('t.account_id IN ($placeholders)');
      args.addAll(accountIds);
    }
    // Hanya ambil transaksi yang sudah settled
    if (startDate != null && endDate != null) {
      conditions.add('t.settled_date BETWEEN ? AND ?');
      args.addAll([startDate.toIso8601String(), endDate.toIso8601String()]);
    } else if (startDate != null) {
      conditions.add('t.settled_date >= ?');
      args.add(startDate.toIso8601String());
    } else if (endDate != null) {
      conditions.add('t.settled_date <= ?');
      args.add(endDate.toIso8601String());
    } else {
      conditions.add('t.settled_date IS NOT NULL');
    }

    // Filter jenis transaksi
    if (transactionType != null && transactionType.isNotEmpty) {
      if (transactionType == 'debit') {
        conditions.add('t.amount > 0');
      } else if (transactionType == 'credit') {
        conditions.add('t.amount < 0');
      }
    }

    // Filter kategori
    if (categoryId != null && categoryId.isNotEmpty) {
      final placeholders = List.filled(categoryId.length, '?').join(',');
      conditions.add('t.transaction_category_id in ($placeholders)');
      args.addAll(categoryId);
    }

    // Build final SQL
    if (conditions.isNotEmpty) {
      sql += ' WHERE ${conditions.join(' AND ')}';
    }

    // Execute query
    final result = await db.rawQuery(sql, args);

    // Return hasil total (default 0 kalau null)
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  Future<double> getUnsettledTransactionSum({
    List<int>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType, // 'debit', 'credit', atau null
    List<int>? categoryId,
  }) async {
    final db = await database;

    // Start building the SQL and parameters
    String sql = 'SELECT SUM(amount) AS total FROM transactions t';
    List<String> conditions = [];
    List<dynamic> args = [];

    // Filter account
    if (accountIds != null && accountIds.isNotEmpty) {
      List<int> childrenAccountIds = [];
      for (final accountId in accountIds) {
        childrenAccountIds
            .addAll(await _getAccountIdsIncludingChildren(accountId));
      }
      accountIds.addAll(childrenAccountIds.toSet());
      final placeholders = List.filled(accountIds.length, '?').join(',');
      conditions.add('t.account_id IN ($placeholders)');
      args.addAll(accountIds);
    }

    // Hanya transaksi belum settle
    conditions.add('t.settled_date IS NULL');

    // Filter tanggal
    if (startDate != null) {
      conditions.add('t.due_date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      conditions.add('t.due_date <= ?');
      args.add(endDate.toIso8601String());
    }

    // Filter transaction type
    if (transactionType != null && transactionType.isNotEmpty) {
      if (transactionType == 'debit') {
        conditions.add('t.amount < 0');
      } else if (transactionType == 'credit') {
        conditions.add('t.amount > 0');
      }
      // kalau null atau 'both', tidak ditambah filter
    }

    // Filter category
    if (categoryId != null && categoryId.isNotEmpty) {
      final placeholders = List.filled(categoryId.length, '?').join(',');
      conditions.add('t.transaction_category_id in ($placeholders)');
      args.addAll(categoryId);
    }

    // Append WHERE clause if needed
    if (conditions.isNotEmpty) {
      sql += ' WHERE ${conditions.join(' AND ')}';
    }

    // Execute the query
    final result = await db.rawQuery(sql, args);

    // Parse and return the total
    return ((result.first['total'] ?? 0) as num).toDouble();
  }

  /// Internal method to update balances of both main and sub accounts
  /// Used when adding or removing transactions
  Future<void> _updateAccountBalances(
      DatabaseExecutor txn, int accountId, double amount) async {
    // Step 1: Update child account balance
    final updated = await txn.rawUpdate(
      '''
      UPDATE accounts
      SET balance = balance + ?
      WHERE id = ?
      ''',
      [amount, accountId],
    );

    if (updated == 0) {
      throw Exception("Failed to update account balance");
    }

    // Step 2: If it's a sub-account, also update the parent
    final parent = await txn.rawQuery(
      'SELECT parent_id FROM accounts WHERE id = ?',
      [accountId],
    );

    if (parent.isNotEmpty && parent.first['parent_id'] != null) {
      final parentId = parent.first['parent_id'];

      final updatedParent = await txn.rawUpdate(
        '''
      UPDATE accounts
      SET balance = balance + ?
      WHERE id = ?
      ''',
        [amount, parentId],
      );

      if (updatedParent == 0) {
        throw Exception("Failed to update parent account balance");
      }
    }
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT sum(balance) AS total FROM accounts WHERE parent_id IS NULL');
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double; // SUM() often returns a double
    }
    return 0;
  }

  /// Inserts a transaction and updates account balances if settled
  ///
  /// The [transaction] map must contain keys:
  /// - title [String]
  /// - amount [double] (positive for income, negative for expense)
  /// - date [String] (ISO 8601 format), which is the transaction creation date
  /// - due_date [String?] (ISO 8601 format), nullable, for scheduled transactions
  /// - settled_date [String?] (ISO 8601 format), nullable, if the transaction is settled
  /// - account_id [int], the associated account ID
  ///
  /// Transacation id is auto-generated.
  ///
  /// Returns the inserted transaction's row ID in [int]
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;

    // kembalikan int (rowid)
    return await db.transaction<int>((txn) async {
      // Step 1: Insert the transaction
      final rowId = await txn.insert(
        'transactions',
        transaction,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Step 2: Update balances only if settled
      if (transaction['settled_date'] != null) {
        final accountId = transaction['account_id'] as int;
        final amount = transaction['amount'] as double;
        await _updateAccountBalances(txn, accountId, amount);
      }

      // hasil dari closure transaction -> jadi return value dari db.transaction
      return rowId;
    });
  }

  /// Deletes a transaction and updates account balances if settled
  Future<void> deleteTransaction(int transactionId) async {
    final db = await database;

    db.transaction((txn) async {
      // Fetch the transaction details first
      final transactionList = await txn.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );
      final targetTransaction =
          transactionList.isNotEmpty ? transactionList.first : null;
      if (targetTransaction == null) {
        throw Exception("Transaction not found");
      }

      /// Step 1: Delete transaction from transaction table
      final response = await txn.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );
      if (response < 0) throw Exception("Failed to delete transaction");

      // Step 2: Update balances if transaction has been settled (since it modified the balance when inserted)
      if (targetTransaction['settled_date'] == null) return;
      final accountId = targetTransaction['account_id'] as int;
      final amount = targetTransaction['amount'] as double;
      await _updateAccountBalances(txn, accountId, -amount);
    });
  }

  Future<List<Map<String, dynamic>>> fetchSettledTransactions({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    String? transactionType, // 'credit', 'debit', atau null (semua)
    List<int>? categoryId,
  }) async {
    final db = await database;

    // Step 1: Ambil id akun + subakun
    if (accountIds != null && accountIds.isNotEmpty) {
      List<int> childrenAccountIds = [];
      for (final accountId in accountIds) {
        childrenAccountIds
            .addAll(await _getAccountIdsIncludingChildren(accountId));
      }
      accountIds.addAll(childrenAccountIds.toSet());
    }

    // Step 2: Bangun where clause
    String where = 't.settled_date IS NOT NULL';
    List<Object?> whereArgs = [];

    if (startDate != null && endDate != null) {
      where = 't.settled_date BETWEEN ? AND ?';
      whereArgs.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    } else if (startDate != null) {
      where = 't.settled_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    } else if (endDate != null) {
      where = 't.settled_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    if (accountIds != null && accountIds.isNotEmpty) {
      final placeholders = List.filled(accountIds.length, '?').join(',');
      where = '$where AND t.account_id IN ($placeholders)';
      whereArgs.addAll(accountIds);
    }

    if (transactionType != null && transactionType.isNotEmpty) {
      if (transactionType == 'debit') {
        where = '$where AND t.amount > 0';
      } else if (transactionType == 'credit') {
        where = '$where AND t.amount < 0';
      }
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      final placeholders = List.filled(categoryId.length, '?').join(',');
      where = '$where AND t.transaction_category_id in ($placeholders)';
      whereArgs.addAll(categoryId);
    }

    // Step 3: Query dengan LEFT OUTER JOIN
    final result = await db.rawQuery('''
      SELECT 
        t.*, 
        c.name AS category_name, 
        c.color AS category_color
      FROM transactions t
      LEFT OUTER JOIN transaction_categories c 
        ON t.transaction_category_id = c.id
      WHERE $where
      ORDER BY t.date DESC
  ''', whereArgs);

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchUnsettledTransactions({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? accountIds,
    String? transactionType, // 'credit', 'debit', atau null (semua)
    List<int>? categoryId,
  }) async {
    final db = await database;

    // Step 1: Ambil id akun + subakun
    if (accountIds != null && accountIds.isNotEmpty) {
      List<int> childrenAccountIds = [];
      for (final accountId in accountIds) {
        childrenAccountIds
            .addAll(await _getAccountIdsIncludingChildren(accountId));
      }
      accountIds.addAll(childrenAccountIds.toSet());
    }

    // Step 2: Bangun where clause
    String where = 't.due_date IS NOT NULL AND t.settled_date IS NULL';
    List<Object?> whereArgs = [];

    if (startDate != null && endDate != null) {
      where += ' AND t.due_date BETWEEN ? AND ?';
      whereArgs.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    } else if (startDate != null) {
      where += ' AND t.due_date >= ?';
      whereArgs.add(startDate.toIso8601String());
    } else if (endDate != null) {
      where += ' AND t.due_date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    if (accountIds != null && accountIds.isNotEmpty) {
      final placeholders = List.filled(accountIds.length, '?').join(',');
      where += ' AND t.account_id IN ($placeholders)';
      whereArgs.addAll(accountIds);
    }

    if (transactionType != null && transactionType.isNotEmpty) {
      if (transactionType == 'debit') {
        where = '$where AND t.amount > 0';
      } else if (transactionType == 'credit') {
        where = '$where AND t.amount < 0';
      }
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      final placeholders = List.filled(categoryId.length, '?').join(',');
      where = '$where AND t.transaction_category_id in ($placeholders)';
      whereArgs.addAll(categoryId);
    }

    // Step 3: Query dengan JOIN
    final result = await db.rawQuery('''
      SELECT 
        t.*, 
        c.name AS category_name, 
        c.color AS category_color
      FROM transactions t
      LEFT OUTER JOIN transaction_categories c 
        ON t.transaction_category_id = c.id
      WHERE $where
      ORDER BY t.due_date DESC
  ''', whereArgs);

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchUnsettledSumPerAccount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        t.account_id,
        a.name,
        SUM(amount) AS total_unsettled
      FROM 
        transactions t
        JOIN accounts a
        ON a.id = t.account_id
      WHERE settled_date IS NULL
      GROUP BY account_id, name
    ''');
    return result;
  }

  Future<Map<String, dynamic>> fetchSingleTransaction(int transactionId,
      {DatabaseExecutor? txn}) async {
    final db = txn ?? await database;

    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    return result.first;
  }

  // Future<void> updateBalance(int accountId, double balance, {Transaction? txn}) async {
  //   final db = txn?? await database;

  //   await db.rawUpdate(
  //     '''
  //   UPDATE accounts
  //   SET balance = balance + ?
  //   WHERE id = ? OR parent_id = ?
  //   ''',
  //     [balance, accountId, accountId],
  //   );
  // }

  /// Helper to get account IDs including sub-accounts
  Future<List<int>> _getAccountIdsIncludingChildren(int accountId,
      {DatabaseExecutor? txn}) async {
    final db = txn ?? await database;

    // Ambil id sendiri + subakun (parent_id = accountId)
    final rows = await db.query(
      'accounts',
      where: 'id = ? OR parent_id = ?',
      whereArgs: [accountId, accountId],
    );

    return rows.map((row) => row['id'] as int).toList();
  }

  /// Marks transaction as settled and updates both the account's and
  /// it's parent(if any)'s balance
  Future<void> markTransactionAsSettled(int transactionId) async {
    try {
      final db = await database;
      db.transaction((txn) async {
        var transactionData =
            await fetchSingleTransaction(transactionId, txn: txn);

        await _updateAccountBalances(
            txn, transactionData["account_id"], transactionData["amount"]);

        await txn.update(
            'transactions', {'settled_date': DateTime.now().toIso8601String()},
            where: 'id = ?', whereArgs: [transactionId]);
      });
    } catch (e) {
      rethrow;
    }
  }
  // ===========================================================================
  // Transaction Category-Related Methods
  // ===========================================================================

  /// Inserts a transaction category
  ///
  /// The [category] map must contain keys:
  /// - name [String]
  /// - type [String] (e.g., 'income', 'expense')
  /// - color [String?] (nullable, hex color code)
  /// - default_account_id [int?] (nullable, default account to be deducted for this category)
  ///
  /// Category id is auto-generated.
  ///
  /// Returns the inserted category's row ID in [int]
  Future<int> insertTransactionCategory(Map<String, dynamic> category) async {
    final db = await database;

    final response = await db.insert(
      'transaction_categories',
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (response < 0) throw Exception("Failed to add category.");
    return response;
  }

  /// Deletes a transaction category, and updates the associated transactions'
  /// category id to null
  Future<void> deleteTransactionCategory(int categoryId) async {
    final db = await database;

    db.transaction((txn) async {
      /// Step 1: Set category id from transaction table
      await txn.update(
        'transactions',
        {'category_id': null}, // set null
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );

      /// Step 2: Delete corresponding categories
      final response = await txn.delete(
        'transaction_categories',
        where: 'id = ?',
        whereArgs: [categoryId],
      );
      if (response < 0) throw Exception("Failed to delete transaction");
    });
  }

  Future<int> updateTransactionCategory(Map<String, dynamic> category) async {
    final db = await database;

    return await db.update(TransactionCategoriesTable.tableName, category,
        where: "${TransactionCategoriesTable.columnId} = ?",
        whereArgs: [category[TransactionCategoriesTable.columnId]]);
  }

  /// Fetches all transaction categories, sorted by name
  Future<List<Map<String, dynamic>>> fetchAllTransactionCategories() async {
    final db = await database;

    return await db.query(
      'transaction_categories',
      orderBy: 'name ASC', // sort by name
    );
  }

  Future<Map<String, dynamic>> fetchSingleTransactionCategory(
      String categoryId) async {
    final db = await database;

    final result = await db.query(
      'transaction_categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );

    return result.first;
  }

  // ===========================================================================
  // Account-Related Methods
  // ===========================================================================

  /// Inserts an account
  ///
  /// The [account] map must contain keys:
  /// - name [String]
  /// - balance [double] (initial balance)
  /// - parent_id [int?] (nullable, if it's a sub-account)
  ///
  /// Account id is auto-generated.
  ///
  /// Returns the inserted account's row ID in [int]
  Future<int> insertAccount(Map<String, dynamic> account) async {
    final db = await database;

    final response = await db.insert(
      'accounts',
      account,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (response < 0) throw Exception("Failed to add account");
    return response;
  }

  /// TODO: Optionally migrate all transactions associated with the account to main account if any
  /// else, delete all transactions associated with the account
  Future<void> deleteAccount(int accountId) async {
    final db = await database;

    db.transaction((txn) async {
      // Step 1: Update balances from both sub and main (if any) account
      final amount =
          await getSettledTransactionSum(accountIds: [accountId], txn: txn);
      await _updateAccountBalances(txn, accountId, amount);

      /// Step 2: Delete transaction from transaction table
      await txn.delete(
        'transactions',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      /// Step 3: Delete account
      final accDeleteResponse = await txn.delete(
        'accounts',
        where: 'id = ?',
        whereArgs: [accountId],
      );
      if (accDeleteResponse == 0) {
        throw Exception("Failed to delete account");
      }
    });
  }

  /// Fetches all accounts, optionally filtering by [parentId]
  Future<List<Map<String, dynamic>>> fetchAccounts({int? parentId}) async {
    final db = await database;

    // Build where clause and arguments dynamically
    String? where;
    List<Object?>? whereArgs;

    if (parentId != null) {
      where = 'parent_id = ?';
      whereArgs = [parentId];
    }

    return await db.query(
      'accounts',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'name DESC', // sort by name
    );
  }

  /// Returns a map containing a single account's data with requested ID
  Future<Map<String, dynamic>> fetchSingleAccount(int accountId) async {
    final db = await database;

    final result = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );

    return result.first;
  }

  // ===========================================================================

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
