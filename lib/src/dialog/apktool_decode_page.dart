import 'dart:io';

import 'package:file_manager/src/io/file.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class ApkToolDialog extends StatefulWidget {
  const ApkToolDialog({Key key, @required this.fileNode}) : super(key: key);
  final NiFile fileNode;

  @override
  _ApkToolDialogState createState() => _ApkToolDialogState(fileNode);
}

class _ApkToolDialogState extends State<ApkToolDialog> {
  _ApkToolDialogState(this._fileNode);
  final NiFile _fileNode;

  Widget apkToolItem(String title, void Function() onTap) {
    return Material(
      color: Colors.white,
      child: Ink(
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 46,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xff000000),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(_fileNode.nodeName),
        apkToolItem(
          '反编译全部',
          () {
            // Navigator.pop(context);
            // showCustomDialog<void>(
            //   height: 600.0,
            //   child: Niterm(
            //     showOnDialog: true,
            //     script: 'apktool  d ${widget.fileNode.path} '
            //         "-f -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src "
            //         '-p /data/data/com.nightmare/files/Apktool/Framework/',
            //   ),
            // );
          },
        ),
        apkToolItem('反编译dex', () {
          // Navigator.pop(context);
          // showCustomDialog<void>(
          //   isPadding: false,
          //   height: 600.0,
          //   child: Niterm(
          //     showOnDialog: true,
          //     script: 'apktool  d ${widget.fileNode.path} '
          //         "-f -r -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src "
          //         '-p /data/data/com.nightmare/files/Apktool/Framework/',
          //   ),
          // );
        }),
        apkToolItem('反编译res', () {
          // Navigator.pop(context);
          // showCustomDialog2<void>(
          //   isPadding: false,
          //   height: 600.0,
          //   child: Niterm(
          //     showOnDialog: true,
          //     script: 'apktool  d ${widget.fileNode.path} '
          //         "-f -s -o ${FileSystemEntity.parentOf(widget.fileNode.path)}/${widget.fileNode.nodeName.replaceAll(".apk", "")}_src "
          //         '-p /data/data/com.nightmare/files/Apktool/Framework/',
          //   ),
          // );
        }),
        apkToolItem('签名', () {}),
        apkToolItem('Zipalign', () {}),
        apkToolItem('解压出META-INF', () {}),
        apkToolItem('添加META-INF', () {}),
        apkToolItem('删除dex', () {}),
        apkToolItem('删除META-INF', () {}),
        apkToolItem('导入框架', () {
          //TODO
          // Niterm.exec(
          //     'echo apktool if ${_fileNode.path} -p /data/data/com.nightmare/files/Apktool/Framework');
        }),
      ],
    );
  }
}
