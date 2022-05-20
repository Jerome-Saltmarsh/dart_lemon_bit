import '../common/ObjectType.dart';
import 'Collider.dart';

class StaticObject extends Collider {
  ObjectType type;

  StaticObject({required double x, required double y, required this.type})
      : super(
            x: x,
            y: y,
            radius: const <ObjectType, double>{
                  ObjectType.House01: 40,
                  ObjectType.House02: 40,
                  ObjectType.Tree: 7,
                  ObjectType.Rock: 14,
                  ObjectType.Torch: 9,
                  ObjectType.Tree_Stump: 7,
                  ObjectType.Rock_Small: 4,
                  ObjectType.Grave: 13,
                  ObjectType.Fireplace: 13,
                }[type] ??
                0) {
    this.x = x;
    this.y = y;

    // TODO Forbidden game logic inside data class
    if (type == ObjectType.Rock_Small) {
      collidable = false;
    }
    // TODO Forbidden game logic inside data class
    if (type == ObjectType.Long_Grass) {
      collidable = false;
    }
    // TODO Forbidden game logic inside data class
    if (type == ObjectType.Tree_Stump) {
      collidable = false;
    }
  }
}
