import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/common/src/team_type.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';

class IsometricGameObject extends IsometricCollider {
  /// Prevents gameobject from being recycled in the object pool until the next frame
  var available = false;
  var id = 0;
  var _type = 0;
  var quantity = 0;
  var interactable = false;
  var collectable = false;
  var persistable = false;
  var destroyable = false;

  var previousX = 0.0;
  var previousY = 0.0;
  var previousZ = 0.0;

  var dirty = false;

  int get type => _type;

  bool get positionDirty => x != previousX || y != previousY || z != previousZ;

  void synchronizePrevious(){
    previousX = x;
    previousY = y;
    previousZ = z;
  }

  set type(int value) {
     _type = value;
     radius           = ItemType.getRadius(value);
     collectable      = ItemType.isCollectable(value);
     physical         = ItemType.isPhysical(value);
     fixed            = ItemType.isFixed(value);
     hitable        = ItemType.isStrikable(value);
     persistable      = ItemType.isPersistable(value);
     interactable     = ItemType.isInteractable(value);
     bounce           = false;
     gravity          = !fixed && physical;
  }

  IsometricGameObject({
    required double x,
    required double y,
    required double z,
    required int type,
    required this.id,
  }) : super(x: x, y: y, z: z, radius: 15) {
    this.type = type;
    team = TeamType.Alone;
    startX = x;
    startY = y;
    startZ = z;
    synchronizePrevious();
  }
}







