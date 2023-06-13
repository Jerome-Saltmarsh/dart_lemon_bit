import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_character_class.dart';
import 'package:bleed_server/common/src/capture_the_flag/capture_the_flag_flag_status.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_gameobject_flag.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player.dart';
import 'package:bleed_server/src/games/capture_the_flag/capture_the_flag_player_ai.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/games/isometric/isometric_job.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';
import 'package:bleed_server/src/utilities/change_notifier.dart';
import 'package:lemon_math/functions/give_or_take.dart';

class CaptureTheFlagGame extends IsometricGame<CaptureTheFlagPlayer> {
  static const Players_Per_Team = 5;
  static const Base_Radius = 64.0;
  static const Flag_Respawn_Duration = 500;

  late final CaptureTheFlagGameObjectFlag flagRed;
  late final CaptureTheFlagGameObjectFlag flagBlue;

  late final IsometricGameObject baseRed;
  late final IsometricGameObject baseBlue;

  late final scoreRed = ChangeNotifier(0, dispatchScore);
  late final scoreBlue = ChangeNotifier(0, dispatchScore);

  CaptureTheFlagGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Capture_The_Flag) {
    flagRed = CaptureTheFlagGameObjectFlag(
        x: 200,
        y: 200,
        z: 25,
        type: ItemType.GameObjects_Flag_Red,
        id: generateId())
      ..team = CaptureTheFlagTeam.Red;
    flagBlue = CaptureTheFlagGameObjectFlag(
        x: 200,
        y: 300,
        z: 25,
        type: ItemType.GameObjects_Flag_Blue,
        id: generateId())
      ..team = CaptureTheFlagTeam.Blue;

    gameObjects.add(flagRed);
    gameObjects.add(flagBlue);

    baseRed = spawnGameObject(
        x: 1000, y: 1000, z: 25, type: ItemType.GameObjects_Base_Red)
      ..fixed = true
      ..team = CaptureTheFlagTeam.Red;
    baseBlue = spawnGameObject(
        x: 300, y: 300, z: 25, type: ItemType.GameObjects_Base_Blue)
      ..fixed = true
      ..team = CaptureTheFlagTeam.Blue;

    flagRed.status = CaptureTheFlagFlagStatus.At_Base;
    flagBlue.status = CaptureTheFlagFlagStatus.At_Base;

    flagRed.moveTo(baseRed);
    flagBlue.moveTo(baseBlue);

    for (var i = 1; i <= 3; i++) {
      characters.add(CaptureTheFlagPlayerAI(
          game: this,
          team: CaptureTheFlagTeam.Red,
          role: CaptureTheFlagAIRole.Defense));
      characters.add(CaptureTheFlagPlayerAI(
          game: this,
          team: CaptureTheFlagTeam.Blue,
          role: CaptureTheFlagAIRole.Defense));
    }
    for (var i = 1; i <= 2; i++) {
      characters.add(CaptureTheFlagPlayerAI(
          game: this,
          team: CaptureTheFlagTeam.Red,
          role: CaptureTheFlagAIRole.Offense));
      characters.add(CaptureTheFlagPlayerAI(
          game: this,
          team: CaptureTheFlagTeam.Blue,
          role: CaptureTheFlagAIRole.Offense));
    }
  }

  int get countPlayersOnTeamRed => countPlayersOnTeam(CaptureTheFlagTeam.Red);

  int get countPlayersOnTeamBlue => countPlayersOnTeam(CaptureTheFlagTeam.Blue);

  int countPlayersOnTeam(int team) =>
      players.where((player) => player.team == team).length;

  @override
  void onPlayerUpdateRequestReceived(
      {required IsometricPlayer player,
      required int direction,
      required bool mouseLeftDown,
      required bool mouseRightDown,
      required bool keySpaceDown,
      required bool inputTypeKeyboard}) {
    if (player.deadOrBusy) return;
    if (!player.active) return;

    if (!player.weaponStateBusy) {
      player.lookRadian = player.mouseAngle;
    }

    if (mouseLeftDown) {
      // characterAttackMelee(player);
      characterUseWeapon(player);
    }

    playerRunInDirection(player, Direction.fromInputDirection(direction));
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target == flagRed.heldBy) {
      clearFlagHeldBy(flagRed);
    }
    if (target == flagBlue.heldBy) {
      clearFlagHeldBy(flagBlue);
    }

    jobs.add(IsometricJob(200, () {
      reviveCharacter(target);
    }));
  }

  void reviveCharacter(IsometricCharacter character) {
    final base = getBaseOwn(character);
    activateCollider(character);
    character.health = character.maxHealth;
    character.state = CharacterState.Idle;
    character.x = base.x + giveOrTake(50);
    character.y = base.y + giveOrTake(50);
    character.z = base.z + 25;
  }

  IsometricGameObject getBaseOwn(IsometricCollider collider) {
    if (collider.team == CaptureTheFlagTeam.Blue) {
      return baseBlue;
    }
    if (collider.team == CaptureTheFlagTeam.Red) {
      return baseRed;
    }
    throw Exception('getBaseOwn($collider)');
  }

  @override
  void customOnCollisionBetweenColliders(
      IsometricCollider a, IsometricCollider b) {
    if (a == flagRed || a == flagBlue) {
      onCollisionBetweenFlagAndCollider(a as CaptureTheFlagGameObjectFlag, b);
      return;
    }
    if (b == flagRed || b == flagBlue) {
      onCollisionBetweenFlagAndCollider(b as CaptureTheFlagGameObjectFlag, a);
      return;
    }
  }

  void onCollisionBetweenFlagAndIsometricCharacter(
    CaptureTheFlagGameObjectFlag flag,
    IsometricCharacter character,
  ) {
    if (flag.heldBy != null) return;
    if (getOtherFlag(flag).heldBy == character) return;

    if (flag.team == character.team) {
      if (flag.statusAtBase) return;
      flag.heldBy = character;
      flag.status = CaptureTheFlagFlagStatus.Carried_By_Allie;
      return;
    }

    assert(flag.team != character.team);
    assert(flag.heldBy == null);
    flag.heldBy = character;
    flag.status = CaptureTheFlagFlagStatus.Carried_By_Enemy;
    if (character is CaptureTheFlagPlayer) {
      character.setFlagStatusHoldingEnemyFlag();
    }
  }

  void onCollisionBetweenFlagAndBase(
    CaptureTheFlagGameObjectFlag flag,
    IsometricGameObject base,
  ) {
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

  void onCollisionBetweenFlagAndCollider(
      CaptureTheFlagGameObjectFlag flag, IsometricCollider collider) {
    if (collider is IsometricCharacter) {
      onCollisionBetweenFlagAndIsometricCharacter(flag, collider);
      return;
    }

    if (collider == baseBlue || collider == baseRed) {
      onCollisionBetweenFlagAndBase(flag, collider as IsometricGameObject);
      return;
    }
  }

  void onFlagScored(CaptureTheFlagGameObjectFlag flag) {
    if (flag == flagRed) {
      scoreBlue.value++;
    } else {
      scoreRed.value++;
    }

    flag.respawnDuration = Flag_Respawn_Duration;
    flag.status = CaptureTheFlagFlagStatus.Respawning;
    deactivateCollider(flag);
    clearFlagHeldBy(flag);

    final response = flag == flagRed
        ? CaptureTheFlagResponse.Blue_Team_Scored
        : CaptureTheFlagResponse.Red_Team_Scored;
    for (final player in players) {
      player.writeByte(ServerResponse.Capture_The_Flag);
      player.writeByte(response);
    }
  }

  void clearFlagHeldBy(CaptureTheFlagGameObjectFlag flag) {
    final flagHeldBy = flag.heldBy;
    flag.heldBy = null;
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

  void returnFlagToBase(CaptureTheFlagGameObjectFlag flag) {
    activateCollider(flag);
    if (flag.statusAtBase) return;
    clearFlagHeldBy(flag);
    flag.status = CaptureTheFlagFlagStatus.At_Base;
    flag.moveTo(getFlagBase(flag));
  }

  IsometricGameObject getFlagBase(CaptureTheFlagGameObjectFlag flag) =>
      (flag == flagRed) ? baseRed : baseBlue;

  CaptureTheFlagGameObjectFlag getOtherFlag(
          CaptureTheFlagGameObjectFlag flag) =>
      flag == flagRed ? flagBlue : flagRed;

  void dispatchScore() {
    for (final player in players) {
      player.writeScore();
    }
  }

  @override
  void customWriteGame() {
    dispatchFlagStatus(); // optimized
  }

  void dispatchFlagStatus() {
    for (final player in players) {
      player.writeFlagStatus();
    }
  }

  void updateFlag(CaptureTheFlagGameObjectFlag flag) {
    if (flag.respawnDuration > 0) {
      flag.respawnDuration--;
      if (flag.respawnDuration <= 0) {
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
    for (final character in characters) {
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

    player.moveTo(getBaseOwn(player));

    if (player.team == CaptureTheFlagTeam.Blue) {
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
  int get maxPlayers => Players_Per_Team * 2;

  @override
  void customOnPlayerJoined(CaptureTheFlagPlayer player) {
    balanceTeams();
    player.writeSelectClass(true);
  }

  int get totalAIOnTeamRed => characters
      .where((character) =>
          character.team == CaptureTheFlagTeam.Red &&
          character is CaptureTheFlagPlayerAI)
      .length;

  int get totalAIOnTeamBlue => characters
      .where((character) =>
          character.team == CaptureTheFlagTeam.Blue &&
          character is CaptureTheFlagPlayerAI)
      .length;

  void balanceTeams() {
    var totalRed = characters
        .where((character) => character.team == CaptureTheFlagTeam.Red)
        .length;

    if (totalRed > Players_Per_Team) {
      var amountToRemove = totalRed - Players_Per_Team;
      if (totalAIOnTeamRed < amountToRemove) {
        throw Exception(
            'balanceTeams Exception because totalAIOnTeamRed < amountToRemove');
      }
      for (var i = 0; i < characters.length; i++) {
        if (characters[i].team != CaptureTheFlagTeam.Red) continue;
        if (characters[i] is! CaptureTheFlagPlayerAI) continue;
        removeInstance(characters[i]);
        amountToRemove--;
        if (amountToRemove == 0) break;
      }
    }


    var totalBlue = characters
        .where((character) => character.team == CaptureTheFlagTeam.Blue)
        .length;

    if (totalBlue > Players_Per_Team) {
      var amountToRemove = totalBlue - Players_Per_Team;
      if (totalAIOnTeamBlue < amountToRemove) {
        throw Exception(
            'balanceTeams Exception because totalAIOnTeamRed < amountToRemove');
      }
      for (var i = 0; i < characters.length; i++) {
        if (characters[i].team != CaptureTheFlagTeam.Blue) continue;
        if (characters[i] is! CaptureTheFlagPlayerAI) continue;
        removeInstance(characters[i]);
        amountToRemove--;
        if (amountToRemove == 0) break;
      }
    }
  }

  void playerSelectCharacterClass(CaptureTheFlagPlayer player, CaptureTheFlagCharacterClass classType){
     switch (classType){
       case CaptureTheFlagCharacterClass.sniper:
         player.weaponType = ItemType.Weapon_Ranged_Sniper_Rifle;
         break;
       case CaptureTheFlagCharacterClass.machineGun:
         player.weaponType = ItemType.Weapon_Ranged_Machine_Gun;
         break;
       case CaptureTheFlagCharacterClass.medic:
         player.weaponType = ItemType.Weapon_Ranged_Smg;
         break;
       case CaptureTheFlagCharacterClass.scout:
         player.weaponType = ItemType.Weapon_Ranged_Handgun;
         break;
       case CaptureTheFlagCharacterClass.shotgun:
         player.weaponType = ItemType.Weapon_Ranged_Shotgun;
         break;
     }
     player.writeSelectClass(false);
  }
}
