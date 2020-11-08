import 'dart:io';

import 'package:global_repository/global_repository.dart';
import 'package:flutter/material.dart';

// enum ThemeMode{
//   dark,
//   light,
//   followSystem,
// }
// 全局类里面有主题、用户信息、外部路径
class Global {
  // 工厂模式
  factory Global() => _getInstance();
  Global._internal() {
    environment = Map<String, String>.from(Platform.environment);
    if (Platform.isWindows) {
      // 因为windows环境路径的分割是不一样的
      environment['PATH'] += ';';
    } else if (Platform.isAndroid) {
      environment['PATH'] += ':/data/data/com.example.example/files';
    }
    themeFollowSystem = true;
  }
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  Map<String, String> environment;
  // 用户信息
  // 主题状态
  ThemeMode themeMode = ThemeMode.light;
  bool themeFollowSystem;
  String _documentsDir;
  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  static Future<void> initGlobal() async {
    instance._documentsDir ??=
        await PlatformUtil.workDirectory('com.nightmare.filemanager');
  }

  static String get documentsDir => instance._documentsDir;
}
