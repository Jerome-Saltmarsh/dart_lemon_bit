
import 'package:gamestream_server/isometric.dart';

import 'amulet_player.dart';

class MMONpc extends Character {

  Function(AmuletPlayer player)? interact;

  MMONpc({
    required super.characterType,
    required super.health,
    required super.weaponType,
    required super.team,
    required super.weaponDamage,
    required super.weaponRange,
    required super.weaponCooldown,
    required super.x,
    required super.y,
    required super.z,
    required super.name,
    this.interact,
  }) {
    clearTargetOnPerformAction = false;
  }
}