import '../common/library.dart';
import 'library.dart';

class GameObject extends Collider {
  var active = true;
  int _type = 0;
  int timer = 0;

  int get type => _type;
  bool get collectable => _isCollectable;

  set type(int value){
     _type = value;
     _isCollectable = ItemType.isCollectable(_type);
  }

  var _isCollectable = false;

  GameObject({
    required double x,
    required double y,
    required double z,
    required int type,
  }) : super(x: x, y: y, z: z, radius: 15) {
    collidable = true;
    moveOnCollision = false;
    this.type = type;
  }
}







