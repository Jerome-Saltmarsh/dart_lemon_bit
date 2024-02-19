

import '../common/src.dart';
import '../isometric/src.dart';

class AmuletGameObject extends GameObject {

  final int frameSpawned;

  AmuletGameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.id,
    required AmuletItem amuletItem,
    required this.frameSpawned,
    required int deactivationTimer
  }) : super(
      itemType: ItemType.Amulet_Item,
      subType: amuletItem.index,
      team: TeamType.Neutral,
  ) {
    this.amuletItem = amuletItem;
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
  bool get ignorePointer => super.ignorePointer || amuletItem.isConsumable;

  AmuletItem get amuletItem => AmuletItem.values[subType];

  set amuletItem(AmuletItem value) {
    subType = value.index;
  }
}