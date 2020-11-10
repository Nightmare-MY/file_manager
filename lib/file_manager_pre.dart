
import 'dart:async';

import 'package:flutter/services.dart';

class FileManager {
  static const MethodChannel _channel =
      const MethodChannel('file_manager');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
