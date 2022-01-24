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

void updateEditor() {
  _handleMouseDrag();
  updateZoom();
  redrawCanvas();
  if (editor.state.panning) {
    Offset mouseWorldDiff = editor.state.mouseWorldStart - mouseWorld;
    camera.y += mouseWorldDiff.dy * zoom;
    camera.x += mouseWorldDiff.dx * zoom;
  }
}

void _handleMouseDrag() {
  if (!engine.state.mouseLeftDown.value) {
    return;
  }
  editor.events.onMouseLeftClicked();

  if (editor.state.selectedCollectable > -1) {
    game.collectables[editor.state.selectedCollectable + 1] = mouseWorldX.toInt();
    game.collectables[editor.state.selectedCollectable + 2] = mouseWorldY.toInt();
    return;
  }
  setTileAtMouse(editor.state.tile.value);
}