

import '../packages/src.dart';

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
      type: amuletItem.type,
      subType: amuletItem.subType,
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
    collectable = amuletItem == AmuletItem.Potion_Health;
  }

  @override
  String get name => amuletItem.name;

  @override
  bool onSameTeam(a) {
    // TODO: implement onSameTeamAs
    throw UnimplementedError();
  }
}