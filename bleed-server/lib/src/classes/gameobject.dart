import 'package:bleed_server/gamestream.dart';

class GameObject extends Collider {
  var active = true;
  var _type = 0;
  var quantity = 0;
  /// used to deactivate object
  var timer = 0;

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







