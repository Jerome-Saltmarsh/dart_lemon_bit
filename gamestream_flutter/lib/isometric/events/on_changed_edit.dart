

import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/enums/camera_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';

void onChangedEdit(bool value) {
  if (value) {
     cameraMode = CameraMode.Free;
     edit.cursorSetToPlayer();
     player.message.value = "-press arrow keys to move\n\n-press tab to play";
     player.messageTimer = 300;
  } else {
    cameraMode = CameraMode.Chase;
    if (sceneEditable.value){
      player.message.value = "press tab to edit";
    }
  }
}

