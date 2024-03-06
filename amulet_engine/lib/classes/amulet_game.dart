import 'dart:math';
import 'dart:typed_data';

import 'package:lemon_lang/src.dart';
import 'package:lemon_math/src.dart';

import '../../src.dart';
import 'amulet.dart';
import 'amulet_fiend.dart';
import '../isometric/src.dart';

class AmuletGame extends IsometricGame<AmuletPlayer> {

  static const weaponSkillTypes = [SkillType.Shoot_Arrow, SkillType.Strike];

  final Amulet amulet;
  final String name;
  final AmuletScene amuletScene;
  final int level;

  final gameObjectDeactivationTimer = 5000;

  var secondsPerRegen = 5;
  var nextRegen = 0;
  var cooldownTimer = 0;
  var flatNodes = Uint8List(0);
  var worldIndex = 255;
  var worldRow = 255;
  var worldColumn = 255;

  AmuletGame({
    required this.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required this.name,
    required this.amuletScene,
    required this.level,
  }) {
    refreshFlatNodes();
  }

  // void spawnMarkPortals() {
  //   final marks = scene.marks;
  //   for (final mark in marks) {
  //      if (MarkType.getType(mark) != MarkType.Portal){
  //        continue;
  //      }
  //      final index = MarkType.getIndex(mark);
  //      final subType = MarkType.getSubType(mark);
  //      final amuletScene = AmuletScene.values[subType];
  //
  //
  //      var targetIndex = -1;
  //      final targetGame = amulet.getAmuletSceneGame(amuletScene);
  //      final targetGameMarks = targetGame.scene.marks;
  //      for (final targetMark in targetGameMarks){
  //         if (MarkType.getType(targetMark) != MarkType.Portal) continue;
  //         final targetMarkSubType = MarkType.getSubType(targetMark);
  //         final targetScene = AmuletScene.values[targetMarkSubType];
  //         if (targetScene != this.amuletScene) continue;
  //         targetIndex = MarkType.getIndex(targetMark);
  //      }
  //
  //      if (targetIndex == -1){
  //        print('INVALID_PORTALS: ${amuletScene.name} does not a have a portal to ${this.amuletScene.name}');
  //      } else {
  //        final portal = spawnGameObjectAtIndex(
  //          index: index,
  //          type: ItemType.Object,
  //          subType: GameObjectType.Interactable,
  //          team: TeamType.Neutral,
  //          persistable: false,
  //          interactable: true,
  //          health: 0,
  //          deactivationTimer: 0,
  //        );
  //        portal.label = amuletScene.name;
  //        portal.fixed = true;
  //        portal.gravity = false;
  //        portal.hitable = false;
  //        portal.collectable = false;
  //        portal.collidable = false;
  //        portal.destroyable = false;
  //        portal.onInteract = (dynamic src){
  //          if (src is! AmuletPlayer){
  //            return;
  //          }
  //          amulet.playerChangeGame(
  //            player: src,
  //            target: targetGame,
  //          );
  //          src.writePlayerEvent(PlayerEvent.Portal_Used);
  //          final targetScene = targetGame.scene;
  //          final targetShapes = targetScene.nodeOrientations;
  //          if (targetShapes[targetIndex + targetScene.columns] == NodeOrientation.None){
  //            targetGame.movePositionToIndex(src, targetIndex + targetScene.columns);
  //          } else if (targetShapes[targetIndex + 1] == NodeOrientation.None) {
  //            targetGame.movePositionToIndex(src, targetIndex + 1);
  //          } else {
  //            print('INVALID_PORTALS: ${amuletScene.name} does not a have a valid port index destination');
  //          }
  //
  //          src.writePlayerMoved();
  //        };
  //      }
  //   }
  // }

  void refreshFlatNodes(){
    final scene = this.scene;
    final area = scene.area;
    if (this.flatNodes.length != area) {
      this.flatNodes = Uint8List(area);
    }
    final flatNodes = this.flatNodes;
    final rows = scene.rows;
    final columns = scene.columns;
    final zs = scene.height;
    final nodeTypes = scene.nodeTypes;
    var i = 0;
    for (var row = 0; row < rows; row++){
      for (var column = 0; column < columns; column++) {
        for (var z = zs - 1; z >= 0; z--){
          final index = (z * area) + (row * columns) + column;
           final nodeType = nodeTypes[index];
           if (const [
             NodeType.Empty,
             NodeType.Rain_Falling,
             NodeType.Rain_Landing,
           ].contains(nodeType)){
             if (z == 0){
               flatNodes[i] = NodeType.Empty;
               i++;
               break;
             }
             continue;
           }
           flatNodes[i] = nodeType;
           i++;
           break;
        }
      }
    }
  }

  @override
  int get maxPlayers => 64;

  @override
  void update() {
    super.update();
    updateCooldownTimer();
    // updatePlayerCollectables();

  }

  void updateCooldownTimer() {
    if (cooldownTimer-- > 0) {
      return;
    }

    cooldownTimer = Frames_Per_Second;
    onSecondElapsed();
  }

  void onSecondElapsed(){

    nextRegen--;
    if (nextRegen > 0) {
      return;
    }
    nextRegen = secondsPerRegen;
    final characters = this.characters;
    for (final character in characters) {
      if (character.dead) continue;

      // TODO
      // final regenHealthLevel = getCharacterSkillTypeLevel(character, SkillType.Health_Regen);
      // final regenMagicLevel = getCharacterSkillTypeLevel(character, SkillType.Magic_Regen);

      if (character is AmuletPlayer) {
        character.regenHealthAndMagic();
      }
    }
  }

  int getCharacterHealthRegen(Character character){
     if (character is AmuletPlayer){
       return character.regenHealth;
     }
     if (character is AmuletFiend){
       return character.regenHealth;
     }
     return 0;
  }

  int getCharacterMagicRegen(Character character){
     if (character is AmuletPlayer){
       return character.regenMagic;
     }
     if (character is AmuletFiend){
       return character.regenMagic;
     }
     return 0;
  }

  void spawnFiendsAtSpawnNodes(Difficulty difficulty) {
    final marks = scene.marks;
    final length = marks.length;
    for (var i = 0; i < length; i++) {
      final markValue = marks[i];
      final markType = MarkType.getType(markValue);
      if (markType != MarkType.Fiend){
        continue;
      }
      final markSubType = MarkType.getSubType(markValue);
      final fiendType = FiendType.values.tryGet(markSubType) ?? FiendType.Goblin;
      final quantity = fiendType.quantity;

      for (var j = 0; j < quantity; j++){
        spawnFiendTypeAtIndex(
          fiendType: fiendType,
          index: MarkType.getIndex(markValue),
          level: level,
          difficulty: difficulty,

        );
      }
    }
  }

  Character spawnFiendTypeAtIndex({
    required FiendType fiendType,
    required int index,
    required int level,
    required Difficulty difficulty,
  }) =>
      spawnAmuletFiendAtXYZ(
        x: scene.getIndexX(index),
        y: scene.getIndexY(index),
        z: scene.getIndexZ(index),
        fiendType: fiendType,
        level: level,
        difficulty: difficulty,
      );

  AmuletFiend spawnAmuletFiendAtXYZ({
    required double x,
    required double y,
    required double z,
    required FiendType fiendType,
    required int level,
    required Difficulty difficulty,
  }) {
    final character = AmuletFiend(
      team: TeamType.Evil,
      x: x,
      y: y,
      z: z,
      fiendType: fiendType,
      level: level,
      difficulty: difficulty,
    )
      ..weaponHitForce = 2;

    character.roamEnabled = true;
    characters.add(character);
    return character;
  }

  @override
  void customOnPlayerDead(AmuletPlayer player) {
    player.reviveTimer = amulet.fps * AmuletSettings.Player_Revive_Timer;
  }

  @override
  void performCharacterEnd(Character character){
     if (character is AmuletFiend){

       if (character.fiendType.clearTargetOnPerformAction){
         character.clearTarget();
       }

        if (character.characterStateAttacking){
          super.performCharacterEnd(character);
          final fiendType = character.fiendType;
          character.setCharacterState(
            value: CharacterState.Idle,
            duration: randomInt(
                fiendType.postAttackPauseDurationMin,
                fiendType.postAttackPauseDurationMax,
            ),
          );
          character.activeSkillType = character.fiendType.skillType;
          return;
        }
     }

     if (character is AmuletPlayer) {
       character.skillActiveLeft = true;
     }
     super.performCharacterEnd(character);
  }

  @override
  void setCharacterStateDead(Character character) {
    super.setCharacterStateDead(character);
    if (character is AmuletPlayer) {
      character.activeSkillActiveLeft();
    }
  }

  @override
  void performCharacterAction(Character character) {
    character.clearActionFrame();
    if (character is AmuletFiend){
      characterPerformSkillType(
        character: character,
        skillType: character.activeSkillType ?? character.fiendType.skillType,
      );
      return;
    }
    if (character is AmuletPlayer) {
      characterPerformSkillType(
        character: character,
        skillType: character.skillActive,
      );
      return;
    }
    super.performCharacterAction(character);
  }

  void characterPerformSkillType({
    required Character character,
    required SkillType skillType,
  }){

    final level = getCharacterSkillTypeLevel(character, skillType);

    if (level <= 0 && !weaponSkillTypes.contains(skillType)){
      throw Exception();
    }

    switch (skillType) {
      case SkillType.Strike:
        characterPerformSkillTypeStrike(character);
        break;
      case SkillType.Shoot_Arrow:
        characterPerformSkillTypeShootArrow(character);
        return;
      case SkillType.Wind_Cut:
        characterPerformSkillTypeWindCut(character);
        return;
      case SkillType.Mighty_Strike:
        characterPerformSkillTypeMightySwing(character, level);
        return;
      case SkillType.Split_Shot:
        characterPerformSkillTypeSplitShot(character, level);
        break;
      case SkillType.Fireball:
        characterPerformSkillTypeFireball(character, level);
        break;
      case SkillType.Frostball:
        characterPerformSkillTypeFrostBall(character, level);
        break;
      case SkillType.Explode:
        characterPerformSkillTypeExplode(character, level);
        break;
      case SkillType.Heal:
        characterPerformSkillTypeHeal(character, level);
        break;
      case SkillType.Ice_Arrow:
        characterPerformSkillTypeIceArrow(character, level);
        break;
      case SkillType.Fire_Arrow:
        characterPerformSkillTypeFireArrow(character, level);
        break;
      // case SkillType.Blind:
      //   characterPerformSkillTypeBlind(character);
      //   break;
      default:
        return;
    }
  }

  double getCharacterSkillTypeRange({
    required Character character,
    required SkillType skillType,
  }){
      if (character is AmuletPlayer) {
        return character.getSkillTypeRange(skillType);
      }
      if (character is AmuletFiend) {
        return character.fiendType.weaponRange;
      }
      return 0;
  }

  double getCharacterAreaDamage(Character character) =>
      SkillType.getAreaDamage(
          getCharacterSkillTypeLevel(
            character,
            SkillType.Area_Damage,
          )
      );

  double getCharacterMissRatio(Character character){
     if (character.conditionIsBlind) {
       return AmuletSettings.Chance_Blind_Miss;
     }
     return 0;
  }

  @override
  void characterGoalAttackTarget(Character character) {

    if (character.deadOrBusy) {
      return;
    }

    // final target = character.target;

    if (character is! AmuletFiend) {
      super.characterGoalAttackTarget(character);
      return;
    }

    // final fiendType = character.fiendType;
    // final skillB = fiendType.skillTypeB;

    // if (
    //   target is Character &&
    //   skillB == SkillType.Blind &&
    //   !target.conditionIsBlind
    // ) {
    //   character.activeSkillType = SkillType.Blind;
    //   character.attack();
    //   return;
    // }

    character.activeSkillType = character.fiendType.skillType;
    super.characterGoalAttackTarget(character);
  }

  @override
  void applyHit({
    required Character srcCharacter,
    required Collider target,
    required double damage,
    required DamageType damageType,
    required double ailmentDuration,
    required double ailmentDamage,
    double? angle,
    double force = 0,
    bool friendlyFire = false,
  }) {

    final missRatio = getCharacterMissRatio(srcCharacter);
    if (missRatio > 0 && randomChance(missRatio)){
      dispatchGameEventPosition(GameEvent.Attack_Missed, target);
      return;
    }

    var damageMultiplier = 1.0;
    final chanceOfCritical = getCharacterChanceOfCriticalHit(srcCharacter);
    if (randomChance(chanceOfCritical)) {
      damageMultiplier = AmuletSettings.Ratio_Critical_Hit_Damage;
      // TODO Dispatch critical hit
    }
    super.applyHit(
        srcCharacter: srcCharacter,
        target: target,
        damage: damage * damageMultiplier,
        damageType: damageType,
        ailmentDuration: ailmentDuration,
        ailmentDamage: ailmentDamage,
        angle: angle,
        friendlyFire: friendlyFire,
    );
  }

  double getCharacterChanceOfCriticalHit(Character character){
     if (character is AmuletPlayer) {
       return character.chanceOfCriticalDamage;
     }
     if (character is AmuletFiend){
       return character.fiendType.chanceOfCriticalDamage;
     }
     return 0;
  }

  void characterPerformSkillTypeStrike(Character character) {

    applyHitMelee(
        character: character,
        damageType: DamageType.Melee,
        range: getCharacterSkillTypeRange(
            character: character,
            skillType: SkillType.Strike,
        ),
        damage: getCharacterWeaponDamage(character),
        areaDamage: getCharacterAreaDamage(character),
        ailmentDuration: 0,
        ailmentDamage: 0,
        maxHitRadian: 90 * degreesToRadians,
      );
  }

  double getCharacterAssignedSkillLevelI(Character character, SkillType skillType) {
    final level = getCharacterAssignedSkillLevel(character, skillType);
    return interpolate(0, 1.0, level / SkillType.Max_Level);
}

  int getCharacterAssignedSkillLevel(Character character, SkillType skillType){
     if (character is AmuletPlayer){
       return character.getSkillTypeLevelAssigned(skillType);
     }
     if (character is AmuletFiend){
       return character.fiendType.skillLevel;
     }
     throw Exception();
  }



  void characterPerformSkillTypeMightySwing(Character character, int level) {

    final weaponDamage = getCharacterWeaponDamage(character);
    final percentage = SkillType.getPercentageMightySwing(level);
    final bonusDamage = weaponDamage + percentage;

    applyHitMelee(
        character: character,
        damageType: DamageType.Melee,
        range: getCharacterWeaponRange(character),
        damage: weaponDamage + bonusDamage,
        areaDamage: getCharacterAreaDamage(character),
        ailmentDuration: 0,
        ailmentDamage: 0,
        maxHitRadian: pi,
      );
  }

  void characterPerformSkillTypeShootArrow(Character character) {
    dispatchGameEvent(
      GameEvent.Bow_Released,
      character.x,
      character.y,
      character.z,
    );
    spawnProjectileArrow(
      src: character,
      damage: getCharacterWeaponDamage(character),
      range: getCharacterWeaponRange(character),
      angle: character.angle,
    );
  }

  void characterPerformSkillTypeIceArrow(Character character, int level) {
    dispatchGameEventPosition(GameEvent.Bow_Released, character);

    final iceDamage = SkillType.getDamageIceArrow(level);
    final weaponDamage = getCharacterWeaponDamage(character);

    spawnProjectileIceArrow(
      src: character,
      damage: iceDamage + weaponDamage,
      range: getCharacterWeaponRange(character),
      ailmentDuration: SkillType.getAilmentDurationIceArrow(level),
      ailmentDamage: SkillType.getAilmentDamageIceArrow(level),
      angle: character.angle,
    );
  }

  void characterPerformSkillTypeFireArrow(Character character, int level) {
    dispatchGameEventPosition(GameEvent.Bow_Released, character);

    final fireDamage = SkillType.getDamageFireArrow(level);
    final weaponDamage = getCharacterWeaponDamage(character);

    spawnProjectileFireArrow(
      src: character,
      damage: fireDamage + weaponDamage,
      range: getCharacterSkillTypeRange(
          character: character,
          skillType: SkillType.Fire_Arrow,
      ),
      ailmentDuration: SkillType.getAilmentDurationFireArrow(level),
      ailmentDamage: SkillType.getAilmentDamageFireArrow(level),
      angle: character.angle,
    );
  }

  double getCharacterWeaponDamage(Character character){
     if (character is AmuletPlayer){
       return character.equippedWeaponDamage;
     }
     if (character is AmuletFiend) {
       return character.attackDamage;
     }
     throw Exception();
  }

  double getCharacterWeaponRange(Character character){
    if (character is AmuletPlayer){
      if (character.equippedWeaponMelee){
        return character.equippedWeaponRange?.melee ?? 0;
      }
      if (character.equippedWeaponRanged){
        return character.equippedWeaponRange?.ranged ?? 0;
      }
      return 0;
    }
    if (character is AmuletFiend) {
      return character.attackRange;
    }
    throw Exception();
  }

  void characterPerformSkillTypeSplitShot(Character character, int skillLevel) {

    final damage = getCharacterWeaponDamage(character);
    final range = getCharacterWeaponRange(character);
    final angle = character.angle;
    final totalArrows = SkillType.getSplitShotTotalArrows(skillLevel);
    final spread = getSplitShortSpread(totalArrows);

    dispatchGameEvent(
      GameEvent.Bow_Released,
      character.x,
      character.y,
      character.z,
    );

    for (var i = 0; i < totalArrows; i++) {
      spawnProjectileArrow(
        src: character,
        damage: damage,
        range: range,
        angle: angle + giveOrTake(spread),
      );
    }
  }

  void characterPerformSkillTypeBlind(Character character) {
    final target = character.target;
    if (target is! Character){
      return;
    }
    applyConditionBlind(target);
  }

  void applyConditionBlind(Character character) {
      character.conditionBlindDuration = blindDuration;
  }

  int get blindDuration => AmuletSettings.Duration_Condition_Blind * fps;

  int get fps => amulet.fps;

  double getSplitShortSpread(int amount){
    return piEighth;
  }

  void characterPerformSkillTypeFireball(Character character, int level) {
    spawnProjectile(
      src: character,
      damage: SkillType.getDamageFireball(level),
      range: getCharacterSkillTypeRange(
        character: character,
        skillType: SkillType.Fireball,
      ),
      projectileType: ProjectileType.Fireball,
      angle: character.angle,
      ailmentDuration: SkillType.getAilmentDurationFireball(level),
      ailmentDamage: SkillType.getAilmentDamageFireball(level),
    );
  }



  void characterPerformSkillTypeFrostBall(Character character, int level) =>
      spawnProjectile(
        src: character,
        damage: SkillType.getDamageFrostBall(level),
        range: getCharacterSkillTypeRange(
            character: character,
            skillType: SkillType.Frostball,
        ),
        projectileType: ProjectileType.FrostBall,
        angle: character.angle,
        ailmentDuration: SkillType.getAilmentDurationFrostBall(level),
        ailmentDamage: SkillType.getAilmentDamageFrostBall(level),
      );

  void characterPerformSkillTypeExplode(Character character, int level) {

    if (character is AmuletPlayer){
      createExplosion(
        x: character.castePositionX,
        y: character.castePositionY,
        z: character.castePositionZ,
        srcCharacter: character,
        radius: 100,
        damage: SkillType.getDamageExplode(level),
        ailmentDuration: 0,
        ailmentDamage: 0,
      );
      return;
    }

    throw Exception('fiend cannot perform ${SkillType.Explode}');
  }

  void characterPerformSkillTypeHeal(Character character, int skillLevel) {
    character.health += SkillType.getHealAmount(skillLevel);
    dispatchGameEventPosition(GameEvent.Character_Caste_Healed, character);
  }

  void characterPerformSkillTypeTeleport(Character character) {

    if (character is AmuletPlayer){
      dispatchGameEventPosition(GameEvent.Blink_Depart, character);
      character.x = character.castePositionX;
      character.y = character.castePositionY;
      character.z = character.castePositionZ;
      dispatchGameEventPosition(GameEvent.Blink_Arrive, character);
      return;
    }
    // throw Exception('fiend cannot perform ${SkillType.Teleport}');
  }

  @override
  void customOnCharacterKilled(Character target, src) {

    // if (target.respawnDurationTotal > 0){
    //   addJob(seconds: target.respawnDurationTotal, action: () {
    //     dispatchGameEventPosition(GameEvent.Character_Vanished, target);
    //     setCharacterStateSpawning(target);
    //     target.moveToStartPosition();
    //     dispatchGameEventPosition(GameEvent.Character_Vanished, target);
    //   });
    // }

    dispatchFiendCount();

    if (target is AmuletFiend) {
      if (randomChance(AmuletSettings.Chance_Of_Drop_Loot_Consumable)) {
           spawnConsumableAtPosition(target);
      }

      if (getFiendCountAlive() == 0){
        // TODO

        // final items = AmuletItem.find(
        //     itemQuality: ItemQuality.Unique,
        //     level: amuletScene.level,
        // );
        // if (items.isNotEmpty) {
        //   spawnAmuletItemObjectAtPosition(
        //     item: generateAmuletItemObject(randomItem(items)),
        //     position: target,
        //   );
        // }
        //
        // spawnAmuletItemObjectAtPosition(
        //   item: AmuletItemObject(amuletItem: AmuletItem.Consumable_Potion_Health, skillPoints: {}),
        //   position: target,
        // );
        //
        // spawnAmuletItemObjectAtPosition(
        //   item: AmuletItemObject(amuletItem: AmuletItem.Consumable_Potion_Magic, skillPoints: {}),
        //   position: target,
        // );
      }

      // if (randomChance(target.fiendType.chanceOfDropLegendary)) {
      //   spawnRandomLootAtFiend(target, itemQuality: ItemQuality.Legendary);
      //   return;
      // }

      // if (randomChance(target.fiendType.chanceOfDropRare)) {
      //   spawnRandomLootAtFiend(target, itemQuality: ItemQuality.Rare);
      //   return;
      // }

      final lootQuality = getLootItemQuality(target);

      if (lootQuality != null) {
        spawnRandomLootAtFiend(
          amuletFiend: target,
          itemQuality: lootQuality,
        );
      }
    }
  }

  bool shouldDropLoot(Character character) =>
      randomChance(AmuletSettings.Chance_Of_Drop_Loot);



  int getFiendCountAlive() {
    var totalAlive = 0;
    final characters = this.characters;
    for (final character in characters){
      if (character is! AmuletFiend) continue;
      if (character.alive) {
        totalAlive++;
      }
    }
    return totalAlive;
  }


  void dispatchFiendCount(){
     for (final player in players){
       player.writeFiendCount();
     }
  }

  void spawnRandomLootAtFiend({
    required AmuletFiend amuletFiend,
    required ItemQuality itemQuality,
  }) =>
    spawnRandomLootAtPosition(
      position: amuletFiend,
      itemQuality: itemQuality,
      level: amuletFiend.level,
    );

  void spawnRandomLootAtPosition({
    required Position position,
    required ItemQuality itemQuality,
    required int level,
  }) {

    final amuletItemObject = generateAmuletItemObject(
        amuletItem: randomItem(AmuletItem.values),
        level: level,
        itemQuality: itemQuality,
    );

    spawnAmuletItemObject(
        amuletItemObject: amuletItemObject,
        x: position.x,
        y: position.y,
        z: position.z,
      );
  }

  ItemQuality? getLootItemQuality(Collider collider){
     if (randomChance(AmuletSettings.Chance_Of_Drop_Loot_Rare)){
       return ItemQuality.Rare;
     }
     if (randomChance(AmuletSettings.Chance_Of_Drop_Loot_Unique)){
       return ItemQuality.Unique;
     }
     if (randomChance(AmuletSettings.Chance_Of_Drop_Loot_Common)){
       return ItemQuality.Common;
     }
     return null;
  }

  /// @deactivationTimer set to -1 to prevent amulet item from deactivating over time
  GameObject spawnAmuletItemObjectAtIndex({
    required int index,
    required AmuletItemObject item,
    int? deactivationTimer
  }) =>
      spawnAmuletItemObject(
        x: scene.getIndexX(index),
        y: scene.getIndexY(index),
        z: scene.getIndexZ(index),
          amuletItemObject: item,
        deactivationTimer: deactivationTimer
      );

  GameObject spawnAmuletItemObjectAtPosition({
    required AmuletItemObject item,
    required Position position,
    int? deactivationTimer
  }) =>
    spawnAmuletItemObject(
      amuletItemObject: item,
      x: position.x,
      y: position.y,
      z: position.z,
    );

  GameObject spawnAmuletItemObject({
    required AmuletItemObject amuletItemObject,
    required double x,
    required double y,
    required double z,
    int? deactivationTimer
  }) {
    final instance = GameObject(
      x: x,
      y: y,
      z: z,
      itemType: ItemType.Amulet_Item,
      subType: amuletItemObject.amuletItem.index,
      team: TeamType.Neutral,
      interactable: true,
      deactivationTimer: deactivationTimer ?? gameObjectDeactivationTimer,
      health: 0,
      data: mapAmuletItemObjectToJson(amuletItemObject),
    );

    add(instance);
    return instance;
  }

  @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    switch (nodeType){
      case NodeType.Grass_Long:
        if (randomChance(AmuletSettings.Chance_Of_Drop_Item_On_Grass_Cut)){
          spawnConsumableAtIndex(nodeIndex);
        }
        break;
    }
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(AmuletPlayer player, GameObject gameObject) {

    final amuletItem = gameObject.amuletItem;

    if (amuletItem == null) {
      return;
    }

    // if (amuletItem.isConsumable) {
    //   player.writePlayerEventItemTypeConsumed(amuletItem.subType);
    //   player.health += amuletItem.health ?? 0;
    //   player.magic += amuletItem.maxMagic ?? 0;
    //   remove(gameObject);
    // }
  }

  @override
  void handleInteraction(Character src, Position target) {
    super.handleInteraction(src, target);

    if (src is AmuletPlayer) {
      if (target is GameObject){
        onAmuletPlayerInteractWithGameObject(src, target);
      }
      if (target is AmuletNpc){
        src.interacting = true;
        target.interact?.call(src, target);
      }
    }
  }

  // @override
  // void customOnCharacterInteractWithGameObject(
  //     Character character,
  //     GameObject gameObject,
  // ) {
  //   if (character is AmuletPlayer && gameObject.isAmuletItem) {
  //     onAmuletPlayerInteractWithAmuletGameObject(character, gameObject);
  //   }
  //   // if (
  //   //   character is AmuletPlayer &&
  //   //   gameObject.type == ItemType.Object &&
  //   //   gameObject.subType == GameObjectType.Wooden_Chest
  //   // ){
  //   //   character.toggleInventoryOpen();
  //   //   character.clearTarget();
  //   // }
  // }

  void onAmuletPlayerInteractWithGameObject(
      AmuletPlayer player,
      GameObject gameObject,
  ){
     final amuletItem = gameObject.amuletItem;
     if (amuletItem == null){
       return;
     }

     final amuletItemObject = mapGameObjectToAmuletItemObject(gameObject);

     if (amuletItemObject == null){ // fix
       return;
     }

     player.setCollectableGameObject(gameObject);
     // player.collectableAmuletItemObject = gameObject;
  }

  void onAmuletPlayerPickupGameObject(
      AmuletPlayer player,
      GameObject gameObject,
  ){
     final amuletItem = gameObject.amuletItem;
     if (amuletItem == null){
       return;
     }

     final amuletItemObject = mapGameObjectToAmuletItemObject(gameObject);

     if (amuletItemObject == null){ // fix
       return;
     }

     if (player.acquireAmuletItemObject(amuletItemObject)){
       remove(gameObject);
     }

     player.setCollectableGameObject(null);
  }

  List<int> getMarkTypes(int markType) =>
      scene.marks.where((markValue) => MarkType.getType(markValue) == markType).toList(growable: false);

  void spawnRandomEnemy(Difficulty difficulty) {
    final marks = scene.marks;
    if (marks.isEmpty){
      return;
    }
    final fiendMarks = getMarkTypes(MarkType.Fiend);
    if (marks.isEmpty) {
      return;
    }

    final markValue = randomItem(fiendMarks.toList());
    final index = MarkType.getIndex(markValue);
    final fiendType = MarkType.getSubType(markValue);
    spawnFiendTypeAtIndex(
      fiendType: FiendType.values[fiendType],
      index: index,
      level: level,
      difficulty: difficulty,
    );
  }

  void endPlayerInteraction(AmuletPlayer player) =>
      player.endInteraction();

  void onAmuletItemUsed(AmuletPlayer amuletPlayer, AmuletItem amuletItem) {}

  void onAmuletItemAcquired(AmuletPlayer amuletPlayer, AmuletItem amuletItem) {}

  // void onPlayerInventoryMoved(
  //     AmuletPlayer player,
  //     AmuletItemSlot srcAmuletItemSlot,
  //     AmuletItemSlot targetAmuletItemSlot,
  // ) {}

  void onPlayerInventoryOpenChanged(AmuletPlayer player, bool value) { }

  @override
  void customDownloadScene(IsometricPlayer player) {
    super.customDownloadScene(player);
    player.writeByte(NetworkResponse.Amulet);
    player.writeByte(NetworkResponseAmulet.Amulet_Scene);
    player.writeByte(amuletScene.index);
  }

  @override
  void onAddedGameObject(GameObject gameObject) {
    if (gameObject.itemType == ItemType.Object){
      final subType = gameObject.subType;
      if (const[
        GameObjectType.Barrel,
        GameObjectType.Wooden_Chest,
        GameObjectType.Crate_Wooden,
      ].contains(subType)){
        gameObject.physical = true;
        gameObject.healthMax = 1;
        gameObject.health = 1;
        gameObject.interactable = false;
        gameObject.dirty = true;
        gameObject.deactivationTimer = -1;
        gameObject.hitable = true;
        gameObject.collidable = true;
      }

      gameObject.fixed = !const [GameObjectType.Barrel].contains(subType);
    }

    if (gameObject.isAmuletItem) {
      gameObject.physical = true;
      gameObject.fixed = false;
      gameObject.healthMax = 0;
      gameObject.health = 0;
      gameObject.interactable = true;
      gameObject.dirty = true;
      gameObject.deactivationTimer = gameObjectDeactivationTimer;
      gameObject.hitable = false;
      gameObject.collidable = true;
    }

  }

  @override
  void onAddedPlayer(AmuletPlayer player) {
    super.onAddedPlayer(player);
    player.writeWorldIndex();
  }

  @override
  void customOnPlayerRevived(AmuletPlayer player) {
    amulet.revivePlayer(player);
  }

  @override
  void onPlayerUpdateRequestReceived({
    required AmuletPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool keyDownShift
  }) {

    if (
      player.deadOrBusy ||
      player.debugging ||
      !player.controlsEnabled
    ) return;

    final mouseLeftClicked = mouseLeftDown && player.mouseLeftDownDuration == 0;
    final mouseLeftHeld = mouseLeftDown && player.mouseLeftDownDuration > 0;
    final mouseRightClicked = mouseRightDown && player.mouseRightDownDuration == 0;

    if (mouseRightDown){
      player.mouseRightDownDuration++;
    } else {
      player.mouseRightDownDuration = 0;
    }

    if (mouseLeftDown) {
      player.mouseLeftDownDuration++;
    } else {
      player.mouseLeftDownDuration = 0;
    }

    if (mouseRightClicked) {
      player.performSkillRight();
      return;
    }

    if (keyDownShift){
      if (mouseLeftDown){
        player.performSkillLeft();
      } else {
        player.setCharacterStateIdle();
      }
      return;
    }

    if (mouseLeftHeld && !player.targetSet){
      player.setDestinationToMouse();
      return;
    }

    if (mouseLeftClicked) {
      final aimTarget = player.aimTarget;

      if (player.interacting){
        player.endInteraction();
      }

      if (aimTarget != null){
        player.target = aimTarget;
        return;
      }

      final aimNodeIndex = player.aimNodeIndex;
      if (aimNodeIndex != null) {
        player.targetNodeIndex = aimNodeIndex;
        return;
      }

      player.setDestinationToMouse();
    }

  }

  @override
  void onCharacterTargetChanged(Character character, Position? value) {
    if (character is! AmuletFiend || value == null) return;
    dispatchGameEventPosition(GameEvent.AI_Target_Acquired, value);
    dispatchByte(character.characterType);
  }

  @override
  void customOnGameObjectDestroyed(GameObject gameObject) {
    if (gameObject.isObject && const [
      GameObjectType.Barrel,
      GameObjectType.Crate_Wooden,
    ].contains(gameObject.subType)){
      spawnConsumableAtPosition(gameObject);
    }

    if (
      gameObject.isObject &&
      gameObject.subType == GameObjectType.Wooden_Chest
    ) {
      spawnRandomLootAtPosition(
          position: gameObject,
          itemQuality: getLootItemQuality(gameObject) ?? ItemQuality.Common,
          level: level,
      );
    }
  }



  @override
  void performCharacterStart(Character character) {
    super.performCharacterStart(character);

    if (character is AmuletPlayer) {
      character.updateCastePosition();
      dispatchAmuletEvent(character, AmuletEvent.Skill_Started);
    }
  }

  void dispatchAmuletEvent(Position position, int amuletEvent){
    for (final player in players) {
      player.writeAmuletEvent(
        position: position,
        amuletEvent: amuletEvent,
      );
    }
  }

  double getCharacterHealthSteal(Character character){
    if (character is AmuletPlayer) {
      return character.healthSteal;
    }
    if (character is AmuletFiend) {
      return character.fiendType.healthSteal;
    }
    return 0;
  }

  double getCharacterMagicSteal(Character character){
    if (character is AmuletPlayer) {
      return character.magicSteal;
    }
    return 0;
  }

  @override
  void onDamageApplied({
    required Character src,
    required Character target,
    required double amount,
  }) {

    final healthSteal = getCharacterHealthSteal(src);
    if (healthSteal > 0) {
      src.health += (amount * healthSteal).toInt();
      dispatchGameEventPosition(GameEvent.Health_Regained, src);
    }

    final magicSteal = getCharacterMagicSteal(src);
    if (magicSteal > 0) {
      src.magic += (amount * healthSteal).toInt();
      dispatchGameEventPosition(GameEvent.Magic_Regained, src);
    }
  }

  void useShrine(AmuletPlayer player, int nodeIndex) {
    player.regainFullMagic();
    player.regainFullHealth();
    setNode(nodeIndex: nodeIndex, variation: NodeType.Variation_Shrine_Inactive);
    final sceneShrinesUsed = player.sceneShrinesUsed;
    if (!sceneShrinesUsed.containsKey(amuletScene)){
      sceneShrinesUsed[amuletScene] = [];
    }
    final shrinesUsed = sceneShrinesUsed[amuletScene];
    if (shrinesUsed == null){
      throw Exception('shrinesUsed == null');
    }
    shrinesUsed.add(nodeIndex);
    dispatchGameEventIndex(GameEvent.Shrine_Used, nodeIndex);
  }

  GameObject spawnGameObjectType({
    required double x,
    required double y,
    required double z,
    required int gameObjectType,
  }) {
    final instance = GameObject(
      x: x,
      y: y,
      z: z,
      itemType: ItemType.Object,
      subType: gameObjectType,
      team: TeamType.Neutral,
      health: destroyableGameObjectTypes.contains(gameObjectType) ? 1 : 0,
      interactable: false,
      deactivationTimer: -1,
    );
    add(instance);
    return instance;
  }

  static const destroyableGameObjectTypes = [
    GameObjectType.Crate_Wooden,
    GameObjectType.Wooden_Chest,
    GameObjectType.Barrel,
  ];

  @override
  void handleCharacterInteractWithTargetNode(Character character) {

    final targetNodeIndex = character.targetNodeIndex;

    if (targetNodeIndex == null || character is! AmuletPlayer){
      return;
    }

    final nodeType = scene.nodeTypes[targetNodeIndex];

    switch (nodeType){
      case NodeType.Shrine:
        useShrine(character, targetNodeIndex);
        break;
      case NodeType.Portal:
        usePortal(character, targetNodeIndex);
        break;
    }
  }

  void usePortal(AmuletPlayer character, int nodeIndex) {

    final amuletScene = scene.tryGetPortalTarget(nodeIndex);

    if (amuletScene == null){
       character.writeGameError(GameError.Invalid_Portal_Scene);
       return;
    }

    final targetGame = amulet.findGame(amuletScene);
    final targetNodeIndex = targetGame.scene.findPortalWithTarget(this.amuletScene);

    if (targetNodeIndex == null) {
      character.writeGameError(GameError.No_Connecting_Portal);
      return;
    }

    amulet.playerChangeGame(
        player: character,
        target: targetGame,
        index: targetNodeIndex,
    );
  }

  int getCharacterSkillTypeLevel(Character character, SkillType skillType){
    if (character is AmuletPlayer){
      return character.getSkillTypeLevelAssigned(skillType);
    }
    if (character is AmuletFiend){
      return character.fiendType.skillTypes[skillType] ?? 0;
    }
    return 0;
  }

  @override
  double getCharacterDamageTypeResistance(Character character, DamageType damageType) {

    if (character is AmuletFiend){
      return character.fiendType.getDamageTypeResistance(damageType);
    }

    switch (damageType){
      case DamageType.Melee:
        final level = getCharacterSkillTypeLevel(character, SkillType.Shield);
        return SkillType.getPercentageDamageResistanceMelee(level);
      case DamageType.Pierce:
        final level = getCharacterSkillTypeLevel(character, SkillType.Shield);
        return SkillType.getPercentageDamageResistanceMelee(level);
      case DamageType.Fire:
        return 0;
      case DamageType.Ice:
        return 0;
    }
  }

  int calculatePoints({
    required int level,
    required ItemQuality quality,
  }) =>
      (level * 5 * quality.bonus).toInt();

  AmuletItemObject generateAmuletItemObject({
    required AmuletItem amuletItem,
    required int level,
    required ItemQuality itemQuality,
  }){
    final skillPoints = <SkillType, int> {};
    final points = calculatePoints(
      level: level,
      quality: itemQuality,
    );
    final skillTypes = amuletItem.skillTypes;

    if (skillTypes.isNotEmpty) {
      for (var i = 0; i < points; i++) {
        final skillType = randomItem(skillTypes);
        final currentPoints = skillPoints[skillType] ?? 0;
        skillPoints[skillType] = currentPoints + 1;
      }
    }

    for (final entry in amuletItem.skillSet.entries){
      final currentPoints = skillPoints[entry.key] ?? 0;
      skillPoints[entry.key] = entry.value + currentPoints;
    }

    final damageMin = amuletItem.damageMin;
    final damageMax = amuletItem.damageMax;
    double? damage;

    if (damageMin != null && damageMax != null){
      damage = randomBetween(damageMin, damageMax);
    }

    return AmuletItemObject(
      amuletItem: amuletItem,
      skillPoints: skillPoints,
      damage: damage,
      level: level,
      itemQuality: itemQuality,
    );
  }

  void characterPerformSkillTypeWindCut(Character character) {
    final weaponDamage = getCharacterWeaponDamage(character);
    final level = getCharacterSkillTypeLevel(character, SkillType.Wind_Cut);
    final bonusRange = SkillType.getRangeWindCut(level);

    applyHitMelee(
      character: character,
      damageType: DamageType.Melee,
      range: getCharacterWeaponRange(character) + bonusRange,
      damage: weaponDamage,
      areaDamage: getCharacterAreaDamage(character),
      ailmentDuration: 0,
      ailmentDamage: 0,
      maxHitRadian: pi,
    );
  }

  void spawnConsumableAtPosition(Position position) {
    spawnConsumableAtXYZ(position.x, position.y, position.z);
  }

  void spawnConsumableAtIndex(int index) {
     spawnConsumableAtXYZ(
         scene.getIndexX(index),
         scene.getIndexY(index),
         scene.getIndexZ(index),
     );
  }

  void spawnConsumableAtXYZ(double x, double y, double z) {

    final amuletItemObject = generateAmuletItemObject(
      amuletItem: randomItem(AmuletItem.Consumables),
      level: 0,
      itemQuality: ItemQuality.Common,
    );

    spawnAmuletItemObject(
      amuletItemObject: amuletItemObject,
      x: x,
      y: y,
      z: z,
    );
  }

  // void updatePlayerCollectables() {
  //   for (final player in players) {
  //      GameObject? nearest;
  //      var nearestDistance = 60.0;
  //      for (final gameObject in gameObjects) {
  //         if (!gameObject.isAmuletItem) continue;
  //         final distance = player.getDistance(gameObject);
  //         if (distance >= nearestDistance) continue;
  //         nearest = gameObject;
  //         nearestDistance = distance;
  //      }
  //      player.setCollectableAmuletItemObject(nearest);
  //   }
  // }


}


