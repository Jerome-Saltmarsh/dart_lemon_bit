

import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/editor/mixin.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_math/Vector2.dart';

import 'enums.dart';

class EditorEvents with EditorScope {

  register() {
    print("editor.events.register()");
    keyboardEvents.listen(onKeyboardEvent);
    engine.callbacks.onLeftClicked = onMouseLeftClicked;
    engine.callbacks.onMouseDragging = onMouseDragging;
    engine.callbacks.onMouseMoved = onMouseMoved;
    engine.callbacks.onMouseScroll = onMouseScroll;
    editor.state.selectedObject.onChanged(onSelectedObjectChanged);
  }

  void onMouseMoved(Offset position, Offset previous){
    if (state.panning) {
      final positionX = screenToWorldX(position.dx);
      final positionY = screenToWorldY(position.dy);
      final previousX = screenToWorldX(previous.dx);
      final previousY = screenToWorldY(previous.dy);
      final diffX = previousX - positionX;
      final diffY = previousY - positionY;
      engine.state.camera.x += diffX * engine.state.zoom;
      engine.state.camera.y += diffY * engine.state.zoom;
    }
  }

  void onMouseDragging(){
    if (editor.state.selectedCollectable > -1) {
      game.collectables[editor.state.selectedCollectable + 1] = mouseWorldX.toInt();
      game.collectables[editor.state.selectedCollectable + 2] = mouseWorldY.toInt();
      return;
    }

    setTileAtMouse(editor.state.tile.value);
  }

  onSelectedObjectChanged(Vector2? value) {
    print("editor._onSelectedObjectChanged($value)");
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
      EnvironmentObject closest = closestToMouse(game.environmentObjects);
      double closestDistance = distanceFromMouse(closest.x, closest.y);
      if (closestDistance <= selectRadius) {
        state.selectedObject.value = closest;
        return;
      } else if (state.selectedObject.value != null) {
        state.selectedObject.value = null;
        return;
      }
    }

    if (state.characters.isNotEmpty){
       final closestCharacter = closestToMouse(state.characters);
    }


    switch (state.tab.value) {
      case ToolTab.Units:
        state.characters.add(Character(type: editor.state.characterType.value, x: mouseWorldX, y: mouseWorldY));
        break;
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
    final Vector2? selectedObject = editor.state.selectedObject.value;

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