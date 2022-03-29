

import 'GameObject.dart';

class DynamicObject extends GameObject {

  late int maxHealth;
  late int health;

  DynamicObject({
    required double x,
    required double y,
    required this.health
  }) : super(x, y) {
    maxHealth = health;
  }
}