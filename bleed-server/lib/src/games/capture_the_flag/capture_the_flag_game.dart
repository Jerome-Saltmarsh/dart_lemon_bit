
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_flag_status.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_player_status.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';
import 'package:bleed_server/src/utilities/change_notifier.dart';


class CaptureTheFlagGame extends IsometricGame<CaptureTheFlagPlayer> {

  static const Base_Radius = 64.0;
  static const Flag_Respawn_Duration = 500;

  late final IsometricGameObject flagRed;
  late final IsometricGameObject flagBlue;

  late final IsometricGameObject baseRed;
  late final IsometricGameObject baseBlue;

  IsometricCharacter? flagRedCharacter;
  IsometricCharacter? flagBlueCharacter;

  var flagRedRespawn = 0;
  var flagBlueRespawn = 0;

  late final scoreRed = ChangeNotifier(0, dispatchScore);
  late final scoreBlue = ChangeNotifier(0, dispatchScore);

  late final flagRedStatus = ChangeNotifier(CaptureTheFlagFlagStatus.At_Base, dispatchFlagStatus);
  late final flagBlueStatus = ChangeNotifier(CaptureTheFlagFlagStatus.At_Base, dispatchFlagStatus);

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

  int get countPlayersOnTeamRed => countPlayersOnTeam(CaptureTheFlagTeam.Red);
  int get countPlayersOnTeamBlue => countPlayersOnTeam(CaptureTheFlagTeam.Blue);

  int countPlayersOnTeam(int team) =>
      players.where((player) => player.team == team).length;

  @override
  void onPlayerUpdateRequestReceived({required IsometricPlayer player, required int direction, required bool mouseLeftDown, required bool mouseRightDown, required bool keySpaceDown, required bool inputTypeKeyboard}) {
    if (player.deadOrBusy) return;
    if (!player.active) return;

    if (!player.weaponStateBusy) {
      player.lookRadian = player.mouseAngle;
    }

    if (mouseLeftDown){
      characterUseWeapon(player);
    }

    playerRunInDirection(player, Direction.fromInputDirection(direction));
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target is CaptureTheFlagPlayer){
      if (target == flagRedCharacter) {
        flagRedCharacter = null;
        target.setFlagStatusNoFlag();
        return;
      }

      if (target == flagBlueCharacter) {
        flagBlueCharacter = null;
        target.setFlagStatusNoFlag();
        return;
      }
    }
  }


  @override
  void customOnCollisionBetweenColliders(IsometricCollider a, IsometricCollider b) {
    if (a == flagBlue || b == flagBlue) {
       if (a == baseBlue || b == baseBlue){
         if (flagBlueCharacter?.team != CaptureTheFlagTeam.Blue) return;
         returnBlueFlagToBase();
         return;
       }
       if (a == baseRed || b == baseRed) {
         if (flagBlueCharacter?.team == CaptureTheFlagTeam.Blue) return;
         onRedTeamScored();
       }
       return;
    }

    if (a == flagRed || b == flagRed) {
      if (a == baseRed || b == baseRed){
        if (flagRedCharacter?.team != CaptureTheFlagTeam.Red) return;
        returnRedFlagToBase();
        return;
      }
      if (a == baseBlue || b == baseBlue) {
        if (flagRedCharacter?.team == CaptureTheFlagTeam.Red) return;
        onBlueTeamScored();
      }
      return;
    }
  }

  void onBlueTeamScored() {
    scoreBlue.value++;
    flagRedRespawn = Flag_Respawn_Duration;
    deactivateCollider(flagRed);

    for (final player in players) {
      player.writeByte(ServerResponse.Capture_The_Flag);
      player.writeByte(CaptureTheFlagResponse.Blue_Team_Scored);
    }
  }

  void onRedTeamScored() {
    scoreRed.value++;
    flagBlueRespawn = Flag_Respawn_Duration;
    deactivateCollider(flagBlue);

    for (final player in players) {
      player.writeByte(ServerResponse.Capture_The_Flag);
      player.writeByte(CaptureTheFlagResponse.Red_Team_Scored);
    }
  }

  void returnRedFlagToBase() {
    if (flagRedCharacter is CaptureTheFlagPlayer){
      (flagRedCharacter as CaptureTheFlagPlayer).setFlagStatusNoFlag();
    }
    flagRedCharacter = null;
    flagRed.moveTo(baseRed);
    flagRedStatus.value = CaptureTheFlagFlagStatus.At_Base;
  }

  void returnBlueFlagToBase() {
    if (flagBlueCharacter is CaptureTheFlagPlayer){
      (flagBlueCharacter as CaptureTheFlagPlayer).setFlagStatusNoFlag();
    }
    flagBlueCharacter = null;
    flagBlue.moveTo(baseBlue);
    flagBlueStatus.value = CaptureTheFlagFlagStatus.At_Base;
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(IsometricPlayer player, IsometricGameObject gameObject) {
    if (player is! CaptureTheFlagPlayer) return;

    if (gameObject == flagBlue && flagBlueCharacter == null) {
      if (player.isTeamRed || flagBlue.getDistance3(baseBlue) > Base_Radius){
        if (flagRedCharacter != player){
          flagBlueCharacter = player;
          if (player.isTeamRed){
            flagBlueStatus.value = CaptureTheFlagFlagStatus.Carried_By_Enemy;
            player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Enemy_Flag;
          } else {
            flagBlueStatus.value = CaptureTheFlagFlagStatus.Carried_By_Allie;
            player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Team_Flag;
          }
        }
      }
      return;
    }

    if (gameObject == flagRed && flagRedCharacter == null) {
      if (player.isTeamBlue || flagRed.getDistance3(baseRed) > Base_Radius){
        if (flagBlueCharacter != player){
          flagRedCharacter = player;
          if (player.isTeamBlue){
            flagRedStatus.value = CaptureTheFlagFlagStatus.Carried_By_Enemy;
            player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Enemy_Flag;
          } else {
            flagRedStatus.value = CaptureTheFlagFlagStatus.Carried_By_Allie;
            player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Team_Flag;
          }
        }
      }
      return;
    }
  }

  void dispatchScore() {
    for (final player in players) {
      player.writeScore();
    }
  }

  void dispatchFlagStatus(){
    for (final player in players) {
      player.writeFlagStatus();
    }
  }

  @override
  void customUpdate() {
      if (flagBlueCharacter != null) {
        flagBlue.moveTo(flagBlueCharacter!);
      }
      if (flagRedCharacter != null) {
        flagRed.moveTo(flagRedCharacter!);
      }

      if (flagRedRespawn > 0){
         flagRedRespawn--;
         if (flagRedRespawn == 0){
           returnRedFlagToBase();
           activateCollider(flagRed);
         }
      }

      if (flagBlueRespawn > 0){
        flagBlueRespawn--;
         if (flagBlueRespawn == 0){
           returnBlueFlagToBase();
           activateCollider(flagBlue);
         }
      }

  }

  @override
  CaptureTheFlagPlayer buildPlayer() {
    final player = CaptureTheFlagPlayer(game: this);
    player.team = countPlayersOnTeamBlue > countPlayersOnTeamRed
        ? CaptureTheFlagTeam.Red
        : CaptureTheFlagTeam.Blue;
    player.x = 50;
    player.y = 50;
    player.z = 50;
    player.weaponType = ItemType.Weapon_Melee_Sword;

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