

import '../common/DynamicObjectType.dart';
import '../common/MaterialType.dart';
import 'Collider.dart';
import 'components.dart';

class DynamicObject extends Collider with Health, Material, Id {
  late int type; // DynamicObjectType.dart
  var respawnDuration = 5000;

  bool get isRock => type == DynamicObjectType.Rock;
  bool get isTree => type == DynamicObjectType.Tree;

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

    material = const <int, MaterialType> {
        DynamicObjectType.Chest: MaterialType.Metal,
        DynamicObjectType.Rock: MaterialType.Rock,
        DynamicObjectType.Tree: MaterialType.Wood,
        DynamicObjectType.Grass: MaterialType.Plant,
        DynamicObjectType.Palisade: MaterialType.Wood,
    }[type] ?? MaterialType.Wood;
  }
}