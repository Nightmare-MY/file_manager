import 'package:file_manager/src/provider/file_manager_notifier.dart';
import 'package:global_repository/global_repository.dart';

class Config {
  Config._();
  // 使用前一定先初始化
  static Future<void> initConfig() async {
    packageName ??= await PlatformUtil.packageName;
  }

  static String packageName;
  static const String backupPath = 'YanTool/Backup';
  static String binPath = '/data/data/$packageName/files/usr/bin';
  static String filesPath = '/data/data/$packageName/files';
  static String appName = 'YanTool';
  static String dataPath = '/data/data/$packageName';
  static FiMaPageNotifier fiMaPageNotifier;
}
