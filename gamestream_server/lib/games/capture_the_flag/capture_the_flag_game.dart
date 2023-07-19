import 'package:gamestream_server/common/src.dart';
import 'package:gamestream_server/isometric/src.dart';
import 'package:gamestream_server/core/job.dart';
import 'package:gamestream_server/utils/change_notifier.dart';

import 'package:gamestream_server/lemon_math.dart';


import 'capture_the_flag_ai.dart';
import 'capture_the_flag_gameobject_flag.dart';
import 'capture_the_flag_player.dart';

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

  void removeGameObjects({required int type, required int subType}) =>
      gameObjects.removeWhere((gameObject) =>
        gameObject.type == type &&
        gameObject.subType == subType
      );

  CaptureTheFlagGame({
    required super.scene,
    required super.time,
    required super.environment,
  }) : super(gameType: GameType.Capture_The_Flag) {

    removeGameObjects(type: GameObjectType.Object, subType: ObjectType.Base_Red);
    removeGameObjects(type: GameObjectType.Object, subType: ObjectType.Base_Blue);
    removeGameObjects(type: GameObjectType.Object, subType: ObjectType.Flag_Red);
    removeGameObjects(type: GameObjectType.Object, subType: ObjectType.Flag_Blue);
    removeGameObjects(type: GameObjectType.Object, subType: ObjectType.Spawn_Red);
    removeGameObjects(type: GameObjectType.Object, subType: ObjectType.Spawn_Blue);

    const spawnDistance = 300.0;

    flagRed = CaptureTheFlagGameObjectFlag(
        x: 200,
        y: 200,
        z: 25,
        subType: ObjectType.Flag_Red,
        id: generateId(),
        team: CaptureTheFlagTeam.Red,
    );

    flagBlue = CaptureTheFlagGameObjectFlag(
        x: 200,
        y: 300,
        z: 25,
        subType: ObjectType.Flag_Blue,
        id: generateId(),
        team: CaptureTheFlagTeam.Blue,
    );

    gameObjects.add(flagRed);
    gameObjects.add(flagBlue);

    baseRed = spawnGameObject(
        x: scene.rowLength * 0.5,
        y: 100,
        z: 25,
        type: GameObjectType.Object,
        subType: ObjectType.Base_Red,
        team: CaptureTheFlagTeam.Red,
    )
      ..physical = false
      ..fixed = true;

    baseBlue = spawnGameObject(
        x: scene.rowLength * 0.5,
        y: scene.columnLength - 100,
        z: 25,
        type: GameObjectType.Object,
        subType: ObjectType.Base_Blue,
        team: CaptureTheFlagTeam.Blue,
    )
      ..physical = false
      ..fixed = true
      ..team = CaptureTheFlagTeam.Blue;

    redFlagSpawn = findGameObjectOrSpawn(
      type: GameObjectType.Object,
      subType: ObjectType.Spawn_Red,
      x: baseRed.x,
      y: baseRed.y + spawnDistance,
      z: baseRed.z,
      team: CaptureTheFlagTeam.Red,
    )
      ..physical = false
      ..fixed = true;

    blueFlagSpawn = findGameObjectOrSpawn(
      type: GameObjectType.Object,
      subType: ObjectType.Spawn_Blue,
      x: baseBlue.x,
      y: baseBlue.y - spawnDistance,
      z: baseBlue.z,
      team: CaptureTheFlagTeam.Blue,
    )
      ..physical = false
      ..fixed = true;

    flagRed.status = CaptureTheFlagFlagStatus.At_Base;
    flagBlue.status = CaptureTheFlagFlagStatus.At_Base;

    flagRed.moveTo(redFlagSpawn);
    flagBlue.moveTo(blueFlagSpawn);

    for (final team in CaptureTheFlagTeam.values) {
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: WeaponType.Sniper_Rifle,
          role: CaptureTheFlagAIRole.Defense,
      ));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: WeaponType.Smg,
          role: CaptureTheFlagAIRole.Defense));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: WeaponType.Sword,
          role: CaptureTheFlagAIRole.Offense));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: WeaponType.Bow,
          role: CaptureTheFlagAIRole.Offense));
      characters.add(CaptureTheFlagAI(
          game: this,
          team: team,
          weaponType: WeaponType.Machine_Gun,
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

  int countPlayersOnTeam(int team) =>
      players.where((player) => player.team == team).length;

  void playerUsePower(CaptureTheFlagPlayer player, IsometricPower power) {

    switch (power.type) {

      case PowerType.Blink:
        player.x = player.activatedPowerX;
        player.y = player.activatedPowerY;
        break;

      case PowerType.Slow:
        final target = player.powerPerformingTarget;
        assert (target != null);
        if (target == null) {
          return;
        }
        if (target is CaptureTheFlagAI) {
           target.slowed = true;
           target.slowedDuration = power.duration;
        }

        break;

      case PowerType.Heal:
        final target = player.powerPerformingTarget;
        assert (target != null);
        if (target is! IsometricCharacter) return;
        target.health = target.maxHealth;
        break;
    }
    player.powerPerformingTarget = null;
    power.activated();
  }

  int getExperience(IsometricCharacter target){
    return 1;
  }

  int getExperienceRequiredForLevel(int level){
    return 100;
  }

  void playerGainExperience(CaptureTheFlagPlayer player, int experience){
    const maxLevel = 5;
    if (player.level.value >= maxLevel) return;

    if (player.experience.value + experience < getExperienceForLevel(player.level.value)){
      player.experience.value += experience;
      return;
    }

    while (player.experience.value + experience > getExperienceForLevel(player.level.value)) {
      experience -= getExperienceForLevel(player.level.value) - player.experience.value;
      player.experience.value = 0;
      player.level.value++;
      player.writePlayerEventLevelGained();
    }

    player.experience.value += experience;
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
    if (src is CaptureTheFlagPlayer) {
      playerGainExperience(src, getExperience(target));
    }

    jobs.add(GameJob(200, () {
      reviveCharacter(target);
    }));
  }

  void reviveCharacter(IsometricCharacter character) {
    final base = getBaseOwn(character);
    activateCollider(character);
    character.clearPath();
    character.target = null;
    character.health = character.maxHealth;
    character.state = CharacterState.Idle;
    character.x = base.x + giveOrTake(50);
    character.y = base.y + giveOrTake(50);
    character.z = base.z + 25;
    character.setDestinationToCurrentPosition();
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
    deactivate(flag);
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
    super.customUpdate();
    updateFlag(flagRed);
    updateFlag(flagBlue);
  }

  @override
  void updatePlayer(CaptureTheFlagPlayer player) {
    super.updatePlayer(player);

    if (player.shouldUsePowerPerforming) {
      playerUsePowerPerforming(player);
    }

    final activatedPower = player.powerActivated.value;
    if (activatedPower == null) return;

    switch (activatedPower.type.mode){
      case CaptureTheFlagPowerMode.Self:
        break;
      case CaptureTheFlagPowerMode.Positional:
        if (player.canUpdatePowerPosition) {
          updatePlayerActivatedPowerPosition(player);
        }
        break;
      case CaptureTheFlagPowerMode.Targeted_Enemy:
        if (player.canUpdatePowerTarget) {
          updatePlayerActivatedPowerTarget(player);
        }
        break;
      case CaptureTheFlagPowerMode.Targeted_Ally:
        if (player.canUpdatePowerTarget) {
          updatePlayerActivatedPowerTargetAlly(player);
        }
        break;
    }

  }

  void playerUsePowerPerforming(CaptureTheFlagPlayer player){
    assert(player.shouldUsePowerPerforming);

    final powerPerforming = player.powerPerforming;
    if (powerPerforming == null) return;
    playerUsePower(player, powerPerforming);
    player.powerPerforming = null;
  }

  void updatePlayerActivatedPowerPosition(CaptureTheFlagPlayer player) {

    final activatedPower = player.powerActivated.value;
    assert (activatedPower != null);
    if (activatedPower == null) return;

    final range = activatedPower.range;
    if (player.mouseDistance <= range){
      player.activatedPowerX = clampX(player.mouseSceneX);
      player.activatedPowerY = clampY(player.mouseSceneY);
    } else {
      final angle = player.mouseAngle;
      player.activatedPowerX = player.x + adj(angle, range);
      player.activatedPowerY = player.y + opp(angle, range);
    }
  }

  void updatePlayerActivatedPowerTarget(CaptureTheFlagPlayer player) {

    final activatedPower = player.powerActivated.value;
    assert (activatedPower != null);
    if (activatedPower == null) return;
    assert (activatedPower.isTargeted);

    var nearestSquared = 10000.0;
    player.powerActivatedTarget = null;
    if (!activatedPower.isTargeted) return;


    if (activatedPower.isTargetedEnemy){
      for (final character in characters) {
        if (character.dead) continue;
        if (!character.active) continue;
        if (!player.isEnemy(character)) continue;
        if (!player.withinRadiusPosition(character, activatedPower.range)) continue;
        if (!character.withinRadiusXYZ(player.mouseSceneX, player.mouseSceneY, character.z, 50)) continue;
        final characterDistanceSquared = character.getDistanceSquaredXYZ(player.mouseSceneX, player.mouseSceneY, player.z);
        if (characterDistanceSquared > nearestSquared) continue;
        nearestSquared = characterDistanceSquared;
        player.powerActivatedTarget = character;
      }
    }
    if (activatedPower.isTargetedAlly){
      for (final character in characters) {
        if (character.dead) continue;
        if (!character.active) continue;
        if (!player.isAlly(character)) continue;
        if (!player.withinRadiusPosition(character, activatedPower.range)) continue;
        if (!character.withinRadiusXYZ(player.mouseSceneX, player.mouseSceneY, character.z, 50)) continue;
        final characterDistanceSquared = character.getDistanceSquaredXYZ(player.mouseSceneX, player.mouseSceneY, player.z);
        if (characterDistanceSquared > nearestSquared) continue;
        nearestSquared = characterDistanceSquared;
        player.powerActivatedTarget = character;
      }
    }

  }

  void updatePlayerActivatedPowerTargetAlly(CaptureTheFlagPlayer player) {

    final activatedPower = player.powerActivated.value;
    assert (activatedPower != null);
    if (activatedPower == null) return;

    var nearestSquared = 10000.0;
    player.powerActivatedTarget = null;
    for (final character in characters) {
      if (character.dead) continue;
      if (!character.active) continue;
      if (!player.isAlly(character)) continue;
      if (!player.withinRadiusPosition(character, activatedPower.range)) continue;
      if (!character.withinRadiusXYZ(player.mouseSceneX, player.mouseSceneY, character.z, 50)) continue;
      final characterDistanceSquared = character.getDistanceSquaredXYZ(player.mouseSceneX, player.mouseSceneY, player.z);
      if (characterDistanceSquared > nearestSquared) continue;
      nearestSquared = characterDistanceSquared;
      player.powerActivatedTarget = character;
    }
  }

  @override
  CaptureTheFlagPlayer buildPlayer() {

    final team = getNewPlayerTeam();
    final baseOwn = team == CaptureTheFlagTeam.Blue ? baseBlue : baseRed;

    final player = CaptureTheFlagPlayer(
      game: this,
      x: baseOwn.x,
      y: baseOwn.y,
      z: baseOwn.z,
      power1: IsometricPower(
        type: PowerType.Blink,
        range: 300,
        cooldown: 400,
      ),
      power2: IsometricPower(
        type: PowerType.Heal,
        range: 300,
        cooldown: 300,
        duration: 120,
      ),
      power3: IsometricPower(
        type: PowerType.Slow,
        range: 300,
        cooldown: 300,
        duration: 120,
      ),
      team: getNewPlayerTeam()
    );

    player.setDestinationToCurrentPosition();

    if (player.team == CaptureTheFlagTeam.Blue) {
      player.legsType = LegType.Blue;
      player.bodyType = BodyType.Shirt_Blue;
    } else {
      player.legsType = LegType.Red;
      player.bodyType = BodyType.Shirt_Red;
    }

    player.writeFlagStatus();
    player.writePlayerLevel();
    player.writePlayerExperience();
    return player;
  }

  int getNewPlayerTeam() {
    return countPlayersOnTeamBlue > countPlayersOnTeamRed
        ? CaptureTheFlagTeam.Red
        : CaptureTheFlagTeam.Blue;
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
        remove(characters[i]);
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
        remove(characters[i]);
        amountToRemove--;
        if (amountToRemove == 0) break;
      }
    }
  }

  void playerSelectCharacterClass(CaptureTheFlagPlayer player, CaptureTheFlagCharacterClass classType){
     switch (classType){
       case CaptureTheFlagCharacterClass.sniper:
         player.weaponType = WeaponType.Sniper_Rifle;
         break;
       case CaptureTheFlagCharacterClass.machineGun:
         player.weaponType = WeaponType.Machine_Gun;
         break;
       case CaptureTheFlagCharacterClass.medic:
         player.weaponType = WeaponType.Smg;
         break;
       case CaptureTheFlagCharacterClass.scout:
         player.weaponType = WeaponType.Bow;
         break;
       case CaptureTheFlagCharacterClass.shotgun:
         player.weaponType = WeaponType.Smg;
         break;
       case CaptureTheFlagCharacterClass.knight:
         player.weaponType = WeaponType.Sword;
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
    WeaponType.Sword: 60,
    WeaponType.Bow: 300,
    WeaponType.Smg: 190,
    WeaponType.Machine_Gun: 200,
    WeaponType.Shotgun: 150,
    WeaponType.Handgun: 200,
    WeaponType.Sniper_Rifle: 350,
  }[weaponType] ?? (throw Exception('getWeaponTypeRange($weaponType)'));

  int getWeaponTypeDamage(int weaponType) => const <int, int>{
    WeaponType.Sword: 2,
  }[weaponType] ?? 1;

  int getWeaponCooldown(int weaponType) => const <int, int>{
    WeaponType.Unarmed: 20,
    WeaponType.Handgun: 20,
    WeaponType.Smg: 5,
    WeaponType.Sniper_Rifle: 40,
    WeaponType.Shotgun: 40,
    WeaponType.Sword: 35,
    WeaponType.Bow: 25,
    WeaponType.Machine_Gun: 5,
  }[weaponType] ?? (throw Exception('getWeaponCooldown(${WeaponType.getName(weaponType)})'));

  int getExperienceForLevel(int level) => (((level - 1) * (level - 1))) * 6;
}
