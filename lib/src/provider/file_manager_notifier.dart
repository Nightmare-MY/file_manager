import 'package:file_manager/src/io/file_entity.dart';
import 'package:flutter/material.dart';

enum ClipType {
  Cut,
  Copy,
}

class FiMaPageNotifier extends ChangeNotifier {
  // 工厂模式
  factory FiMaPageNotifier() => _getInstance();
  static FiMaPageNotifier _getInstance() {
    _instance ??= FiMaPageNotifier._internal();
    return _instance;
  }

  FiMaPageNotifier._internal() {}
  static FiMaPageNotifier _instance;
  List<FileEntity> checkNodes = <FileEntity>[];
  final List<String> _clipboard = <String>[];
  ClipType _clipType;
  ClipType get clipType => _clipType;
  List<String> get clipboard => _clipboard;
  void addCheck(FileEntity fileNode) {
    checkNodes.add(fileNode);
  }

  void removeCheck(FileEntity fileNode) {
    checkNodes.remove(fileNode);
  }

  void removeAllCheck() {
    checkNodes.clear();
    notifyListeners();
  }

  void setClipBoard(ClipType clipType, String path) {
    print('添加$path到剪切板');
    _clipType = clipType;
    if (!clipboard.contains(path)) {
      _clipboard.add(path);
    }
    notifyListeners();
  }

  void clearClipBoard() {
    _clipboard.clear();
    notifyListeners();
  }
}
