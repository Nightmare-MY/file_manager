import 'dart:io';
import 'dart:ui';
import 'package:file_manager/src/dialog/long_press.dart';
import 'package:file_manager/src/widgets/item_imgheader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:file_manager/src/io/directory.dart';
import 'package:file_manager/src/io/file.dart';
import 'package:file_manager/src/io/file_entity.dart';
import 'package:file_manager/src/provider/file_manager_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../file_manager.dart';
import 'text_edit.dart';
import 'widget/file_item_suffix.dart';

Directory appDocDir;

typedef PathCallback = Future<void> Function(String path);

class FMPage extends StatefulWidget {
  const FMPage({
    Key key,
    this.initpath,
    this.chooseFile = false,
    this.pathCallBack,
  }) : super(key: key);
  final String initpath; //打开文件管理器初始化的路径
  final bool chooseFile; //是用这个页面选择文件
  final PathCallback pathCallBack;

  @override
  _FMPageState createState() => _FMPageState();
}

class _FMPageState extends State<FMPage> with TickerProviderStateMixin {
  String _currentdirectory = ''; //当前所在的文件夹
  List<FileEntity> _fileNodes = <FileEntity>[]; //保存所有文件的节点
  final ScrollController _scrollController = ScrollController(); //列表滑动控制器
  AnimationController _animationController; //动画控制器，用来控制文件夹进入时的透明度
  Animation<double> _opacityTween; //透明度动画补间值
  final Map<String, double> _historyOffset =
      <String, double>{}; //记录每一次的浏览位置，key 是路径，value是offset
  bool listIsBuilding = false;

  @override
  void initState() {
    super.initState();
    initAnimation();
    initFMPage();
  }

  @override
  void didUpdateWidget(FMPage oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(
          color: Theme.of(context).accentColor,
        ),
      ),
      child: buldHome(context),
    );
  }

  void initAnimation() {
    //初始化动画，这是切换文件路径时的透明度动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    final Animation<double> curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
    );
    _opacityTween = Tween<double>(begin: 0.0, end: 1.0)
        .animate(curve); //初始化这个动画的值始终为一，那么第一次打开就不会有透明度的变化
    _opacityTween.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  void _onAfterRendering(Duration timeStamp) {
    // final Animation curve =
    //     CurvedAnimation(parent: _animationController, curve: Curves.ease);
    // _opacityTween = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _historyOffset.forEach((String key, double value) {
      if (key == _currentdirectory) {
        _scrollController.jumpTo(value);
        // _scrollController.animateTo(value,
        //     duration: Duration(microseconds: 1), curve: Curves.linear);
      }
    });
    _historyOffset.remove(_currentdirectory);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initFMPage() async {
    //页面启动的时候的初始化
    eventBus.on<String>().listen((String event) {
      //当触发粘贴，删除等操作需要接收广播来进行刷新
      //这个eventBus的监听是为了检测何时刷新文件列表
      _currentdirectory = event ?? _currentdirectory;
      if (mounted) {
        _getFileNodes(_currentdirectory);
      }
    });
    _currentdirectory = widget.initpath ?? await PlatformUtil.documentsDir;
    print('_currentdirectory->$_currentdirectory');
    _getFileNodes(_currentdirectory);
  }

  void repeatAnima() {
    //重复播放动画
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _getFileNodes(String path, {void Function() afterSort}) async {
    // 获取文件列表和刷新页面
    _fileNodes = await NiDirectory(path).listAndSort();
    setState(() {});
    // 在一次获取后异步更新文件节点的其他参数，这个过程是非常快的
    getNodeFullArgs();
    if (afterSort != null) {
      afterSort();
    }
    if (widget.pathCallBack != null) {
      widget.pathCallBack(path); //返回当前的路径
    }
  }

  void itemOnTap(FileEntity fileNode) {
    if (fileNode.nodeName == '..') {
      //清除所有已选择
      // fiMaPageNotifier.removeAllCheck();
      //如果点了两个点的默认始终返上级目录
      final String backpath = Directory(_currentdirectory).parent.path; //
      _currentdirectory = backpath;
      _getFileNodes(_currentdirectory, afterSort: () async {
        repeatAnima();
      });
    } else if (!fileNode.isFile) {
      //如果不是文件就进入这个文件夹
      //进入文件夹前把当前文件夹浏览到的Offset保存下来
      _historyOffset[_currentdirectory] = _scrollController.offset;
      if (_currentdirectory == '/') {
        //是否是最顶层文件夹的
        _currentdirectory = '/${fileNode.nodeName}';
      } else {
        _currentdirectory = '$_currentdirectory/${fileNode.nodeName}';
      }
      listIsBuilding = true;
      _getFileNodes(_currentdirectory, afterSort: () {
        repeatAnima();
        _scrollController.jumpTo(0);
        Future<void>.delayed(const Duration(milliseconds: 1000), () {
          listIsBuilding = false;
        });
      });
    } else if (widget.chooseFile) {
      // 通过路由将文件路径带回去
      Navigator.pop(context, '$_currentdirectory/${fileNode.nodeName}');
    } else {
      // --------------------------------
      // 以下是当前节点是文件的情况
      if (FileEntity.isText(fileNode)) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext c) {
              return TextEdit(
                fileNode: fileNode as NiFile,
              );
            },
          ),
        );
      }

      if (FileEntity.isImg(fileNode)) {
        final List<FileEntity> _imagelist = <FileEntity>[];
        for (final FileEntity _file in _fileNodes) {
          if (FileEntity.isImg(_file)) {
            _imagelist.add(_file);
          }
        }
        final PageController controller =
            PageController(initialPage: _imagelist.indexOf(fileNode));
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) {
              return Hero(
                tag: fileNode.path,
                child: PageView.builder(
                  controller: controller,
                  itemCount: _imagelist.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.black,
                      child: Image.file(
                        File(_imagelist[index].path),
                        //mode: ExtendedImageMode.Gesture,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
        // --------------------------------
      }
    }
  }

  void itemOnLongPress(
    String currentFile,
    FileEntity fileNode,
    BuildContext context,
  ) {
    if (widget.chooseFile) {
      NiToast.showToast('点击文件即可选择');
      return;
    }
    if (currentFile != '..') {
      int initpage0 = 0;
      int initpage1 = 0;
      if (currentFile.endsWith('_dex')) {
        initpage0 = 1;
      }
      if (currentFile.endsWith('_src')) {
        initpage0 = 1;
        initpage1 = 1;
      }
      showCustomDialog<void>(
        context: context,
        child: Theme(
          data: Theme.of(context),
          child: LongPressDialog(
            fileNode: fileNode,
            initpage0: initpage0,
            initpage1: initpage1,
            fiMaPageNotifier: Provider.of(context),
            callback: () async {
              _getFileNodes(
                _currentdirectory,
                afterSort: () {},
              );
            },
          ),
        ),
      );
    }
  }

  //这是一个异步方法，来获得文件节点的其他参数
  //
  Future<void> getNodeFullArgs() async {
    for (final FileEntity fileNode in _fileNodes) {
      //将文件的ls输出详情以空格隔开分成列表
      if (fileNode.nodeName != '..') {
        final List<String> infos = fileNode.fullInfo.split(RegExp(r'\s{1,}'));
        fileNode.modified = '${infos[3]}  ${infos[4]}';
        if (fileNode.isFile) {
          fileNode.size = FileSizeUtils.getFileSizeFromStr(infos[2]);
        } else {
          fileNode.itemsNumber = '${infos[1]}项';
        }
        fileNode.mode = infos[0];
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Future<bool> onWillPop() async {
    print('拦截');
    // fiMaPageNotifier.removeAllCheck();
    //触发
    if (Scaffold.of(context).isDrawerOpen) {
      return true;
    }
    if (widget.chooseFile) {
      //当在其他面直接唤起文件管理器的时候返回键直接pop
      return true;
    }
    if (_currentdirectory == '/') {
      if (!widget.chooseFile) {
        Navigator.pop(context);
        // PlatformChannel.Drawer.invokeMethod<void>('Exit');
      }
    }
    final String backpath = Directory(_currentdirectory).parent.path;
    _currentdirectory = backpath;
    listIsBuilding = true;
    _getFileNodes(_currentdirectory, afterSort: () {
      repeatAnima();
      _scrollController.jumpTo(0);
      Future<void>.delayed(const Duration(milliseconds: 1000), () {
        listIsBuilding = false;
      });
    });
    return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  WillPopScope buldHome(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Material(
        textStyle: TextStyle(
          fontFamily: Platform.isLinux ? 'SourceHanSansSC-Light' : null,
        ),
        color: Colors.white,
        elevation: 8.0,
        child: FadeTransition(
          opacity: _opacityTween,
          child: RefreshIndicator(
            onRefresh: () async {
              if (!listIsBuilding)
                _getFileNodes(_currentdirectory, afterSort: () async {});
            },
            displacement: 1,
            child: DraggableScrollbar.semicircle(
              controller: _scrollController,
              child: buildListView(),
            ),
          ),
        ),
      ),
    );
  }

  ListView buildListView() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      cacheExtent: 400,
      controller: _scrollController,
      itemCount: _fileNodes.length,
      padding: const EdgeInsets.only(top: 0.0),
      //不然会有一个距离上面的边距
      itemBuilder: (BuildContext context, int index) {
        // print(widget.fileNode);
        final List<String> _tmp =
            _fileNodes[index].path.split(' -> '); //有的有符号链接
        final String currentFile =
            _tmp.first.split('/').last.toString(); //取前面那个就没错
        return FileItem(
            checkCall: (String path) {
              // if (fiMaPageNotifier.checkPath.contains(path)) {
              //   fiMaPageNotifier.removeCheck(path);
              // } else {
              //   fiMaPageNotifier.addCheck(path);
              // }
            },
            // isCheck: fiMaPageNotifier.checkPath.contains(_fileNodes[index].path),
            fileNode: _fileNodes[index],
            onTap: () => itemOnTap(_fileNodes[index]),
            apkTool: () {},
            onLongPress: () {
              itemOnLongPress(currentFile, _fileNodes[index], context);
            });
      },
    );
  }
}

class FileItem extends StatefulWidget {
  const FileItem({
    Key key,
    this.onTap,
    this.onLongPress,
    this.fileNode,
    this.isCheck = false,
    this.checkCall,
    this.apkTool,
  }) : super(key: key);
  final FileEntity fileNode;
  final Function onTap;
  final Function onLongPress;
  final Function apkTool;
  final bool isCheck;
  final Function(String path) checkCall;

  @override
  _FileItemState createState() => _FileItemState();
}

class _FileItemState extends State<FileItem>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController; //动画控制器
  Animation<double> curvedAnimation;
  Animation<double> tweenPadding; //边距动画补间值
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
    curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
  }

  double dx = 0.0;
  double _tmp;
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
    if (dx >= 40) {
      dx = 40.0;
    }
    if (dx <= 0) {
      dx = 0;
    }
    // print(dx);
    setState(() {});
  }

  void _handleDragEnd(DragEndDetails details) {
    if (dx == 40.0) {
      Feedback.forLongPress(context);
      if (!fiMaPageNotifier.checkNodes.contains(widget.fileNode)) {
        fiMaPageNotifier.addCheck(widget.fileNode);
      }
      setState(() {});
    }
    tweenPadding = Tween<double>(
      begin: dx,
      end: 0,
    ).animate(curvedAnimation);
    tweenPadding.addListener(() {
      setState(() {
        dx = tweenPadding.value;
      });
    });
    _animationController.reset();
    _animationController.forward().whenComplete(() {});
  }

  FiMaPageNotifier fiMaPageNotifier;
  @override
  Widget build(BuildContext context) {
    fiMaPageNotifier = Provider.of(context);
    PrintUtil.printn(fiMaPageNotifier.checkNodes, 32);
    final List<String> _tmp = widget.fileNode.path.split(' -> '); //有的有符号链接
    final String currentFileName =
        _tmp.first.split('/').last.toString(); //取前面那个就没错
    // /bin -> /system/bin
    final Widget _iconData = getWidgetFromExtension(
      widget.fileNode,
      context,
      widget.fileNode.isFile,
    ); //显示的头部件
    return Container(
      height: 54,
      child: Stack(
        children: <Widget>[
          if (fiMaPageNotifier.checkNodes.contains(widget.fileNode))
            Container(
              color: Colors.grey.withOpacity(0.6),
            ),
          InkWell(
            splashColor: Colors.transparent,
            onLongPress: () => widget.onLongPress(),
            onTap: () {
              // if (fiMaPageNotifier.checkNodes.isEmpty ||
              //     widget.fileNode.nodeName == '..') {
              widget.onTap();
              // } else {
              //   if (fiMaPageNotifier.checkNodes.contains(widget.fileNode)) {
              //     fiMaPageNotifier.removeCheck(widget.fileNode);
              //   } else {
              //     fiMaPageNotifier.addCheck(widget.fileNode);
              //   }
              //   setState(() {});
              // }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: Transform(
                transform: Matrix4.identity()..translate(dx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // header icon
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: _iconData,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  // width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      currentFileName,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .fontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width -
                                        8 -
                                        30,
                                    child: Text(
                                      widget.fileNode.info,
                                      maxLines: 1,
                                      style: TextStyle(
                                        // fontSize: 12,
                                        fontFamily: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .fontFamily,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      FileItemSuffix(
                        fileNode: widget.fileNode,
                      ),
                      if (_tmp.length == 2)
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '->    ',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
