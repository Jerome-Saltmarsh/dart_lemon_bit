import '../classes.dart';
import '../common/ObjectType.dart';

class EnvironmentObject extends GameObject {
  EnvironmentObjectType type;

  EnvironmentObject({
    double x = 0,
    double y = 0,
    this.type = EnvironmentObjectType.House01
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
        radius = 10;
        break;
      case EnvironmentObjectType.Tree02:
        radius = 10;
        break;
      case EnvironmentObjectType.Rock:
        radius = 17;
        break;
    }
  }
}
