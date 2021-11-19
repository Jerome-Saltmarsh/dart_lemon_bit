import '../common/enums/ObjectType.dart';
import 'GameObject.dart';

class EnvironmentObject extends GameObject {
  ObjectType type;

  EnvironmentObject({
    required double x,
    required double y,
    required this.type
  }) : super(x, y) {
    this.x = x;
    this.y = y;
    // TODO Forbidden game logic inside data class
    radius = _getRadius(type);

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

// state doesn't belong in classes directory
final Map<ObjectType, double> _radiusMap = {
  ObjectType.House01: 40,
  ObjectType.House02: 40,
  ObjectType.Tree01: 8,
  ObjectType.Tree02: 8,
  ObjectType.Rock: 14,
  ObjectType.Torch: 10,
  ObjectType.Tree_Stump: 8,
  ObjectType.Rock_Small: 4,
  ObjectType.Grave: 13,
};

double _getRadius(ObjectType type){
  if (_radiusMap.containsKey(type)){
    return _radiusMap[type] ?? 0;
  }
  return 0;
}