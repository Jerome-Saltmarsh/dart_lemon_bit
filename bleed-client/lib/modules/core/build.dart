

import 'package:bleed_client/assets.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/core/buildLoadingScreen.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_engine/game.dart';

import 'init.dart';
import 'render.dart';
import 'update.dart';

class CoreBuild {

  Widget gameStream(){
    return Game(
      title: core.state.title,
      init: init,
      update: update,
      buildUI: buildView,
      drawCanvas: drawCanvas2,
      drawCanvasAfterUpdate: true,
      backgroundColor: colours.black,
      buildLoadingScreen: buildLoadingScreen,
      themeData: themes.jetbrains,
    );
  }
}