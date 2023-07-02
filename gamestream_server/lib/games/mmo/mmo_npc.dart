
import 'package:gamestream_server/games/mmo/mmo_player.dart';
import 'package:gamestream_server/isometric.dart';

class MMONpc extends IsometricCharacter {

  Function(MmoPlayer player)? interact;

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
    this.interact,
  });
}