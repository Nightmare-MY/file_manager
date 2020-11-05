import 'package:custom_process/custom_process.dart';
import 'package:flutter/material.dart';

import '../file_manager.dart';

class AddFileNode extends StatelessWidget {
  const AddFileNode({Key key, this.isAddFile, this.currentPath})
      : super(key: key);
  final bool isAddFile;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();

    return Column(
      children: <Widget>[
        Text(
          '请输入要创建的文件${isAddFile ? '' : '夹'}名称',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextField(
          controller: textEditingController,
          decoration:
              const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  // Navigator.pop(globalContext);
                },
                child: const Text('取消')),
            FlatButton(
                onPressed: () async {
                  if (isAddFile)
                    await NiProcess.exec(
                        'touch $currentPath/${textEditingController.text}\n');
                  else {
                    await NiProcess.exec(
                        'mkdir $currentPath/${textEditingController.text}\n');
                  }
                  eventBus.fire(1);
                  Navigator.pop(context);
                },
                child: const Text('确定')),
          ],
        )
      ],
    );
  }
}
