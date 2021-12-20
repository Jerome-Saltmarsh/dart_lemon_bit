
import 'dart:async';

Timer periodic(void callback(Timer timer), {int seconds = 0, int ms = 0}) {
  return Timer.periodic(Duration(seconds: seconds, milliseconds: ms), callback);
}

Future<T> delayed<T>(FutureOr<T> computation()?, {int seconds = 0, int ms = 0}) {
  return Future.delayed(Duration(seconds: seconds, milliseconds: ms), computation);
}

List<T> copy<T>(List<T> list){
  return [...list];
}


