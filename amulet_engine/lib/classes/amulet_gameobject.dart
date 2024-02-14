

import '../common/src.dart';
import '../isometric/src.dart';

class AmuletGameObject extends GameObject {

  final int frameSpawned;
  final AmuletItem amuletItem;

  AmuletGameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.id,
    required this.amuletItem,
    required this.frameSpawned,
    required int deactivationTimer
  }) : super(
      type: ItemType.Amulet_Item,
      subType: amuletItem.index,
      team: TeamType.Neutral,
  ) {
    this.deactivationTimer = deactivationTimer;
    fixed = false;
    gravity = true;
    collidable = true;
    interactable = true;
    persistable = false;
    hitable = false;
    physical = false;
    collectable = AmuletItem.Consumables.contains(amuletItem);
  }

  @override
  String get name => amuletItem.label;

  @override
  bool onSameTeam(a) {
    // TODO: implement onSameTeamAs
    throw UnimplementedError();
  }

  @override
  bool get ignorePointer => amuletItem.isConsumable;
}