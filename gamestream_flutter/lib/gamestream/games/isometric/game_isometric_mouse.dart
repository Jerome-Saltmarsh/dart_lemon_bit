

import 'package:gamestream_flutter/library.dart';

import 'game_isometric.dart';

class GameIsometricMouse {
  static double get positionX => GameIsometric.convertWorldToGridX(engine.mouseWorldX, engine.mouseWorldY) + gamestream.games.isometric.player.position.z;
  static double get positionY => GameIsometric.convertWorldToGridY(engine.mouseWorldX, engine.mouseWorldY) + gamestream.games.isometric.player.position.z;
  static double get positionZ => gamestream.games.isometric.player.position.z;

  static int get nodeIndex => gamestream.games.isometric.nodes.getNodeIndex(positionX, positionY, positionZ);
  static double get playerAngle => angleBetween(gamestream.games.isometric.player.position.x, gamestream.games.isometric.player.position.y, positionX, positionY);
  static double get playerDistance => distanceBetween(gamestream.games.isometric.player.position.x, gamestream.games.isometric.player.position.y, positionX, positionY);

  static bool get inBounds {
    return !gamestream.games.isometric.clientState.outOfBoundsXYZ(positionX, positionY, positionZ);
  }
}