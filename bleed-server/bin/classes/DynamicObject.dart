

import '../common/DynamicObjectType.dart';
import 'Collider.dart';
import 'components.dart';

class DynamicObject extends Collider with Health {
  late int type; // DynamicObjectType.dart
  var respawnDuration = 5000;

  DynamicObject({
    required this.type,
    required double x,
    required double y,
    required int health,
  }) : super(x: x, y: y, radius: const<int, double> {
    DynamicObjectType.Rock: 10,
    DynamicObjectType.Tree: 7,
    DynamicObjectType.Grass: 7,
    DynamicObjectType.Pot: 12,
    DynamicObjectType.Crate: 12,
  }[type] ?? 10) {
    maxHealth = health;
    this.health = health;
  }
}