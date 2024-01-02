import 'dart:math';
import 'dart:typed_data';

import 'package:amulet_engine/mixins/equipped_weapon.dart';

import '../mixins/elemental.dart';
import '../packages/isometric_engine/isometric_engine.dart';
import 'amulet.dart';
import 'amulet_fiend.dart';
import 'amulet_gameobject.dart';
import 'amulet_item_slot.dart';
import 'amulet_npc.dart';
import 'amulet_player.dart';


class AmuletGame extends IsometricGame<AmuletPlayer> {

  final Amulet amulet;
  final String name;
  final AmuletScene amuletScene;

  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final lootDeactivationTimer = 5000;

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

  void spawnMarkPortals() {
    final marks = scene.marks;
    for (final mark in marks) {
       if (MarkType.getType(mark) != MarkType.Portal){
         continue;
       }
       final index = MarkType.getIndex(mark);
       final subType = MarkType.getSubType(mark);
       final amuletScene = AmuletScene.values[subType];


       var targetIndex = -1;
       final targetGame = amulet.getAmuletSceneGame(amuletScene);
       final targetGameMarks = targetGame.scene.marks;
       for (final targetMark in targetGameMarks){
          if (MarkType.getType(targetMark) != MarkType.Portal) continue;
          final targetMarkSubType = MarkType.getSubType(targetMark);
          final targetScene = AmuletScene.values[targetMarkSubType];
          if (targetScene != this.amuletScene) continue;
          targetIndex = MarkType.getIndex(targetMark);
       }

       if (targetIndex == -1){
         print('INVALID_PORTALS: ${amuletScene.name} does not a have a portal to ${this.amuletScene.name}');
       } else {
         final portal = spawnGameObjectAtIndex(
           index: index,
           type: ItemType.Object,
           subType: GameObjectType.Interactable,
           team: TeamType.Neutral,
         );
         portal.customName = amuletScene.name;
         portal.interactable = true;
         portal.fixed = true;
         portal.gravity = false;
         portal.hitable = false;
         portal.collectable = false;
         portal.collidable = false;
         portal.persistable = false;
         portal.destroyable = false;
         portal.onInteract = (dynamic src){
           if (src is! AmuletPlayer){
             return;
           }
           amulet.playerChangeGame(
             player: src,
             target: targetGame,
           );
           src.writePlayerEvent(PlayerEvent.Portal_Used);
           final targetScene = targetGame.scene;
           final targetShapes = targetScene.shapes;
           if (targetShapes[targetIndex + targetScene.columns] == NodeOrientation.None){
             targetGame.movePositionToIndex(src, targetIndex + targetScene.columns);
           } else if (targetShapes[targetIndex + 1] == NodeOrientation.None) {
             targetGame.movePositionToIndex(src, targetIndex + 1);
           } else {
             print('INVALID_PORTALS: ${amuletScene.name} does not a have a valid port index destination');
           }

           src.writePlayerMoved();
         };
       }
    }
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
    final characters = this.characters;
    for (final character in characters) {
      if (character is EquippedWeapon) {
        (character as EquippedWeapon).updateItemSlots();
      }
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

      for (var j = 0; j < quantity; j++){
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
      spawnAmuletFiendAtXYZ(
        x: scene.getIndexX(index),
        y: scene.getIndexY(index),
        z: scene.getIndexZ(index),
        fiendType: fiendType,
      );

  AmuletFiend spawnAmuletFiendAtXYZ({
    required double x,
    required double y,
    required double z,
    required FiendType fiendType,
  }) {
    final character = AmuletFiend(
      team: AmuletTeam.Monsters,
      x: x,
      y: y,
      z: z,
      fiendType: fiendType,
    )
      ..weaponHitForce = 2;

    character.roamEnabled = true;
    characters.add(character);
    return character;
  }

  @override
  void customOnPlayerDead(AmuletPlayer player) {
    addJob(seconds: 5, action: () {
      revive(player);
    });
  }

  @override
  void performCharacterAction(Character character) {

    if (character is! EquippedWeapon) {
      super.performCharacterAction(character);
      return;
    }

    final equipped = character as EquippedWeapon;
    character.clearActionFrame();
    final activeSlot = equipped.itemSlotActive;
    final activeSlotAmuletItem = activeSlot.amuletItem;

    if (character is AmuletPlayer){
      character.clearActivatedPowerIndex();
    }

    if (equipped.itemSlotPowerActive){
      equipped.deactivateItemSlotPower();
    }

    if (activeSlotAmuletItem == null){
      throw Exception('amuletItem == null');
    }

    if (character is! Elemental){
      throw Exception('character is! Elemental');
    }

    final elements = character as Elemental;
    final activeSlotAmuletItemLevel = elements.getLevelForAmuletItem(activeSlotAmuletItem);

    if (activeSlotAmuletItemLevel == -1){
      if (character is AmuletPlayer){
        character.writeGameError(GameError.Insufficient_Elements);
      }
      return;
    }

    final activeSlotAmuletItemStats = activeSlotAmuletItem.getStatsForLevel(
        activeSlotAmuletItemLevel
    );

    if (activeSlotAmuletItemStats == null){
      throw Exception('activeSlotAmuletItemStats == null');
    }

    final damage = randomInt(
        activeSlotAmuletItemStats.damageMin,
        activeSlotAmuletItemStats.damageMax + 1,
    );
    final range = activeSlotAmuletItemStats.range;

    switch (activeSlotAmuletItem) {
      case AmuletItem.Spell_Thunderbolt:
        performAbilityLightning(character);
        break;
      case AmuletItem.Spell_Fireball:
        performSpellFireball(
            character: character,
            damage: damage,
            range: range,
        );
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
      case AmuletItem.Weapon_Staff_Wooden:
        performAbilityMelee(character);
        break;
      case AmuletItem.Weapon_Old_Bow:
        performAbilityArrow(
            character: character,
            damage: damage,
            range: range,
        );
        break;
      case AmuletItem.Weapon_Holy_Bow:
        performAbilityArrow(
          character: character,
          damage: damage,
          range: range,
        );
        break;
      case AmuletItem.Weapon_Staff_Of_Frozen_Lake:
        performAbilityFrostBall(
            character,
            damage: damage,
            range: range,
        );
        break;
      case AmuletItem.Spell_Heal:
        useAmuletItemSpellHeal(character: character, stats: activeSlotAmuletItemStats);
        break;
      case AmuletItem.Spell_Bow_Split_Arrow:
        final equippedWeaponSlot = equipped.itemSlotWeapon;

        final weapon = equippedWeaponSlot.amuletItem;

        if (weapon == null){
          throw Exception('weapon is null');
        }

        final equippedWeaponLevel = weapon.getLevel(
          fire: elements.elementFire,
          water: elements.elementWater,
          electricity: elements.elementElectricity,
        );

        final equippedWeaponStats = weapon.getStatsForLevel(equippedWeaponLevel);

        if (equippedWeaponStats == null){
          throw Exception('equippedWeaponStats is null');
        }
        final totalArrows = activeSlotAmuletItemStats.quantity;
        final radian = pi * 0.25;
        final radianPerArrow = radian / totalArrows;
        final initialAngle = character.angle - (radian * 0.5);
        var angle = initialAngle;
        for (var i = 0; i < totalArrows; i++){
          spawnProjectileArrow(
              src: character,
              damage: randomInt(equippedWeaponStats.damageMin, equippedWeaponStats.damageMax),
              range: equippedWeaponStats.range,
              angle: angle,
          );
          angle += radianPerArrow;
        }
        break;
      default:
        throw Exception('amulet.PerformCharacterAction($activeSlotAmuletItem)');
    }
  }

  void performAbilityFrostBall(
      Character character, {required int damage, required double range}) {
     spawnProjectile(
      src: character,
      damage: damage,
      range: range,
      projectileType: ProjectileType.FrostBall,
      angle: character.angle,
    );
  }

  void performSpellFireball({
    required Character character,
    required int damage,
    required double range,
  }) =>
    spawnProjectile(
        src: character,
        damage: damage,
        range: range,
        projectileType: ProjectileType.Fireball,
        angle: character.angle,
    );

  void performAbilityArrow({
    required Character character,
    required int damage,
    required double range,
  }) {
     dispatchGameEvent(
      GameEvent.Bow_Released,
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

  void performAbilityBlink(Character character){
    if (character is! EquippedWeapon){
      throw Exception('character is! EquippedWeapon');
    }
    final equippedWeapon = character as EquippedWeapon;
    dispatchGameEventPosition(GameEvent.Blink_Depart, character);
    character.x = equippedWeapon.activePowerX;
    character.y = equippedWeapon.activePowerY;
    character.z = equippedWeapon.activePowerZ;
    dispatchGameEventPosition(GameEvent.Blink_Arrive, character);
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
      dispatchGameEventPosition(GameEvent.Lightning_Bolt, otherCharacter);
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
        spawnRandomLootAtPosition(target);
      }
    }

    if (target.respawnDurationTotal > 0){
      addJob(seconds: target.respawnDurationTotal, action: () {
        dispatchGameEventPosition(GameEvent.Character_Vanished, target);
        setCharacterStateSpawning(target);
        target.moveToStartPosition();
        dispatchGameEventPosition(GameEvent.Character_Vanished, target);
      });
    }

    if (src is AmuletPlayer) {
      src.gainExperience(target.experience);
    }
  }


  void spawnRandomLootAtPosition(Position position) =>
      spawnRandomLoot(
        x: position.x,
        y: position.y,
        z: position.z,
      );

  void spawnRandomLoot({
    required double x,
    required double y,
    required double z,
  }) => spawnAmuletItem(
      x: x,
      y: y,
      z: z,
      item: randomItem(AmuletItem.values),
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
      // case AmuletItem.Potion_Magic:
      //   for (final weapon in player.weapons){
      //     if (weapon.charges >= weapon.max) continue;
      //     weapon.charges++;
      //   }
      //   break;
      // case AmuletItem.Potion_Experience:
      //   player.experience += (player.experienceRequired * 0.1).toInt();
      //   break;
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
    );
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

  void useAmuletItemSpellHeal({
    required Character character,
    required AmuletItemStats stats,
  }) {
    character.health += stats.health;
    dispatchGameEventPosition(GameEvent.Spell_Used, character);
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
      dispatchGameEventPosition(GameEvent.Amulet_GameObject_Spawned, gameObject);
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

  @override
  void onCharacterTargetChanged(Character character, Position? value) {
    if (character is! AmuletFiend || value == null) return;
    dispatchGameEventPosition(GameEvent.AI_Target_Acquired, value);
    dispatchByte(character.characterType);
  }
}


