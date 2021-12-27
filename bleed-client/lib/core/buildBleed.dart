
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';

import 'buildLoadingScreen.dart';
import 'drawCanvas.dart';
import 'init.dart';
import 'update.dart';

Widget buildBleed(){
  return Game(
    title: "BLEED",
    init: init,
    update: update,
    buildUI: buildView,
    drawCanvas: drawCanvas,
    drawCanvasAfterUpdate: false,
    backgroundColor: colours.white,
    buildLoadingScreen: buildLoadingScreen
  );
}