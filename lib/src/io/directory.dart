import 'dart:io';

import 'package:global_repository/global_repository.dart';

import 'file.dart';
import 'file_entity.dart';

// 这套代码写得很烂，欢迎帮忙优化
// 佛祖保佑能正常使用

class NiDirectory extends FileEntity {
  NiDirectory(String _path) {
    path = _path;
  }
  NiDirectory.initWithFullInfo(String _path, String _fullInfo) {
    path = _path;
    fullInfo = _fullInfo;
  }
  // final String _path;
  // @override
  // String get path => _path;
  // @override
  // String get fullInfo => _fullInfo;
  // String _fullInfo;
  //如果是文件夹才有该属性，表示它包含的项目数
  // String itemsNumber = '';
  Future<List<FileEntity>> listAndSortForWin() async {
    final List<FileEntity> _fileNodes = <FileEntity>[];
    _fileNodes.add(NiDirectory(path + Platform.pathSeparator + '..'));
    for (final FileSystemEntity fileSystemEntity
        in Directory(path).listSync()) {
      if (fileSystemEntity is Directory) {
        _fileNodes.add(NiDirectory(fileSystemEntity.path));
      } else {
        _fileNodes.add(NiFile(fileSystemEntity.path, ''));
      }
    }
    return _fileNodes;
  }

  Future<List<FileEntity>> listAndSort({
    bool verbose = true,
  }) async {
    // if (Platform.isWindows) {
    //   return await listAndSortForWin();
    // }
    final List<FileEntity> _fileNodes = <FileEntity>[];

    // --------------------------------------
    String lsPath;
    if (Platform.isAndroid)
      lsPath = '/system/bin/ls';
    else if (Platform.isWindows) {
      lsPath = 'ls';
    } else
      lsPath = 'ls';
    // --------------------------------------
    int _startIndex;
    List<String> _fullmessage = <String>[];
    path = path.replaceAll('//', '/');
    // print('刷新的路径=====>>$path');
    final String lsOut = await NiProcess.exec(
      "$lsPath -aog '${PlatformUtil.getUnixPath(path)}'\n",
    );
    if (verbose) {
      print('lsOut===>$lsOut');
    }
    // 删除第一行 -> total xxx
    _fullmessage = lsOut.split('\n')..removeAt(0);
    // ------------------------------------------------------------------------
    // ------------------------- 不要动这段代码，阿弥陀佛。-------------------------
    // linkFileNode 是当前文件节点有符号链接的情况。
    String linkFileNode = '';
    for (int i = 0; i < _fullmessage.length; i++) {
      if (_fullmessage[i].startsWith('l')) {
        //说明这个节点是符号链接
        if (_fullmessage[i].split(' -> ').last.startsWith('/')) {
          //首先以 -> 符号分割开，last拿到的是该节点链接到的那个元素
          //如果这个元素不是以/开始，则该符号链接使用的是相对链接
          linkFileNode += _fullmessage[i].split(' -> ').last + '\n';
        } else {
          linkFileNode += '$path/${_fullmessage[i].split(' -> ').last}\n';
        }
      }
    }
    if (verbose) {
      print('linkFileNode\n>>>>>>>>>\n$linkFileNode\n<<<<<<<<<');
    }
    //
    if (linkFileNode.isNotEmpty) {
      // 当当前文件夹存在包含符号链接的节点时
      //-g取消打印owner  -0取消打印group   -L不跟随符号链接，会指向整个符号链接最后指向的那个
      final String lsOut = await NiProcess.exec(
        "echo '$linkFileNode'|xargs $lsPath -ALdog\n",
      );
      final List<String> linkFileNodes =
          lsOut.replaceAll('//', '/').split('\n');

      if (verbose) {
        print('====>$linkFileNodes');
      }
      // 文件名到文件类型的 map
      // 例如 tmp:d
      // 类型是tag，'d'->文件夹，'l'->符号链接，'-'->普通文件
      final Map<String, String> map = <String, String>{};
      for (final String str in linkFileNodes) {
        // print(str);
        final String key = PlatformUtil.getFileName(
          str.replaceAll(RegExp('.*[0-9] '), ''),
        );
        map[key] = str.substring(0, 1);
      }
      if (verbose) {
        // print('====>$map');
      }
      for (int i = 0; i < _fullmessage.length; i++) {
        final String linkFromFile = _fullmessage[i].split(' -> ').last;

        if (verbose) {
          print('linkFromFile====>$linkFromFile');
        }
        if (_fullmessage[i].trim().startsWith('l') &&
            map.keys.contains(linkFromFile)) {
          _fullmessage[i] = _fullmessage[i].replaceAll(
              RegExp('^l'), map[_fullmessage[i].split(' -> ').last]);
          // f.remove(f.first);r
        }
      }
    }
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------

    if (verbose) {
      print(_fullmessage);
    }
    _fullmessage.removeWhere((String element) {
      //查找 -> ' .' 这个所在的行数
      return element.endsWith(' .');
    });
    final int currentIndex = _fullmessage.indexWhere((String element) {
      //查找 -> ' ..' 这个所在的行数
      return element.endsWith(' ..');
    });
    if (currentIndex == -1) {
      _fileNodes.add(NiDirectory('..'));
    }
    if (verbose) {
      print('currentIndex-->$currentIndex');
    }
    // ls 命令输出有空格上的对齐，不能用 list.split 然后以多个空格分开的方式来解析数据
    // 因为有的文件(夹)存在空格
    print(_fullmessage);
    if (_fullmessage.isNotEmpty) {
      _startIndex = _fullmessage.first.indexOf(
        RegExp(':[0-9][0-9] '),
      ); //获取文件名开始的地址
      _startIndex += 4;
      if (verbose) {
        print('startIndex===>>>$_startIndex');
      }
      if (path == '/') {
        //如果当前路径已经是/就不需要再加一个/了
        for (int i = 0; i < _fullmessage.length; i++) {
          FileEntity fileEntity;
          if (_fullmessage[i].startsWith(RegExp('-|l'))) {
            fileEntity = NiFile(
                path + _fullmessage[i].substring(_startIndex), _fullmessage[i]);
          } else {
            fileEntity = NiDirectory.initWithFullInfo(
                path + _fullmessage[i].substring(_startIndex), _fullmessage[i]);
          }
          _fileNodes.add(fileEntity);
        }
      } else {
        for (int i = 0; i < _fullmessage.length; i++) {
          FileEntity fileEntity;
          if (_fullmessage[i].startsWith(RegExp('-|l'))) {
            fileEntity = NiFile(
              '$path/' + _fullmessage[i].substring(_startIndex),
              _fullmessage[i],
            );
          } else {
            fileEntity = NiDirectory.initWithFullInfo(
              '$path/' + _fullmessage[i].substring(_startIndex),
              _fullmessage[i],
            );
          }
          _fileNodes.add(fileEntity);
        }
      }
    }

    _fileNodes.sort((FileEntity a, FileEntity b) => fileNodeCompare(a, b));
    return _fileNodes;
  }

  /* */
//文件节点的比较，文件夹在上面
  int fileNodeCompare(FileEntity a, FileEntity b) {
    //在遵循文件夹在上的条件下且按文件名排序
    if (a.isFile && !b.isFile) {
      return 1;
    }
    if (!a.isFile && b.isFile) {
      return -1;
    }
    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  }
}
