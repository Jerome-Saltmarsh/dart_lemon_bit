import 'package:universal_html/html.dart';

void requestPointerLock() {
  var canvas = document.getElementById('canvas');
  if (canvas != null) {
    canvas.requestPointerLock();
  }
}
