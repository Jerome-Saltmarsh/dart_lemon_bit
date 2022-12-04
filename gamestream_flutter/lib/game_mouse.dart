
import 'package:gamestream_flutter/library.dart';

class GameMouse {
  static double get positionX => GameConvert.convertWorldToGridX(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  static double get positionY => GameConvert.convertWorldToGridY(Engine.mouseWorldX, Engine.mouseWorldY) + GamePlayer.position.z;
  static double get positionZ => GamePlayer.position.z;

  static int get nodeIndex => GameQueries.getNodeIndex(positionX, positionY, positionZ);
  static double get playerAngle => Engine.calculateAngleBetween(GamePlayer.position.x, GamePlayer.position.y, positionX, positionY);
}