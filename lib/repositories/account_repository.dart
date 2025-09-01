import 'dart:async';

import 'package:finance_tracker/models/account.dart';
import 'package:finance_tracker/services/local_data_service.dart';
import 'package:finance_tracker/models/mappers/account_mapper.dart';

class AccountRepository {
  AccountRepository(this._localDataService);

  final LocalDataService _localDataService;

  Future<List<Account>> getAllAccounts() async {
    final accountMaps = await _localDataService.fetchAccounts();
    return accountMaps.map((accountMap) => accountMap.fromMap()).toList();
  } 

  Future<int> addAccount(Account account) async{
    try {
      int id = await _localDataService.insertAccount(account.toMap());
      return id;
    } catch (e){
      rethrow;
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try{
      await _localDataService.deleteAccount(accountId);
    } catch (e){
      rethrow;
    }
  }
}