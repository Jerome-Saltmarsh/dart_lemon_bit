

import '../common/DynamicObjectType.dart';
import 'Collider.dart';

class DynamicObject extends Collider {
  late int type; // DynamicObjectType.dart
  late int maxHealth;
  late int health;
  var respawnDuration = 5000;

  DynamicObject({
    required this.type,
    required double x,
    required double y,
    required this.health,
  }) : super(x, y, const<int, double> {
    DynamicObjectType.Rock: 10,
    DynamicObjectType.Tree: 7,
    DynamicObjectType.Grass: 7,
    DynamicObjectType.Pot: 12,
    DynamicObjectType.Crate: 12,
  }[type] ?? 10) {
    maxHealth = health;
  }
}