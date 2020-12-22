import 'dart:io';

import 'package:file_manager/src/provider/file_manager_notifier.dart';
import 'package:global_repository/global_repository.dart';

class Config {
  Config._();
  // 使用前一定先初始化
  static Future<void> initConfig() async {
    packageName ??= await PlatformUtil.packageName;
    if (!Directory(frameworkPath).existsSync()) {
      Directory(frameworkPath).create(
        recursive: true,
      );
    }
  }

  static String packageName;
  static String appName = 'FileManager';
  static const String backupPath = 'YanTool/Backup';
  static String binPath = '/data/data/$packageName/files/usr/bin';
  static String filesPath = '/data/data/$packageName/files';
  static String dataPath = '$filesPath/$appName';
  static String aaptPath = '$filesPath/$appName/aapt';
  static String frameworkPath = dataPath + '/Framework';
  static FiMaPageNotifier fiMaPageNotifier;
}
