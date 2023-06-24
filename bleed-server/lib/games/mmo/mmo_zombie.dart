
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/isometric/src.dart';

import 'mmo_game.dart';

class MMOZombie extends IsometricCharacter {

  final MmoGame game;

  MMOZombie({
    required this.game,
    required super.health,
    required super.damage,
    required super.x,
    required super.y,
    required super.z,
  }) : super(
      characterType: CharacterType.Zombie,
      team: MmoTeam.Alien,
      weaponType: ItemType.Empty,
  );

  @override
  void customOnUpdate() {
    super.customOnUpdate();

    updateTarget();
  }

  void updateTarget(){

  }
}