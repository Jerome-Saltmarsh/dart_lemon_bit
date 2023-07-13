
import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric.dart';

import 'mmo_game.dart';

class MMOGameObject extends IsometricGameObject {

  final int frameSpawned;
  final MMOItem item;

  MMOGameObject({
    required super.x,
    required super.y,
    required super.z,
    required super.id,
    required this.item,
    required this.frameSpawned,
  }) : super(type: item.type, subType: item.subType, team: TeamType.Neutral) {
    deactivationTimer = MmoGame.GameObjectDeactivationTimer;
    fixed = false;
    gravity = true;
    collidable = true;
    collectable = item.collectable;
    persistable = false;
    hitable = false;
    physical = false;
  }

  @override
  String get name => item.name;
}