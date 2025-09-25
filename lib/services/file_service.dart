import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart';

class FileService {
  static const downloadsPath = '/storage/emulated/0/Download';

  static Future<void> saveJsonToDownloads(String jsonString, String fileName) async {
    // Step 1: Check Android SDK version
    int? sdkInt;
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      sdkInt = androidInfo.version.sdkInt;

      // Step 2: Request permission only if needed (Android 8 or 9)
      if (sdkInt <= 28) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }
    }

    // Step 3: Write file to Downloads
    final file = File(join(downloadsPath, fileName));

    try {
      await file.writeAsString(jsonString);
      print('Exported to ${file.path}');
    } catch (e) {
      print('Failed to export: $e');
      throw Exception('Could not export file');
    }
  }
}
