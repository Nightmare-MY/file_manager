import 'dart:io';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_repository/global_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../colors/file_colors.dart';
import '../file_manager.dart';
import '../utils/bookmarks.dart';

class FileManagerDrawer extends StatefulWidget {
  const FileManagerDrawer({
    Key key,
  }) : super(key: key);

  @override
  _FileManagerDrawerState createState() => _FileManagerDrawerState();
}

class _FileManagerDrawerState extends State<FileManagerDrawer> {
  List<String> rootInfo = <String>[];
  List<String> sdcardInfo = <String>[];
  List<String> bookMarks = <String>[];
  @override
  void initState() {
    super.initState();
    init();
    initBookMarks();
  }

  Future<void> init() async {
    final String result = await NiProcess.exec('df -k');
    File('/storage/emulated/0/YanTool/123/2.txt').writeAsStringSync(result);
    final List<String> infos = result.split('\n');
    for (final String line in infos) {
      if (line.endsWith('/data')) {
        rootInfo = line.split(RegExp(r'\s{1,}'));
        setState(() {});
      }
      if (line.endsWith('/storage/emulated')) {
        sdcardInfo = line.split(RegExp(r'\s{1,}'));
        setState(() {});
      }
    }
    // print(result);
  }

  Future<void> initBookMarks() async {
    bookMarks = await BookMarks.getBookMarks();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (rootInfo.isEmpty | sdcardInfo.isEmpty) {
      return const SpinKitThreeBounce(
        color: FileColors.fileAppColor,
        size: 16.0,
      );
    }
    double width;
    if (PlatformUtil.isDesktop()) {
      width = 300;
    } else {
      width = MediaQuery.of(context).size.width * 3 / 4;
    }
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
        ),
        elevation: 8.0,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 100,
                color: FileColors.fileAppColor,
              ),
              Material(
                  color: Colors.white,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 100.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, top: 4.0),
                          child: Text(
                            '本地路径',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            eventBus.fire('/');
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            height: 48.0,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        '根目录',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (rootInfo.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(rootInfo[0]),
                                            Text(
                                                '${FileSizeUtils.getFileSizeFromStr('${int.parse(rootInfo[2]) * 1024}')}/ ${FileSizeUtils.getFileSizeFromStr('${int.parse(rootInfo[1]) * 1024}')}')
                                          ],
                                        )
                                      else
                                        const SizedBox(),
                                      LinearProgressIndicator(
                                        backgroundColor: Colors.grey,
                                        value: int.parse(rootInfo[2]) /
                                            int.parse(rootInfo[1]),
                                        valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).accentColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            eventBus.fire(await PlatformUtil.documentsDir);
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            height: 48.0,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        '外部储存',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (sdcardInfo.isNotEmpty)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(sdcardInfo[0]),
                                            Text(
                                                '${FileSizeUtils.getFileSizeFromStr('${int.parse(sdcardInfo[2]) * 1024}')}/ ${FileSizeUtils.getFileSizeFromStr('${int.parse(sdcardInfo[1]) * 1024}')}')
                                          ],
                                        )
                                      else
                                        const SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, top: 4.0),
                          child: Text(
                            '书签',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12.0,
                        ),
                        if (bookMarks.isNotEmpty)
                          SizedBox(
                            height: bookMarks.length * 48.0,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(0.0),
                              itemCount: bookMarks.length,
                              itemBuilder: (BuildContext c, int i) {
                                return InkWell(
                                  onTap: () {
                                    eventBus.fire(bookMarks[i]);
                                    Navigator.pop(context);
                                  },
                                  onLongPress: () {
                                    // showCustomDialog2<void>(
                                    //   context: context,
                                    //   child: FullHeightListView(
                                    //     child: Column(
                                    //       children: <Widget>[
                                    //         InkWell(
                                    //           onTap: () {
                                    //             BookMarks.removeMarks(
                                    //                 bookMarks[i]);
                                    //             Navigator.pop(context);
                                    //             initBookMarks();
                                    //           },
                                    //           child: SizedBox(
                                    //             height: 30.0,
                                    //             width: MediaQuery.of(context)
                                    //                 .size
                                    //                 .width,
                                    //             child: const Text('删除该书签'),
                                    //           ),
                                    //         )
                                    //       ],
                                    //     ),
                                    //   ),
                                    // );
                                  },
                                  child: MarksItem(
                                    marksPath: bookMarks[i],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ))
              // Padding(
              //   padding: EdgeInsets.only(left: 4.0, top: 4.0),
              //   child: Text(
              //     '其他',
              //     style: TextStyle(
              //       color: Colors.grey,
              //       fontSize: 16.0,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(left: 12.0, top: 4.0),
              //   child: Text(
              //     'Img镜像比较功能',
              //     style: TextStyle(
              //       color: Colors.black,
              //       fontSize: 16.0,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarksItem extends StatefulWidget {
  const MarksItem({Key key, this.marksPath}) : super(key: key);
  final String marksPath;

  @override
  _MarksItemState createState() => _MarksItemState();
}

class _MarksItemState extends State<MarksItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController; //动画控制器
  Animation<double> curvedAnimation;
  Animation<double> tweenPadding; //边距动画补间值
  double _tmp;

  double dx = 0.0;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  void initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    curvedAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.bounceOut);
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
  }

  void _handleDragStart(DragStartDetails details) {
    //控件点击的回调
    _tmp = details.globalPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // print(details.globalPosition);
    // if (dx >= 40.0) {
    //   if (dx != (details.globalPosition.dx - _tmp)) {
    //     Feedback.forLongPress(context);
    //   }
    // } else
    dx = details.globalPosition.dx - _tmp;
    if (dx <= -40) {
      dx = -40.0;
    }
    if (dx >= 0) {
      dx = 0;
    }
    // print(dx);
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (dx == 40.0) {
      Feedback.forLongPress(context);

      setState(() {});
    }
    // tweenPadding = Tween<double>(
    //   begin: dx,
    //   end: 0,
    // ).animate(curvedAnimation);
    // tweenPadding.addListener(() {
    //   setState(() {
    //     dx = tweenPadding.value;
    //   });
    // });
    // _animationController.reset();
    // _animationController.forward().whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: <Widget>[
          Transform(
            transform: Matrix4.identity()..translate(dx),
            child: SizedBox(
              height: 48.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'packages/file_manager/assets/icon/directory.svg',
                    width: 30.0,
                    height: 30.0,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(PlatformUtil.getFileName(widget.marksPath)),
                      SizedBox(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            widget.marksPath,
                            // softWrap: true,
                            maxLines: 2,
                            // overflow: TextOverflow.visible,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // Transform(
          //   transform: Matrix4.identity()..translate(dx),
          //   child: SizedBox(
          //     height: 40.0,
          //     child: Text(widget.marksPath),
          //   ),
          // ),
        ],
      ),
    );
  }
}
