import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:file_manager/src/config/config.dart';
import 'package:flutter/material.dart';

class VideoPlay extends StatefulWidget {
  const VideoPlay({Key key, this.filePath}) : super(key: key);
  final String filePath;

  @override
  _VideoPlayState createState() => _VideoPlayState();
}

List<int> tmp = <int>[];

Future<void> runTimer(SendPort sendPort) async {
  // final String libPath = FileSystemEntity.parentOf(Platform.resolvedExecutable) +
  //     '/lib/libnative-lib.so';
  // print(libPath);
  // final ReceivePort receivePort = ReceivePort();
  // sendPort.send(receivePort.sendPort);
  // final String path = await receivePort.first as String;
  // final DynamicLibrary dylib = DynamicLibrary.open(libPath);
  // final Pointer<NativeFunction> bofang = dylib.lookup<NativeFunction<videoStreamPlay>>('videoStreamPlay');
  // final VideoStreamPlay videoStrmPlay = bofang.asFunction<VideoStreamPlay>();
  // EnvirPath.filesPath =
  //     "${FileSystemEntity.parentOf(Platform.resolvedExecutable)}/data";
  // videoStrmPlay(Utf8.toUtf8(path));
  // ServerSocket.bind('127.0.0.1', 8887) //绑定端口4041，根据需要自行修改，建议用动态，防止端口占用
  //     .then((serverSocket) {
  //   // port.send("启动的回调");

  //   serverSocket.listen((socket) {
  //     var tmpData = "";
  //     print(socket);
  //     socket.listen((s) {
  //       port.send(s);
  //     });
  //   });
  // });
  // receivePort.listen((message) {
  //   print("来自主islate的消息===>$message");
  // });
}

class _VideoPlayState extends State<VideoPlay> {
  Uint8List uint8list;
  Isolate isolate;
  int index = 0;
  bool isStart = false;
  @override
  void initState() {
    super.initState();
    // Future<void>.delayed(const Duration(milliseconds: 10), () async {
    //   while (true) {
    //     ImageCache().clear();
    //     // print("判断$index");
    //     if (await File('${EnvirPath.filesPath}/Frame/${index + 1}').exists()) {
    //       File("${EnvirPath.filesPath}/Frame/$index\.jpg").delete();
    //       File("${EnvirPath.filesPath}/Frame/$index").delete();
    //       index++;
    //     }
    //     if (await File("${EnvirPath.filesPath}/Frame/$index").exists()) {
    //       isStart = true;
    //       // uint8list=await File("/sdcard/MToolkit/Frame/$index").readAsBytes();
    //       await precacheImage(
    //           FileImage(File("${EnvirPath.filesPath}/Frame/$index.jpg")),
    //           context);
    //       // }
    //       setState(() {});
    //     }
    //     await Future<void>.delayed(Duration(milliseconds: 20));
    //   }
    // });
    // final String libPath = FileSystemEntity.parentOf(Platform.resolvedExecutable) +
    //     '/lib/libnative-lib.so';
    // final DynamicLibrary dylib = DynamicLibrary.open(libPath);
    // final Pointer<NativeFunction> pointer =
    //     dylib.lookup<NativeFunction<init_dart_print>>("init_dart_print");
    // final InitDartPrint initDartPrint = pointer.asFunction<InitDartPrint>();
    // Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> a =
    //     Pointer.fromFunction(dartPrintFunc);
    // initDartPrint(a);
    // init();
  }

  Future<void> init() async {
    // index = 0;
    // setState(() {});
    // final receive = ReceivePort();
    // isolate = await Isolate.spawn(runTimer, receive.sendPort);
    // var sendPort = await receive.first;
    // print("isolate启动");
    // sendPort.send(widget.filePath);
    // receive.listen((data) {
    //   print("来自子isolate的消息====>$data");
    //   setState(() {});
    // });
  }
  @override
  void dispose() {
    isolate.kill(priority: Isolate.immediate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isStart
          ? Image.file(File('${Config.filesPath}/Frame/$index.jpg'))
          : const SizedBox(
              child: Text('data'),
            ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   index = 0;
      //   setState(() {});
      //   final receive = ReceivePort();
      //   isolate = await Isolate.spawn(runTimer, receive.sendPort);
      //   // print(DateTime.now().toString() + " Socket服务启动，正在监听端口 4041...");
      //   print("isolate启动");
      //   receive.listen((data) {
      //     setState(() {});
      //   });
      // }),
    );
  }
}
