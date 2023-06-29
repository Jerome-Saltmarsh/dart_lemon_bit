
import 'package:gamestream_server/isometric.dart';

import 'moba_game.dart';

class MobaCreep extends IsometricCharacter {

  final MobaGame game;

  MobaCreep({
    required this.game,
    required super.characterType,
    required super.health,
    required super.weaponType,
    required super.team,
    required super.damage,
    required super.weaponRange,
    required super.x,
    required super.y,
    required super.z,
  });


  @override
  void customOnUpdate() {

  }
}