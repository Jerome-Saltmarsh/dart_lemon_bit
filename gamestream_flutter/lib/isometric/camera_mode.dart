import 'package:gamestream_flutter/isometric/events/on_camera_mode_changed.dart';
import 'package:lemon_watch/watch.dart';

enum CameraMode {
  Chase,
  Locked,
  Free,
}

const cameraModes = CameraMode.values;
final cameraModeWatch = Watch(CameraMode.Chase, onChanged: onCameraModeChanged);
CameraMode get cameraMode => cameraModeWatch.value;


void cameraModeNext(){
  cameraMode = cameraModes[(cameraMode.index + 1) % cameraModes.length];
}

void cameraModeSetFree(){
  cameraMode = CameraMode.Free;
}

void cameraModeSetChase(){
  cameraMode = CameraMode.Chase;
}

void set cameraMode(CameraMode value) {
  cameraModeWatch.value = value;
}