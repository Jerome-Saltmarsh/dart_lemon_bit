
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/cube/camera3d.dart';
import 'package:universal_html/html.dart';
import 'package:vector_math/vector_math_64.dart';

void initCube(){
  print("initCube()");
  document.addEventListener("mousemove", (value){
    if (value is MouseEvent){
      camera3D.rotateCamera(
          value.movement.x.toDouble(),
          value.movement.y.toDouble(),
          1.0
      );
    }
  }, false);

  RawKeyboard.instance.addListener(onRawKeyEvent);
}

Camera3D get _camera => camera3D;

void onRawKeyEvent(RawKeyEvent event) {
  if (event is RawKeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.keyW) {
      double cameraTargetY = _camera.target.y;
      _camera.target.y = _camera.position.y;
      translateCamera(_camera.backward.normalized());
      _camera.target.y = cameraTargetY;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyS) {
      double cameraTargetY = _camera.target.y;
      _camera.target.y = _camera.position.y;
      translateCamera(_camera.forward.normalized());
      _camera.target.y = cameraTargetY;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      translateCamera(_camera.left.normalized());
    }
    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      translateCamera(_camera.right.normalized());
    }
  }
}

void translateCamera(Vector3 translation) {
  Vector3 f = _camera.target - _camera.position;
  _camera.position.x += translation.x;
  _camera.position.z += translation.z;
  _camera.target = _camera.position + f;
}

