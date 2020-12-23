import 'package:event_bus/event_bus.dart';

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

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Future<void> initGlobal() async {}
}
