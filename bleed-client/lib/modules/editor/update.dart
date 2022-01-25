import 'package:bleed_client/modules.dart';
import 'package:bleed_client/update.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/camera.dart';
import 'package:lemon_engine/state/zoom.dart';

void updateEditor() {
  updateZoom();
  redrawCanvas();
  // if (editor.state.panning) {
  //   Offset mouseWorldDiff = editor.state.mouseWorldStart - mouseWorld;
  //   camera.y += mouseWorldDiff.dy * zoom;
  //   camera.x += mouseWorldDiff.dx * zoom;
  // }
}
