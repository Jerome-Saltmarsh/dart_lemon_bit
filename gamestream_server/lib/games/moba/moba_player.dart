import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric.dart';

class MobaPlayer extends IsometricPlayer {

  MobaCharacterClass? characterClass;

  MobaPlayer({
    required super.game,
    required super.x,
    required super.y,
    required super.z,
    required super.team,
  }): super(health: 10) {
    weaponType = WeaponType.Sword;
    weaponDamage = 1;
    weaponCooldown = 20;
    weaponRange = 30;
  }
}