import 'package:finance_tracker/services/local_data_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late LocalDataService service;

  setUpAll(() {
    sqfliteFfiInit(); // init driver FFI
    databaseFactory = databaseFactoryFfi; // override default
  });

  setUp(() async {
    // pastikan DB fresh untuk tiap test
    final dbPath = await databaseFactory.getDatabasesPath();
    final path = p.join(dbPath, 'finance_tracker.db');
    if (await File(path).exists()) {
      await File(path).delete();
    }

    service = LocalDataService();
    await service.database; // trigger init
  });

  tearDown(() async {
    await service.close();
  });

  group('Account Storage Test', () {
    test('Summing unsettled per account', () async {
      // add account
      await service.insertAccount({
        'id': 1,
        'name': 'Cash',
        'balance': 0.0,
      });
      await service.insertAccount({
        'id': 2,
        'name': 'BCA',
        'balance': 0.0,
      });
      await service.insertAccount({
        'id': 3,
        'name': 'BCA 1',
        'balance': 0.0,
        'parent_id': 2
      });


      final now = DateTime.now();

      await service.insertTransaction({
        'title': 'Test Transaction',
        'amount': 50.0,
        'date': now.toIso8601String(),
        'account_id': 1,
      });

      await service.insertTransaction({
        'title': 'Test Transaction',
        'amount': 30.0,
        'date': now.toIso8601String(),
        'account_id': 1,
      });
      await service.insertTransaction({
        'title': 'Test Transaction',
        'amount': 15.0,
        'date': now.toIso8601String(),
        'settled_date': now.toIso8601String(),
        'account_id': 1,
      });
      await service.insertTransaction({
        'title': 'Test Transaction',
        'amount': 10.0,
        'date': now.toIso8601String(),
        'account_id': 2,
      });
      await service.insertTransaction({
        'title': 'Test Transaction',
        'amount': 15.0,
        'date': now.toIso8601String(),
        'account_id': 2,
        'settled_date': now.toIso8601String(),
      });
      await service.insertTransaction({
        'title': 'Test Transaction',
        'amount': 23.0,
        'date': now.toIso8601String(),
        'account_id': 3,
      });

      final result = await service.fetchUnsettledSumPerAccount();

debugPrint(result.toString());
      // expect(result[0]['total_unsettled'], 80.0);
      // expect(result[1]['total_unsettled'], 10.0);
    });
  });
}
