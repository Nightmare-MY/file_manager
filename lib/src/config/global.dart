import 'package:event_bus/event_bus.dart';
import 'package:global_repository/global_repository.dart';

class Global {
  // 工厂模式
  factory Global() => _getInstance();
  Global._internal() {
    // TODO
  }
  // 用户信息
  // 主题状态
  static Global get instance => _getInstance();
  static Global _instance;

  String doucumentDir;
  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Future<void> initGlobal() async {
    doucumentDir = await PlatformUtil.getDocumentDirectory();
  }
}
