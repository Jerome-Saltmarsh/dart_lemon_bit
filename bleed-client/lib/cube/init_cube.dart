
import 'package:bleed_client/cube/camera3d.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart';
import 'package:vector_math/vector_math_64.dart';

void initCube(){
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

Camera3D get camera => camera3D;

void onRawKeyEvent(RawKeyEvent event) {
  if (event is RawKeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.keyW) {
      double cameraTargetY = camera.target.y;
      camera.target.y = camera.position.y;
      translateCamera(camera.backward.normalized());
      camera.target.y = cameraTargetY;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyS) {
      double cameraTargetY = camera.target.y;
      camera.target.y = camera.position.y;
      translateCamera(camera.forward.normalized());
      camera.target.y = cameraTargetY;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      translateCamera(camera.left.normalized());
    }
    if (event.logicalKey == LogicalKeyboardKey.keyD) {
      translateCamera(camera.right.normalized());
    }
  }
}

void translateCamera(Vector3 translation) {
  Vector3 f = camera.target - camera.position;
  camera.position.x += translation.x;
  camera.position.z += translation.z;
  camera.target = camera.position + f;
}

