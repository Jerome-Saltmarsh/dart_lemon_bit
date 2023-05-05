
import 'package:gamestream_flutter/library.dart';

class GameMouse {
  static double get positionX => GameConvert.convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  static double get positionY => GameConvert.convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  static double get positionZ => GamePlayer.position.z;

  static int get nodeIndex => GameQueries.getNodeIndex(positionX, positionY, positionZ);
  static double get playerAngle => angleBetween(GamePlayer.position.x, GamePlayer.position.y, positionX, positionY);
  static double get playerDistance => distanceBetween(GamePlayer.position.x, GamePlayer.position.y, positionX, positionY);

  static bool get inBounds {
    return !GameState.outOfBoundsXYZ(positionX, positionY, positionZ);
  }
}