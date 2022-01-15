
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';

import '../assets.dart';
import 'buildLoadingScreen.dart';
import 'drawCanvas.dart';
import 'init.dart';
import 'update.dart';

Widget buildGameStream(){
  return Game(
    title: "GAMESTREAM",
    init: init,
    update: update,
    buildUI: buildView,
    drawCanvas: drawCanvas,
    drawCanvasAfterUpdate: true,
    backgroundColor: colours.black,
    buildLoadingScreen: buildLoadingScreen,
    themeData: themes.jetbrains,
  );
}