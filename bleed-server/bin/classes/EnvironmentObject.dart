import '../classes.dart';
import '../common/enums/EnvironmentObjectType.dart';

class EnvironmentObject extends GameObject {
  EnvironmentObjectType type;

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
    if (type == EnvironmentObjectType.Rock_Small){
      collidable = false;
    }
    // TODO Forbidden game logic inside data class
    if (type == EnvironmentObjectType.LongGrass){
      collidable = false;
    }
    // TODO Forbidden game logic inside data class
    if (type == EnvironmentObjectType.Tree_Stump){
      collidable = false;
    }
  }
}

// state doesn't belong in classes directory
final Map<EnvironmentObjectType, double> _radiusMap = {
  EnvironmentObjectType.House01: 40,
  EnvironmentObjectType.House02: 40,
  EnvironmentObjectType.Tree01: 8,
  EnvironmentObjectType.Tree02: 8,
  EnvironmentObjectType.Rock: 14,
  EnvironmentObjectType.Torch: 10,
  EnvironmentObjectType.Tree_Stump: 8,
  EnvironmentObjectType.Rock_Small: 4,
  EnvironmentObjectType.Grave: 13,
};

double _getRadius(EnvironmentObjectType type){
  if (_radiusMap.containsKey(type)){
    return _radiusMap[type] ?? 0;
  }
  return 0;
}