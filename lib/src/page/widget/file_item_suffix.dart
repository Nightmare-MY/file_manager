import 'package:file_manager/src/dialog/apktool_decode_page.dart';
import 'package:file_manager/src/io/file.dart';
import 'package:file_manager/src/io/file_entity.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class FileItemSuffix extends StatelessWidget {
  const FileItemSuffix({Key key, this.fileNode}) : super(key: key);

  final FileEntity fileNode;

  @override
  Widget build(BuildContext context) {
    if (fileNode.nodeName.endsWith('_src') && fileNode.isDirectory)
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.build),
          onPressed: () {
            // showCustomDialog2<void>(
            //   isPadding: false,
            //   context: context,
            //   duration: const Duration(milliseconds: 200),
            //   child: FullHeightListView(
            //     child: ApkToolEncode(
            //         fileNode: widget.fileNode as NiFile),
            //   ),
            // );
          },
        ),
      );
    if (fileNode.nodeName.endsWith('apk'))
      return Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: const Icon(Icons.build),
          onPressed: () {
            showCustomDialog<void>(
              context: context,
              duration: const Duration(milliseconds: 200),
              child: ApkToolDialog(
                fileNode: fileNode as NiFile,
              ),
            );
          },
        ),
      );
    return const SizedBox();
  }
}
