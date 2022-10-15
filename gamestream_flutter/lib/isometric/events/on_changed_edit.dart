

import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/enums/camera_mode.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';

void onChangedEdit(bool value) {
  if (value) {
     cameraMode = CameraMode.Free;
     EditState.cursorSetToPlayer();
     GameState.player.message.value = "-press arrow keys to move\n\n-press tab to play";
     GameState.player.messageTimer = 300;
  } else {
    cameraMode = CameraMode.Chase;
    if (sceneEditable.value){
      GameState.player.message.value = "press tab to edit";
    }
  }
}

