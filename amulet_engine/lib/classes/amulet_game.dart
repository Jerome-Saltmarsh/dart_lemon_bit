import 'dart:typed_data';

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
    onSecondElapsed();
  }

  void onSecondElapsed(){

    final characters = this.characters;
    for (final character in characters) {
      if (character is AmuletPlayer) {
        character.regenHealthAndMagic();
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
      ..clearTargetOnPerformAction = fiendType.clearTargetOnPerformAction
      ..weaponHitForce = 2;

    character.roamEnabled = true;
    characters.add(character);
    return character;
  }

  @override
  void customOnPlayerDead(AmuletPlayer player) {
    player.deathCount++;
    addJob(seconds: 5, action: () {
      revive(player);
    });
  }

  @override
  void endCharacterAction(Character character){
     if (character is AmuletFiend){
        if (character.characterStateAttacking){
          super.endCharacterAction(character);
          final fiendType = character.fiendType;
          character.setCharacterState(
            value: CharacterState.Idle,
            duration: randomInt(
                fiendType.postAttackPauseDurationMin,
                fiendType.postAttackPauseDurationMax,
            ),
          );
          return;
        }
     }
     super.endCharacterAction(character);
  }

  @override
  void performCharacterAction(Character character) {

    if (character is AmuletFiend){
      if (character.idling) {
        return;
      }
      switch (character.fiendType){
        case FiendType.Gargoyle:
          spawnProjectile(
            src: character,
            angle: character.angle,
            range: character.weaponRange,
            projectileType: ProjectileType.Fireball,
            damage: character.weaponDamage,
          );
          return;
        default:
          break;
      }
    }

    if (character is! AmuletPlayer) {
      super.performCharacterAction(character);
      return;
    }


    character.clearActionFrame();
    final activeAmuletItemSlot = character.activeAmuletItemSlot;
    final activeSlot = activeAmuletItemSlot ?? character.equippedWeapon;
    final amuletItem = activeSlot.amuletItem;

    if (amuletItem == null){
      throw Exception('amuletItem == null');
    }

    if (activeAmuletItemSlot != null){
      character.clearActivatedPowerIndex();
    }

    final skillType = amuletItem.skillType;

    if (skillType == null){
      throw Exception('skill type is null: $amuletItem');
    }

    final damage = getAmuletItemDamage(amuletItem);

    switch (skillType){
      case SkillType.Strike:
        performAbilityMelee(
          character: character,
          damageType: DamageType.melee,
          range: amuletItem.range ?? (throw Exception()),
          damage: damage,
        );
        break;
      case SkillType.Arrow:
        performAbilityArrow(
          character: character,
          damage: damage,
          range: amuletItem.range ?? (throw Exception('range is null')),
        );
        break;
      case SkillType.Fireball:
        performAbilityFireball(
          character,
          damage: damage,
          range: amuletItem.range ?? (throw Exception()),
        );
        break;
      case SkillType.Explode:
        createExplosion(
          x: character.activePowerX,
          y: character.activePowerY,
          z: character.activePowerZ,
          srcCharacter: character,
        );
        break;
      case SkillType.Heal:
        performAbilityHeal(
            character: character,
            target: character,
            amount: damage,
        );
        break;
      case SkillType.Teleport:
        performAbilityBlink(character);
        break;
      case SkillType.Freeze_Target:
        throw Exception('not implemented');
      case SkillType.Freeze_Area:
        throw Exception('not implemented');
      case SkillType.Firestorm:
        throw Exception('not implemented');
      case SkillType.Invisible:
        throw Exception('not implemented');
      case SkillType.Terrify:
        throw Exception('not implemented');
      default:
        throw Exception('not implemented');
    }

    // switch (amuletItem) {
    //   case AmuletItem.Weapon_Short_Sword:
    //     performAbilityMelee(
    //         character: character,
    //         damageType: DamageType.melee,
    //         range: amuletItem.range ?? (throw Exception()),
    //         damage: getAmuletItemDamage(amuletItem),
    //     );
    //     break;
    //   case AmuletItem.Weapon_Staff_Wooden:
    //     createExplosion(
    //         x: character.activePowerX,
    //         y: character.activePowerY,
    //         z: character.activePowerZ,
    //         srcCharacter: character,
    //     );
    //     break;
    //   case AmuletItem.Weapon_Old_Bow:
    //     performAbilityArrow(
    //         character: character,
    //         damage: getAmuletItemDamage(amuletItem),
    //         range: amuletItem.range ?? (throw Exception('range is null')),
    //     );
    //     break;
    //   case AmuletItem.Weapon_Holy_Bow:
    //     performAbilityArrow(
    //       character: character,
    //       damage: getAmuletItemDamage(amuletItem),
    //       range: amuletItem.range ?? (throw Exception('range is null')),
    //     );
    //     break;
    //   case AmuletItem.Moth_Hat_Of_Magic:
    //     performAbilityFireball(
    //         character,
    //         damage: getAmuletItemDamage(amuletItem),
    //         range: amuletItem.range ?? (throw Exception()),
    //     );
    //     break;
    //   default:
    //     // final weaponType = amuletItem.subType;
    //     // if (WeaponType.valuesMelee.contains(weaponType)){
    //     //   performAbilityMelee(
    //     //       character: character,
    //     //       damageType: DamageType.melee,
    //     //   );
    //     //   return;
    //     // }
    //     throw Exception('amulet.PerformCharacterAction($amuletItem)');
    // }
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

  void performAbilityHeal({
    required Character character,
    required Character target,
    required int amount,
  }){
    target.health += amount;
    dispatchGameEventPosition(GameEvent.Character_Caste_Healed, character);
    if (character != target) {
      dispatchGameEventPosition(GameEvent.Character_Healed, target);
    }
  }

  void performAbilityFireball(
      Character character, {required int damage, required double range}) {
     spawnProjectile(
      src: character,
      damage: damage,
      range: range,
      projectileType: ProjectileType.Fireball,
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

  void performAbilityBlink(AmuletPlayer character){
    dispatchGameEventPosition(GameEvent.Blink_Depart, character);
    character.x = character.activePowerX;
    character.y = character.activePowerY;
    character.z = character.activePowerZ;
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
        damageType: DamageType.electric
      );
      boltsRemaining--;
      if (boltsRemaining <= 0) {
        return;
      }
    }
  }

  @override
  void customOnCharacterKilled(Character target, src) {

    if (target is AmuletFiend){
      if (randomChance(target.fiendType.chanceOfDropLegendary)) {
        spawnRandomLootAtFiend(target, itemQuality: ItemQuality.Legendary);
        return;
      }

      if (randomChance(target.fiendType.chanceOfDropRare)) {
        spawnRandomLootAtFiend(target, itemQuality: ItemQuality.Rare);
        return;
      }

      if (randomChance(target.fiendType.chanceOfDropCommon)) {
        spawnRandomLootAtFiend(target, itemQuality: ItemQuality.Common);
        return;
      }

      if (randomChance(target.fiendType.chanceOfDropPotion)) {
        spawnAmuletItemAtPosition(
          item: AmuletItem.Consumable_Potion_Health,
          position: target,
          deactivationTimer: lootDeactivationTimer,
        );
        return;
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

    // if (src is AmuletPlayer) {
    //   src.gainExperience(target.experience);
    // }
  }

  void spawnRandomLootAtFiend(AmuletFiend fiend, {
    required ItemQuality itemQuality,
  }) {

    final fiendType = fiend.fiendType;
    final fiendLevel = fiendType.level;
    
    final values = AmuletItem.values.where((element) =>
      fiendLevel >= element.levelMin &&
      fiendLevel < element.levelMax &&
      element.quality == itemQuality
    );
    
    if (values.isEmpty){
      return;
    }

    spawnAmuletItem(
        item: randomItem(values),
        x: fiend.x,
        y: fiend.y,
        z: fiend.z,
      );
  }

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
      amuletItem: item,
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
        item: AmuletItem.Consumable_Potion_Health,
    );
  }

  @override
  void customOnCollisionBetweenPlayerAndGameObject(AmuletPlayer player, GameObject gameObject) {
    if (gameObject is! AmuletGameObject) {
      return;
    }

    final amuletItem = gameObject.amuletItem;
    if (amuletItem == AmuletItem.Consumable_Potion_Health){
      player.writePlayerEventItemTypeConsumed(amuletItem.subType);
      player.health += player.maxHealth ~/ 4;
      deactivate(gameObject);
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

  @override
  void customOnCharacterInteractWithGameObject(
      Character character,
      GameObject gameObject,
  ) {
    if (character is AmuletPlayer && gameObject is AmuletGameObject) {
      onAmuletPlayerInteractWithAmuletGameObject(character, gameObject);
    }
    // if (
    //   character is AmuletPlayer &&
    //   gameObject.type == ItemType.Object &&
    //   gameObject.subType == GameObjectType.Wooden_Chest
    // ){
    //   character.toggleInventoryOpen();
    //   character.clearTarget();
    // }
  }

  void onAmuletPlayerInteractWithAmuletGameObject(
      AmuletPlayer player,
      AmuletGameObject gameObject,
  ){
     player.acquireAmuletItem(gameObject.amuletItem);
     deactivate(gameObject);
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

  void endPlayerInteraction(AmuletPlayer player) =>
      player.endInteraction();

  void useAmuletItemSpellHeal({
    required Character character,
  }) {
    character.health += 10;
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
      if (player.activeAmuletItemSlot == null){
        player.performForceAttack();
        return;
      } else {
        player.deactivateSlotType();
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

    // if (mouseLeftClicked && player.inventoryOpen){
    //   player.inventoryOpen = false;
    // }

    if (mouseLeftClicked && player.activeAmuletItemSlot != null) {
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

  @override
  void applyDamageToCharacter({
    required Character src,
    required Character target,
    required int amount,
    required DamageType damageType,
  }) {
    if (target is AmuletFiend) {
      final resists = target.fiendType.resists;
      if (resists == damageType){
        amount = amount ~/ 2;
      }
    }
    super.applyDamageToCharacter(
      src: src,
      target: target,
      amount: amount,
      damageType: damageType,
    );
  }

  static int getAmuletItemDamage(AmuletItem amuletItem){
    final min = amuletItem.damageMin;
    final max = amuletItem.damageMax;
    if (min == null || max == null) return 0;
    return randomInt(min, max + 1);
  }
}


