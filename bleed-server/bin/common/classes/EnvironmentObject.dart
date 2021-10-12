import '../ObjectType.dart';
import '../mixins/Position.dart';

class EnvironmentObject with Position {
  EnvironmentObjectType type;

  EnvironmentObject({
    double x = 0,
    double y = 0,
    this.type = EnvironmentObjectType.House01
  }) {
    this.x = x;
    this.y = y;
  }
}
