
import 'package:bleed_server/games/mmo/mmo_player.dart';
import 'package:bleed_server/isometric/isometric_character_template.dart';

class MMONpc extends IsometricCharacterTemplate {

  var viewRange = 400.0;
  var timerUpdateTarget = 0;
  var timerUpdateTargetDuration = 200;

  Function(MmoPlayer player)? interact;

  MMONpc({
    required super.health,
    required super.weaponType,
    required super.team,
    required super.damage,
    required super.x,
    required super.y,
    required super.z,
    this.interact,
  });
}