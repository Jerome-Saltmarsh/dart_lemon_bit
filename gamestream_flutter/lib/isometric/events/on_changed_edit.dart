

import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/enums/camera_mode.dart';

void onChangedEdit(bool value) {
  if (value) {
     cameraMode = CameraMode.Free;
     edit.cursorSetToPlayer();
  } else {
    cameraMode = CameraMode.Chase;
  }
}

