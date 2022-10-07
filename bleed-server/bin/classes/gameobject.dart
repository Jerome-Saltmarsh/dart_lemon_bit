import '../common/library.dart';
import 'library.dart';

class GameObject extends Collider {
  var active = true;
  /// game_object_type
  int type;
  dynamic spawn;

  GameObject({
    required double x,
    required double y,
    required double z,
    required this.type,
  }) : super(x: x, y: y, z: z, radius: 10) {
    collidable = GameObjectType.isCollidable(type);
  }
}







