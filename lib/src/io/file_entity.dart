import 'directory.dart';
import 'file.dart';

abstract class FileEntity {
  //这个名字可能带有->/x/x的字符
  String path;
  //完整信息
  String fullInfo;
  //文件创建日期

  String accessed = '';
  //文件修改日期
  String modified = '';
  //如果是文件夹才有该属性，表示它包含的项目数
  String itemsNumber = '';
  // 节点的权限信息
  String mode = '';
  // 文件的大小，isFile为true才赋值该属性
  String size = '';
  String uid = '';
  String gid = '';
  String get nodeName => path.split(' -> ').first.split('/').last;
  bool get isFile => runtimeType == NiFile;
  bool get isDirectory => runtimeType == NiDirectory;
  static final List<String> imagetype = <String>['jpg', 'png']; //图片的所有扩展名
  static final List<String> textType = <String>[
    'smali',
    'txt',
    'xml',
    'py',
    'sh',
    'dart'
  ]; //文本的扩展名
  static bool isText(FileEntity fileNode) {
    final String type = fileNode.nodeName.replaceAll(RegExp('.*\\.'), '');
    return textType.contains(type);
  }

  static bool isImg(FileEntity fileNode) {
    // Directory();
    // File
    final String type = fileNode.nodeName.replaceAll(RegExp('.*\\.'), '');
    return imagetype.contains(type);
  }

  // 用在显示文件item的subtitle
  String get info => '$modified  $itemsNumber  $size  $mode';
}
