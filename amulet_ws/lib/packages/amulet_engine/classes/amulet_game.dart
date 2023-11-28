import 'dart:math';
import 'dart:typed_data';

import '../packages/isometric_engine/isometric_engine.dart';
import '../packages/isometric_engine/packages/lemon_math/src/functions/random_chance.dart';
import 'amulet.dart';
import 'amulet_gameobject.dart';
import 'amulet_item_slot.dart';
import 'amulet_npc.dart';
import 'amulet_player.dart';


class AmuletGame extends IsometricGame<AmuletPlayer> {

  final Amulet amulet;

  final String name;
  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final lootDeactivationTimer = 5000;
  final AmuletScene amuletScene;
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
  }) {
    spawnFiendsAtSpawnNodes();
    refreshFlatNodes();
  }

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
    final nodeTypes = scene.types;
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
  }

  void updateCooldownTimer() {
    if (cooldownTimer-- > 0) {
      return;
    }

    cooldownTimer = Frames_Per_Second;
    for (final player in players) {
      player.incrementWeaponCooldowns();
    }
  }

  void spawnFiendsAtSpawnNodes() {
    final marks = scene.marks;
    final length = marks.length;
    for (var i = 0; i < length; i++) {
      final markValue = marks[i];
      final markType = MarkType.getType(markValue);
      if (markType != MarkType.Fiend){
        continue;
      }
      final markSubType = MarkType.getSubType(markValue);
      final fiendType = FiendType.values[markSubType];
      final quantity = fiendType.quantity;

      for (var i = 0; i < quantity; i++){
        spawnFiendTypeAtIndex(
          fiendType: fiendType,
          index: MarkType.getIndex(markValue),
        );
      }


    }
  }

  Character spawnFiendTypeAtIndex({
    required FiendType fiendType,
    required int index,
  }) =>
    assignFiendTypeToCharacter(
      fiendType,
      spawnCharacterAtIndex(index),
    );

  static Character assignFiendTypeToCharacter(
      FiendType fiendType,
      Character character,
  ) =>
    character
      ..maxHealth = fiendType.health
      ..health = fiendType.health
      ..name = fiendType.name
      ..weaponDamage = fiendType.damage
      ..attackDuration = fiendType.attackDuration
      ..runSpeed = fiendType.runSpeed
      ..experience = fiendType.experience
      ..chanceOfSetTarget = fiendType.chanceOfSetTarget
      ..weaponType = fiendType.weaponType
      ..weaponRange = fiendType.weaponRange
      ..characterType = fiendType.characterType;

  Character spawnCharacterAtIndex(int index) =>
    spawnCharacterAtXYZ(
      x: scene.getIndexX(index),
      y: scene.getIndexY(index),
      z: scene.getIndexZ(index),
    );

  Character spawnCharacterAtXYZ({
    required double x,
    required double y,
    required double z,
  }) {
    final character = Character(
      team: AmuletTeam.Monsters,
      x: x,
      y: y,
      z: z,
      health: 7,
      weaponDamage: 1,
      characterType: CharacterType.Fallen,
      weaponType: WeaponType.Unarmed,
      weaponCooldown: 20,
      weaponRange: 20,
      actionFrame: 15,
      attackDuration: 25,
      doesWander: true,
      name: 'Fallen',
      runSpeed: 0.75,
    )
      ..weaponHitForce = 2;

    characters.add(character);
    return character;
  }

  @override
  void customOnPlayerDead(AmuletPlayer player) {
    addJob(seconds: 5, action: () {
      // setCharacterStateSpawning(player);
      revive(player);
    });
  }

  @override
  void performCharacterAction(Character character) {
    if (character is! AmuletPlayer) {
      super.performCharacterAction(character);
      return;
    }

    character.clearActionFrame();
    final activeItemSlot = character.activeItemSlot;

    if (activeItemSlot == null) {
      return;
    }

    character.clearActivatedPowerIndex();

    final amuletItem = activeItemSlot.amuletItem;

    if (amuletItem == null){
      throw Exception('activeSlotItem == null');
    }

    final level = amuletItem.getLevel(
        fire: character.elementFire,
        water: character.elementWater,
        electricity: character.elementElectricity,
    );

    if (level == -1){
      character.writeGameError(GameError.Insufficient_Elements);
      return;
    }

    final stats = amuletItem.getStatsForLevel(level);

    if (stats == null){
      throw Exception('stats == null');
    }

    switch (amuletItem) {
      case AmuletItem.Spell_Thunderbolt:
        performAbilityLightning(character);
        break;
      case AmuletItem.Spell_Blink:
        performAbilityBlink(character);
        break;
      case AmuletItem.Blink_Dagger:
        performAbilityBlink(character);
        break;
      case AmuletItem.Weapon_Rusty_Old_Sword:
        performAbilityMelee(character);
        break;
      case AmuletItem.Weapon_Old_Bow:
        performAbilityArrow(
            character: character,
            damage: stats.damage,
            range: stats.range,
        );
        break;
      case AmuletItem.Weapon_Holy_Bow:
        performAbilityArrow(
          character: character,
          damage: stats.damage,
          range: stats.range,
        );
        break;
      case AmuletItem.Weapon_Staff_Of_Frozen_Lake:
        performAbilityFrostBall(character, damage: 1, range: 50);
        break;
      case AmuletItem.Spell_Heal:
        useAmuletItemSpellHeal(character);
        break;
      case AmuletItem.Spell_Split_Arrow:
        final totalArrows = stats.quantity;
        final radian = pi * 0.25;
        final radianPerArrow = radian / totalArrows;
        final initialAngle = character.angle - (radian * 0.5);
        var angle = initialAngle;
        for (var i = 0; i < totalArrows; i++){
          spawnProjectileArrow(
              src: character,
              damage: character.equippedWeaponDamage ?? (throw Exception()),
              range: character.equippedWeaponRange ?? (throw Exception()),
              angle: angle,
          );
          angle += radianPerArrow;
        }

        break;
      default:
        throw Exception('amulet.PerformCharacterAction($amuletItem)');
    }
  }

  void performAbilityFrostBall(AmuletPlayer character, {required int damage, required double range}) {
     spawnProjectile(
      src: character,
      damage: damage,
      range: range,
      projectileType: ProjectileType.FrostBall,
      angle: character.angle,
    );
  }

  void performAbilityArrow({
    required Character character,
    required int damage,
    required double range,
  }) {
     dispatchGameEvent(
      GameEventType.Bow_Released,
      character.x,
      character.y,
      character.z,
    );
    spawnProjectileArrow(
      src: character,
      damage: damage,
      range: range,
      angle: character.angle,
    );
  }

  void performAbilityBlink(AmuletPlayer player){
    dispatchGameEventPosition(GameEventType.Blink_Depart, player);
    player.x = player.activePowerX;
    player.y = player.activePowerY;
    player.z = player.activePowerZ;
    dispatchGameEventPosition(GameEventType.Blink_Arrive, player);
  }

  void performAbilityLightning(Character character){
    var boltsRemaining = 3;
    final characters = this.characters;
    for (final otherCharacter in characters){
      if (!character.active || !character.isEnemy(otherCharacter)) {
        continue;
      }
      if (!character.withinRadiusPosition(otherCharacter, 300)){
        continue;
      }
      dispatchGameEventPosition(GameEventType.Lightning_Bolt, otherCharacter);
      applyHit(
        srcCharacter: character,
        target: otherCharacter,
        damage: 3,
      );
      boltsRemaining--;
      if (boltsRemaining <= 0) {
        return;
      }
    }
  }

  AmuletItemQuality getRandomAmuletItemQuality({
      double chanceOfMythical = 0.005,
      double chanceOfRare = 0.015,
      double chanceOfMagic = 0.05,
    }){

    final value = random.nextDouble();

    if (value <= chanceOfMythical) {
      return AmuletItemQuality.Mythical;
    }

    if (value <= chanceOfRare) {
      return AmuletItemQuality.Rare;
    }

    if (value <= chanceOfMagic) {
      return AmuletItemQuality.Unique;
    }

    return AmuletItemQuality.Common;
  }


  @override
  void customOnCharacterKilled(Character target, src) {
    if (target.spawnLootOnDeath) {
      if (randomChance(target.chanceOfDropConsumable)) {
        spawnAmuletItemAtPosition(
          item: randomItem(AmuletItem.typeConsumables),
          position: target,
          deactivationTimer: lootDeactivationTimer,
        );
      }
      else
      if (randomChance(target.chanceOfDropLoot)) {
        final amuletItemQuality = getRandomAmuletItemQuality();
        spawnRandomLootAtPosition(target, amuletItemQuality);
      }
    }

    if (target.respawnDurationTotal > 0){
      addJob(seconds: target.respawnDurationTotal, action: () {
        setCharacterStateSpawning(target);
      });
    }

    if (src is AmuletPlayer) {
      playerGainExperience(src, target.experience);
    }
  }

  void playerGainExperience(AmuletPlayer player, int experience){
    player.experience += experience;
    while (player.experience > player.experienceRequired) {
      player.gainLevel();
      player.experience -= player.experienceRequired;
    }
  }

  void spawnRandomLootAtPosition(
      Position position,
      AmuletItemQuality quality,
  ) =>
      spawnRandomLoot(
        x: position.x,
        y: position.y,
        z: position.z,
        quality: quality,
      );

  void spawnRandomLoot({
    required double x,
    required double y,
    required double z,
    required AmuletItemQuality quality,
  }) => spawnAmuletItem(
      x: x,
      y: y,
      z: z,
      item: randomItem(AmuletItem.findByQuality(quality)),
  );

  /// @deactivationTimer set to -1 to prevent amulet item from deactivating over time
  AmuletGameObject spawnAmuletItemAtIndex({
    required int index,
    required AmuletItem item,
    int? deactivationTimer
  }) =>
      spawnAmuletItem(
        x: scene.getIndexX(index),
        y: scene.getIndexY(index),
        z: scene.getIndexZ(index),
        item: item,
        deactivationTimer: deactivationTimer
      );

  AmuletGameObject spawnAmuletItemAtPosition({
    required AmuletItem item,
    required Position position,
    int? deactivationTimer
  }) =>
    spawnAmuletItem(
      item: item,
      x: position.x,
      y: position.y,
      z: position.z,
    );

  AmuletGameObject spawnAmuletItem({
    required AmuletItem item,
    required double x,
    required double y,
    required double z,
    int? deactivationTimer
  }) {
    final amuletGameObject = AmuletGameObject(
      x: x,
      y: y,
      z: z,
      item: item,
      id: generateId(),
      frameSpawned: frame,
      deactivationTimer: deactivationTimer ?? gameObjectDeactivationTimer,
    )
      ..velocityZ = 10
      ..setVelocity(randomAngle(), 1.0);

    add(amuletGameObject);
    return amuletGameObject;
  }

  @override
  void onCharacterCollectedGameObject(
    Character character,
    GameObject gameObject,
  ) {

    if (
      character is! AmuletPlayer ||
      gameObject is! AmuletGameObject
    ) return;


    if (character.acquireAmuletItem(gameObject.item)) {
      super.onCharacterCollectedGameObject(character, gameObject);
    }
  }

  @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    switch (nodeType){
      case NodeType.Grass_Long:
        if (randomChance(chanceOfDropItemOnGrassCut)){
          spawnRandomConsumableAtIndex(nodeIndex);
        }
        break;
    }
  }

  void spawnRandomConsumableAtIndex(int nodeIndex) {
    spawnAmuletItemAtIndex(
        index: nodeIndex,
        item: randomItem(AmuletItem.typeConsumables),
    );
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(AmuletPlayer player, GameObject gameObject) {
    if (gameObject is! AmuletGameObject || !gameObject.item.consumable) {
      return;
    }

    onPlayerPickupConsumable(player, gameObject.item);
    deactivate(gameObject);
  }

  void onPlayerPickupConsumable(AmuletPlayer player, AmuletItem amuletItem){
    player.writePlayerEventItemTypeConsumed(amuletItem.subType);
    switch (amuletItem) {
      case AmuletItem.Potion_Health:
        player.health += player.maxHealth ~/ 4;
        break;
      case AmuletItem.Potion_Magic:
        for (final weapon in player.weapons){
          if (weapon.charges >= weapon.max) continue;
          weapon.charges++;
        }
        break;
      case AmuletItem.Potion_Experience:
        player.experience += (player.experienceRequired * 0.1).toInt();
        break;
      default:
        break;
    }
  }

  @override
  void customOnInteraction(Character character, Character target) {
    super.customOnInteraction(character, target);

    if (character is AmuletPlayer && target is AmuletNpc){
       character.interacting = true;
       target.interact?.call(character, target);
    }
  }

  List<int> getMarkTypes(int markType) =>
      scene.marks.where((markValue) => MarkType.getType(markValue) == markType).toList(growable: false);

  void spawnRandomEnemy() {
    final marks = scene.marks;
    if (marks.isEmpty){
      return;
    }
    final spawnFallens = getMarkTypes(MarkType.Fiend);
    if (spawnFallens.isEmpty) {
      return;
    }

    final markValue = randomItem(spawnFallens.toList());
    final index = MarkType.getIndex(markValue);
    spawnCharacterAtIndex(index);
  }

  // @override
  // void characterAttack(Character character) {
  //   if (character is AmuletPlayer){
  //     final equippedWeaponIndex = character.equippedWeaponIndex;
  //
  //     if (equippedWeaponIndex == -1){
  //       return;
  //     }
  //
  //     final weapons = character.weapons;
  //     final equippedWeapon = weapons[equippedWeaponIndex];
  //
  //     if (equippedWeapon.chargesEmpty) {
  //       character.writeGameError(GameError.Insufficient_Weapon_Charges);
  //       return;
  //     }
  //
  //     character.reduceAmuletItemSlotCharges(equippedWeapon);
  //   }
  //   character.attack();
  // }

  void endPlayerInteraction(AmuletPlayer player) =>
      player.endInteraction();

  void useAmuletItemSpellHeal(AmuletPlayer character) {

    final stats = character.getAmuletItemLevel(AmuletItem.Spell_Heal);
    if (stats == null) {
      character.writeGameError(GameError.Insufficient_Elements);
      return;
    }

    character.health += stats.health;

    dispatchGameEventPosition(GameEventType.Spell_Used, character);
    dispatchByte(SpellType.Heal);
  }

  void onAmuletItemUsed(AmuletPlayer amuletPlayer, AmuletItem amuletItem) {}

  void onAmuletItemAcquired(AmuletPlayer amuletPlayer, AmuletItem amuletItem) {}

  void onPlayerLevelGained(AmuletPlayer player) {

    final players = this.players;

    for (final otherPlayer in players){
      if (!player.onSameTeam(otherPlayer)) {
        continue;
      }
      otherPlayer.spawnConfettiAtPosition(player);
    }
  }

  void onPlayerInventoryMoved(
      AmuletPlayer player,
      AmuletItemSlot srcAmuletItemSlot,
      AmuletItemSlot targetAmuletItemSlot,
  ) {}

  void onPlayerInventoryOpenChanged(AmuletPlayer player, bool value) { }

  @override
  void customDownloadScene(IsometricPlayer player) {
    super.customDownloadScene(player);
    player.writeByte(NetworkResponse.Amulet);
    player.writeByte(NetworkResponseAmulet.Amulet_Scene);
    player.writeByte(amuletScene.index);
  }

  @override
  void onGameObjectSpawned(GameObject gameObject) {
    // if (gameObject.type != ItemType.Object) {
    //   dispatchGameEventPosition(GameEventType.GameObject_Spawned, gameObject);
    //   dispatchByte(gameObject.type);
    //   dispatchByte(gameObject.subType);
    // }
  }

  @override
  void onGameObjectedAdded(GameObject gameObject) {
    if (gameObject is AmuletGameObject) {
      dispatchGameEventPosition(GameEventType.Amulet_GameObject_Spawned, gameObject);
      dispatchByte(gameObject.type);
      dispatchByte(gameObject.subType);
    }
  }

  @override
  void onPlayerJoined(AmuletPlayer player) {
    super.onPlayerJoined(player);
    player.writeWorldIndex();
  }

  @override
  void revive(AmuletPlayer player) {
    super.revive(player);
    player.x = 1000;
    player.y = 1000;
    player.z = 300.0;
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
        !player.active ||
        player.debugging ||
        !player.controlsEnabled
    ) return;


    final mouseLeftClicked = mouseLeftDown && player.mouseLeftDownDuration == 0;
    final mouseRightClicked = mouseRightDown && player.mouseRightDownDuration == 0;

    if (mouseRightDown){
      player.mouseRightDownDuration++;
    } else {
      player.mouseRightDownDuration = 0;
    }

    if (mouseRightClicked){
      if (player.activatedPowerIndex == -1){
        player.performForceAttack();
        return;
      } else {
        player.deselectActivatedPower();
      }

      return;
    }

    if (keyDownShift){
      player.setCharacterStateIdle();
    }

    if (mouseLeftDown) {
      player.mouseLeftDownDuration++;
    } else {
      player.mouseLeftDownDuration = 0;
      player.mouseLeftDownIgnore = false;
    }

    if (mouseLeftClicked && player.activatedPowerIndex != -1) {
      player.useActivatedPower();
      player.mouseLeftDownIgnore = true;
      return;
    }

    if (mouseLeftDown && !player.mouseLeftDownIgnore) {
      final aimTarget = player.aimTarget;

      if (aimTarget == null || (player.isEnemy(aimTarget) && !player.controlsCanTargetEnemies)){
        if (keyDownShift){
          player.performForceAttack();
          return;
        } else {
          player.setDestinationToMouse();
          player.runToDestinationEnabled = true;
          player.pathFindingEnabled = false;
          player.target = null;
        }
      } else if (mouseLeftClicked) {
        player.target = aimTarget;
        player.runToDestinationEnabled = true;
        player.pathFindingEnabled = false;
        player.mouseLeftDownIgnore = true;
      }
      return;
    }
  }

}
