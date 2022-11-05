import 'package:gamestream_flutter/library.dart';

class GamePlayer {
  static final weapon = Watch(0);
  static final body = Watch(0);
  static final head = Watch(0);
  static final legs = Watch(0);
  static final previousPosition = Vector3();
  static var position = Vector3();
  static var runningToTarget = false;
  static var targetCategory = TargetCategory.Nothing;
  static var targetPosition = Vector3();
  static var aimTargetCategory = TargetCategory.Nothing;
  static var aimTargetType = TargetCategory.Nothing;
  static var aimTargetSubType = TargetCategory.Nothing;
  static var aimTargetName = "";
  static var aimTargetPosition = Vector3();

  static double get renderX => GameConvert.convertV3ToRenderX(position);
  static double get renderY => GameConvert.convertV3ToRenderY(position);

  static double get positionScreenX => Engine.worldToScreenX(position.renderX);
  static double get positionScreenY => Engine.worldToScreenY(position.renderX);
}