import 'dart:math';

import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/actions/action_game_dialog_show_quests.dart';
import 'package:gamestream_flutter/isometric/actions/action_toggle_inventory.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:lemon_engine/engine.dart';

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

  if (key == PhysicalKeyboardKey.keyI){
    return actionToggleInventoryVisible();
  }

  if (key == PhysicalKeyboardKey.keyT){
    return actionGameDialogShowQuests();
  }

  if (playModeEdit) {
    if (key == PhysicalKeyboardKey.arrowUp){
      if (keyPressed(LogicalKeyboardKey.shiftLeft)){
        edit.z.value++;
        if (edit.z.value >= gridTotalZ) {
          edit.z.value = gridTotalZ - 1;
        }
      } else {
        edit.row.value--;
        if (edit.row.value < 0){
          edit.row.value = 0;
        }
      }
    }
    if (key == PhysicalKeyboardKey.arrowRight){
      edit.column.value--;
      if (edit.column.value < 0){
        edit.column.value = 0;
      }
    }
    if (key == PhysicalKeyboardKey.arrowDown){
      if (keyPressed(LogicalKeyboardKey.shiftLeft)){
        edit.z.value--;
        if (edit.z.value < 0){
          edit.z.value = 0;
        }
      } else {
        edit.row.value = min(edit.row.value + 1, gridTotalRows - 1);
      }
    }
    if (key == PhysicalKeyboardKey.arrowLeft){
      edit.column.value++;
      if (edit.column.value >= gridTotalColumns){
        edit.column.value = gridTotalColumns - 1;
      }
    }
    edit.type.value = grid[edit.z.value][edit.row.value][edit.column.value];
  }
}

