

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
    required this.health
  }) : super(x, y, 20) {
    maxHealth = health;
  }
}