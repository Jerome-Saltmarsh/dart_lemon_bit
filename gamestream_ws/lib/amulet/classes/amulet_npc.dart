
import 'package:gamestream_ws/amulet/classes/amulet_character.dart';
import 'package:gamestream_ws/isometric.dart';

import 'amulet_player.dart';

class AmuletNpc extends Character with AmuletCharacter {

  Function(AmuletPlayer player, AmuletNpc self)? interact;

  AmuletNpc({
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
    super.invincible = false,
    this.interact,
  }) {
    clearTargetOnPerformAction = false;
  }
}