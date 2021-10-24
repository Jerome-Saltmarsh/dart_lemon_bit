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

    switch(type){
      case EnvironmentObjectType.House01:
        radius = 40;
        break;
      case EnvironmentObjectType.House02:
        radius = 40;
        break;
      case EnvironmentObjectType.Tree01:
        radius = 8;
        break;
      case EnvironmentObjectType.Tree02:
        radius = 8;
        break;
      case EnvironmentObjectType.Rock:
        radius = 14;
        break;
    }
  }
}
