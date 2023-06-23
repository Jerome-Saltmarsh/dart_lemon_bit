
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/games/mmo/mmo_npc.dart';
import 'package:bleed_server/isometric/src.dart';

import 'mmo_player.dart';

class Mmo extends IsometricGame<MmoPlayer> {

  Mmo({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Mmo) {

    characters.add(MMONpc(
      x: 900,
      y: 1100,
      z: 25,
      health: 50,
      weaponType: ItemType.Weapon_Ranged_Handgun,
      team: MmoTeam.Human,
      damage: 1,
    ));
  }

  @override
  MmoPlayer buildPlayer() => MmoPlayer(game: this)
    ..x = 880
    ..y = 1100
    ..z = 50
    ..team = MmoTeam.Human;

  @override
  int get maxPlayers => 64;

  @override
  void onPlayerUpdateRequestReceived({
    required MmoPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {

  }
}