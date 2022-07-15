import 'dart:math';

import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/actions/action_toggle_inventory.dart';
import 'package:gamestream_flutter/isometric/camera.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/editor/editor.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
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
  }

  if (playModeEdit) {
    if (key == PhysicalKeyboardKey.keyG){
      cameraSetPositionGrid(edit.row.value, edit.column.value, edit.z.value);
    }
    if (key == PhysicalKeyboardKey.keyY){
      editor.actions.elevate();
    }
    if (key == PhysicalKeyboardKey.arrowUp){
      if (keyPressed(LogicalKeyboardKey.shiftLeft)){
        edit.z.value++;
      } else {
        edit.row.value--;
      }
    }
    if (key == PhysicalKeyboardKey.arrowRight){
      edit.column.value--;
    }
    if (key == PhysicalKeyboardKey.arrowDown){
      if (keyPressed(LogicalKeyboardKey.shiftLeft)){
        edit.z.value--;
      } else {
        edit.row.value = min(edit.row.value + 1, gridTotalRows - 1);
      }
    }
    if (key == PhysicalKeyboardKey.arrowLeft){
      edit.column.value++;
    }
    edit.type.value = grid[edit.z.value][edit.row.value][edit.column.value];
  }
}

