import '../common/ObjectType.dart';
import 'Collider.dart';

class EnvironmentObject extends Collider {
  ObjectType type;

  EnvironmentObject({
    required double x,
    required double y,
    required this.type
  }) : super(x, y, _getRadius(type)) {
    this.x = x;
    this.y = y;

    // TODO Forbidden game logic inside data class
    if (type == ObjectType.Rock_Small){
      collidable = false;
    }
    // TODO Forbidden game logic inside data class
    if (type == ObjectType.LongGrass){
      collidable = false;
    }
    // TODO Forbidden game logic inside data class
    if (type == ObjectType.Tree_Stump){
      collidable = false;
    }
  }
}

double _getRadius(ObjectType type){
  return const <ObjectType, double> {
    ObjectType.House01: 40,
    ObjectType.House02: 40,
    ObjectType.Tree01: 7,
    ObjectType.Rock: 14,
    ObjectType.Torch: 9,
    ObjectType.Tree_Stump: 7,
    ObjectType.Rock_Small: 4,
    ObjectType.Grave: 13,
  }[type] ?? 0;
}