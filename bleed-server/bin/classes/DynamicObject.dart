

import '../common/DynamicObjectType.dart';
import 'Collider.dart';

class DynamicObject extends Collider {
  late DynamicObjectType type;
  late int maxHealth;
  late int health;

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