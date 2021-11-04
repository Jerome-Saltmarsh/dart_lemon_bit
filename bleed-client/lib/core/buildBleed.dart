
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:flutter/material.dart';

import 'buildUI.dart';
import 'drawCanvas.dart';
import 'init.dart';
import 'update.dart';

Widget buildBleed(){
  return GameWidget(
    title: "BLEED",
    init: init,
    update: update,
    buildUI: buildUI,
    drawCanvas: drawCanvas,
    drawCanvasAfterUpdate: false,
  );
}