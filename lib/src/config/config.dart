import 'package:flutter/foundation.dart';

class Config {
  Config._();
  static String baseURL =
      kReleaseMode ? 'https://api2.bmob.cn/1' : 'https://api2.bmob.cn/1';
  static String dbPath = '/data/data/com.nightmare/databases/user.db';
  static const String backupPath = 'YanTool/Backup';
  static String binPath = '/data/data/com.nightmare/files/usr/bin';
  static String filesPath = '/data/data/com.nightmare/files';
  static String usrPath = '/data/data/com.nightmare/files/usr';
  static String homePath = '/data/data/com.nightmare/files/home';
  static String tmpPath = '/data/data/com.nightmare/files/usr/tmp';
  static const String busyboxPath =
      '/data/data/com.nightmare/files/usr/bin/busybox';
  static const String appName = 'YanTool';
  static const String dataPath = '/data/data/com.nightmare';

  /// debug开关，上线需要关闭
  /// App运行在Release环境时，inProduction为true；当App运行在Debug和Profile环境时，inProduction为false
  static const bool inProduction = bool.fromEnvironment('dart.vm.product');
  static const bool isTest = false;
  static const int versionCode = 69; //防止工具箱被反编译更改版本
  static const String version = '2.0-0923-ef1807a6'; //防止工具箱被反编译更改版本
  static const String packageName = 'com.nightmare';
  static const String execWithLoading = r'''
  #!/usr/bin/env python
# -*- coding: UTF-8 -*-
import os,sys,time, threading
#适用场景,当在Python中执行sh命令时
#如os.system("sleep 10"),或者os.system("cp a b"),
#凡是一些需要耗时的sh命令,
#可以使用这个Python文件给你的终端附加一个等待效果
#两种使用方式
#1.直接在Python内部调用
#使用import ExecWithLoading
#print(f"\033[1;31m这即将耗时3s\033[0m",end='',flush=True)
#ExecWithLoading.ExecWithLoading(f'sleep 3')
#亦或者在Console中,直接运行./ExecWithLoading.py "sh_script"
#以上两种方式,都将有一个简陋的等待效果,不仅如此,在这行命令运行结束之时,于这行命令的末尾会返回命令运行的时间
show=True
script=''
list1 = ['⣿','⣷','⣯','⣟','⡿','⣿','⢿','⣻','⣽','⣾']
# 新线程执行的代码:
def change(n):
    global show
    show=n
def setscript(sh):
    global script
    script=sh
def loop():
    os.system(script)
    change(False)
def execScript(script):
    change(True)
    setscript(script)
    t = threading.Thread(target=loop, name='LoopThread')
    t.start()
    time.sleep(0.05)
    tick=time.time()
    os.system(f'echo -n -e "        {list1[0]}"')
    i=0
    while show:
        os.system(f'echo -n -e "\b{list1[i]}"')
        time.sleep(0.04)
        if i<9:
            i+=1
        else:
            i=0
    tick=time.time()-tick
    tick=round(tick,1)
    os.system(f'echo -n -e "\b{tick}s\n"')
    t.join()
if __name__ == '__main__':
    try:
        script = str(sys.argv[1])
    except IndexError:
        print('你需要添加一行sh命令参数')
        sys.exit()
    execScript(sys.argv[1])
    ''';
  static const String termMotd = '''
欢迎使用 NiTerm ! 

安装资源 ：

 * 搜索依赖:    apt search  <query>
 * 安装依赖:    apt install <package>
 * 升级依赖:    apt upgrade

例子：

 * brotli:     apt install brotli
 * python:     apt install python
 * ssh:        apt install openssh

Report issues at https://github.com/Niterm/flutter_terminal

''';
}
