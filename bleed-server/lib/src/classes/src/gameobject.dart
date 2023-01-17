import 'package:bleed_server/gamestream.dart';

class GameObject extends Collider {
  var _type = 0;
  var quantity = 0;
  var interactable = false;
  var collectable = false;

  int get type => _type;

  set type(int value) {
     _type = value;
     collectable      = ItemType.isCollectable(type);
     physical         = ItemType.isPhysical(type);
     movable  = ItemType.physicsMoveOnCollision(type);
     applyGravity     = ItemType.applyGravity(type);
     collidable       = ItemType.isCollidable(type);
     interactable     = value == ItemType.GameObjects_Vending_Machine;
  }

  GameObject({
    required double x,
    required double y,
    required double z,
    required int type,
  }) : super(x: x, y: y, z: z, radius: 15) {
    collidable = true;
    movable = false;
    this.type = type;
    team = TeamType.Alone;
    startX = x;
    startY = y;
    startZ = z;
  }
}







