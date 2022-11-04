import 'library.dart';

class GameObject extends Collider {
  var active = true;
  /// GameObjectType.dart
  int type;
  int subType = 0;
  int timer = 0;

  GameObject({
    required double x,
    required double y,
    required double z,
    required this.type,
    this.subType = 0,
  }) : super(x: x, y: y, z: z, radius: 15) {
    collidable = true;
    moveOnCollision = false;
  }
}







