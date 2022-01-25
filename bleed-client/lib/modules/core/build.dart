

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bleed_client/assets.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/flutterkit.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/toString.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/views.dart';
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
      buildUI: buildUI,
      drawCanvas: renderCore,
      drawCanvasAfterUpdate: true,
      backgroundColor: colours.black,
      buildLoadingScreen: buildLoadingScreen,
      themeData: themes.jetbrains,
    );
  }

  Widget buildUI(BuildContext context) {
    return Stack(
      children: [
        buildWatchGameMode(),
        buildWatchErrorMessage(),
      ],
    );
  }

  Widget buildWatchGameMode(){
    return WatchBuilder(core.state.mode, (Mode mode) {
      if (mode == Mode.Edit) {
        return editor.build.buildEditorUI();
      }
      return buildWatchOperationStatus();
    });
  }

  Widget buildWatchOperationStatus(){
    return WatchBuilder(core.state.operationStatus, (OperationStatus operationStatus){
      if (operationStatus != OperationStatus.None){
        return buildViewOperationStatus(operationStatus);
      }
      return watchAccount(buildAccount);
    });
  }

  Widget buildViewOperationStatus(OperationStatus operationStatus) {
    return layout(
        child: fullScreen(
          child: Row(
            mainAxisAlignment: axis.main.center,
            children: [
              AnimatedTextKit(repeatForever: true, animatedTexts: [
                RotateAnimatedText(enumString(operationStatus),
                    textStyle: TextStyle(color: Colors.white, fontSize: 45,
                        fontFamily: assets.fonts.libreBarcode39Text
                    )),
              ])
            ],
          ),
        )
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