import 'package:bleed_server/common/src.dart';
import 'package:bleed_server/common/src/capture_the_flag/src.dart';
import 'package:bleed_server/src/game/job.dart';
import 'package:bleed_server/src/games/isometric/isometric_character.dart';
import 'package:bleed_server/src/games/isometric/isometric_collider.dart';
import 'package:bleed_server/src/games/isometric/isometric_game.dart';
import 'package:bleed_server/src/games/isometric/isometric_gameobject.dart';
import 'package:bleed_server/src/utilities/change_notifier.dart';
import 'package:lemon_math/functions/give_or_take.dart';

import 'capture_the_flag_gameobject_flag.dart';
import 'capture_the_flag_player.dart';
import 'capture_the_flag_ai.dart';

class CaptureTheFlagGame extends IsometricGame<CaptureTheFlagPlayer> {
  static const Target_Points = 11;
  static const Players_Per_Team = 5;
  static const Base_Radius = 64.0;
  static const Flag_Respawn_Duration = 500;
  static const Next_Game_Duration = 45 * 8;

  late final CaptureTheFlagGameObjectFlag flagRed;
  late final CaptureTheFlagGameObjectFlag flagBlue;

  late final IsometricGameObject baseRed;
  late final IsometricGameObject baseBlue;

  late final IsometricGameObject redFlagSpawn;
  late final IsometricGameObject blueFlagSpawn;

  late final gameStatus = ChangeNotifier(CaptureTheFlagGameStatus.In_Progress, onChangedGameStatus);
  late final scoreRed = ChangeNotifier(0, onChangedScoreRed);
  late final scoreBlue = ChangeNotifier(0, onChangedScoreBlue);
  late final nextGameCountDown = ChangeNotifier(Next_Game_Duration, onChangedNextGameCountDown);

  CaptureTheFlagGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Capture_The_Flag) {

    removeFlags();


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

    redFlagSpawn = findGameObjectByTypeOrFail(ItemType.GameObjects_Flag_Spawn_Red);
    blueFlagSpawn = findGameObjectByTypeOrFail(ItemType.GameObjects_Flag_Spawn_Blue);

    baseRed = (findGameObjectByType(ItemType.GameObjects_Base_Red) ?? spawnGameObject(
        x: scene.gridRowLength * 0.5, y: scene.gridColumnLength - 150, z: 25, type: ItemType.GameObjects_Base_Red)
    )
      ..fixed = true
      ..team = CaptureTheFlagTeam.Red;

    baseBlue = (findGameObjectByType(ItemType.GameObjects_Base_Blue) ?? spawnGameObject(
        x: scene.gridRowLength * 0.5, y: 150, z: 25, type: ItemType.GameObjects_Base_Blue))
      ..fixed = true
      ..team = CaptureTheFlagTeam.Blue;

    flagRed.status = CaptureTheFlagFlagStatus.At_Base;
    flagBlue.status = CaptureTheFlagFlagStatus.At_Base;

    flagRed.moveTo(redFlagSpawn);
    flagBlue.moveTo(blueFlagSpawn);

    for (final team in CaptureTheFlagTeam.values) {
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: ItemType.Weapon_Ranged_Sniper_Rifle,
          role: CaptureTheFlagAIRole.Defense,
      ));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: ItemType.Weapon_Ranged_Smg,
          role: CaptureTheFlagAIRole.Defense));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: ItemType.Weapon_Melee_Sword,
          role: CaptureTheFlagAIRole.Offense));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: ItemType.Weapon_Ranged_Bow,
          role: CaptureTheFlagAIRole.Offense));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: ItemType.Weapon_Ranged_Machine_Gun,
          role: CaptureTheFlagAIRole.Offense));
    }
  }

  void addCharacterAI({
      required int team,
      required int weaponType,
      required CaptureTheFlagAIRole role,
  }) =>
      characters.add(CaptureTheFlagAI(
        game: this,
        team: team,
        weaponType: weaponType,
        role: role,
      ));

  int get countPlayersOnTeamRed => countPlayersOnTeam(CaptureTheFlagTeam.Red);

  int get countPlayersOnTeamBlue => countPlayersOnTeam(CaptureTheFlagTeam.Blue);

  void removeFlags() {
     for (var i = 0; i < gameObjects.length; i++){
      final gameObject = gameObjects[i];
      if (const [ItemType.GameObjects_Flag_Blue, ItemType.GameObjects_Flag_Red]
          .contains(gameObject.type)) {
        gameObjects.removeAt(i);
        i--;
      }
    }
  }

  int countPlayersOnTeam(int team) =>
      players.where((player) => player.team == team).length;

  @override
  void onPlayerUpdateRequestReceived({
      required CaptureTheFlagPlayer player,
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
      final activatedPower = player.activatedPower.value;
      if (activatedPower == null){
        characterUseWeapon(player);
      } else if (activatedPower.type == CaptureTheFlagPowerType.Blink){
         player.x = player.mouseGridX;
         player.y = player.mouseGridY;
         player.activatedPower.value = null;
      }
    }

    if (mouseRightDown){
      player.selectAINearestToMouse();
    }

    playerRunInDirection(player, Direction.fromInputDirection(direction));
  }

  @override
  void customOnCharacterKilled(IsometricCharacter target, src) {
    if (target == flagRed.heldBy) {
      clearFlagHeldBy(flagRed);
      flagRed.setStatusDropped();
    }
    if (target == flagBlue.heldBy) {
      clearFlagHeldBy(flagBlue);
      flagBlue.setStatusDropped();
    }
    jobs.add(GameJob(200, () {
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
      flag.status = CaptureTheFlagFlagStatus.Carried_By_Ally;
      if (character.target == flag){
        character.target = null;
      }
      return;
    }

    assert(flag.team != character.team);
    assert(flag.heldBy == null);
    if (character.target == flag){
      character.target = null;
    }
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
      returnFlagToRespawn(flag);
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

  void returnFlagToRespawn(CaptureTheFlagGameObjectFlag flag) {
    activateCollider(flag);
    if (flag.statusAtBase) return;
    clearFlagHeldBy(flag);
    flag.status = CaptureTheFlagFlagStatus.At_Base;
    flag.moveTo(getFlagSpawn(flag));
  }

  IsometricGameObject getFlagBase(CaptureTheFlagGameObjectFlag flag) =>
      (flag == flagRed) ? baseRed : baseBlue;

  IsometricGameObject getFlagSpawn(CaptureTheFlagGameObjectFlag flag) =>
      (flag == flagRed) ? redFlagSpawn : blueFlagSpawn;

  CaptureTheFlagGameObjectFlag getOtherFlag(
          CaptureTheFlagGameObjectFlag flag) =>
      flag == flagRed ? flagBlue : flagRed;



  void onChangedScoreRed(int scoreRed) {
    dispatchScore();
    if (scoreRed >= Target_Points) {
      gameStatus.value = CaptureTheFlagGameStatus.Red_Won;
    }
  }

  void onChangedNextGameCountDown(int value) {
    for (final player in players) {
      player.writeNextGameCountDown(value);
    }
    if (value == 0){
      setGameStatusInProgress();
    }
  }

  void setGameStatusInProgress() {
    gameStatus.value = CaptureTheFlagGameStatus.In_Progress;
  }



  void onChangedScoreBlue(int scoreBlue){
    dispatchScore();
    if (scoreBlue >= Target_Points) {
      gameStatus.value = CaptureTheFlagGameStatus.Blue_Won;
    }
  }

  void dispatchScore() {
    for (final player in players) {
      player.writeScore();
    }
  }

  @override
  void customWriteGame() {
    super.customWriteGame();
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
        returnFlagToRespawn(flag);
        return;
      }
    }

    final flagHeldBy = flag.heldBy;
    if (flagHeldBy == null) return;
    flag.moveTo(flagHeldBy);
  }

  @override
  void customNotRunningUpdate() {
     if (nextGameCountDown.value > 0) {
       nextGameCountDown.value--;
     }
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
    player.writeCaptureTheFlagGameStatus(gameStatus.value);
  }

  int get totalAIOnTeamRed => characters
      .where((character) =>
          character.team == CaptureTheFlagTeam.Red &&
          character is CaptureTheFlagAI)
      .length;

  int get totalAIOnTeamBlue => characters
      .where((character) =>
          character.team == CaptureTheFlagTeam.Blue &&
          character is CaptureTheFlagAI)
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
        if (characters[i] is! CaptureTheFlagAI) continue;
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
        if (characters[i] is! CaptureTheFlagAI) continue;
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
         player.weaponType = ItemType.Weapon_Ranged_Bow;
         break;
       case CaptureTheFlagCharacterClass.shotgun:
         player.weaponType = ItemType.Weapon_Ranged_Shotgun;
         break;
       case CaptureTheFlagCharacterClass.knight:
         player.weaponType = ItemType.Weapon_Melee_Sword;
         break;
     }
     player.writeSelectClass(false);
  }

  void onChangedGameStatus(CaptureTheFlagGameStatus value){
    final gameOver = value != CaptureTheFlagGameStatus.In_Progress;
    running = !gameOver;
    if (gameOver) {
      resetNextGameCountDown();
    }
    for (final player in players) {
      player.writeCaptureTheFlagGameStatus(value);
    }
  }

  void resetNextGameCountDown() {
    nextGameCountDown.value = Next_Game_Duration;
  }

  double getWeaponTypeRange(int weaponType) => const <int, double>{
    ItemType.Weapon_Melee_Sword: 60,
    ItemType.Weapon_Ranged_Bow: 300,
    ItemType.Weapon_Ranged_Smg: 190,
    ItemType.Weapon_Ranged_Machine_Gun: 200,
    ItemType.Weapon_Ranged_Shotgun: 150,
    ItemType.Weapon_Ranged_Handgun: 200,
    ItemType.Weapon_Ranged_Sniper_Rifle: 350,
  }[weaponType] ?? (throw Exception('getWeaponTypeRange(${ItemType.getName(weaponType)})'));

}
