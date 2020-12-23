import 'dart:io';

import 'package:file_manager/src/provider/file_manager_notifier.dart';
import 'package:global_repository/global_repository.dart';

class Config {
  Config._();
  // 使用前一定先初始化
  static Future<void> initConfig() async {
    await PlatformUtil.init();
    documentDir = PlatformUtil.documentsDir;
    packageName = PlatformUtil.packageName;
    if (!Directory(frameworkPath).existsSync()) {
      Directory(frameworkPath).create(
        recursive: true,
      );
    }
  }

  static String packageName;
  static String documentDir;
  static String appName = 'FileManager';
  static String binPath = PlatformUtil.getBinaryPath();
  static String filesPath = PlatformUtil.getDataPath();
  static String dataPath = PlatformUtil.getDataPath() + appName;
  static String aaptPath = '$dataPath/aapt';
  static String frameworkPath = dataPath + '/Framework';
  static Clipboards fiMaPageNotifier;
}
