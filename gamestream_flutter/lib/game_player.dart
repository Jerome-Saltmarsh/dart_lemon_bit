import 'package:gamestream_flutter/library.dart';

class GamePlayer {
  static final weapon = Watch(0);
  static final body = Watch(0);
  static final head = Watch(0);
  static final legs = Watch(0);
  static final alive = Watch(true);
  static final previousPosition = Vector3();
  static final storeItems = Watch(<int>[]);

  static var position = Vector3();
  static var runningToTarget = false;
  static var targetCategory = TargetCategory.Nothing;
  static var targetPosition = Vector3();
  static var aimTargetCategory = TargetCategory.Nothing;
  static var aimTargetType = 0;
  static var aimTargetName = "";
  static var aimTargetQuantity = 0;
  static var aimTargetPosition = Vector3();
  static final weaponCooldown = Watch(1.0);
  static final interpolating = Watch(true);
  static final target = Vector3();

  static var indexZ = 0;
  static var indexRow = 0;
  static var indexColumn = 0;

  static double get renderX => GameConvert.convertV3ToRenderX(position);
  static double get renderY => GameConvert.convertV3ToRenderY(position);
  static double get positionScreenX => Engine.worldToScreenX(position.renderX);
  static double get positionScreenY => Engine.worldToScreenY(position.renderX);
  static bool get interactModeTrading => ServerState.interactMode.value == InteractMode.Trading;
  static bool get dead => !alive.value;
  static bool get inBounds => GameQueries.inBoundsVector3(position);

  static bool isCharacter(Character character){
    return position.x == character.x && position.y == character.y && position.z == character.z;
  }
}