

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
    required double radius,
  }) : super(x, y, radius) {
    maxHealth = health;
  }
}