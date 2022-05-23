

import '../common/game_object_type.dart';
import '../common/MaterialType.dart';
import 'Collider.dart';
import 'components.dart';

class GameObject extends Collider with Health, Material, Id {
  late int type; // game_object_type.dart
  var respawnDuration = 0;

  bool get isRock => type == GameObjectType.Rock;
  bool get isTree => type == GameObjectType.Tree;

  GameObject({
    required this.type,
    required double x,
    required double y,
    required int health,
  }) : super(x: x, y: y, radius: const<int, double> {
    GameObjectType.Rock: 10,
    GameObjectType.Tree: 7,
    GameObjectType.Grass: 7,
    GameObjectType.Torch: 7,
    GameObjectType.Rock_Small: 4,
  }[type] ?? 10) {
    maxHealth = health;
    this.health = health;

    material = const <int, MaterialType> {
        GameObjectType.Chest: MaterialType.Metal,
        GameObjectType.Rock: MaterialType.Rock,
        GameObjectType.Tree: MaterialType.Wood,
        GameObjectType.Grass: MaterialType.Plant,
        GameObjectType.House: MaterialType.Wood,
    }[type] ?? MaterialType.Wood;
  }
}