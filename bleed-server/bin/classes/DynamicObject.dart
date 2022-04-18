

import 'Collider.dart';

class DynamicObject extends Collider {
  late int type; // DynamicObjectType.dart
  late int maxHealth;
  late int health;
  var respawnDuration = 1000;

  DynamicObject({
    required this.type,
    required double x,
    required double y,
    required this.health,
  }) : super(x, y, 15) {
    maxHealth = health;
  }
}