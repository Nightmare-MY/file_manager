import 'dart:io';
import 'package:file_manager/src/config/config.dart';
import 'package:file_manager/src/io/file.dart';
import 'package:file_manager/src/utils/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

class ApktoolDecodeAll extends StatefulWidget {
  const ApktoolDecodeAll({
    Key key,
    this.fileNode,
    this.cmd,
  }) : super(key: key);
  final NiFile fileNode;
  final String cmd;

  @override
  _ApktoolDecodeAllState createState() => _ApktoolDecodeAllState();
}

class _ApktoolDecodeAllState extends State<ApktoolDecodeAll> {
  final ScrollController _scrollController = ScrollController();
  String output = '';
  double height = 48;
  @override
  void initState() {
    super.initState();
    exec();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ApktoolDecodeAll oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    // print(maxScrollExtent);
    // print(_scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent);
    // print(_scrollController.position.viewportDimension + maxScrollExtent * 2);
    // print('刷新了');
    // print(_scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent);
    // height = _scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent;
    // dialogeventBus.fire(Height(_scrollController.position.viewportDimension +

    //     _scrollController.position.maxScrollExtent));
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> exec() async {
    //
    print('自动执行');
    NetworkManager.startServer();
    return;
    const MethodChannel _channel = MethodChannel('file_manager');
    final String logpath =
        '/data/data/${Config.packageName}/files/Apktool/apktool_pipe';
    print(logpath);
    File('${Config.binPath}/apktool').writeAsStringSync(
      '''
    mkfifo $logpath
            echo -n apktoolFunc "\$@"
            {
              cat $logpath
            } &
            while [ -p $logpath ]
            do {
              sleep 0.5
            }
            done
            exit''',
    );
    // return;
    await NiProcess.exec(
      'chmod 777 ${Config.binPath}/apktool\n'
      'chmod 777 ${Config.binPath}/baksmali\n'
      'chmod 777 ${Config.binPath}/smali\n',
    );

    NiProcess.exec(
      // 'apktool -advance',
      widget.cmd,
      getStderr: true,
      callback: (out) async {
        print('out->$out');
        if (out.startsWith(RegExp('apktoolFunc|baksmaliFunc|smaliFunc'))) {
          //域内都是apktool相关的方法
          // print('line===>$line');
          final List<String> args = out
              .replaceAll(
                  RegExp('apktoolFunc|baksmaliFunc|smaliFunc|exitCode'), '')
              .trim()
              .split(' ');
          print(args);
          // return;

          final String ress = await _channel.invokeMethod<String>(
            'logout',
            logpath,
          );
          print('设置成功--->$ress');
          final String result = await _channel.invokeMethod<String>(
            'apktool',
            args,
          );
          output += '完成';
          ProcessResult a = await Process.run('rm', ['-rf', logpath]);
          print(a.stderr);
          print(a.stdout);
          setState(() {});
          print('result->$result');
        } else {
          output += out.replaceAll('exitCode', '');
          setState(() {});
          print(_scrollController.position.viewportDimension +
              _scrollController.position.maxScrollExtent);
          Future.delayed(const Duration(milliseconds: 100), () {
            dialogeventBus.fire(
              Height(
                _scrollController.position.viewportDimension +
                    _scrollController.position.maxScrollExtent,
              ),
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Text(output.trim()),
    );
  }
}
