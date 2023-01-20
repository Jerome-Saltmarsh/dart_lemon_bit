import 'package:bleed_server/gamestream.dart';

class GameObject extends Collider {
  var _type = 0;
  var quantity = 0;
  var interactable = false;
  var collectable = false;
  var persistable = false;
  var destroyable = false;

  int get type => _type;

  set type(int value) {
     _type = value;
     radius           = ItemType.getRadius(value);
     collectable      = ItemType.isCollectable(value);
     physical         = ItemType.isPhysical(value);
     movable          = ItemType.isMovable(value);
     collidable       = ItemType.isCollidable(value);
     persistable      = ItemType.isPersistable(value);
     interactable     = value == ItemType.GameObjects_Vending_Machine;
  }

  GameObject({
    required double x,
    required double y,
    required double z,
    required int type,
  }) : super(x: x, y: y, z: z, radius: 15) {
    this.type = type;
    team = TeamType.Alone;
    startX = x;
    startY = y;
    startZ = z;
  }
}







