import 'package:gamestream_ws/packages/common.dart';
import 'package:gamestream_ws/isometric.dart';

class AmuletGameObject extends GameObject {

  final int frameSpawned;
  final AmuletItem item;

  AmuletGameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.id,
    required this.item,
    required this.frameSpawned,
    required int deactivationTimer
  }) : super(
      type: item.type,
      subType: item.subType,
      team: TeamType.Neutral,
  ) {
    this.deactivationTimer = deactivationTimer;
    fixed = false;
    gravity = true;
    collidable = true;
    collectable = !item.consumable;
    persistable = false;
    hitable = false;
    physical = false;
  }

  @override
  String get name => item.name;

  @override
  bool onSameTeam(a) {
    // TODO: implement onSameTeamAs
    throw UnimplementedError();
  }
}