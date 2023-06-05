
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_team.dart';
import 'package:bleed_server/common/src/game_type.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';

class CaptureTheFlagGame extends IsometricGame<CaptureTheFlagPlayer> {

  late final IsometricGameObject flagRed;
  late final IsometricGameObject flagBlue;

  IsometricCharacter? flagRedCharacter;
  IsometricCharacter? flagBlueCharacter;

  int get countPlayersOnTeamRed => countPlayersOnTeam(CaptureTheFlagTeam.Red);
  int get countPlayersOnTeamBlue => countPlayersOnTeam(CaptureTheFlagTeam.Blue);

  int countPlayersOnTeam(int team) =>
      players.where((player) => player.team == team).length;

  CaptureTheFlagGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Capture_The_Flag) {
    flagRed = spawnGameObject(x: 200, y: 200, z: 24, type: ItemType.GameObjects_Flag_Red);
    flagBlue = spawnGameObject(x: 100, y: 100, z: 24, type: ItemType.GameObjects_Flag_Blue);
  }

  @override
  void customWriteGame() {
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target == flagRedCharacter) {
      flagRedCharacter = null;
      return;
    }

    if (target == flagBlueCharacter) {
      flagBlueCharacter = null;
      return;
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(IsometricPlayer player, IsometricGameObject gameObject) {

    if (gameObject == flagBlue && player.team == CaptureTheFlagTeam.Red && flagBlueCharacter == null) {
      flagBlueCharacter = player;
      return;
    }

    if (gameObject == flagRed && player.team == CaptureTheFlagTeam.Blue && flagRedCharacter == null) {
      flagRedCharacter = player;
      return;
    }
  }

  @override
  void customUpdate() {
      if (flagBlueCharacter != null) {
        flagBlue.x = flagBlueCharacter!.x;
        flagBlue.y = flagBlueCharacter!.y;
        flagBlue.z = flagBlueCharacter!.z;
      }
      if (flagRedCharacter != null) {
        flagRed.x = flagRedCharacter!.x;
        flagRed.y = flagRedCharacter!.y;
        flagRed.z = flagRedCharacter!.z;
      }
  }

  @override
  CaptureTheFlagPlayer buildPlayer() {
    final player = CaptureTheFlagPlayer(game: this);
    player.team = countPlayersOnTeamBlue > countPlayersOnTeamRed
        ? CaptureTheFlagTeam.Red
        : CaptureTheFlagTeam.Blue;
    player.x = 100;
    player.y = 100;
    player.z = 50;
    return player;
  }

  @override
  int get maxPlayers => 8;
}