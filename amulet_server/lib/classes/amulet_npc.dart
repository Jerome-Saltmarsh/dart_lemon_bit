
import 'package:amulet_common/src.dart';

import '../isometric/src.dart';
import 'amulet_player.dart';

class AmuletNpc extends Character {

  Function(AmuletPlayer player, AmuletNpc self)? interact;

  AmuletNpc({
    required super.health,
    required super.weaponType,
    required super.team,
    required super.attackDamage,
    required super.attackRange,
    required super.x,
    required super.y,
    required super.z,
    required super.name,
    required super.attackDuration,
    super.invincible = false,
    this.interact,
  }) : super (characterType: CharacterType.Human);
}