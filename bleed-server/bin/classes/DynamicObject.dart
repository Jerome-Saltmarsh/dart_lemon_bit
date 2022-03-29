

import '../common/DynamicObjectType.dart';
import 'GameObject.dart';

class DynamicObject extends GameObject {

  late DynamicObjectType type;
  late int maxHealth;
  late int health;

  DynamicObject({
    required this.type,
    required double x,
    required double y,
    required this.health
  }) : super(x, y) {
    maxHealth = health;
  }
}