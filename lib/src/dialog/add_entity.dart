import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

enum FileType {
  file,
  directory,
}

// create file or directory page
class AddEntity extends StatefulWidget {
  const AddEntity({Key key, this.curDir}) : super(key: key);
  final String curDir;
  @override
  _AddEntityState createState() => _AddEntityState();
}

class _AddEntityState extends State<AddEntity> {
  FileType fileType;
  final TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FullHeightListView(
      child: Column(
        children: [
          const Text(
            '新建',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (fileType != null)
            Column(
              children: [
                TextField(
                  autofocus: false,
                  controller: controller,
                  decoration: InputDecoration(
                    isDense: true,
                    helperText: '请输入名称',
                    contentPadding: const EdgeInsets.only(top: 10.0),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () async {
                      switch (fileType) {
                        case FileType.file:
                          await NiProcess.exec(
                            'touch "${widget.curDir}/${controller.text}"',
                          );
                          break;
                        case FileType.directory:
                          await NiProcess.exec(
                            'mkdir "${widget.curDir}/${controller.text}"',
                          );
                          break;
                      }
                      Navigator.pop(context);
                      // print(widget.curDir);
                    },
                    child: const Text(
                      '确认',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                InkWell(
                  onTap: () {
                    fileType = FileType.file;
                    DialogBuilder.changeHeight(110);
                    setState(() {});
                  },
                  child: const SizedBox(
                    height: 36.0,
                    child: Center(
                      child: Text(
                        '文件',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    fileType = FileType.directory;
                    DialogBuilder.changeHeight(110);
                    setState(() {});
                  },
                  child: const SizedBox(
                    height: 36.0,
                    child: Center(
                      child: Text(
                        '文件夹',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
