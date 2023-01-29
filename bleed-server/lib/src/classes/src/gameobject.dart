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
     fixed            = ItemType.isFixed(value);
     strikable       = ItemType.isStrikable(value);
     persistable      = ItemType.isPersistable(value);
     interactable     = ItemType.isInteractable(value);
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







