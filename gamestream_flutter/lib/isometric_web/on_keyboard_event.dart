
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/actions/action_toggle_inventory.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/editor/editor.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:lemon_engine/engine.dart';

import '../isometric/actions/action_game_dialog_show_map.dart';

void onKeyboardEvent(RawKeyEvent event){
  if (event is RawKeyDownEvent){
    return onRawKeyDownEvent(event);
  }
  if (event is RawKeyUpEvent){
    return;
  }
}

void onRawKeyDownEvent(RawKeyDownEvent event){
  final key = event.physicalKey;

  if (playModePlay) {
    if (key == PhysicalKeyboardKey.keyG) {
      sendClientRequestTeleport();
    }
    if (key == PhysicalKeyboardKey.keyI){
      return actionToggleInventoryVisible();
    }
    if (key == PhysicalKeyboardKey.keyT){
      return actionGameDialogShowQuests();
    }
    if (key == PhysicalKeyboardKey.keyM){
      return actionGameDialogShowMap();
    }
    if (key == PhysicalKeyboardKey.keyJ){
      sendClientRequestAttackBasic();
    }
    if (key == PhysicalKeyboardKey.keyK){
      sendClientRequestCasteBasic();
    }
  }

  if (playModeEdit) {
    if (key == PhysicalKeyboardKey.keyG){
      cameraSetPositionGrid(edit.row.value, edit.column.value, edit.z.value);
    }
    if (key == PhysicalKeyboardKey.keyY){
      editor.actions.elevate();
    }
    if (key == PhysicalKeyboardKey.keyH){
      editor.actions.lower();
    }
    if (key == PhysicalKeyboardKey.keyN){
      editor.actions.clear();
    }
    if (key == PhysicalKeyboardKey.keyE){
      edit.fill();
    }

    if (key == PhysicalKeyboardKey.arrowUp){
      if (shiftLeftDown){
        edit.z.value++;
      } else {
        edit.row.value--;
      }
    }
    if (key == PhysicalKeyboardKey.arrowRight){
      edit.column.value--;
    }
    if (key == PhysicalKeyboardKey.arrowDown){
      if (shiftLeftDown){
        edit.z.value--;
      } else {
        edit.row.value++;
      }
    }
    if (key == PhysicalKeyboardKey.arrowLeft){
      edit.column.value++;
    }
  }
}

bool get shiftLeftDown => keyPressed(LogicalKeyboardKey.shiftLeft);