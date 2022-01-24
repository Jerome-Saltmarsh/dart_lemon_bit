import 'package:bleed_client/update.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
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
    events.handleMouseDrag();
    updateZoom();
    redrawCanvas();
    if (state.panning) {
      Offset mouseWorldDiff = state.mouseWorldStart - mouseWorld;
      camera.y += mouseWorldDiff.dy * zoom;
      camera.x += mouseWorldDiff.dx * zoom;
    }
  }
}
