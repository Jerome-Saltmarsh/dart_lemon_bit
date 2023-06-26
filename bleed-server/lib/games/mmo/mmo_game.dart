
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/games/mmo/mmo_npc.dart';
import 'package:bleed_server/isometric/isometric_zombie.dart';
import 'package:bleed_server/isometric/src.dart';

import 'mmo_player.dart';

class MmoGame extends IsometricGame<MmoPlayer> {

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

    characters.add(IsometricZombie(team: MmoTeam.Alien, game: this, x: 50, y: 50, z: 24, health: 5, damage: 1));
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
  void updateCharacter(IsometricCharacter character) {
    super.updateCharacter(character);

    if (character is MMONpc) {
      if (character.timerUpdateTarget-- <= 0){
        character.target = findNearestEnemy(character, radius: character.viewRange);
        character.timerUpdateTarget = character.refreshRateTarget;
      }
    }
  }

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