

import 'package:gamestream_flutter/gamestream/isometric_engine/isometric_player.dart';
import 'package:gamestream_flutter/library.dart';

import 'game_isometric.dart';

class GameIsometricMouse {
  static IsometricPlayer get player => gamestream.isometricEngine.player;
  
  static double get positionX => GameIsometric.convertWorldToGridX(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  static double get positionY => GameIsometric.convertWorldToGridY(engine.mouseWorldX, engine.mouseWorldY) + player.position.z;
  static double get positionZ => player.position.z;

  static int get nodeIndex => gamestream.isometricEngine.nodes.getNodeIndex(positionX, positionY, positionZ);
  static double get playerAngle => angleBetween(player.position.x, player.position.y, positionX, positionY);
  static double get playerDistance => distanceBetween(player.position.x, player.position.y, positionX, positionY);

  static bool get inBounds {
    return !gamestream.isometricEngine.clientState.outOfBoundsXYZ(positionX, positionY, positionZ);
  }
}