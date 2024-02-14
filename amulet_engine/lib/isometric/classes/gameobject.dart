
import '../../common/src.dart';
import 'collider.dart';

class GameObject extends Collider {
  /// Prevents gameobject from being recycled in the object pool until the next frame
  var available = false;
  var id = 0;
  /// ItemType.dart
  var type = 0;
  var subType = -1;
  var quantity = 0;
  var interactable = false;
  /// collectable means that the player automatically picks this item up by colliding with it
  /// this is used for health potions
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
  String? customName;
  Function(dynamic src)? onInteract;

  @override
  int get materialType => getMaterialType(type, subType);

  bool get ignorePointer =>
        !active || (
          !collectable &&
          !interactable &&
          onInteract == null &&
          !hitable
        );

  static int getMaterialType(int type, int subType){
     switch (type){
       case ItemType.Object:
         switch (subType){
           case GameObjectType.Crystal_Glowing_False:
             return MaterialType.Glass;
           case GameObjectType.Crystal_Glowing_True:
             return MaterialType.Glass;
         }
     }
     return MaterialType.None;
  }

  GameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.team,
    required this.type,
    required this.subType,
    required this.id,
    super.radius = 15.0,
    this.health = 0,
  }) : super(materialType: getMaterialType(type, subType)) {
    startPositionX = x;
    startPositionY = y;
    startPositionZ = z;
    healthMax = health;
    synchronizePrevious();
  }

  bool get positionDirty => x != previousX || y != previousY || z != previousZ;

  String get typeName => ItemType.getName(type);

  String get subTypeName => ItemType.getNameSubType(type, subType);

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
  String get name => customName ?? ItemType.getNameSubType(type, subType);

  GameObject copy() =>
      GameObject(
          x: x,
          y: y,
          z: z,
          team: team,
          type: type,
          subType: subType,
          id: id,
      )
        ..interactable = interactable
        ..collectable = collectable
        ..persistable = persistable
        ..destroyable = destroyable
        ..recyclable = recyclable
        ..dirty = dirty
        ..previousX = previousX
        ..previousY = previousY
        ..previousZ = previousZ
        ..health = health
        ..healthMax = healthMax
        ..deactivationTimer = deactivationTimer
        ..startPositionX = startPositionX
        ..startPositionY = startPositionY
        ..startPositionZ = startPositionZ;

  @override
  void deactivate() {
    super.deactivate();
    dirty = true;
    available = false;
  }

  @override
  bool onSameTeam(a) {
    // TODO: implement onSameTeamAs
    throw UnimplementedError();
  }
}







