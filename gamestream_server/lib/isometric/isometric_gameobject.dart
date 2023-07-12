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
  var dirty = true;
  var previousX = 0.0;
  var previousY = 0.0;
  var previousZ = 0.0;
  var health = 0;
  var healthMax = 0;
  var deactivationTimer = -1;

  IsometricGameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.team,
    required this.type,
    required this.subType,
    required this.id,
    super.radius = 15.0,
    this.health = 0,
  }) {
    startX = x;
    startY = y;
    startZ = z;
    healthMax = health;
    synchronizePrevious();
  }

  bool get positionDirty => x != previousX || y != previousY || z != previousZ;

  String get typeName => GameObjectType.getName(type);

  String get subTypeName => GameObjectType.getNameSubType(type, subType);

  void synchronizePrevious(){
    previousX = x;
    previousY = y;
    previousZ = z;
  }

  @override
  String toString() {
    return '{type: $typeName, subType: $subTypeName, id: $id}';
  }

  @override
  String get name => GameObjectType.getNameSubType(type, subType);
}







