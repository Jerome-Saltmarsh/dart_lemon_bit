
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';

import 'capture_the_flag_game.dart';

class CaptureTheFlagZombie extends IsometricCharacter {

  final CaptureTheFlagGame game;
  late final IsometricGameObject enemyBase;

  CaptureTheFlagZombie({
    required this.game,
    required super.health,
    required super.team,
    required super.damage,
  }) : super(characterType: CharacterType.Zombie, weaponType: ItemType.Empty) {
    enemyBase = isTeamRed ? game.baseBlue : game.baseRed;
  }

  bool get isTeamRed => team == CaptureTheFlagTeam.Red;
  bool get isTeamBlue => team == CaptureTheFlagTeam.Blue;

  @override
  void customUpdate() {
    
  }
}