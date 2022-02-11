

import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/modules/editor/actions.dart';
import 'package:bleed_client/modules/editor/scope.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

import 'enums.dart';

class EditorEvents with EditorScope {

  final EditorActions actions;
  EditorEvents(this.actions);

  onActivated(){
    print("editor.events.onActivated()");
    modules.isometric.actions.setHour(12);
    register();
  }

  register() {
    print("editor.events.register()");
    engine.callbacks.onLeftClicked = onMouseLeftClicked;
    engine.callbacks.onMouseDragging = onMouseDragging;

    engine.state.keyPressedHandlers = {
      config.keys.pan: actions.panModeActivate,
      config.keys.delete: actions.deleteSelected,
      config.keys.move: actions.moveSelectedToMouse,
    };

    engine.state.keyReleasedHandlers = {
      config.keys.pan:  actions.panModeDeactivate,
    };

    editor.state.selected.onChanged(onSelectedObjectChanged);
  }

  void onMouseMoved(Vector2 position, Vector2 previous) {
    final positionX = screenToWorldX(position.x);
    final positionY = screenToWorldY(position.y);
    final previousX = screenToWorldX(previous.x);
    final previousY = screenToWorldY(previous.y);
    final diffX = previousX - positionX;
    final diffY = previousY - positionY;
    final zoom = engine.state.zoom;
    engine.state.camera.x += diffX * zoom;
    engine.state.camera.y += diffY * zoom;
  }

  void onMouseDragging(){
    if (editor.state.selectedCollectable > -1) {
      game.collectables[editor.state.selectedCollectable + 1] = mouseWorldX.toInt();
      game.collectables[editor.state.selectedCollectable + 2] = mouseWorldY.toInt();
      return;
    }

    setTileAtMouse(editor.state.tile.value);
  }

  void onSelectedObjectChanged(Vector2? value) {
    print("editor.events.onSelectedObjectChanged($value)");
    engine.actions.redrawCanvas();
  }

  void onMouseLeftClicked() {
    print("editor.events.onMouseLeftClicked()");

    final closest =  getClosest(mouseWorldX, mouseWorldY, [
      state.environmentObjects,
      state.teamSpawnPoints,
      state.items,
      state.characters,
    ]);

    if (closest != null){
      final closestDistance = distanceFromMouse(closest.x, closest.y);
      final double selectRadius = 25;
      if (closestDistance <= selectRadius) {
        state.selected.value = closest;
        return;
      }
    }

    if (state.selected.isNotNull){
      actions.deleteSelected();
      return;
    }

    if (modules.isometric.properties.tileAtMouse == Tile.Boundary){
      return;
    }

    switch (state.tab.value) {
      case ToolTab.Units:
        state.characters.add(Character(type: editor.state.characterType.value, x: mouseWorldX, y: mouseWorldY));
        break;
      case ToolTab.Tiles:
        actions.setTile();
        break;
      case ToolTab.Objects:
        actions.addEnvironmentObject();
        break;
      case ToolTab.All:
        break;
      case ToolTab.Misc:
        break;
      case ToolTab.Items:
        state.items.add(
            Item(type: state.itemType.value, x: mouseWorldX, y: mouseWorldY)
        );
        break;
    }

    engine.actions.redrawCanvas();
  }

  void onTorchAdded(){
    print("editor.events.onTorchAdded()");
    // modules.isometric.actions.updateTileRender();
    // modules.isometric.actions.applyEnvironmentObjectsToBakeMapping();
    // modules.isometric.actions.setBakeMapToAmbientLight();
    // modules.isometric.actions.setDynamicMapToAmbientLight();
  }

  void onEditorKeyDownEvent(RawKeyDownEvent event){
    if (event.logicalKey == LogicalKeyboardKey.keyC) {
      for (Vector2 position in game.crates) {
        position.x = mouseWorldX;
        position.y = mouseWorldY;
        engine.actions.redrawCanvas();
        return;
      }
    }

    final double v = 1.5;
    final Vector2? selectedObject = editor.state.selected.value;

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
    // if (event.logicalKey == LogicalKeyboardKey.space && !state.panning) {
    //   state.panning = true;
    // }
  }
}
