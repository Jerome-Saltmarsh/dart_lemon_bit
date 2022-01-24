

import 'package:bleed_client/assets.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/core/buildLoadingScreen.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/ui/views.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_watch/watch_builder.dart';

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

  Widget buildLoadingScreen(BuildContext context) {
    final double _width = 300;
    final double _height = 50;
    return fullScreen(
      color: colours.black,
      child: WatchBuilder(core.state.download, (double value) {
        value = 0.6182;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: axis.main.center,
              children: [
                text("${core.state.title} ${(value * 100).toInt()}%", color: Colors.white),
                height8,
                Container(
                  width: _width,
                  height: _height,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.white,
                    width: _width * value,
                    height: _height,
                  ),
                )
              ],
            ),
          ],
        );
      }),
    );
  }
}