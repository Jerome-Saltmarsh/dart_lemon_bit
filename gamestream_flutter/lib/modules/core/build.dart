

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/assets.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/core/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/toString.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
import 'package:gamestream_flutter/ui/views.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'init.dart';

class CoreBuild {

  Widget gameStream(){
    return Game(
      title: core.state.title,
      init: init,
      update: (){},
      buildUI: buildUI,
      drawCanvas: null,
      drawCanvasAfterUpdate: true,
      backgroundColor: colours.black,
      buildLoadingScreen: buildLoadingScreen,
      themeData: themes.jetbrains,
      framesPerSecond: 35,
    );
  }

  Widget buildUI(BuildContext context) {
    return Stack(
      children: [
        buildWatchOperationStatus(),
        buildWatchErrorMessage(),
      ],
    );
  }

  Widget buildWatchOperationStatus(){
    return WatchBuilder(core.state.operationStatus, (OperationStatus operationStatus){
      if (operationStatus != OperationStatus.None){
        return _layoutOperationStatus(operationStatus);
      }
      return WatchBuilder(core.state.mode, (Mode mode) {
        if (mode == Mode.Editor) {
          return editor.build.buildEditorUI();
        }
        return watchAccount(buildAccount);
      });
    });
  }

  Widget _layoutOperationStatus(OperationStatus operationStatus) {
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