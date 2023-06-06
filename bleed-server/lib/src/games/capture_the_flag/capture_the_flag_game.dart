
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';

class CaptureTheFlagGame extends IsometricGame<CaptureTheFlagPlayer> {

  static const Base_Radius = 64.0;

  late final IsometricGameObject flagRed;
  late final IsometricGameObject flagBlue;

  late final IsometricGameObject baseRed;
  late final IsometricGameObject baseBlue;

  IsometricCharacter? flagRedCharacter;
  IsometricCharacter? flagBlueCharacter;

  var scoreRed = 0;
  var scoreBlue = 0;

  int get countPlayersOnTeamRed => countPlayersOnTeam(CaptureTheFlagTeam.Red);
  int get countPlayersOnTeamBlue => countPlayersOnTeam(CaptureTheFlagTeam.Blue);

  int countPlayersOnTeam(int team) =>
      players.where((player) => player.team == team).length;

  CaptureTheFlagGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Capture_The_Flag) {
    flagRed = spawnGameObject(x: 200, y: 200, z: 25, type: ItemType.GameObjects_Flag_Red);
    flagBlue = spawnGameObject(x: 100, y: 100, z: 25, type: ItemType.GameObjects_Flag_Blue);

    baseRed = spawnGameObject(x: 300, y: 500, z: 25, type: ItemType.GameObjects_Base_Red)..fixed = true;
    baseBlue = spawnGameObject(x: 300, y: 300, z: 25, type: ItemType.GameObjects_Base_Blue)..fixed = true;
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

    if (gameObject == flagBlue && flagBlueCharacter == null) {
      if (player.team == CaptureTheFlagTeam.Red || flagBlue.getDistance3(baseBlue) > Base_Radius){
        flagBlueCharacter = player;
      }
      return;
    }

    if (gameObject == flagRed && flagRedCharacter == null) {
      if (player.team == CaptureTheFlagTeam.Blue || flagRed.getDistance3(baseRed) > Base_Radius){
        flagRedCharacter = player;
      }
      return;
    }

    if (gameObject == baseBlue && player == flagRedCharacter) {
      flagRedCharacter = null;
      flagRed.moveTo(baseRed);
      scoreBlue++;
      dispatchScore();
      return;
    }

    if (gameObject == baseRed && player == flagBlueCharacter) {
      flagBlueCharacter = null;
      flagBlue.moveTo(baseBlue);
      scoreRed++;
      dispatchScore();
      return;
    }
  }

  void dispatchScore() {
    for (final player in players) {
      player.writeScore();
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

    if (player.team == CaptureTheFlagTeam.Blue){
       player.legsType = ItemType.Legs_Blue;
       player.bodyType = ItemType.Body_Shirt_Blue;
    } else {
      player.legsType = ItemType.Legs_Red;
      player.bodyType = ItemType.Body_Shirt_Red;
    }

    return player;
  }

  @override
  int get maxPlayers => 10;
}