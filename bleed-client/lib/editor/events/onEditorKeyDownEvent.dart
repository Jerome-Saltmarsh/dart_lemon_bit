import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/editor/state/mouseWorldStart.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:bleed_client/state/game.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';

void onEditorKeyDownEvent(RawKeyDownEvent event){
  if (event.logicalKey == LogicalKeyboardKey.keyC) {
    for (Vector2 position in game.crates) {
      if (!position.isZero) continue;
      position.x = mouseWorldX;
      position.y = mouseWorldY;
      redrawCanvas();
      return;
    }
  }

  final double v = 1.5;
  final EnvironmentObject? selectedObject = editor.selectedObject.value;

  if (selectedObject != null){
    if (event.logicalKey == LogicalKeyboardKey.keyW) {
        selectedObject.y -= v;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyS) {
        selectedObject.y += v;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyA) {
        selectedObject.x -= v;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyD) {
        selectedObject.x += v;
    }
  }

  if (event.logicalKey == LogicalKeyboardKey.delete) {
    editor.deleteSelected();
  }
  if (event.logicalKey == LogicalKeyboardKey.space && !panning) {
    panning = true;
    mouseWorldStart = mouseWorld;
  }
}
