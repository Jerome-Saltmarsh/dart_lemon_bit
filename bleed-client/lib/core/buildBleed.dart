
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';

import 'buildUI.dart';
import 'drawCanvas.dart';
import 'init.dart';
import 'update.dart';

Widget buildBleed(){
  return Game(
    title: "BLEED",
    init: init,
    update: update,
    buildUI: buildUI,
    drawCanvas: drawCanvas,
    drawCanvasAfterUpdate: false,
  );
}