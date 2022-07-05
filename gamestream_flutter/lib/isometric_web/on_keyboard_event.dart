import 'dart:math';

import 'package:flutter/services.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/lower_tile_mode.dart';
import 'package:lemon_engine/engine.dart';

void onKeyboardEvent(RawKeyEvent event){
  if (event is RawKeyDownEvent){
    if (event.physicalKey == PhysicalKeyboardKey.space){
      lowerTileMode = !lowerTileMode;
    }
    if (event.physicalKey == PhysicalKeyboardKey.arrowUp){
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
    if (event.physicalKey == PhysicalKeyboardKey.arrowRight){
      edit.column.value--;
      if (edit.column.value < 0){
        edit.column.value = 0;
      }
    }
    if (event.physicalKey == PhysicalKeyboardKey.arrowDown){
      if (keyPressed(LogicalKeyboardKey.shiftLeft)){
        edit.z.value--;
        if (edit.z.value < 0){
          edit.z.value = 0;
        }
      } else {
        edit.row.value = min(edit.row.value + 1, gridTotalRows - 1);
      }
    }
    if (event.physicalKey == PhysicalKeyboardKey.arrowLeft){
      edit.column.value++;
      if (edit.column.value >= gridTotalColumns){
        edit.column.value = gridTotalColumns - 1;
      }
    }
    edit.type.value = grid[edit.z.value][edit.row.value][edit.column.value];
    return;
  }
  if (event is RawKeyUpEvent){
    return;
  }
}

