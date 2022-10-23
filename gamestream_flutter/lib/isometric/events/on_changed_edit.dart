

import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_editor.dart';
import 'package:gamestream_flutter/isometric/watches/scene_meta_data.dart';

void onChangedEdit(bool value) {
  if (value) {
     GameState.cameraModeSetFree();
     GameEditor.cursorSetToPlayer();
     GameState.player.message.value = "-press arrow keys to move\n\n-press tab to play";
     GameState.player.messageTimer = 300;
  } else {
    GameState.cameraModeSetChase();
    if (sceneEditable.value){
      GameState.player.message.value = "press tab to edit";
    }
  }
}

