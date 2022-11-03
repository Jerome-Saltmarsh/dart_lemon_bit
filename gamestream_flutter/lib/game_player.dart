import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/library.dart';

class GamePlayer {
  static final weapons = Watch(<Weapon>[]);
  static final weapon = AttackSlot();
  static final bodyType = Watch(0);
  static final headType = Watch(0);
  static final pantsType = Watch(0);
  static Vector3 position = Vector3();
  static Vector3 target = Vector3();
  static bool runningToTarget = false;

  static double get renderX => GameConvert.convertV3ToRenderX(position);
  static double get renderY => GameConvert.convertV3ToRenderY(position);

  static double get positionScreenX => Engine.worldToScreenX(position.renderX);
  static double get positionScreenY => Engine.worldToScreenY(position.renderX);
}