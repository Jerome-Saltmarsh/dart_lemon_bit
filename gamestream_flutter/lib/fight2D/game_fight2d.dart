
import 'dart:ui';

import 'package:gamestream_flutter/library.dart';

abstract class Game {
  void drawCanvas(Canvas canvas, Size size);
  void renderForeground(Canvas canvas, Size size);
}

class GameFight2D extends Game {
  @override
  void drawCanvas(Canvas canvas, Size size) {
      Engine.cameraCenter(0, 0);
      Engine.zoom = 1.0;
      Engine.targetZoom = 1.0;
      canvas.drawCircle(const Offset(0, 0), 100, Engine.paint);
  }

  @override
  void renderForeground(Canvas canvas, Size size) {
    // TODO: implement renderForeground
  }
}

class Games {
  static Game? currentGame;

  static final fight2D = GameFight2D();
}