

import 'package:gamestream_flutter/library.dart';

import 'game_isometric.dart';

class GameIsometricMouse {
  static double get positionX => GameIsometric.convertWorldToGridX(engine.mouseWorldX, engine.mouseWorldY) + GamePlayer.position.z;
  static double get positionY => GameIsometric.convertWorldToGridY(engine.mouseWorldX, engine.mouseWorldY) + GamePlayer.position.z;
  static double get positionZ => GamePlayer.position.z;

  static int get nodeIndex => gamestream.games.isometric.nodes.getNodeIndex(positionX, positionY, positionZ);
  static double get playerAngle => angleBetween(GamePlayer.position.x, GamePlayer.position.y, positionX, positionY);
  static double get playerDistance => distanceBetween(GamePlayer.position.x, GamePlayer.position.y, positionX, positionY);

  static bool get inBounds {
    return !gamestream.games.isometric.clientState.outOfBoundsXYZ(positionX, positionY, positionZ);
  }
}