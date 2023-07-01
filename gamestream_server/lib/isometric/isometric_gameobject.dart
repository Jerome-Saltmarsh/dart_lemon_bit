import 'package:gamestream_server/common.dart';

import 'isometric_collider.dart';

class IsometricGameObject extends IsometricCollider {
  /// Prevents gameobject from being recycled in the object pool until the next frame
  var available = false;
  var id = 0;
  var type = 0;
  var subType = -1;
  var quantity = 0;
  var interactable = false;
  var collectable = false;
  var persistable = false;
  var destroyable = false;
  var recyclable = true;
  var dirty = false;
  var previousX = 0.0;
  var previousY = 0.0;
  var previousZ = 0.0;

  IsometricGameObject({
    required double x,
    required double y,
    required double z,
    required int type,
    required this.subType,
    required this.id,
  }) : super(x: x, y: y, z: z, radius: 15) {
    this.type = type;
    team = TeamType.Alone;
    startX = x;
    startY = y;
    startZ = z;
    synchronizePrevious();
  }

  // int get type => _type;

  bool get positionDirty => x != previousX || y != previousY || z != previousZ;

  void synchronizePrevious(){
    previousX = x;
    previousY = y;
    previousZ = z;
  }

  // set type(int value) {
  //    _type = value;
  //    radius           = ObjectType.getRadius(value);
  //    collectable      = false;
  //    physical         = true;
  //    fixed            = false;
  //    hitable          = false;
  //    persistable      = true;
  //    interactable     = false;
  //    bounce           = false;
  //    gravity          = !fixed && physical;
  // }
}







