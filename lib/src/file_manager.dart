import 'dart:io';
import 'dart:ui';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'colors/file_colors.dart';
import 'config/config.dart';
import 'page/center_drawer.dart';
import 'page/file_manager_drawer.dart';
import 'page/fm_page.dart';
import 'page_choose.dart';
import 'provider/file_manager_notifier.dart';
import 'utils/bookmarks.dart';

Directory appDocDir;

class FileManager extends StatelessWidget {
  // static initFileManager
  static Future<String> chooseFile({@required BuildContext context}) async {
    final String documentDir = await PlatformUtil.documentsDir;
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          // SafeArea;
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('选择文件'),
            ),
            body: FMPage(
              chooseFile: true,
              initpath: '$documentDir/YanTool/Rom',
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider<FiMaPageNotifier>(
          create: (_) => FiMaPageNotifier(),
        ),
      ],
      child: Theme(
        data: ThemeData(
          textTheme: const TextTheme(
            bodyText2: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
          ),
          iconTheme: const IconThemeData(
            color: const Color(
              0xff213349,
            ),
          ),
          brightness: Brightness.light,
          primaryColorBrightness: Brightness.dark,
          backgroundColor: Colors.white,
          accentColor: const Color(0xff213349),
          primaryColor: const Color(0xff213349),

          // cursorColor: Colors.red,
          // textSelectionColor: Colors.red,
          // textSelectionHandleColor: Colors.red,
        ),
        child: const FiMaHome(),
      ),
    );
  }
}

class FiMaHome extends StatefulWidget {
  const FiMaHome({
    Key key,
  }) : super(key: key);
  @override
  _FiMaHomeState createState() => _FiMaHomeState();
}

enum FileState {
  checkWindow,
  fileDefault,
}

EventBus eventBus = EventBus();

class _FiMaHomeState extends State<FiMaHome> with TickerProviderStateMixin {
  List<String> _paths = <String>[];
  final PageController _pageController = PageController(); //最下面接收手势的Widget
  final PageController _commonController = PageController(
    initialPage: 0,
  ); //主页面切换的页面切换控制器
  final PageController _titlePageController = PageController(
    initialPage: 0,
  ); //头部是一个可以滑动的PageView
  int currentPage = 0; //当前页面
  AnimationController animationController;
  FileState fileState = FileState.fileDefault;
  // 多个页面在缩放时用到的四阶矩阵
  Matrix4 matrix4;
  AnimationController pastIconAnimaController;
  // 是否有储存权限
  bool hasPermission = false;
  bool pageIsInit = false;

  @override
  void initState() {
    super.initState();
    initAnimation();
    initFMPage();
    temp();
  }

  @override
  void dispose() {
    _titlePageController.dispose();
    _commonController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  void _onAfterRendering(Duration timeStamp) {
    //页面构建完成后悔拿到context
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    NiToast.initContext(context);
    return Scaffold(
      drawer: PlatformUtil.isMobilePhone() ? const FileManagerDrawer() : null,
      backgroundColor: Colors.white,
      body: Builder(
        builder: (BuildContext context) {
          return Row(
            children: [
              if (PlatformUtil.isDesktop()) const FileManagerDrawer(),
              SizedBox(
                width: MediaQuery.of(context).size.width -
                    (PlatformUtil.isMobilePhone() ? 0.0 : 300),
                child: Stack(
                  children: <Widget>[
                    if (_paths.isEmpty)
                      const SpinKitThreeBounce(
                        color: FileColors.fileAppColor,
                        size: 16.0,
                      )
                    else
                      buildStack(context),
                    // 最下面的透明的 widget
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 20.0,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _paths.length,
                          itemBuilder: (BuildContext c, int i) {
                            return Container(
                              height: 20,
                              color: Colors.transparent,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 48,
        child: Material(
          elevation: 8,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_back_ios),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: <Widget>[
      //     Padding(
      //       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      //       child: ScaleTransition(
      //         scale:
      //             _rotated.drive(Tween<double>(begin: 0.0, end: 1.0 / 0.125)),
      //         child: FloatingActionButton(
      //           onPressed: () async {
      //             showCustomDialog2<void>(
      //               child: FullHeightListView(
      //                 child: AddFileNode(
      //                   currentPath: _paths[_titlePageController.page.toInt()],
      //                   isAddFile: false,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Icon(
      //             Octicons.getIconData('file-directory'),
      //             size: 24.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      //       child: ScaleTransition(
      //         scale:
      //             _rotated.drive(Tween<double>(begin: 0.0, end: 1.0 / 0.125)),
      //         child: FloatingActionButton(
      //           onPressed: () async {
      //             showCustomDialog2<void>(
      //               child: FullHeightListView(
      //                 child: AddFileNode(
      //                   currentPath: _paths[_titlePageController.page.toInt()],
      //                   isAddFile: true,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Icon(
      //             Octicons.getIconData('file'),
      //             size: 24.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Padding(
      //       padding: EdgeInsets.all(8.0),
      //       child: FloatingActionButton(
      //         onPressed: () async {
      //           if (animationController.isDismissed) {
      //             await animationController.forward();
      //           } else if (animationController.isCompleted) {
      //             await animationController.reverse();
      //           }
      //           // animationController.reverse();
      //         },
      //         child: RotationTransition(
      //           turns: _rotated,
      //           child: Icon(
      //             Icons.add,
      //             size: 36.0,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Stack buildStack(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        buildAppBar(context),
        Padding(
          padding: EdgeInsets.only(
            top: MediaQueryData.fromWindow(window).padding.top + kToolbarHeight,
          ),
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: _commonController,
                itemCount: _paths.length,
                itemBuilder: (BuildContext context, int index) {
                  double scale = 1.0;
                  if (pageIsInit) {
                    if (index - currentPage == 0)
                      scale = 1 - 0.2 * (_pageController.page - currentPage);
                    if (index - currentPage == 1)
                      scale = 0.8 + 0.2 * (_pageController.page - currentPage);
                  }
                  matrix4 = Matrix4.identity()..scale(scale);
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Transform(
                      transform: matrix4,
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: FMPage(
                          pathCallBack: (String path) async {
                            _paths[index] = path;
                            setState(() {});
                            setStatePathFile();
                          },
                          initpath: _paths[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        CenterDrawer(),
      ],
    );
  }

  void temp() {
     ProcessResult result = Process.runSync('ls', ['/storage/emulated/0/DCIM']);
     print(result.stdout);
     print(result.stderr);
     print('object');
  }

  void initAnimation() {
    //初始化动画
    pastIconAnimaController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ),
    );
  }

  Future<void> initFMPage() async {
    // 先初始化配置文件，因为要用很多平台路径
    await Config.initConfig();
    if (Platform.isAndroid) {
      // 头部的pageview跟随
      // 滑动底栏即可滑动主页
      _pageController.addListener(() {
        _commonController.jumpTo(_pageController.offset);
        currentPage = _pageController.page.toInt();
        _titlePageController.animateToPage(
          _pageController.page.round(),
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        ); //title的文件夹路径动画
        setState(() {});
      });
    }
    await createWorkDir();
    getHistoryPaths();
    // print(appDocDir);
  }

  Future<void> createWorkDir() async {
    // 创建 FileManager 文件夹
    if (Platform.isAndroid) {
      final Directory workDir = Directory('${Config.filesPath}/FileManager');
      if (!workDir.existsSync()) {
        await workDir.create(recursive: true);
      }
    }
  }

  //软件将页面路径的列表以换行符分割保存进了储存
  Future<void> getHistoryPaths() async {
    String temp = '';
    final File historyFile = File(
      '${Config.filesPath}/FileManager/History_Path',
    );
    if (historyFile.existsSync()) {
      try {
        temp = await historyFile.readAsString();
      } catch (e) {
        print(e);
      }
    } else {
      if (Platform.isAndroid)
        temp = '/storage/emulated/0';
      else {
        temp = await PlatformUtil.documentsDir;
      }
    }
    _paths = temp.trim().split('\n');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    pageIsInit = true; //这个值为真才会启动左右滑动的效果
    setState(() {});
  }

  void addNewPage(String path) {
    //添加一个页面
    _paths.add(path);
    setState(() {});
    setStatePathFile();
    changePage(_paths.length - 1);
  }

  Future<void> deletePage(int index) async {
    // 删除一个页面
    // _paths.removeAt(index);
    setState(() {});
    setStatePathFile();
  }

  void changePage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.ease,
    );
  }

  void setStatePathFile() {
    // if (Platform.isAndroid)
    //   File('${Config.filesPath}/FileManager/History_Path')
    //       .writeAsString(_paths.join('\n'));
  }

  PreferredSize buildAppBar(BuildContext context) {
    final FiMaPageNotifier fiMaPageNotifier =
        Provider.of<FiMaPageNotifier>(context);
    if (fiMaPageNotifier.clipboard.isNotEmpty &&
        pastIconAnimaController.isDismissed)
      pastIconAnimaController.forward();
    else if (fiMaPageNotifier.clipboard.isEmpty &&
        pastIconAnimaController.isCompleted) {
      pastIconAnimaController.reverse();
    }
    //Appbar
    return PreferredSize(
      child: AppBar(
        elevation: 0.0,
        titleSpacing: 0,
        title: InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(
              text: _paths[_titlePageController.page.toInt()],
            ));
            Feedback.forLongPress(context);
            NiToast.showToast('已复制路径');
          },
          child: SizedBox(
            height: 24.0,
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: _titlePageController,
              itemCount: _paths.length,
              itemBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _commonController.hasClients
                          ? _paths[index]
                          : _paths[index],
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        backgroundColor: FileColors.fileAppColor,
        leading: Align(
          alignment: Alignment.center,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            onLongPress: () {
              // Scaffold.of(pushContext).openDrawer();
            },
            child: const SizedBox(
              height: 36.0,
              width: 36.0,
              child: Icon(Icons.menu, size: 24.0),
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  // if (fiMaPageNotifier.clipType == ClipType.Copy)
                  // showCustomDialog2<void>(
                  //   context: context,
                  //   child: FullHeightListView(
                  //     child: Copy(
                  //       targetPath: _paths[_titlePageController.page.toInt()],
                  //       sourcePaths: fiMaPageNotifier.clipboard,
                  //     ),
                  //   ),
                  // );
                  // else {
                  //   for (final String path in fiMaPageNotifier.clipboard) {
                  //     await NiProcess.exec(
                  //         'mv $path ${_paths[_titlePageController.page.toInt()]}\n');
                  //   }

                  //   // showToast2('粘贴完成');
                  //   fiMaPageNotifier.clearClipBoard();
                  //   eventBus.fire('');
                  // }
                  // fiMaPageNotifier.clearClipBoard();
                },
                child: SizedBox(
                  height: 36.0,
                  width: 36.0,
                  child: ScaleTransition(
                    scale: pastIconAnimaController,
                    child: const Icon(Icons.content_paste, size: 24.0),
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          //   child: ScaleTransition(
          //     scale: pastIconAnimaController,
          //     child: FloatingActionButton(
          //       mini: true,
          //       // materialTapTargetSize: MaterialTapTargetSize.padded,
          //       onPressed: () async {
          //       },
          //       child: Icon(
          //         Icons.content_paste,
          //         size: 18.0,
          //       ),
          //     ),
          //   ),
          // ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 24.0,
              height: 24.0,
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () {
                  showDialog<void>(
                    useRootNavigator: false,
                    context: context,
                    builder: (_) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: TextTheme(
                            bodyText2: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(fontSize: 10.0),
                          ),
                        ),
                        child: PageChoose(
                          paths: _paths,
                          initIndex: currentPage,
                          changePageCall: changePage,
                          deletePageCall: deletePage,
                          addNewPageCall: () async {
                            Navigator.of(context).pop();
                            addNewPage(await PlatformUtil.documentsDir);
                          },
                        ),
                      );
                    },
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                        style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Text('${_paths.length}'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Builder(
            builder: (BuildContext context) {
              return Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 36.0,
                  width: 36.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    child: const Icon(Icons.more_vert, size: 22.0),
                    onTapDown: (TapDownDetails detials) {},
                    onTap: () {
                      Future<void> showButtonMenu() async {
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final RenderBox overlay = Overlay.of(context)
                            .context
                            .findRenderObject() as RenderBox;
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(Offset(button.size.width, 0.0),
                                ancestor: overlay),
                            button.localToGlobal(
                                button.size.bottomRight(Offset.zero),
                                ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );
                        final int choose = await showMenu<int>(
                          context: context,
                          elevation: 1,

                          items: const <PopupMenuItem<int>>[
                            PopupMenuItem<int>(
                              value: 0,
                              child: Text('添加书签'),
                            ),
                            PopupMenuItem<int>(
                              child: Text('设为首页'),
                            ),
                            PopupMenuItem<int>(
                              child: Text('查看模式'),
                            ),
                            PopupMenuItem<int>(
                              value: 3,
                              child: Text('退出'),
                            ),
                          ],
                          // initialValue: 0,
                          position: position,
                        );
                        if (choose == 0) {
                          print(PlatformUtil.packageName);
                          BookMarks.addMarks(
                            _paths[_titlePageController.page.toInt()],
                          );
                          NiToast.showToast('已添加');
                          // showToast2('已添加');
                        }
                        if (choose == 3) {
                          SystemNavigator.pop(animated: false);
                        }
                        // PlatformChannel.Drawer.invokeMethod<void>('Exit');
                      }

                      showButtonMenu();
                      // Overlay.of(context).insert(weixinOverlayEntry);
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            width: 10.0,
          )
        ],
      ),
      preferredSize: const Size.fromHeight(50),
    );
  }
}
