package com.nightmare.file_manager;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;

import brut.common.BrutException;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FileManagerPlugin
 */
public class FileManagerPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "file_manager");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        String id = call.method;
        String[] args = {};
        if (!id.equals("logout"))
            args = (String[]) ((ArrayList) call.arguments).toArray(new String[0]);
        switch (id) {
            case "logout":
                //重定向java的标准输入输出
                try {
//                        System.set
//                        PrintStream ps=new PrintStream(new FileOutputStream("work"));
                    System.setErr(new PrintStream(new FileOutputStream(new File(call.arguments.toString()), false), false));
                    System.setOut(new PrintStream(new FileOutputStream(new File(call.arguments.toString()), false), false));
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }

                result.success("");
                break;

            case "apktool"://apktool的
                try {
                    brut.apktool.Main.main(args);

                } catch (IOException e) {
                    //methodChannel.invokeMethod("Terminal", e.getMessage());
                    e.printStackTrace();
                } catch (InterruptedException e) {
                    //methodChannel.invokeMethod("Terminal", e.getMessage());
                    e.printStackTrace();
                } catch (BrutException e) {
                    //methodChannel.invokeMethod("Terminal", e.getMessage());
                    e.printStackTrace();
                }
                result.success("");
                break;
            case "smali":
                org.jf.smali.Main.main(args);

                result.success("");
                break;
            case "baksmali":
                org.jf.baksmali.Main.main(args);
                result.success("");
                //String[] A = new String[]{"d", "/storage/emulated/0/Apktool/jar/1/classes.dex", "-o", "/storage/emulated/0/Apktool/jar/1/sdasd"};
//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            Dynamic dynamic;
//                            File cacheFile = FileUtils.getCacheDir(getApplicationContext());
//                            //String[] A = new String[]{"d", "/storage/emulated/0/Apktool/jar/1/classes.dex", "-o", "/storage/emulated/0/Apktool/jar/1/sdasd"};
//                            //下面开始加载dex class
//                            @SuppressLint("SdCardPath") DexClassLoader dexClassLoader = new DexClassLoader("/sdcard/Apktool/apktool.dex", cacheFile.getAbsolutePath(), null, getClassLoader());
//                            try {
//                                Class libClazz = dexClassLoader.loadClass("com.nightmare.Decomplie");
//                                dynamic = (Dynamic) libClazz.newInstance();
//                                String[] args= (String[]) ((ArrayList)call.arguments).toArray(new String[0]);
//                                if (dynamic != null)
//                                    dynamic.main(args);
//                            } catch (Exception e) {
//                                e.printStackTrace();
//                            }
//                        }
//                    });
                //Main.main(A);
                break;
        }
//        if (call.method.equals("getPlatformVersion")) {
//            result.success("Android " + android.os.Build.VERSION.RELEASE);
//        } else {
//            result.notImplemented();
//        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
