
import '../../common/src.dart';
import 'collider.dart';

class GameObject extends Collider {
  /// Prevents gameobject from being recycled in the object pool until the next frame
  var id = -1;
  var itemType = 0;
  var subType = -1;
  var quantity = 0;
  var interactable = false;
  /// collectable means that the player automatically picks this item up by colliding with it
  /// this is used for health potions
  var collectable = false;
  // var destroyable = false;
  var dirty = true;
  var health = 0;
  var healthMax = 0;
  var deactivationTimer = -1;
  String? label;

  GameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.team,
    required this.itemType,
    required this.subType,
    required this.interactable,
    super.radius = 15.0,
    this.health = 0,
    this.healthMax = 0,
    this.deactivationTimer = -1,
    int? id,
  }) : super(materialType: getMaterialType(itemType, subType)) {
    startPositionX = x;
    startPositionY = y;
    startPositionZ = z;
    healthMax = health;

    if (id != null){
      this.id = id;
    }
  }

  @override
  set x(double value){
    final current = x;
    if (current == value) return;
    super.x = value;
    if (current.toInt() == value.toInt()) return;
      markAsDirty();
  }

  @override
  set y(double value){
    final current = y;
    if (current == value) return;
    super.y = value;
    if (current.toInt() == value.toInt()) return
    markAsDirty();
  }

  @override
  set z(double value) {
    final current = z;
    if (current == value) return;
    super.z = value;
    if (current.toInt() == value.toInt()) return;
    markAsDirty();
  }


  void markAsDirty() {
    dirty = true;
  }

  @override
  int get materialType => getMaterialType(itemType, subType);

  bool get ignorePointer =>
      (
          !collectable &&
              !interactable &&
              !hitable
      );

  String get typeName => ItemType.getName(itemType);

  String get subTypeName => ItemType.getNameSubType(itemType, subType);

  // void synchronizePrevious(){
  //   previousX = x;
  //   previousY = y;
  //   previousZ = z;
  // }

  @override
  String toString() {
    return '{type: $typeName, subType: $subTypeName, id: $id}';
  }

  @override
  String get name => label ?? ItemType.getNameSubType(itemType, subType);

  GameObject copy() =>
      GameObject(
          x: x,
          y: y,
          z: z,
          team: team,
          itemType: itemType,
          subType: subType,
          id: id,
          interactable: interactable,
      )
        ..physical = physical
        ..hitable = hitable
        ..fixed = fixed
        ..gravity = gravity
        ..collidable = collidable
        ..radius = radius
        ..team = team
        ..collectable = collectable
        ..dirty = dirty
        ..health = health
        ..healthMax = healthMax
        ..deactivationTimer = deactivationTimer
        ..startPositionX = startPositionX
        ..startPositionY = startPositionY
        ..startPositionZ = startPositionZ;

  @override
  bool onSameTeam(a) {
    // TODO: implement onSameTeamAs
    throw UnimplementedError();
  }

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
}







