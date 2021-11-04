import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/functions/update.dart';
import 'package:bleed_client/init.dart';
import 'package:bleed_client/render/drawCanvas.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(
    title: "BLEED",
    init: bleedInit,
    update: updateGame,
    buildUI: buildBleedUI,
    drawCanvas: drawCanvasBleed,
  ));
}
