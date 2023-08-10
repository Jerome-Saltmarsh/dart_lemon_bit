
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric.dart';

class IsometricZombie extends Character {

  IsometricZombie({
    required super.health,
    required super.weaponDamage,
    required super.team,
    required super.x,
    required super.y,
    required super.z,
  }) : super(
    characterType: CharacterType.Zombie,
    weaponType: WeaponType.Unarmed,
    weaponRange: 20,
    weaponCooldown: 20,
    name: "Zombie",
  ) {
    doesWander = true;
  }
}