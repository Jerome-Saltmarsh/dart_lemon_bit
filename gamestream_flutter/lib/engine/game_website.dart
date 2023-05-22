
import 'dart:ui';

import 'package:flutter/src/widgets/framework.dart';
import 'package:gamestream_flutter/game_website.dart' as gw;
import 'package:gamestream_flutter/library.dart';

import 'game.dart';

class GameWebsite extends Game {

  @override
  Widget buildUI(BuildContext context) {
    return gw.GameWebsite.buildUI(context);
  }

  @override
  void drawCanvas(Canvas canvas, Size size) {
    // TODO: implement drawCanvas
  }

  @override
  void onActivated() {
    GameAudio.musicStop();
    Engine.fullScreenExit();
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    // TODO: implement renderForeground
  }

  @override
  void update() {
    // TODO: implement update
  }
}