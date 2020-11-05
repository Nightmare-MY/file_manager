import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'io/file.dart';
import 'io/file_entity.dart';
import 'widgets/item_imgheader.dart';

// 获得列表的头部
// 在多图列表的地方必须优化

Widget getWidgetFromExtension(FileEntity fileNode, BuildContext context,
    [bool isFile = true]) {
  if (isFile) {
    if (fileNode.nodeName.endsWith('.zip'))
      return SvgPicture.asset(
        'packages/file_manager/assets/icon/zip.svg',
        width: 20.0,
        height: 20.0,
        color: Theme.of(context).iconTheme.color,
      );
    else if (fileNode.nodeName.endsWith('.apk'))
      return const Icon(
        Icons.android,
      );
    else if (fileNode.nodeName.endsWith('.mp4'))
      return const Icon(
        Icons.video_library,
      );
    else if (fileNode.nodeName.endsWith('.jpg') ||
        fileNode.nodeName.endsWith('.png')) {
      return ItemImgHeader(
        fileNode: fileNode as NiFile,
      );
    } else
      return SvgPicture.asset(
        'packages/file_manager/assets/icon/file.svg',
        width: 20.0,
        height: 20.0,
      );
  } else {
    return SvgPicture.asset(
      'packages/file_manager/assets/icon/directory.svg',
      width: 20.0,
      height: 20.0,
      color: Theme.of(context).iconTheme.color,
    );
  }
}
