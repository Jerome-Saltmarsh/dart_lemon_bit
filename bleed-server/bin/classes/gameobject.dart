import 'library.dart';

class GameObject extends Collider {
  var active = true;
  /// GameObjectType.dart
  int type;
  dynamic spawn;

  GameObject({
    required double x,
    required double y,
    required double z,
    required this.type,
  }) : super(x: x, y: y, z: z, radius: 15) {
    collidable = true;
    moveOnCollision = false;
  }
}







