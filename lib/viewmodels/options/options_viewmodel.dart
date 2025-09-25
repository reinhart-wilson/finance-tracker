import 'dart:io';

import 'package:finance_tracker/services/file_service.dart';
import 'package:finance_tracker/services/local_data_service.dart';

class OptionsViewmodel {
  final LocalDataService _dbService;
  static const fileName = 'melekduit_bak.json';

  const OptionsViewmodel(this._dbService);

  Future<void> exportDb() async {
    final dbJsonString = await _dbService.convertTableToJson();
    await FileService.saveJsonToDownloads(dbJsonString, fileName);
  }

  Future<void> importDb(String dbJsonPath) async{
    final dbJsonString = await File(dbJsonPath).readAsString();
    await _dbService.importTableFromJson(dbJsonString);
  }
}
