
import '../packages/src.dart';
import 'amulet_character.dart';
import 'amulet_player.dart';

class AmuletNpc extends Character with AmuletCharacter {

  Function(AmuletPlayer player, AmuletNpc self)? interact;

  AmuletNpc({
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
    required super.attackDuration,
    super.invincible = false,
    this.interact,
  }) : super (characterType: CharacterType.Human){
    clearTargetOnPerformAction = false;
  }
}