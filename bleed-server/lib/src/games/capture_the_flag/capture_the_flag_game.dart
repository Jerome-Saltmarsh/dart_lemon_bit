
import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_flag_status.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_gameobject_flag.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player_ai.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';
import 'package:bleed_server/src/utilities/change_notifier.dart';


class CaptureTheFlagGame extends IsometricGame<CaptureTheFlagPlayer> {

  static const Base_Radius = 64.0;
  static const Flag_Respawn_Duration = 500;

  late final CaptureTheFlagGameObjectFlag flagRed;
  late final CaptureTheFlagGameObjectFlag flagBlue;

  late final IsometricGameObject baseRed;
  late final IsometricGameObject baseBlue;

  late final scoreRed = ChangeNotifier(0, dispatchScore);
  late final scoreBlue = ChangeNotifier(0, dispatchScore);

  void onChangedFlagRedStatus() {
    dispatchFlagStatus();
  }

  CaptureTheFlagGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Capture_The_Flag) {
    flagRed = CaptureTheFlagGameObjectFlag(x: 200, y: 200, z: 25, type: ItemType.GameObjects_Flag_Red, id: generateId())..team = CaptureTheFlagTeam.Red;
    flagBlue = CaptureTheFlagGameObjectFlag(x: 200, y: 300, z: 25, type: ItemType.GameObjects_Flag_Blue, id: generateId())..team = CaptureTheFlagTeam.Blue;

    gameObjects.add(flagRed);
    gameObjects.add(flagBlue);

    baseRed = spawnGameObject(x: 300, y: 700, z: 25, type: ItemType.GameObjects_Base_Red)..fixed = true..team = CaptureTheFlagTeam.Red;
    baseBlue = spawnGameObject(x: 300, y: 300, z: 25, type: ItemType.GameObjects_Base_Blue)..fixed = true..team = CaptureTheFlagTeam.Blue;

    flagRed.status = CaptureTheFlagFlagStatus.Dropped;
    flagBlue.status = CaptureTheFlagFlagStatus.Dropped;

    characters.add(CaptureTheFlagPlayerAI(game: this, team: CaptureTheFlagTeam.Red));
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
      if (target == flagRed.heldBy) {
        flagRed.heldBy = null;
        flagRed.status = CaptureTheFlagFlagStatus.Dropped;
        target.setFlagStatusNoFlag();
        return;
      }

      if (target == flagBlue.heldBy) {
        flagBlue.heldBy = null;
        flagBlue.status = CaptureTheFlagFlagStatus.Dropped;
        target.setFlagStatusNoFlag();
        return;
      }
    }
  }

  @override
  void customOnCollisionBetweenColliders(IsometricCollider a, IsometricCollider b) {
    if (a == flagRed || a == flagBlue){
      customOnCollisionBetweenFlagAndCollider(a as CaptureTheFlagGameObjectFlag, b);
      return;
    }
    if (b == flagRed || b == flagBlue){
      customOnCollisionBetweenFlagAndCollider(b as CaptureTheFlagGameObjectFlag, a);
      return;
    }
  }

  void customOnCollisionBetweenFlagAndIsometricCharacter(
      CaptureTheFlagGameObjectFlag flag,
      IsometricCharacter character,
  ){
    if (flag.heldBy != null) return;
    if (getOtherFlag(flag).heldBy == character) return;

    if (flag.team == character.team) {
       if (flag.statusAtBase) return;
       flag.heldBy = character;
       flag.status = CaptureTheFlagFlagStatus.Carried_By_Allie;
       return;
    }

    assert (flag.team != character.team);
    assert (flag.heldBy == null);
    flag.heldBy = character;
    flag.status = CaptureTheFlagFlagStatus.Carried_By_Enemy;
    if (character is CaptureTheFlagPlayer){
      character.setFlagStatusHoldingEnemyFlag();
    }
  }

  void customOnCollisionBetweenFlagAndBase(
      CaptureTheFlagGameObjectFlag flag,
      IsometricGameObject base,
      ){

    final flagHeldBy = flag.heldBy;
    if (flagHeldBy == null) return;

    if (flag.team == base.team) {
      if (flag.team != flagHeldBy.team) return;
      returnFlagToBase(flag);
      return;
    }

    if (flagHeldBy.team != base.team) return;
    onFlagScored(flag);
  }

  void customOnCollisionBetweenFlagAndCollider(CaptureTheFlagGameObjectFlag flag, IsometricCollider collider){

    if (collider is IsometricCharacter){
       customOnCollisionBetweenFlagAndIsometricCharacter(flag, collider);
       return;
    }

    if (collider == baseBlue || collider == baseRed){
       customOnCollisionBetweenFlagAndBase(flag, collider as IsometricGameObject) ;
       return;
    }
  }

  void onFlagScored(CaptureTheFlagGameObjectFlag flag){

    if (flag == flagRed){
      scoreBlue.value++;
    } else {
      scoreRed.value++;
    }

    flag.respawnDuration = Flag_Respawn_Duration;
    flag.status = CaptureTheFlagFlagStatus.Respawning;
    deactivateCollider(flag);
    clearFlagHeldBy(flag);

    final response = flag == flagRed ? CaptureTheFlagResponse.Blue_Team_Scored : CaptureTheFlagResponse.Red_Team_Scored;
    for (final player in players) {
      player.writeByte(ServerResponse.Capture_The_Flag);
      player.writeByte(response);
    }
  }

  void clearFlagHeldBy(CaptureTheFlagGameObjectFlag flag){
    final flagHeldBy = flag.heldBy;
    if (flagHeldBy is! CaptureTheFlagPlayer) return;
    flagHeldBy.setFlagStatusNoFlag();
  }


  void onRedTeamScored() {
    scoreRed.value++;
    onFlagScored(flagBlue);

    for (final player in players) {
      player.writeByte(ServerResponse.Capture_The_Flag);
      player.writeByte(CaptureTheFlagResponse.Red_Team_Scored);
    }
  }

  void returnFlagToBase(CaptureTheFlagGameObjectFlag flag){
    if (flag.statusAtBase) return;
    final heldBy = flag.heldBy;
    if (heldBy is CaptureTheFlagPlayer){
      heldBy.setFlagStatusNoFlag();
    }
    flag.heldBy = null;
    flag.moveTo(getFlagBase(flag));
  }

  IsometricGameObject getFlagBase(CaptureTheFlagGameObjectFlag flag) =>
      (flag == flagRed) ? baseRed : baseBlue;

  CaptureTheFlagGameObjectFlag getOtherFlag(CaptureTheFlagGameObjectFlag flag) =>
      flag == flagRed ? flagBlue : flagRed;

  @override
  void customOnCollisionBetweenPlayerAndGameObject(IsometricPlayer player, IsometricGameObject gameObject) {
    if (player is! CaptureTheFlagPlayer) return;

    // if (gameObject == flagBlue && flagBlueCharacter == null) {
    //   if (player.isTeamRed || flagBlue.getDistance3(baseBlue) > Base_Radius){
    //     if (flagRedCharacter != player){
    //       flagBlueCharacter = player;
    //       if (player.isTeamRed){
    //         flagBlueStatus.value = CaptureTheFlagFlagStatus.Carried_By_Enemy;
    //         player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Enemy_Flag;
    //       } else {
    //         flagBlueStatus.value = CaptureTheFlagFlagStatus.Carried_By_Allie;
    //         player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Team_Flag;
    //       }
    //     }
    //   }
    //   return;
    // }
    //
    // if (gameObject == flagRed && flagRedCharacter == null) {
    //   if (player.isTeamBlue || flagRed.getDistance3(baseRed) > Base_Radius){
    //     if (flagBlueCharacter != player){
    //       flagRedCharacter = player;
    //       if (player.isTeamBlue){
    //         flagRedStatus.value = CaptureTheFlagFlagStatus.Carried_By_Enemy;
    //         player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Enemy_Flag;
    //       } else {
    //         flagRedStatus.value = CaptureTheFlagFlagStatus.Carried_By_Allie;
    //         player.flagStatus.value = CaptureTheFlagPlayerStatus.Holding_Team_Flag;
    //       }
    //     }
    //   }
    //   return;
    // }
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

  void updateFlag(CaptureTheFlagGameObjectFlag flag){

    if (flag.respawnDuration > 0){
      flag.respawnDuration--;
      if (flag.respawnDuration == 0){
        returnFlagToBase(flag);
        return;
      }
    }


    final flagHeldBy = flag.heldBy;
    if (flagHeldBy == null) return;
    flag.moveTo(flagHeldBy);
  }

  @override
  void customUpdate() {

      for (final character in characters){
        character.customUpdate();
      }

      updateFlag(flagRed);
      updateFlag(flagBlue);
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

    player.writeFlagStatus();

    return player;
  }

  @override
  int get maxPlayers => 10;
}