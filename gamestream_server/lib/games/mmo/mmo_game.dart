
import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/isometric.dart';

import 'package:gamestream_server/games/mmo/mmo_npc.dart';

import 'mmo_player.dart';

class MmoGame extends IsometricGame<MmoPlayer> {

  late MMONpc npcGuard;

  MmoGame({
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
      weaponRange: 200,
      interact: (player) {
        player.talk("Hello there");
      }
    ));

    npcGuard = MMONpc(
      x: 800,
      y: 1000,
      z: 25,
      health: 200,
      weaponType: ItemType.Weapon_Ranged_Machine_Gun,
      weaponRange: 200,
      damage: 1,
      team: MmoTeam.Human,
    );

    characters.add(npcGuard);

    characters.add(IsometricZombie(team: MmoTeam.Alien, game: this, x: 50, y: 50, z: 24, health: 5, damage: 1));

    characters.add(
        IsometricZombie(
            team: MmoTeam.Alien,
            game: this,
            x: 80,
            y: 50,
            z: 24,
            health: 5,
            damage: 1,
        )..target = npcGuard
    );
  }

  @override
  MmoPlayer buildPlayer() => MmoPlayer(game: this)
    ..x = 880
    ..y = 1100
    ..z = 50
    ..team = MmoTeam.Human
    ..setDestinationToCurrentPosition();

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

    if (mouseRightDown) {
      player.selectDebugCharacterNearestToMouse();
    }
  }
}