import 'dart:io';

void main() {
  // Stream a = stdin.asBroadcastStream();
  // a.listen((dynamic event) {
  //   print(event);
  // });
  stdin.echoMode = true;
  stdin.lineMode = false;
  int a = stdin.readByteSync();
  print(a);
}
