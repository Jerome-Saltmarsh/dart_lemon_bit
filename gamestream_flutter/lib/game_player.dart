import 'package:gamestream_flutter/library.dart';

class GamePlayer {
  static Vector3 position = Vector3();
  
  static double get renderX => GameConvert.convertV3ToRenderX(position);
  static double get renderY => GameConvert.convertV3ToRenderY(position);
}