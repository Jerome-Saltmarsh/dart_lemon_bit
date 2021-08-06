
import 'dart:async';

Timer periodic(Function function, {int seconds = 0, int ms = 0}) {
  return Timer.periodic(Duration(seconds: seconds, milliseconds: ms), (timer) {
    function();
  });
}

Future<T> delayed<T>(FutureOr<T> computation()?, {int seconds = 0, int ms = 0}) {
  return Future.delayed(Duration(seconds: seconds, milliseconds: ms), computation);
}

double round(double value, {int decimals = 1}) {
  return double.parse(value.toStringAsFixed(decimals));
}

