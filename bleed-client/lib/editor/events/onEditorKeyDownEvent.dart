import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/editor/state/mouseWorldStart.dart';
import 'package:bleed_client/editor/state/panning.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/environmentObjects.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/editor/state/editState.dart';
import 'package:flutter/services.dart';

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

  double v = 1.5;
  if (event.logicalKey == LogicalKeyboardKey.keyW) {
    if(editState.selectedObject != null) {
      editState.selectedObject.y -= v;
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.keyS) {
    if(editState.selectedObject != null) {
      editState.selectedObject.y += v;
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.keyA) {
    if(editState.selectedObject != null) {
      editState.selectedObject.x -= v;
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.keyD) {
    if(editState.selectedObject != null) {
      editState.selectedObject.x += v;
    }
  }

  if (event.logicalKey == LogicalKeyboardKey.delete) {
    if (editState.selectedBlock != null) {
      blockHouses.remove(editState.selectedBlock);
      editState.selectedBlock = null;
    }

    if(editState.selectedObject != null){
      environmentObjects.remove(editState.selectedObject);
      editState.selectedObject = null;
      redrawCanvas();
    }
  }
  if (event.logicalKey == LogicalKeyboardKey.space && !panning) {
    panning = true;
    mouseWorldStart = mouseWorld;
  }
}
