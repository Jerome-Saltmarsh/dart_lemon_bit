
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';

class CaptureTheFlagGuardTower extends IsometricGameObject {
  CaptureTheFlagGuardTower({
    required super.x,
    required super.y,
    required super.z,
    required super.id,
  }) :super(type: ItemType.GameObjects_Guard_Tower);
}