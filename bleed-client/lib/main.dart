import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/core/update.dart';
import 'package:bleed_client/core/init.dart';
import 'package:bleed_client/render/drawCanvas.dart';
import 'package:flutter/material.dart';

import 'core/buildUI.dart';

void main() {
  runApp(GameWidget(
    title: "BLEED",
    init: init,
    update: update,
    buildUI: buildUI,
    drawCanvas: drawCanvasBleed,
  ));
}
