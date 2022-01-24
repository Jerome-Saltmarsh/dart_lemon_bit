import 'package:bleed_client/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/update.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';

import 'actions.dart';
import 'builder.dart';
import 'config.dart';
import 'events.dart';
import 'state.dart';

class EditorModule {
  final state = EditorState();
  final actions = EditorActions();
  final build = EditorBuilder();
  final events = EditorEvents();
  final config = EditorConfig();

  void update() {
    handleMouseDrag();
    updateZoom();
    redrawCanvas();
    if (state.panning) {
      Offset mouseWorldDiff = state.mouseWorldStart - mouseWorld;
      camera.y += mouseWorldDiff.dy * zoom;
      camera.x += mouseWorldDiff.dx * zoom;
    }
  }

  void handleMouseDrag() {
    if (engine.state.mouseLeftDownFrames.value == 0) {
      state.mouseDragClickProcess = false;
      return;
    }

    if (!state.mouseDragClickProcess) {
      state.mouseDragClickProcess = true;
      events.onMouseLeftClicked();
      return;
    }

    if (state.selectedCollectable > -1) {
      game.collectables[state.selectedCollectable + 1] = mouseWorldX.toInt();
      game.collectables[state.selectedCollectable + 2] = mouseWorldY.toInt();
      return;
    }

    setTileAtMouse(editor.state.tile.value);
  }

}
