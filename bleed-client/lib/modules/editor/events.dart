

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/editor/mixin.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_math/Vector2.dart';

import 'enums.dart';

class EditorEvents with EditorScope {

  register() {
    print("editor.events.register()");
    keyboardEvents.listen(onKeyboardEvent);
    engine.callbacks.onLeftClicked = onMouseLeftClicked;
    editor.state.selectedObject.onChanged(onSelectedObjectChanged);
  }

  void onMouseLeftDown(int frames){
      print("onMouseLeftDown($frames)");
  }

  onSelectedObjectChanged(EnvironmentObject? environmentObject) {
    print("editor._onSelectedObjectChanged($environmentObject)");
    redrawCanvas();
  }

  onKeyboardEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      onEditorKeyDownEvent(event);
      return;
    }
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == editor.config.keys.pan) {
        state.panning = false;
      }
      if (event.logicalKey == config.keys.selectTileType) {
        state.tile.value = tileAtMouse;
      }
    }
  }

  onMouseLeftClicked() {
    final double selectRadius = 25;
    if (game.environmentObjects.isNotEmpty) {
      EnvironmentObject closest =
      findClosest(game.environmentObjects, mouseWorldX, mouseWorldY);
      double closestDistance = distanceFromMouse(closest.x, closest.y);
      if (closestDistance <= selectRadius) {
        state.selectedObject.value = closest;
        return;
      } else if (state.selectedObject.value != null) {
        state.selectedObject.value = null;
        return;
      }
    }

    switch (editor.state.tab.value) {
      case ToolTab.Tiles:
        setTileAtMouse(editor.state.tile.value);
        break;
      case ToolTab.Objects:
        game.environmentObjects.add(EnvironmentObject(
          x: mouseWorldX,
          y: mouseWorldY,
          type: editor.state.objectType.value,
          radius: 0,
        ));
        redrawCanvas();
        break;
      case ToolTab.All:
        break;
      case ToolTab.Misc:
        break;
    }

    redrawCanvas();
  }

  void onEditorKeyDownEvent(RawKeyDownEvent event){
    if (event.logicalKey == LogicalKeyboardKey.keyC) {
      for (Vector2 position in game.crates) {
        position.x = mouseWorldX;
        position.y = mouseWorldY;
        redrawCanvas();
        return;
      }
    }

    final double v = 1.5;
    final EnvironmentObject? selectedObject = editor.state.selectedObject.value;

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
      editor.actions.deleteSelected();
    }
    if (event.logicalKey == LogicalKeyboardKey.space && !state.panning) {
      state.panning = true;
      state.mouseWorldStart = mouseWorld;
    }
  }
}