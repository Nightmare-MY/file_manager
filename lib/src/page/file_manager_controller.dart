import 'dart:io';

import 'observable.dart';

class FileManagerController with Observable {
  FileManagerController(this.dirPath);
  String dirPath;

  void setStatePathFile() {
    /// 在新建页面删除页面的时候会用到
    /// 页面初始打开会读取这个文件生成页面
    // if (Platform.isAndroid) {
    //   File('${Config.filesPath}/FileManager/History_Path').writeAsString(
    //     _dirPaths.join('\n'),
    //   );
    // }
  }
  void updatePath(String path) {
    dirPath = path;
    notifyListeners();
  }
}
