import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/editor/actions.dart';
import 'package:bleed_client/editor/builder.dart';
import 'package:bleed_client/editor/config.dart';
import 'package:bleed_client/editor/events.dart';
import 'package:bleed_client/editor/state.dart';
import 'package:bleed_client/update.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';

final _EditorModule editor = _EditorModule();

class _EditorModule {
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
