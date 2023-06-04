import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_server/src/game/game.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';
import '../../io/write_scene_to_file.dart';
import '../../game/player.dart';
import 'isometric_ai.dart';
import 'isometric_character.dart';
import 'isometric_collider.dart';
import 'isometric_environment.dart';
import 'isometric_gameobject.dart';
import 'isometric_hit_type.dart';
import 'isometric_job.dart';
import 'isometric_physics.dart';
import 'isometric_player.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';
import 'isometric_scene.dart';
import 'isometric_script.dart';
import 'isometric_time.dart';

abstract class IsometricGame<T extends IsometricPlayer> extends Game<T> {

  var frame = 0;
  var _running = true;
  IsometricScene scene;
  final characters = <IsometricCharacter>[];
  final projectiles = <IsometricProjectile>[];
  final jobs = <IsometricJob>[];
  final scripts = <IsometricScript>[];
  final scriptReader = ByteReader();
  var _timerUpdateAITargets = 0;
  var gameObjectId = 0;
  IsometricEnvironment environment;
  IsometricTime time;

  bool get running => _running;

  set running(bool value) {
    if (_running == value) return;
    _running = value;
    for (final player in players) {
      player.writeGameProperties();
    }
  }

  IsometricScript performScript({required int timer}) {
    for (final script in scripts) {
      if (script.timer > 0) continue;
      script.timer = timer;
      script.clear();
      return script;
    }
    final instance = IsometricScript();
    scripts.add(instance);
    instance.timer = timer;
    return instance;
  }

  /// In seconds
  void customInitPlayer(IsometricPlayer player) {}

  /// @override
  void customUpdatePlayer(IsometricPlayer player) {}

  /// @override
  void customOnPlayerInteractWithGameObject(IsometricPlayer player,
      IsometricGameObject gameObject) {}

  /// @override
  void customDownloadScene(IsometricPlayer player) {}

  /// @override
  void customUpdate() {}

  /// @override
  void customOnPlayerDisconnected(IsometricPlayer player) {}

  /// @override
  void customOnColliderDeactivated(IsometricCollider collider) {}

  /// @override
  void customOnColliderActivated(IsometricCollider collider) {}

  /// @override
  void customOnCharacterSpawned(IsometricCharacter character) {}

  /// @override
  void customOnCharacterKilled(IsometricCharacter target, dynamic src) {}

  /// @override
  void customOnCharacterDamageApplied(IsometricCharacter target, dynamic src,
      int amount) {}

  /// @override
  void customOnPlayerRevived(IsometricPlayer player) {}

  /// @override
  void customOnPlayerCreditsChanged(IsometricPlayer player) {}

  /// @override
  void customOnPlayerDead(IsometricPlayer player) {}

  /// @override
  void customOnGameStarted() {}

  /// @override
  void customOnNpcObjectivesCompleted(IsometricCharacter npc) {}

  /// @override
  void customOnPlayerLevelGained(T player) {}

  /// @override
  void customOnCollisionBetweenColliders(IsometricCollider a, IsometricCollider b) {}

  /// @override
  void customOnCollisionBetweenPlayerAndOther(IsometricPlayer player,
      IsometricCollider collider) {}

  /// @override
  void customOnCollisionBetweenPlayerAndGameObject(IsometricPlayer player,
      IsometricGameObject gameObject) {}

  /// @override
  void customOnAIRespawned(IsometricAI ai) {}

  /// @override
  void customOnPlayerWeaponChanged(IsometricPlayer player,
      int previousWeaponType, int newWeaponType) {}

  /// @override
  void customOnHitApplied({
    required IsometricCharacter srcCharacter,
    required IsometricCollider target,
    required int damage,
    required double angle,
    required int hitType,
    required double force,
  }) {}

  /// @override
  void customOnPlayerJoined(IsometricPlayer player) {}

  /// @override
  void customInit() {}

  /// @override
  void customOnGameObjectSpawned(IsometricGameObject gameObject) {}

  /// @override
  void customOnGameObjectDestroyed(IsometricGameObject gameObject) {}

  /// @override
  void customOnCharacterWeaponStateReady(IsometricCharacter character) {}

  /// @override
  void customOnPlayerAimTargetChanged(IsometricPlayer player,
      IsometricCollider? collider) {}

  /// @override
  void customOnPlayerPerkTypeChanged(IsometricPlayer player) {}

  /// @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    // default behavior is to respawn after a period however this can be safely overriden
    performJob(1000, () {
      setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
      );
    });
  }

  /// PROPERTIES
  List<IsometricGameObject> get gameObjects => scene.gameObjects;

  /// @override
  double get minAimTargetCursorDistance => 35;

  /// CONSTRUCTOR
  IsometricGame({
    required this.scene,
    required this.time,
    required this.environment,
    required super.gameType,
  }) {
    IsometricPosition.sort(gameObjects);

    /// TODO Illegal external scope reference
    gameObjectId = scene.gameObjects.length;
    customInit();

    for (final gameObject in gameObjects) {
      customOnGameObjectSpawned(gameObject);
    }
  }

  /// QUERIES

  IsometricGameObject? findGameObjectByType(int type) {
    for (final gameObject in gameObjects) {
      if (gameObject.type == type) return gameObject;
    }
    return null;
  }

  IsometricGameObject? findGameObjectById(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  /// ACTIONS

  void moveV3ToNodeIndex(IsometricPosition vector3, int nodeIndex) {
    vector3.x = scene.convertNodeIndexToPositionX(nodeIndex);
    vector3.y = scene.convertNodeIndexToPositionY(nodeIndex);
    vector3.z = scene.convertNodeIndexToPositionZ(nodeIndex);
  }

  void move(IsometricPosition value, double angle, double distance) {
    value.x += getAdjacent(angle, distance);
    value.y += getOpposite(angle, distance);
  }

  double getDistanceFromPlayerMouse(IsometricPlayer player,
      IsometricPosition position) =>
      getDistanceV3(
        player.mouseGridX,
        player.mouseGridY,
        player.z,
        position.x,
        position.y,
        position.z,
      );

  /// @inputTypeKeyboard keyboard = true, touchscreen = false
  void onPlayerUpdateRequestReceived({
    required IsometricPlayer player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {
    if (player.deadOrBusy) return;

    playerUpdateAimTarget(player);

    if (!player.weaponStateBusy) {
      player.lookRadian = player.mouseAngle;
    }

    if (inputTypeKeyboard) {
      playerRunInDirection(player, Direction.fromInputDirection(direction));
    } else {
      if (mouseLeftDown) {
        player.runToMouse();
      }
    }
  }

  void changeGame(IsometricPlayer player, IsometricGame to) {
    if (this == to) return;
    removePlayer(player);
    for (final character in characters) {
      if (character.target != this) continue;
      clearCharacterTarget(character);
    }
    to.players.add(player);
    to.characters.add(player);
    player.sceneDownloaded = false;
    player.game = to;
    player.game.clearCharacterTarget(player);
  }

  void playerUpdateAimTarget(IsometricPlayer player) {
    var closestDistance = GameSettings.Pickup_Range_Squared;

    final mouseX = player.mouseGridX;
    final mouseY = player.mouseGridY;
    final mouseZ = player.z;

    IsometricCollider? closestCollider;

    for (final character in characters) {
      if (character.dead) continue;
      if ((mouseX - character.x).abs() > GameSettings.Pickup_Range) continue;
      if ((mouseY - character.y).abs() > GameSettings.Pickup_Range) continue;
      if ((mouseZ - character.z).abs() > GameSettings.Pickup_Range) continue;
      if (character == player) continue;
      final distance = getDistanceV3Squared(
          mouseX, mouseY, mouseZ, character.x, character.y, character.z);
      if (distance > closestDistance) continue;
      closestDistance = distance;
      closestCollider = character;
    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.collectable && !gameObject.interactable) continue;
      if ((mouseX - gameObject.x).abs() > GameSettings.Pickup_Range) continue;
      if ((mouseY - gameObject.y).abs() > GameSettings.Pickup_Range) continue;
      if ((mouseZ - gameObject.z).abs() > GameSettings.Pickup_Range) continue;
      final distance = getDistanceV3Squared(
          mouseX, mouseY, mouseZ, gameObject.x, gameObject.y, gameObject.z);
      if (distance > closestDistance) continue;
      closestDistance = distance;
      closestCollider = gameObject;
    }

    player.aimTarget = closestCollider;
  }

  void playerRunInDirection(IsometricPlayer player, int direction) {
    if (direction == Direction.None && player.target == null) {
      player.setCharacterStateIdle();
      return;
    }

    if (player.targetSet) {
      if (direction == Direction.None) {
        return;
      }
      clearCharacterTarget(player);
      player.setCharacterStateIdle();
      return;
    } else if (direction == Direction.None) {
      clearCharacterTarget(player);
      player.setCharacterStateIdle();
      return;
    }
    player.faceDirection = direction;
    setCharacterStateRunning(player);
    clearCharacterTarget(player);

    if (
    player.interactMode == InteractMode.Trading ||
        player.interactMode != InteractMode.Talking
    ) {
      return player.endInteraction();
    }
  }

  void characterWeaponAim(IsometricCharacter character) {
    character.weaponState = WeaponState.Aiming;
    character.weaponStateDurationTotal = 30;
  }

  void characterUseOrEquipWeapon({
    required IsometricCharacter character,
    required int weaponType,
    required bool characterStateChange,
  }) {
    if (character.deadBusyOrWeaponStateBusy) return;

    if (character.weaponType != weaponType) {
      character.weaponType = weaponType;
      if (characterStateChange) {
        setCharacterStateChanging(character);
        return;
      }
    }
    characterUseWeapon(character);
  }

  void playerEquipNextItemGroup(IsometricPlayer player, ItemGroup itemGroup) {
    if (!player.canChangeEquipment) return;

    final equippedItemType = player.getEquippedItemGroupItem(itemGroup);

    if (equippedItemType == ItemType.Empty) {
      playerEquipFirstItemTypeFromItemGroup(player, itemGroup);
      return;
    }

    final equippedWeaponItemGroup = ItemType.getItemGroup(player.weaponType);

    if (equippedWeaponItemGroup != itemGroup) {
      characterEquipItemType(
          player, player.getEquippedItemGroupItem(itemGroup));
      return;
    }

    final equippedItemIndex = player.getItemIndex(equippedItemType);
    assert (equippedItemType != -1);

    final itemEntries = player.item_level.entries.toList(growable: false);
    final itemEntriesLength = itemEntries.length;
    for (var i = equippedItemIndex + 1; i < itemEntriesLength; i++) {
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      characterEquipItemType(player, entryItemType);
      return;
    }

    for (var i = 0; i < equippedItemIndex; i++) {
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      characterEquipItemType(player, entryItemType);
      return;
    }
  }

  void playerEquipFirstItemTypeFromItemGroup(IsometricPlayer player,
      ItemGroup itemGroup) {
    final itemEntries = player.item_level.entries.toList(growable: false);
    final itemEntriesLength = itemEntries.length;
    for (var i = 0 + 1; i < itemEntriesLength; i++) {
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      characterEquipItemType(player, entryItemType);
      return;
    }
  }

  void characterEquipItemType(IsometricCharacter character, int itemType) {
    if (!character.canChangeEquipment) return;

    if (ItemType.isTypeWeapon(itemType)) {
      characterEquipWeapon(
        character: character,
        weaponType: itemType,
        characterStateChange: true,
      );
      return;
    }

    if (ItemType.isTypeHead(itemType)) {
      character.headType = itemType;
      setCharacterStateChanging(character);
      return;
    }

    if (ItemType.isTypeBody(itemType)) {
      character.bodyType = itemType;
      setCharacterStateChanging(character);
      return;
    }

    if (ItemType.isTypeLegs(itemType)) {
      character.legsType = itemType;
      setCharacterStateChanging(character);
      return;
    }

    throw Exception(
        "game.characterEquipItemType(${ItemType.getName(itemType)})"
    );
  }

  void characterEquipWeapon({
    required IsometricCharacter character,
    required int weaponType,
    required bool characterStateChange,
  }) {
    if (!character.canChangeEquipment) return;
    if (character.weaponType == weaponType) return;
    character.weaponType = weaponType;
    if (characterStateChange) {
      setCharacterStateChanging(character);
    }
  }

  void characterAimWeapon(IsometricCharacter character) {
    if (character.deadBusyOrWeaponStateBusy && !character.weaponStateAiming)
      return;
    character.assignWeaponStateAiming();
  }

  int getCharacterWeaponEnergyCost(IsometricCharacter character) =>
      const <int, int>{
        ItemType.Weapon_Ranged_Flamethrower: 1,
        ItemType.Weapon_Ranged_Sniper_Rifle: 5,
        ItemType.Weapon_Ranged_Shotgun: 5,
        ItemType.Weapon_Ranged_Plasma_Pistol: 2,
        ItemType.Weapon_Ranged_Bazooka: 10,
        ItemType.Weapon_Ranged_Plasma_Rifle: 2,
        ItemType.Weapon_Ranged_Teleport: 10,
        ItemType.Weapon_Melee_Knife: 5,
        ItemType.Weapon_Melee_Sword: 8,
        ItemType.Weapon_Melee_Crowbar: 2,
      }[character.weaponType] ?? 1;

  void characterUseWeapon(IsometricCharacter character) {
    if (character.deadBusyOrWeaponStateBusy) return;

    final weaponType = character.weaponType;

    if (character is IsometricPlayer) {
        final cost = getCharacterWeaponEnergyCost(character);
        if (character.energy < cost) {
          character.writeGameError(GameError.Insufficient_Energy);
          return;
        }
        character.energy -= cost;
    } else if (character is IsometricAI) {
      if (ItemType.isTypeWeaponFirearm(weaponType)) {
        if (character.rounds <= 0) {
          character.assignWeaponStateReloading();
          character.rounds = ItemType.getMaxQuantity(weaponType);
          return;
        }
        character.rounds--;
      }
    }

    if (character.buffInvisible) {
      character.buffInvisible = false;
    }

    if (weaponType == ItemType.Weapon_Thrown_Grenade) {
      if (character is IsometricPlayer) {
        playerThrowGrenade(character, damage: 10);
        return;
      }
      throw Exception('ai cannot throw grenades');
    }

    if (weaponType == ItemType.Weapon_Ranged_Teleport) {
      if (character is IsometricPlayer) {
        characterTeleport(
          character: character,
          x: character.mouseGridX,
          y: character.mouseGridY,
          range: ItemType.getRange(ItemType.Weapon_Ranged_Teleport),
        );
      }
      return;
    }

    if (weaponType == ItemType.Weapon_Ranged_Flamethrower) {
      if (character is IsometricPlayer) {
        playerUseFlamethrower(character);
        return;
      }
      throw Exception('ai cannot use flamethrower');
    }

    if (weaponType == ItemType.Weapon_Ranged_Bazooka) {
      if (character is IsometricPlayer) {
        playerUseBazooka(character);
      }
      return;
    }

    if (weaponType == ItemType.Weapon_Ranged_Minigun) {
      if (character is IsometricPlayer) {
        playerUseMinigun(character);
      }
      return;
    }

    if (ItemType.isTypeWeaponFirearm(weaponType)) {
      characterFireWeapon(character);
      // if (character is Player){
      //   if (character.buffNoRecoil > 0) return;
      // }
      character.accuracy += 0.25;
      return;
    }

    if (ItemType.isTypeWeaponMelee(weaponType)) {
      characterAttackMelee(character);
      return;
    }

    switch (weaponType) {
      case ItemType.Weapon_Ranged_Crossbow:
        spawnProjectileArrow(
          damage: character.damage,
          range: ItemType.getRange(weaponType),
          src: character,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        return;
      case ItemType.Weapon_Melee_Staff:
        characterSpawnProjectileFireball(
          character,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        break;
      case ItemType.Weapon_Ranged_Bow:
        spawnProjectileArrow(
          src: character,
          damage: character.damage,
          range: ItemType.getRange(weaponType),
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        break;
    }
  }

  void playerTeleport(IsometricPlayer player) =>
      characterTeleport(
        character: player,
        x: player.mouseGridX,
        y: player.mouseGridY,
        range: ItemType.getRange(ItemType.Weapon_Ranged_Teleport),
      );

  void characterTeleport({
    required IsometricCharacter character,
    required double x,
    required double y,
    required double range,
  }) {
    if (!scene.inboundsXYZ(x, y, character.z)) return;

    final startX = character.x;
    final startY = character.y;
    final startZ = character.z;

    final z = character.z;
    final r = radian(x1: character.x, y1: character.y, x2: x, y2: y);
    var completed = false;

    if (!character.withinDistance(x, y, z, range)) {
      x = character.x + getAdjacent(r, range);
      y = character.y + getOpposite(r, range);
    }

    final nodeIndex = scene.getNodeIndexXYZ(x, y, z);
    final nodeOrientation = scene.nodeOrientations[nodeIndex];

    if (!completed && nodeOrientation == NodeOrientation.None) {
      character.x = x;
      character.y = y;
      completed = true;
    }

    if (!completed && z + Node_Height < scene.gridHeightLength) {
      final aboveNodeIndex = scene.getNodeIndexXYZ(x, y, z + Node_Height);
      final aboveNodeOrientation = scene.nodeOrientations[aboveNodeIndex];
      if (aboveNodeOrientation == NodeOrientation.None) {
        character.x = x;
        character.y = y;
        character.z = z + Node_Height;
        completed = true;
      }
    }

    if (!completed) {
      final distance = getDistanceXY(x, y, character.x, character.y);
      final jumps = distance ~/ Node_Size_Half;
      final jumpX = getAdjacent(r, Node_Size_Half);
      final jumpY = getOpposite(r, Node_Size_Half);

      for (var i = 0; i < jumps; i++) {
        x -= jumpX;
        y -= jumpY;
        final frontNodeIndex = scene.getNodeIndexXYZ(x, y, z);
        final frontNodeOrientation = scene.nodeOrientations[frontNodeIndex];
        if (frontNodeOrientation == NodeOrientation.None) {
          character.x = x;
          character.y = y;
          character.z = z;
          completed = true;
          break;
        }
      }
    }

    if (completed) {
      dispatch(GameEventType.Teleport_Start, startX, startY, startZ);
      dispatchV3(GameEventType.Teleport_End, character);
      if (character is IsometricPlayer) {
        character.writePlayerEvent(PlayerEvent.Teleported);
      }
    }
  }

  void playerReload(IsometricPlayer player) {
    final equippedWeaponAmmoType = player.equippedWeaponAmmunitionType;
    final totalAmmoRemaining = player.inventoryGetTotalQuantityOfItemType(
        equippedWeaponAmmoType);

    if (totalAmmoRemaining == 0) {
      player.writeGameError(GameError.Insufficient_Ammunition);
      return;
    }
    var total = min(totalAmmoRemaining, player.equippedWeaponCapacity);
    player.inventoryReduceItemTypeQuantity(
      itemType: equippedWeaponAmmoType,
      reduction: total,
    );
    player.inventorySetQuantityAtIndex(
      quantity: total,
      index: player.equippedWeaponIndex,
    );
    player.assignWeaponStateReloading();
  }

  void playerThrowGrenade(IsometricPlayer player, {int damage = 10}) {
    if (player.deadBusyOrWeaponStateBusy) return;

    // if (options.items){
    //   if (player.grenades <= 0) {
    //     player.writeError('No grenades left');
    //     return;
    //   }
    //   player.grenades--;
    // }

    dispatchAttackPerformed(
      ItemType.Weapon_Thrown_Grenade,
      player.x + getAdjacent(player.lookRadian, 60),
      player.y + getOpposite(player.lookRadian, 60),
      player.z + Character_Gun_Height,
      player.lookRadian,
    );

    player.assignWeaponStateThrowing();

    final mouseDistance = getDistanceXY(
        player.x, player.y, player.mouseGridX, player.mouseGridY);
    final throwDistance = min(mouseDistance, IsometricPhysics.Max_Throw_Distance);
    final throwRatio = throwDistance / IsometricPhysics.Max_Throw_Distance;
    final velocity = IsometricPhysics.Max_Throw_Velocity * throwRatio;
    final velocityZ = IsometricPhysics.Max_Throw_Velocity_Z * throwRatio;

    final instance = spawnGameObject(
      x: player.x,
      y: player.y,
      z: player.z + Character_Height,
      type: ItemType.Weapon_Thrown_Grenade,
    )
      ..setVelocity(player.lookRadian, velocity)
      ..quantity = 1
      ..friction = 0.985
      ..bounce = true
      ..physical = true
      ..gravity = true
      ..hitable = true
      ..persistable = false
      ..collectable = false
      ..interactable = false
      ..velocityZ = velocityZ
      ..owner = player
      ..damage = damage;

    performJob(GameSettings.Grenade_Cook_Duration, () {
      deactivateCollider(instance);
      final owner = instance.owner;
      if (owner == null) return;
      createExplosion(
        x: instance.x,
        y: instance.y,
        z: instance.z,
        srcCharacter: owner,
      );
    });
  }

  void playerUseFlamethrower(IsometricPlayer player) {
    dispatchPlayerAttackPerformed(player);
    player.assignWeaponStateFiring();
    spawnProjectileFireball(player, damage: 3, range: player.weaponTypeRange);
  }

  void playerUseBazooka(IsometricPlayer player) {
    dispatchPlayerAttackPerformed(player);
    player.assignWeaponStateFiring();
    spawnProjectileRocket(player, damage: 3, range: player.weaponTypeRange);
  }

  void playerUseMinigun(IsometricPlayer player) {
    characterFireWeapon(player);
  }

  void positionToPlayerMouse(Position position, IsometricPlayer player) {
    position.x = player.mouseGridX;
    position.y = player.mouseGridY;
  }

  void playerAutoAim(IsometricPlayer player) {
    if (player.deadOrBusy) return;
    var closestTargetDistance = player.weaponTypeRange * 1.5;
    IsometricCollider? closestTarget = null;
    for (final character in characters) {
      if (character.dead) continue;
      if (IsometricCollider.onSameTeam(player, character)) continue;
      final distance = player.getDistance3(character);
      if (distance > closestTargetDistance) continue;
      closestTarget = character;
      closestTargetDistance = distance;
    }
    if (closestTarget != null) {
      player.lookAt(closestTarget);
      player.face(closestTarget);
      return;
    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;
      // if (Collider.onSameTeam(player, character)) continue;
      final distance = player.getDistance3(gameObject);
      if (distance > closestTargetDistance) continue;
      closestTarget = gameObject;
      closestTargetDistance = distance;
    }
    if (closestTarget != null) {
      player.lookAt(closestTarget);
      player.face(closestTarget);

      return;
    }
  }

  void characterAttackMelee(IsometricCharacter character) {
    assert (character.active);
    assert (character.alive);
    assert (character.damage >= 0);

    if (character.deadBusyOrWeaponStateBusy) return;

    final angle = character.lookRadian;
    final attackRadius = ItemType.getMeleeAttackRadius(character.weaponType);

    if (attackRadius <= 0) {
      throw Exception(
          'ItemType.getRange(${ItemType.getName(character.weaponType)})');
    }

    final attackRadiusHalf = attackRadius * 0.5;
    final performX = character.x + getAdjacent(angle, attackRadiusHalf);
    final performY = character.y + getOpposite(angle, attackRadiusHalf);
    final performZ = character.z;

    character.assignWeaponStateMelee();

    dispatchMeleeAttackPerformed(
      character.weaponType,
      performX,
      performY,
      performZ,
      angle,
    );

    character.applyForce(
      force: 2.5,
      angle: angle,
    );

    var attackHit = false;

    IsometricCollider? nearest;
    var nearestDistance = 999.0;
    final areaOfEffect = ItemType.isMeleeAOE(character.weaponType);

    for (final other in characters) {
      if (!other.active) continue;
      if (!other.hitable) continue;
      if (IsometricCollider.onSameTeam(character, other)) continue;
      if (!other.withinDistance(
        performX,
        performY,
        performZ,
        attackRadiusHalf,
      )) continue;

      if (!areaOfEffect) {
        final distance = character.getDistance3(other);
        if (distance > nearestDistance) continue;
        nearest = other;
        nearestDistance = distance;
        attackHit = true;
        continue;
      }

      applyHit(
          angle: radiansV2(character, other),
          target: other,
          damage: character.damage,
          srcCharacter: character,
          hitType: IsometricHitType.Melee
      );
      attackHit = true;
    }

    final gameObjectsLength = gameObjects.length;
    for (var i = 0; i < gameObjectsLength; i++) {
      final gameObject = gameObjects[i];
      if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;
      if (!gameObject.withinDistance(
        performX,
        performY,
        performZ,
        attackRadiusHalf,
      )) continue;

      if (!areaOfEffect) {
        final distance = character.getDistance3(gameObject);
        if (distance > nearestDistance) continue;
        nearest = gameObject;
        nearestDistance = distance;
        attackHit = true;
        continue;
      }

      applyHit(
          angle: radiansV2(character, gameObject),
          target: gameObject,
          damage: character.damage,
          srcCharacter: character,
          hitType: IsometricHitType.Melee
      );
      attackHit = true;
    }

    if (nearest != null) {
      applyHit(
          angle: radiansV2(character, nearest),
          target: nearest,
          damage: character.damage,
          srcCharacter: character,
          hitType: IsometricHitType.Melee);
    }

    if (!scene.isInboundXYZ(performX, performY, performZ)) return;
    final nodeIndex = scene.getNodeIndexXYZ(performX, performY, performZ);
    final nodeType = scene.nodeTypes[nodeIndex];

    if (!NodeType.isRainOrEmpty(nodeType)) {
      character.applyForce(
        force: 4.5,
        angle: angle + pi,
      );
      character.clampVelocity(IsometricPhysics.Max_Velocity);
      attackHit = true;
      for (final player in players) {
        if (!player.onScreen(performX, performY)) continue;
        player.writeGameEvent(
          type: GameEventType.Node_Struck,
          x: performX,
          y: performY,
          z: performZ,
          angle: angle,
        );
      }
    }

    // TODO Abstract
    if (NodeType.isDestroyable(nodeType)) {
      destroyNode(nodeIndex);
      attackHit = true;
    }

    if (!attackHit) {
      for (final player in players) {
        if (!player.onScreen(performX, performY)) continue;
        player.writeGameEvent(
          type: GameEventType.Attack_Missed,
          x: performX,
          y: performY,
          z: performZ,
          angle: angle,
        );
        player.writeUInt16(character.weaponType);
      }
    }
  }

  void destroyNode(int nodeIndex) {
    final nodeOrientation = scene.nodeOrientations[nodeIndex];
    if (nodeOrientation == NodeOrientation.Destroyed) return;
    final nodeType = scene.nodeTypes[nodeIndex];
    if (nodeType == NodeType.Empty) return;
    setNode(
      nodeIndex: nodeIndex,
      nodeType: nodeType,
      nodeOrientation: NodeOrientation.Destroyed,
    );
    customOnNodeDestroyed(nodeType, nodeIndex, nodeOrientation);
  }

  bool characterMeleeAttackTargetInRange(IsometricCharacter character) {
    assert (character.active);
    assert (character.alive);
    assert (character.damage >= 0);

    if (character.deadBusyOrWeaponStateBusy) return false;

    final angle = character.lookRadian;
    final attackRadius = ItemType.getMeleeAttackRadius(character.weaponType) *
        0.75;

    if (attackRadius <= 0) {
      return false;
    }

    final attackRadiusHalf = attackRadius * 0.5;
    final performX = character.x + getAdjacent(angle, attackRadiusHalf);
    final performY = character.y + getOpposite(angle, attackRadiusHalf);
    final performZ = character.z;

    for (final other in characters) {
      if (!other.active) continue;
      if (!other.hitable) continue;
      if (IsometricCollider.onSameTeam(character, other)) continue;
      if (other.withinDistance(
        performX,
        performY,
        performZ,
        attackRadiusHalf,
      )) return true;
    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;
      if (gameObject.withinDistance(
        performX,
        performY,
        performZ,
        attackRadiusHalf,
      )) return true;
    }
    return false;
  }

  void characterFireWeapon(IsometricCharacter character) {
    assert (!character.weaponStateBusy);
    final angle = (character is IsometricPlayer)
        ? character.lookRadian
        : character.faceAngle;

    if (character.weaponType == ItemType.Weapon_Ranged_Shotgun) {
      characterFireShotgun(character, angle);
      return;
    }

    character.assignWeaponStateFiring();
    character.applyForce(
      force: 1.0,
      angle: angle + pi,
    );
    character.clampVelocity(IsometricPhysics.Max_Velocity);

    spawnProjectile(
      src: character,
      accuracy: character.accuracy,
      angle: angle,
      range: character.weaponTypeRange,
      projectileType: ProjectileType.Bullet,
      damage: character.damage,
    );

    if (character.buffDoubleDamage) {
      const angleOffset = degreesToRadians * 20;
      spawnProjectile(
        src: character,
        accuracy: character.accuracy,
        angle: angle - angleOffset,
        range: character.weaponTypeRange,
        projectileType: ProjectileType.Bullet,
        damage: character.damage,
      );
    }

    if (character.buffDoubleDamage) {
      const angleOffset = degreesToRadians * 20;
      spawnProjectile(
        src: character,
        accuracy: character.accuracy,
        angle: angle + angleOffset,
        range: character.weaponTypeRange,
        projectileType: ProjectileType.Bullet,
        damage: character.damage,
      );
    }

    dispatchAttackPerformed(
      character.weaponType,
      character.x + getAdjacent(angle, 70),
      character.y + getOpposite(angle, 70),
      character.z + Character_Gun_Height,
      angle,
    );
  }

  void playerFaceMouse(IsometricPlayer player) {
    player.faceXY(
      player.mouseGridX,
      player.mouseGridY,
    );
  }

  void activateCollider(IsometricCollider collider) {
    if (collider.active) return;
    collider.active = true;
    if (collider is IsometricGameObject) {
      collider.dirty = true;
    }
    if (collider is IsometricPlayer) {
      collider.writePlayerActive();
    }
    customOnColliderActivated(collider);
  }

  void onGridChanged() {
    scene.refreshGridMetrics();
    for (final player in players) {
      player.writeGrid();
    }
  }

  void deactivateCollider(IsometricCollider collider) {
    if (!collider.active) return;
    collider.active = false;
    collider.velocityX = 0;
    collider.velocityY = 0;
    collider.velocityZ = 0;

    if (collider is IsometricGameObject) {
      collider.dirty = true;
      collider.available = false;
    }
    if (collider is IsometricPlayer) {
      collider.writePlayerActive();
    }

    for (final character in characters) {
      if (character.target != collider) continue;
      clearCharacterTarget(character);
    }

    for (final projectile in projectiles) {
      if (projectile.target != collider) continue;
      projectile.target = null;
    }

    customOnColliderDeactivated(collider);
  }

  void dispatchGameEventCharacterDeath(IsometricCharacter character) {
    for (final player in players) {
      player.writeGameEvent(
        type: GameEventType.Character_Death,
        x: character.x,
        y: character.y,
        z: character.z,
        angle: character.velocityAngle,
      );
      player.writeByte(character.characterType);
    }
  }

  void dispatchGameEventGameObjectDestroyed(IsometricGameObject gameObject) {
    for (final player in players) {
      player.writeGameEventGameObjectDestroyed(gameObject);
    }
  }

  void removeFromEngine() {
    print("removeFromEngine()");
    engine.games.remove(this);
  }

  void setHourMinutes(int hour, int minutes) {
    time.time = (hour * 60 * 60) + (minutes * 60);
    // environment.updateShade();
    playersWriteWeather();
  }

  /// UPDATE

  void updateInProgress() {
    if (!_running) return;

    frame++;
    time.update();
    environment.update();

    updateAITargets();
    internalUpdateJobs();
    internalUpdateScripts();
    customUpdate();
    updateGameObjects();
    updateCollisions();
    updateCharacters();
    updateProjectiles(); // called twice to fix collision detection
    updateProjectiles(); // called twice to fix collision detection
    updateProjectiles(); // called twice to fix collision detection
    updateCharacterFrames();
    sortColliders();
  }

  void performJob(int timer, Function action) {
    assert (timer > 0);
    for (final job in jobs) {
      if (job.timer > 0) continue;
      job.timer = timer;
      job.action = action;
      return;
    }
    final job = IsometricJob(timer, action);
    jobs.add(job);
  }

  void internalUpdateJobs() {
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      if (job.timer <= 0) continue;
      job.timer--;
      if (job.timer > 0) continue;
      job.action();
    }
  }

  void internalUpdateScripts() {
    for (final script in scripts) {
      if (script.timer <= 0) continue;
      script.timer--;
      if (script.timer > 0) continue;
      readGameScript(script.compile());
    }
  }

  void readGameScript(Uint8List script) {
    scriptReader.values = script;
    scriptReader.index = 0;
    final length = script.length;
    while (scriptReader.index < length) {
      switch (scriptReader.readUInt8()) {
        case IsometricScriptType.GameObject_Deactivate:
          final id = scriptReader.readUInt16();
          final instance = findGameObjectById(id);
          if (instance != null) {
            deactivateCollider(instance);
          }
          break;
        case IsometricScriptType.Spawn_GameObject:
          final type = scriptReader.readUInt16();
          final x = scriptReader.readUInt16();
          final y = scriptReader.readUInt16();
          final z = scriptReader.readUInt16();
          spawnGameObject(
            x: x.toDouble(),
            y: y.toDouble(),
            z: z.toDouble(),
            type: type,
          );
          break;
        case IsometricScriptType.Spawn_AI:
          final type = scriptReader.readUInt16();
          final x = scriptReader.readUInt16();
          final y = scriptReader.readUInt16();
          final z = scriptReader.readUInt16();
          final team = scriptReader.readUInt8();
          spawnAIXYZ(
            x: x.toDouble(),
            y: y.toDouble(),
            z: z.toDouble(),
            characterType: type,
            team: team,
          );
          break;
        default:
          return;
      }
    }
  }

  void updateColliderSceneCollisionHorizontal(IsometricCollider collider) {
    const Shifts = 5;
    final z = collider.z + Node_Height_Half;

    if (scene.getCollisionAt(collider.left, collider.y, z)) {
      if (collider.velocityX < 0) {
        collider.velocityX = -collider.velocityX;
      }
      for (var i = 0; i < Shifts; i++) {
        collider.x++;
        if (!scene.getCollisionAt(collider.left, collider.y, z)) break;
      }
    }
    if (scene.getCollisionAt(collider.right, collider.y, z)) {
      if (collider.velocityX > 0) {
        collider.velocityX = -collider.velocityX;
      }
      for (var i = 0; i < Shifts; i++) {
        collider.x--;
        if (!scene.getCollisionAt(collider.right, collider.y, z)) break;
      }
    }
    if (scene.getCollisionAt(collider.x, collider.top, z)) {
      if (collider.y < 0) {
        collider.velocityY = -collider.velocityY;
      }
      for (var i = 0; i < Shifts; i++) {
        collider.y++;
        if (!scene.getCollisionAt(collider.x, collider.top, z)) break;
      }
    }
    if (scene.getCollisionAt(collider.x, collider.bottom, z)) {
      if (collider.y > 0) {
        collider.velocityY = -collider.velocityY;
      }
      for (var i = 0; i < Shifts; i++) {
        collider.y--;
        if (!scene.getCollisionAt(collider.x, collider.bottom, z)) break;
      }
    }
  }

  void updateGameObjects() {
    var sortRequired = false;
    for (final gameObject in gameObjects) {
      if (!gameObject.active) {
        if (!gameObject.available) {
          gameObject.available = true;
        }
      } else {
        updateColliderPhysics(gameObject);
      }
      if (gameObject.positionDirty) {
        gameObject.dirty = true;
        sortRequired = true;
      }
      if (!gameObject.dirty) continue;
      gameObject.dirty = false;
      gameObject.synchronizePrevious();
      for (final player in players) {
        player.writeGameObject(gameObject);
      }
    }

    if (sortRequired) {
      IsometricPosition.sort(gameObjects);
    }
  }

  void updateColliderPhysics(IsometricCollider collider) {
    assert (collider.active);

    collider.updateVelocity();

    if (collider.z < 0) {
      if (collider is IsometricCharacter) {
        setCharacterStateDead(collider);
        return;
      }
      deactivateCollider(collider);
      return;
    }

    if (collider.physical && !collider.fixed) {
      updateColliderSceneCollision(collider);
    }
  }

  void createExplosion({
    required double x,
    required double y,
    required double z,
    required IsometricCharacter srcCharacter,
    double radius = 100.0,
    int damage = 25,
  }) {
    if (!scene.inboundsXYZ(x, y, z)) return;
    dispatch(GameEventType.Explosion, x, y, z);
    final length = characters.length;

    if (scene.inboundsXYZ(x, y, z - Node_Height_Half)) {
      dispatch(
        GameEventType.Node_Struck,
        x,
        y,
        z - Node_Height_Half,
      );
    }

    final gameObjectsLength = gameObjects.length;
    for (var i = 0; i < gameObjectsLength; i++) {
      final gameObject = gameObjects[i];
      if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;
      if (!gameObject.withinDistance(x, y, z, radius)) continue;
      applyHit(
        angle: radian(x1: x, y1: y, x2: gameObject.x, y2: gameObject.y),
        target: gameObject,
        srcCharacter: srcCharacter,
        damage: damage,
        friendlyFire: true,
        hitType: IsometricHitType.Explosion,
      );
    }

    for (var i = 0; i < length; i++) {
      final character = characters[i];
      if (!character.hitable) continue;
      if (!character.active) continue;
      if (character.dead) continue;
      if (!character.withinDistance(x, y, z, radius)) continue;
      applyHit(
        angle: radian(x1: x, y1: y, x2: character.x, y2: character.y),
        target: character,
        srcCharacter: srcCharacter,
        damage: damage,
        friendlyFire: true,
        hitType: IsometricHitType.Explosion,
      );
    }
  }

  void update() {
    if (players.length == 0) return;
    updateInProgress();

  }

  bool containsPlayerWithName(String name) {
    for (final character in players) {
      if (character.name == name) return true;
    }
    return false;
  }

  var _nextCharacterAnimationFrame = 0;

  void updateCharacterFrames() {
    _nextCharacterAnimationFrame++;
    if (_nextCharacterAnimationFrame < 6) return;
    _nextCharacterAnimationFrame = 0;
    for (final character in characters) {
      if (character.animationFrame++ > 6) {
        character.animationFrame = 0;
      }
    }
  }

  void revive(IsometricPlayer player) {
    if (player.aliveAndActive) return;

    player.setCharacterStateSpawning();
    activateCollider(player);
    player.health = player.maxHealth;
    player.energy = player.maxEnergy;
    player.score = 0;
    clearCharacterTarget(player);

    if (player.inventoryOpen) {
      player.interactMode = InteractMode.Inventory;
    }

    player.buffInvincible = false;
    player.buffDoubleDamage = false;

    customOnPlayerRevived(player);

    player.writePlayerMoved();
    player.writeApiPlayerSpawned();
    player.writePlayerAlive();
    player.writePlayerStats();
    player.writePlayerCredits();
    player.writeGameTime(time.time);
    player.health = player.maxHealth;
  }

  int countAlive(List<IsometricCharacter> characters) {
    var total = 0;
    for (final character in characters) {
      if (character.alive) total++;
    }
    return total;
  }

  void playersWriteWeather() {
    for (final player in players) {
      player.writeWeather();
      player.writeGameTime(time.time);
      player.writeEnvironmentLightningFlashing(environment.lightningFlashing);
    }
  }

  IsometricCharacter? getClosestEnemy({
    required double x,
    required double y,
    required IsometricCharacter character,
  }) {
    return findClosestVector3(
        positions: characters,
        x: x,
        y: y,
        z: character.z,
        where: (other) =>
        other.alive && !IsometricCollider.onSameTeam(other, character));
  }

  void applyDamageToCharacter({
    required IsometricCharacter src,
    required IsometricCharacter target,
    required int amount,
  }) {
    if (target.dead) return;
    if (target.buffInvincible) return;

    final damage = min(amount, target.health);
    target.health -= damage;

    if (target.health <= 0) {
      setCharacterStateDead(target);
      if (target is IsometricAI) {
        clearCharacterTarget(target);
        target.clearDest();
        target.clearPath();
      }
      customOnCharacterKilled(target, src);
      return;
    }
    customOnCharacterDamageApplied(target, src, damage);
    target.setCharacterStateHurt();
    dispatchGameEventCharacterHurt(target);

    if (target is IsometricAI) {
      onAIDamagedBy(target, src);
    }
  }

  /// Can be safely overridden to customize behavior
  void onAIDamagedBy(IsometricAI ai, dynamic src) {
    final targetAITarget = ai.target;
    if (targetAITarget == null) {
      ai.target = src;
      return;
    }
    final aiTargetDistance = distanceV2(ai, targetAITarget);
    final srcTargetDistance = distanceV2(src, ai);
    if (srcTargetDistance < aiTargetDistance) {
      ai.target = src;
    }
  }

  void dispatchGameEventCharacterHurt(IsometricCharacter character) {
    for (final player in players) {
      final targetVelocityAngle = character.velocityAngle;
      player.writeGameEvent(
        type: GameEventType.Character_Hurt,
        x: character.x,
        y: character.y,
        z: character.z,
        angle: targetVelocityAngle,
      );
      player.writeByte(character.characterType);
    }
  }

  void updateCharacters() {
    final characterLength = characters.length;
    for (var i = 0; i < characterLength; i++) {
      final character = characters[i];
      updateCharacter(character);
      if (character is IsometricPlayer) {
        updatePlayer(character);
        customUpdatePlayer(character);
      }
    }
  }

  void updateCollisions() {
    resolveCollisions(characters);
    resolveCollisionsBetween(characters, gameObjects);
    resolveCollisions(gameObjects);
  }

  void resolveCollisions(List<IsometricCollider> colliders) {
    final numberOfColliders = colliders.length;
    final numberOfCollidersMinusOne = numberOfColliders - 1;
    for (var i = 0; i < numberOfCollidersMinusOne; i++) {
      final colliderI = colliders[i];
      if (!colliderI.active) continue;
      // if (!colliderI.strikable) continue;
      for (var j = i + 1; j < numberOfColliders; j++) {
        final colliderJ = colliders[j];
        if (!colliderJ.active) continue;
        // if (!colliderJ.strikable) continue;
        if (colliderJ.top > colliderI.bottom) continue;
        if (colliderJ.left > colliderI.right) continue;
        if (colliderJ.right < colliderI.left) continue;
        if ((colliderJ.z - colliderI.z).abs() > Node_Height) continue;
        internalOnCollisionBetweenColliders(colliderJ, colliderI);
      }
    }
  }

  void resolveCollisionsBetween(List<IsometricCollider> collidersA,
      List<IsometricCollider> collidersB,) {
    final aLength = collidersA.length;
    final bLength = collidersB.length;
    for (var indexA = 0; indexA < aLength; indexA++) {
      final colliderA = collidersA[indexA];
      if (!colliderA.active) continue;
      for (var indexB = 0; indexB < bLength; indexB++) {
        final colliderB = collidersB[indexB];
        if (!colliderB.active) continue;
        // if (colliderA.order > colliderB.order) break;
        if (colliderA.bottom < colliderB.top) continue;
        if (colliderA.top > colliderB.bottom) continue;
        if (colliderA.right < colliderB.left) continue;
        if (colliderA.left > colliderB.right) continue;
        if ((colliderA.z - colliderB.z).abs() > Node_Height) continue;
        if (colliderA == colliderB) continue;
        internalOnCollisionBetweenColliders(colliderA, colliderB);
      }
    }
  }

  void internalOnCollisionBetweenColliders(IsometricCollider a, IsometricCollider b) {
    assert (a.active);
    assert (b.active);
    // assert (a.strikable);
    // assert (b.strikable);
    assert (a != b);
    if (a.physical && b.physical) {
      resolveCollisionPhysics(a, b);
    }

    if (a is IsometricPlayer) {
      if (b is IsometricGameObject) {
        customOnCollisionBetweenPlayerAndGameObject(a, b);
      }
      customOnCollisionBetweenPlayerAndOther(a, b);
    }
    if (b is IsometricPlayer) {
      if (a is IsometricGameObject) {
        customOnCollisionBetweenPlayerAndGameObject(b, a);
      }
      customOnCollisionBetweenPlayerAndOther(b, a);
    }
    customOnCollisionBetweenColliders(a, b);
  }

  void resolveCollisionPhysics(IsometricCollider a, IsometricCollider b) {
    resolveCollisionPhysicsRadial(a, b);
  }

  void resolveCollisionPhysicsRadial(IsometricCollider a, IsometricCollider b) {
    final combinedRadius = a.radius + b.radius;
    final totalDistance = getDistanceXY(a.x, a.y, b.x, b.y);
    final overlap = combinedRadius - totalDistance;
    if (overlap < 0) return;
    var xDiff = a.x - b.x;
    var yDiff = a.y - b.y;

    if (xDiff == 0 && yDiff == 0) {
      if (!a.fixed) {
        a.x += 5;
        xDiff += 5;
      }
      if (!b.fixed) {
        b.x -= 5;
        xDiff += 5;
      }
    }

    final ratio = 1.0 / getHypotenuse(xDiff, yDiff);
    final xDiffNormalized = xDiff * ratio;
    final yDiffNormalized = yDiff * ratio;
    final halfOverlap = overlap * 0.5;
    final targetX = xDiffNormalized * halfOverlap;
    final targetY = yDiffNormalized * halfOverlap;
    if (!a.fixed) {
      a.x += targetX;
      a.y += targetY;
    }
    if (!b.fixed) {
      b.x -= targetX;
      b.y -= targetY;
    }
  }

  void sortColliders() {
    IsometricPosition.sort(characters);
    IsometricPosition.sort(projectiles);
  }

  void setCharacterStateStunned(IsometricCharacter character,
      {int duration = Engine.Frames_Per_Second * 2}) {
    if (character.dead) return;
    if (character.buffInvincible) return;
    character.stateDurationRemaining = duration;
    character.state = CharacterState.Stunned;
    character.onCharacterStateChanged();
  }

  void setCharacterStateChanging(IsometricCharacter character) {
    if (!character.canChangeEquipment) return;
    character.assignWeaponStateChanging();
    dispatchV3(GameEventType.Character_Changing, character);
  }

  void setCharacterStateDead(IsometricCharacter character) {
    if (character.state == CharacterState.Dead) return;

    dispatchGameEventCharacterDeath(character);
    character.health = 0;
    character.state = CharacterState.Dead;
    character.stateDuration = 0;
    character.animationFrame = 0;
    deactivateCollider(character);
    clearCharacterTarget(character);

    if (character is IsometricPlayer) {
      character.interactMode = InteractMode.None;
      character.writePlayerAlive();
      customOnPlayerDead(character);
    }
  }

  void changeCharacterHealth(IsometricCharacter character, int amount) {
    if (character.dead) return;
    character.health += amount;
    if (character.health > 0) return;
    setCharacterStateDead(character);
  }

  void deactivateProjectile(IsometricProjectile projectile) {
    assert (projectile.active);
    switch (projectile.type) {
      case ProjectileType.Orb:
        dispatch(GameEventType.Blue_Orb_Deactivated, projectile.x, projectile.y,
            projectile.z);
        break;
      case ProjectileType.Rocket:
        final owner = projectile.owner;
        if (owner == null) return;
        createExplosion(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          srcCharacter: owner,
        );
        break;
      case ProjectileType.Bullet:
        dispatch(
          GameEventType.Bullet_Deactivated,
          projectile.x,
          projectile.y,
          projectile.z,
        );
        break;
      default:
        break;
    }
    projectile.active = false;
    projectile.owner = null;
    projectile.target = null;
  }

  void updateProjectiles() {
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      projectile.x += projectile.velocityX;
      projectile.y += projectile.velocityY;
      final target = projectile.target;
      if (target != null) {
        projectile.reduceDistanceZFrom(target);
      } else if (projectile.overRange) {
        deactivateProjectile(projectile);
      }
    }
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      if (!scene.getCollisionAt(projectile.x, projectile.y, projectile.z))
        continue;
      deactivateProjectile(projectile);

      final velocityAngle = projectile.velocityAngle;
      final nodeType = scene.getNodeTypeXYZ(
          projectile.x, projectile.y, projectile.z);

      if (!NodeType.isRainOrEmpty(nodeType)) {
        for (final player in players) {
          if (!player.onScreen(projectile.x, projectile.y)) continue;
          player.writeGameEvent(
            type: GameEventType.Node_Struck,
            x: projectile.x,
            y: projectile.y,
            z: projectile.z,
            angle: velocityAngle,
          );
        }
      }
    }

    checkProjectileCollision(characters);
    checkProjectileCollision(gameObjects);
  }

  void removeInstance(dynamic instance) {
    if (instance == null) return;

    if (instance is IsometricPlayer) {
      instance.aimTarget = null;
      players.remove(instance);
    }
    if (instance is IsometricCharacter) {
      characters.remove(instance);
      return;
    }
    if (instance is IsometricGameObject) {
      gameObjects.remove(instance);
      for (final player in players) {
        player.writeUInt8(ServerResponse.GameObject_Deleted);
        player.writeUInt16(instance.id);
      }
      return;
    }
    if (instance is IsometricProjectile) {
      projectiles.remove(instance);
      return;
    }
    throw Exception();
  }

  void updatePlayer(IsometricPlayer player) {
    player.framesSinceClientRequest++;

    if (player.respawnTimer > 0) {
      player.respawnTimer--;
    }

    if (player.dead) return;
    if (!player.active) return;

    if (player.energy < player.maxEnergy) {
      player.nextEnergyGain--;
      if (player.nextEnergyGain <= 0) {
        player.energy++;
        player.nextEnergyGain = player.energyGainRate;
      }
    }

    if (player.powerCooldown > 0) {
      player.powerCooldown--;
      if (player.powerCooldown == 0) {
        player.writePlayerPower();
      }
    }

    if (player.buffDuration > 0) {
      player.buffDuration--;
      if (player.buffDuration == 0) {
        switch (player.powerType) {
          case PowerType.Shield:
            player.buffInvincible = false;
            break;
          case PowerType.Invisible:
            player.buffInvisible = false;
            break;
        }
      }
    }


    if (player.idling && !player.weaponStateBusy) {
      final diff = Direction.getDifference(
          player.lookDirection, player.faceDirection);
      if (diff >= 2) {
        player.faceAngle += piQuarter;
      } else if (diff <= -3) {
        player.faceAngle -= piQuarter;
      }
    }

    final target = player.target;
    if (target == null) return;
    if (!player.busy) {
      player.face(target);
    }

    if (target is IsometricCollider) {
      if (target is IsometricGameObject) {
        if (!target.active) {
          clearCharacterTarget(player);
          return;
        }
        if (target.collectable || target.interactable) {
          // if (getDistanceBetweenV3(player, target) >
          if (player.getDistance3(target) >
              GameSettings.Interact_Radius) {
            setCharacterStateRunning(player);
            return;
          }
          if (target.interactable) {
            player.setCharacterStateIdle();
            customOnPlayerInteractWithGameObject(player, target);
            player.target = null;
            return;
          }
          if (target.collectable) {
            player.setCharacterStateIdle();
            customOnPlayerCollectGameObject(player, target);
            player.target = null;
            return;
          }
        }
      } else {
        if (!target.active || !target.hitable) {
          clearCharacterTarget(player);
          return;
        }
      }

      if (player.targetIsEnemy) {
        player.lookAt(target);
        if (player.withinAttackRange(target)) {
          if (!player.weaponStateBusy) {
            characterUseWeapon(player);
          }
          clearCharacterTarget(player);
          return;
        }
        setCharacterStateRunning(player);
        return;
      }

      if (target is IsometricAI && player.targetIsAlly) {
        if (player.withinRadius(target, 100)) {
          if (!target.deadOrBusy) {
            target.face(player);
          }
          final onInteractedWith = target.onInteractedWith;
          if (onInteractedWith != null) {
            player.interactMode = InteractMode.Talking;
            onInteractedWith(player);
          }
          clearCharacterTarget(player);
          player.setCharacterStateIdle();
          return;
        }
        setCharacterStateRunning(player);
        return;
      }
      return;
    }

    if (player.distanceFromPos2(target) <= player.velocitySpeed) {
      clearCharacterTarget(player);
      player.setCharacterStateIdle();
      return;
    }

    setCharacterStateRunning(player);
  }

  void setCharacterStateRunning(IsometricCharacter character) {
    character.setCharacterState(value: CharacterState.Running, duration: 0);
  }

  void checkProjectileCollision(List<IsometricCollider> colliders) {
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      if (!projectile.hitable) continue;
      final target = projectile.target;
      if (target != null) {
        if (projectile.withinRadius(target, projectile.radius)) {
          handleProjectileHit(projectile, target);
        }
        continue;
      }

      assert (target == null);
      for (var j = 0; j < colliders.length; j++) {
        final collider = colliders[j];
        if (!collider.active) continue;
        if (!collider.hitable) continue;
        final radius = collider.radius + projectile.radius;
        if ((collider.x - projectile.x).abs() > radius) continue;
        if ((collider.y - projectile.y).abs() > radius) continue;
        if (projectile.z + projectile.radius < collider.z) continue;
        if (projectile.z - projectile.radius > collider.z + Character_Height)
          continue;
        if (projectile.owner == collider) continue;
        if (IsometricCollider.onSameTeam(projectile, collider)) continue;
        handleProjectileHit(projectile, collider);
        break;
      }
    }
  }

  void handleProjectileHit(IsometricProjectile projectile, IsometricPosition target) {
    assert (projectile.active);
    assert (projectile != target);
    assert (projectile.owner != target);

    final owner = projectile.owner;
    if (owner == null) return;

    if (target is IsometricCollider) {
      applyHit(
        angle: projectile.velocityAngle,
        srcCharacter: owner,
        target: target,
        damage: projectile.damage,
        hitType: IsometricHitType.Projectile,
      );
    }

    deactivateProjectile(projectile);

    if (projectile.type == ProjectileType.Arrow) {
      dispatch(GameEventType.Arrow_Hit, target.x, target.y, target.z);
    }
    if (projectile.type == ProjectileType.Orb) {
      dispatch(
          GameEventType.Blue_Orb_Deactivated, target.x, target.y, target.z);
    }
  }

  void applyHit({
    required IsometricCharacter srcCharacter,
    required IsometricCollider target,
    required int damage,
    required double angle,
    required int hitType,
    double force = 20,
    bool friendlyFire = false,
  }) {
    if (!target.hitable) return;
    if (!target.active) return;

    target.applyForce(
      force: force,
      angle: angle,
    );

    target.clampVelocity(IsometricPhysics.Max_Velocity);

    customOnHitApplied(
      srcCharacter: srcCharacter,
      target: target,
      damage: damage,
      angle: angle,
      force: force,
      hitType: hitType,
    );

    if (target is IsometricGameObject) {
      if (ItemType.isMaterialMetal(target.type)) {
        dispatch(
            GameEventType.Material_Struck_Metal, target.x, target.y, target.z,
            angle);
      }
      if (target.destroyable) {
        destroyGameObject(target);
      }
    }

    // TODO Hack
    if (srcCharacter.characterTypeZombie) {
      dispatchV3(GameEventType.Zombie_Strike, srcCharacter);
    }
    if (target is IsometricCharacter) {
      if (!friendlyFire && IsometricCollider.onSameTeam(srcCharacter, target)) return;
      if (target.dead) return;
      applyDamageToCharacter(src: srcCharacter, target: target, amount: damage);
    }
  }

  void updateCharacterStatePerforming(IsometricCharacter character) {
    if (character.isTemplate) {
      if (!character.weaponStateBusy) {
        characterUseWeapon(character);
      }
      return;
    }
    const framePerformStrike = 10;
    if (character.stateDuration != framePerformStrike) return;

    dispatchAttackPerformed(
      character.weaponType,
      character.x + getAdjacent(character.faceAngle, 30),
      character.y + getOpposite(character.faceAngle, 30),
      character.z,
      character.faceAngle,
    );

    final attackTarget = character.target;
    if (attackTarget == null) return;
    if (attackTarget is IsometricCollider) {
      applyHit(
        target: attackTarget,
        angle: radiansV2(character, attackTarget),
        srcCharacter: character,
        damage: character.damage,
        hitType: IsometricHitType.Projectile,
      );
      clearCharacterTarget(character);
    }
  }

  void updateCharacter(IsometricCharacter character) {
    if (character.dead) return;
    if (!character.active) return;

    if (!character.isPlayer) {
      character.lookRadian = character.faceAngle;
    }

    character.updateAccuracy();

    if (character.weaponStateDuration > 0) {
      character.weaponStateDuration--;

      if (character.weaponStateDuration <= 0) {
        customOnCharacterWeaponStateReady(character);
        switch (character.weaponState) {
          case WeaponState.Firing:
            character.assignWeaponStateAiming();
            break;
          default:
            character.assignWeaponStateIdle();
            break;
        }
      }
    }

    if (character is IsometricAI) {
      character.updateAI();
      character.applyBehaviorWander(this);

      if (character.running) {
        final frontX = character.x +
            getAdjacent(character.faceAngle, Node_Size_Three_Quarters);
        final frontY = character.y +
            getAdjacent(character.faceAngle, Node_Size_Three_Quarters);
        final nodeTypeInFront = scene.getNodeTypeXYZ(
            frontX, frontY, character.z - Node_Height_Half);
        if (nodeTypeInFront == NodeType.Water) {
          character.setCharacterStateIdle();
        } else {
          final nodeOrientationInFrontAbove = scene.getNodeOrientationXYZ(
              frontX, frontY, character.z + Node_Height_Half);
          if (nodeOrientationInFrontAbove == NodeOrientation.Solid) {
            character.setCharacterStateIdle();
          }
        }
      }
    }
    updateColliderPhysics(character);
    updateCharacterState(character);
  }

  void faceCharacterTowards(IsometricCharacter character, Position position) {
    assert(!character.deadOrBusy);
    character.faceAngle = getAngleBetweenV3(character, position);
  }

  void updateCharacterState(IsometricCharacter character) {
    if (character.stateDurationRemaining > 0) {
      character.stateDurationRemaining--;
      if (character.stateDurationRemaining == 0) {
        return character.setCharacterStateIdle();
      }
    }
    switch (character.state) {
      case CharacterAction.Idle:
      // only do this if not struck or recovering
      // speed *= 0.75;
        break;
      case CharacterState.Running:
        character.applyForce(
            force: character.runSpeed, angle: character.faceAngle);
        if (character.nextFootstep++ >= 10) {
          dispatch(
            GameEventType.Footstep,
            character.x,
            character.y,
            character.z,
          );
          character.nextFootstep = 0;
          character.velocityZ += 1;
        }
        break;
      case CharacterState.Performing:
        updateCharacterStatePerforming(character);
        break;
      case CharacterState.Spawning:
        if (character.stateDurationRemaining == 1) {
          customOnCharacterSpawned(character);
        }
        if (character.stateDuration == 0 && character is IsometricPlayer) {
          // character.writePlayerEvent(PlayerEvent.Spawn_Started);
        }
        break;
    }
    character.stateDuration++;
  }

  void respawnAI(IsometricAI ai) {
    assert (ai.dead);
    final distance = randomBetween(0, 100);
    final angle = randomAngle();
    ai.x = ai.spawnX + getAdjacent(angle, distance);
    ai.y = ai.spawnY + getOpposite(angle, distance);
    ai.z = ai.spawnZ;
    ai.clearDest();
    clearCharacterTarget(ai);
    ai.clearPath();
    activateCollider(ai);
    ai.health = ai.maxHealth;
    ai.target = null;
    ai.setCharacterStateSpawning();
    customOnAIRespawned(ai);
  }

  IsometricProjectile spawnProjectileOrb({
    required IsometricCharacter src,
    required int damage,
    required double range,
  }) {
    dispatchV3(GameEventType.Blue_Orb_Fired, src);
    return spawnProjectile(
      src: src,
      accuracy: 0,
      range: range,
      target: src.target,
      projectileType: ProjectileType.Orb,
      angle: src.target != null ? null : (src is IsometricPlayer ? src
          .lookRadian : src.faceAngle),
      damage: damage,
    );
  }

  void spawnProjectileArrow({
    required IsometricCharacter src,
    required int damage,
    required double range,
    double accuracy = 0,
    IsometricPosition? target,
    double? angle,
  }) {
    assert (range > 0);
    assert (damage > 0);
    dispatch(GameEventType.Arrow_Fired, src.x, src.y, src.z);
    spawnProjectile(
      src: src,
      accuracy: accuracy,
      range: range,
      target: target,
      angle: target != null ? null : angle ?? src.faceAngle,
      projectileType: ProjectileType.Arrow,
      damage: damage,
    );
  }

  IsometricProjectile spawnProjectileFireball(IsometricCharacter src, {
    required int damage,
    required double range,
    double? angle,
  }) =>
      spawnProjectile(
        src: src,
        accuracy: 0,
        range: range,
        target: src.target,
        angle: angle,
        projectileType: ProjectileType.Fireball,
        damage: damage,
      );

  IsometricProjectile spawnProjectileRocket(IsometricCharacter src, {
    required int damage,
    required double range,
    double? angle,
  }) =>
      spawnProjectile(
        src: src,
        accuracy: 0,
        range: range,
        target: src.target,
        angle: angle,
        projectileType: ProjectileType.Rocket,
        damage: damage,
      );

  // Projectile spawnProjectileBullet({
  //   required Character src,
  //   required double speed,
  //   double accuracy = 0,
  // }) =>
  //   spawnProjectile(
  //     src: src,
  //     accuracy: 0,
  //     angle: src.faceAngle,
  //     range: src.weaponTypeRange,
  //     projectileType: ProjectileType.Bullet,
  //     damage: src.damage,
  //   );

  void characterSpawnProjectileFireball(IsometricCharacter character, {
    required double angle,
    double speed = 3.0,
    double range = 300,
    int damage = 5,
  }) {
    spawnProjectile(
      src: character,
      projectileType: ProjectileType.Fireball,
      accuracy: 0,
      // TODO delete accuracy
      angle: angle,
      range: range,
      damage: damage,
    );
  }

  void characterFireShotgun(IsometricCharacter src, double angle) {
    src.applyForce(
      force: 6.0,
      angle: angle + pi,
    );
    src.clampVelocity(IsometricPhysics.Max_Velocity);
    for (var i = 0; i < 5; i++) {
      spawnProjectile(
        src: src,
        accuracy: 0,
        angle: angle + giveOrTake(0.25),
        range: src.weaponTypeRange,
        projectileType: ProjectileType.Bullet,
        damage: src.damage,
      );
    }
    src.assignWeaponStateFiring();
    dispatchAttackPerformed(
      src.weaponType,
      src.x + getAdjacent(angle, 60),
      src.y + getOpposite(angle, 60),
      src.z + Character_Gun_Height,
      angle,
    );
  }

  IsometricProjectile spawnProjectile({
    required IsometricCharacter src,
    required double range,
    required int projectileType,
    required int damage,
    double accuracy = 0,
    double? angle = 0,
    IsometricPosition? target,
  }) {
    assert (range > 0);
    assert (damage > 0);
    final projectile = getInstanceProjectile();
    var finalAngle = angle;
    if (finalAngle == null) {
      if (target != null && target is IsometricCollider) {
        finalAngle = target.getAngle(src);
      } else {
        finalAngle = src is IsometricPlayer ? src.lookRadian : src.faceAngle;
      }
    }
    if (accuracy != 0) {
      const accuracyAngleDeviation = pi * 0.1;
      finalAngle += giveOrTake(accuracy * accuracyAngleDeviation);
    }
    projectile.damage = damage;
    projectile.hitable = true;
    projectile.active = true;
    if (target is IsometricCollider) {
      projectile.target = target;
    }
    // final r = 10.0 + (src.isTemplate ? ItemType.getWeaponLength(src.weaponType) : 0);
    final r = 5.0;
    projectile.x = src.x + getAdjacent(finalAngle, r);
    projectile.y = src.y + getOpposite(finalAngle, r);
    projectile.z = src.z + Character_Gun_Height;
    projectile.startX = projectile.x;
    projectile.startY = projectile.y;
    projectile.startZ = projectile.z;
    projectile.setVelocity(finalAngle, ProjectileType.getSpeed(projectileType));
    projectile.owner = src;
    projectile.range = range;
    projectile.type = projectileType;
    projectile.radius = ProjectileType.getRadius(projectileType);

    return projectile;
  }

  IsometricProjectile getInstanceProjectile() {
    for (final projectile in projectiles) {
      if (projectile.active) continue;
      return projectile;
    }

    final projectile = IsometricProjectile();
    projectiles.add(projectile);
    return projectile;
  }

  IsometricAI spawnAIXYZ({
    required double x,
    required double y,
    required double z,
    required int characterType,
    int health = 10,
    int damage = 1,
    int team = TeamType.Evil,
    double wanderRadius = 200,
  }) {
    if (!scene.inboundsXYZ(x, y, z)) throw Exception(
        'game.spawnAIXYZ() - out of bounds');

    final instance = IsometricAI(
      weaponType: ItemType.Empty,
      characterType: characterType,
      health: health,
      damage: damage,
      team: team,
      wanderRadius: wanderRadius,
    );
    instance.x = x;
    instance.y = y;
    instance.z = z;
    instance.clearDest();
    instance.clearPath();
    instance.spawnX = instance.x;
    instance.spawnY = instance.y;
    instance.spawnZ = instance.z;
    instance.setCharacterStateSpawning();
    characters.add(instance);
    instance.spawnNodeIndex = scene.getNodeIndexXYZ(x, y, z);
    customOnAIRespawned(instance);
    return instance;
  }

  IsometricAI spawnAI({
    required int nodeIndex,
    required int characterType,
    int health = 10,
    int damage = 1,
    int team = TeamType.Evil,
    double wanderRadius = 200,
  }) {
    if (nodeIndex < 0) throw Exception('nodeIndex < 0');
    if (nodeIndex >= scene.gridVolume) {
      throw Exception(
          'game.spawnZombieAtIndex($nodeIndex) \ni >= scene.gridVolume');
    }
    final instance = IsometricAI(
      weaponType: ItemType.Empty,
      characterType: characterType,
      health: health,
      damage: damage,
      team: team,
      wanderRadius: wanderRadius,
    );
    moveToIndex(instance, nodeIndex);
    instance.clearDest();
    instance.clearPath();
    instance.spawnX = instance.x;
    instance.spawnY = instance.y;
    instance.spawnZ = instance.z;
    characters.add(instance);
    instance.spawnNodeIndex = nodeIndex;
    customOnAIRespawned(instance);
    return instance;
  }

  void moveToIndex(IsometricPosition position, int index) {
    position.x = scene.convertNodeIndexToPositionX(index);
    position.y = scene.convertNodeIndexToPositionY(index);
    position.z = scene.convertNodeIndexToPositionZ(index);
  }

  IsometricGameObject spawnGameObjectAtIndex({required int index, required int type}) =>
      spawnGameObject(
        x: scene.convertNodeIndexToPositionX(index),
        y: scene.convertNodeIndexToPositionY(index),
        z: scene.convertNodeIndexToPositionZ(index),
        type: type,
      );

  void spawnGameObjectItemAtPosition({
    required IsometricPosition position,
    required int type,
    int quantity = 1,
  }) =>
      spawnGameObjectItem(
        x: position.x,
        y: position.y,
        z: position.z,
        type: type,
        quantity: quantity,
      );

  void spawnGameObjectItem({
    required double x,
    required double y,
    required double z,
    required int type,
    int quantity = 1,
  }) {
    assert (type != ItemType.Empty);
    assert (type != ItemType.Equipped_Legs);
    assert (type != ItemType.Equipped_Body);
    assert (type != ItemType.Equipped_Head);
    assert (type != ItemType.Equipped_Weapon);
    spawnGameObject(x: x, y: y, z: z, type: type)
      ..quantity = quantity;
  }

  IsometricGameObject spawnGameObjectAtPosition({
    required IsometricPosition position,
    required int type,
  }) =>
      spawnGameObject(
        x: position.x,
        y: position.y,
        z: position.z,
        type: type,
      );

  IsometricGameObject spawnGameObject({
    required double x,
    required double y,
    required double z,
    required int type,
  }) {
    for (final gameObject in gameObjects) {
      if (gameObject.active) continue;
      if (!gameObject.available) continue;
      gameObject.x = x;
      gameObject.y = y;
      gameObject.z = z;
      gameObject.startX = x;
      gameObject.startY = y;
      gameObject.startZ = z;
      gameObject.velocityX = 0;
      gameObject.velocityY = 0;
      gameObject.velocityZ = 0;
      gameObject.type = type;
      gameObject.active = true;
      gameObject.dirty = true;
      gameObject.friction = IsometricPhysics.Friction;
      gameObject.synchronizePrevious();
      customOnGameObjectSpawned(gameObject);
      return gameObject;
    }
    final instance = IsometricGameObject(
      x: x,
      y: y,
      z: z,
      type: type,
      id: gameObjectId++,
    );
    instance.type = type;
    instance.active = true;
    instance.dirty = true;
    gameObjects.add(instance);
    customOnGameObjectSpawned(instance);
    return instance;
  }

  /// GameEventType
  void dispatchV3(int type, IsometricPosition position, {double angle = 0}) {
    dispatch(type, position.x, position.y, position.z, angle);
  }

  /// GameEventType
  void dispatch(int type, double x, double y, double z, [double angle = 0]) {
    for (final player in players) {
      player.writeGameEvent(type: type,
          x: x,
          y: y,
          z: z,
          angle: angle);
    }
  }

  void dispatchPlayerAttackPerformed(IsometricPlayer player) =>
      dispatchAttackPerformed(
        player.weaponType,
        player.x,
        player.y,
        player.z,
        player.lookRadian,
      );

  void dispatchAttackPerformed(int attackType, double x, double y, double z,
      double angle) {
    for (final player in players) {
      if (!player.onScreen(x, y)) continue;
      player.writeGameEvent(
        type: GameEventType.Attack_Performed,
        x: x,
        y: y,
        z: z,
        angle: angle,
      );
      player.writeUInt16(attackType);
    }
  }

  void dispatchMeleeAttackPerformed(int attackType, double x, double y,
      double z, double angle) {
    for (final player in players) {
      if (!player.onScreen(x, y)) continue;
      player.writeGameEvent(
        type: GameEventType.Melee_Attack_Performed,
        x: x,
        y: y,
        z: z,
        angle: angle,
      );
      player.writeUInt16(attackType);
    }
  }

  void dispatchAttackTypeEquipped(int attackType, double x, double y, double z,
      double angle) {
    for (final player in players) {
      if (!player.onScreen(x, y)) continue;
      player.writeGameEvent(
        type: GameEventType.Weapon_Type_Equipped,
        x: x,
        y: y,
        z: z,
        angle: angle,
      );
      player.writeByte(attackType);
    }
  }

  void updateAITargets() {
    if (_timerUpdateAITargets-- > 0) return;

    _timerUpdateAITargets = 15;

    for (final character in characters) {
      if (!character.alive) continue;
      if (character is IsometricAI == false) continue;
      updateAITarget(character as IsometricAI);
    }
  }

  void updateAITarget(IsometricAI ai) {
    assert (ai.alive);
    var target = ai.target;

    final targetSet = target != null;

    if (targetSet && !ai.withinChaseRange(target)) {
      clearCharacterTarget(ai);
    }

    var closestDistanceX = ai.viewRange;
    var closestDistanceY = closestDistanceX;

    for (final character in characters) {
      if (!character.aliveAndActive) continue;
      if (IsometricCollider.onSameTeam(character, ai)) continue;
      if (character.buffInvisible) continue;
      final distanceX = (ai.x - character.x).abs();
      if (closestDistanceX < distanceX) continue;
      final distanceY = (ai.y - character.y).abs();
      if (closestDistanceY < distanceY) continue;

      closestDistanceX = distanceX;
      closestDistanceY = distanceY;
      ai.target = character;
    }
    target = ai.target;
    if (target == null) return;
    if (!targetSet) {
      dispatchGameEventAITargetAcquired(ai);
      // npcSetPathTo(ai, target);
    }
  }

  void dispatchGameEventAITargetAcquired(IsometricAI ai) {
    for (final player in players) {
      if (!player.onScreen(ai.x, ai.y)) continue;
      player.writeGameEvent(
        type: GameEventType.AI_Target_Acquired,
        x: ai.x,
        y: ai.y,
        z: ai.z,
        angle: 0,
      );
      player.writeByte(ai.characterType);
    }
  }

  void removePlayer(IsometricPlayer player) {
    if (!players.remove(player));
    characters.remove(player);
    customOnPlayerDisconnected(player);
  }

  void saveSceneToFileBytes() {
    assert(scene.name.isNotEmpty);
    writeSceneToFileBytes(scene);
  }

  void npcSetRandomDestination(IsometricAI ai, {int radius = 10}) {
    // final node = scene.getNodeByPosition(ai);
    // if (!node.open) return;
    // final minColumn = max(0, node.column - radius);
    // final maxColumn = min(scene.numberOfColumns, node.column + radius);
    // final minRow = max(0, node.row - radius);
    // final maxRow = min(scene.numberOfRows, node.row + radius);
    // final randomColumn = randomInt(minColumn, maxColumn);
    // final randomRow = randomInt(minRow, maxRow);
    // final randomTile = scene.nodes[randomRow][randomColumn];
    // npcSetPathToTileNode(ai, randomTile);
  }

  void npcSetPathTo(IsometricAI ai, IsometricPosition position) {
    // npcSetPathToTileNode(ai, scene.getNodeByPosition(position));
  }

  // void npcSetPathToTileNode(AI ai, Node node) {
  //   pathFindDestination = node;
  //   pathFindAI = ai;
  //   pathFindSearchID++;
  //   ai.pathIndex = -1;
  //   // scene.visitNodeFirst(scene.getNodeByPosition(ai));
  // }

  IsometricAI addNpc({
    required String name,
    required int row,
    required int column,
    required int z,
    required int weaponType,
    required int headType,
    required int armour,
    required int pants,
    required int team,
    Function(IsometricPlayer player)? onInteractedWith,
    int health = 10,
    double speed = 3.0,
    double wanderRadius = 0,
    int damage = 1,
  }) {
    final npc = IsometricAI(
      characterType: CharacterType.Template,
      name: name,
      onInteractedWith: onInteractedWith,
      x: 0,
      y: 0,
      z: 0,
      weaponType: weaponType,
      team: team,
      health: health,
      wanderRadius: wanderRadius,
      damage: damage,
    );
    npc.headType = headType;
    npc.bodyType = armour;
    npc.legsType = pants;
    setGridPosition(position: npc, z: z, row: row, column: column);
    npc.spawnX = npc.x;
    npc.spawnY = npc.y;
    npc.clearDest();
    characters.add(npc);
    return npc;
  }

  double angle2(double adjacent, double opposite) {
    if (adjacent > 0) {
      return pi2 - (atan2(adjacent, opposite) * -1);
    }
    return atan2(adjacent, opposite);
  }

  void playerDeleteEditorSelectedGameObject(IsometricPlayer player) {
    removeInstance(player.editorSelectedGameObject);
    playerDeselectEditorSelectedGameObject(player);
  }

  void playerDeselectEditorSelectedGameObject(IsometricPlayer player) {
    if (player.editorSelectedGameObject == null) return;
    player.editorSelectedGameObject = null;
    player.writePlayerEvent(PlayerEvent.GameObject_Deselected);
  }

  void updateColliderSceneCollision(IsometricCollider collider) {
    updateColliderSceneCollisionVertical(collider);
    updateColliderSceneCollisionHorizontal(collider);
  }

  void internalOnColliderEnteredWater(IsometricCollider collider) {
    deactivateCollider(collider);
    if (collider is IsometricCharacter) {
      setCharacterStateDead(collider);
    }
    dispatchV3(GameEventType.Splash, collider);
  }

  void updateColliderSceneCollisionVertical(IsometricCollider collider) {
    if (!scene.isInboundV3(collider)) {
      if (collider.z > -100) return;
      deactivateCollider(collider);
      if (collider is IsometricCharacter) {
        setCharacterStateDead(collider);
      }
      return;
    }

    final bottomZ = collider.z;
    final nodeBottomIndex = scene.getNodeIndexXYZ(
      collider.x,
      collider.y,
      bottomZ,
    );
    final nodeBottomOrientation = scene.nodeOrientations[nodeBottomIndex];
    final nodeBottomType = scene.nodeTypes[nodeBottomIndex];

    if (nodeBottomOrientation == NodeOrientation.Solid) {
      final nodeTop = ((bottomZ ~/ Node_Height) * Node_Height) + Node_Height;
      if (nodeTop - bottomZ > IsometricPhysics.Max_Vertical_Collision_Displacement)
        return;
      collider.z = nodeTop;
      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * IsometricPhysics.Bounce_Friction;
          dispatchV3(GameEventType.Item_Bounce, collider,
              angle: -collider.velocityZ);
        } else {
          collider.velocityZ = 0;
        }
      }
      return;
    }

    if (nodeBottomOrientation != NodeOrientation.None) {
      final percX = ((collider.x % Node_Size) / Node_Size);
      final percY = ((collider.y % Node_Size) / Node_Size);
      final nodeBottom = (bottomZ ~/ Node_Height) * Node_Height;
      final nodeTop = nodeBottom +
          (NodeOrientation.getGradient(nodeBottomOrientation, percX, percY) *
              Node_Height);
      if (nodeTop <= bottomZ) {
        return;
      }

      if (nodeTop - bottomZ > IsometricPhysics.Max_Vertical_Collision_Displacement)
        return;

      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * IsometricPhysics.Bounce_Friction;
          dispatchV3(GameEventType.Item_Bounce, collider,
              angle: -collider.velocityZ);
        } else {
          collider.velocityZ = 0;
          collider.z = nodeTop;
        }
      }
      return;
    } else {
      updateColliderSceneCollisionVertical2(collider);
    }

    if (nodeBottomType == NodeType.Water) {
      if (collider.z % Node_Height < Node_Height_Half) {
        internalOnColliderEnteredWater(collider);
      }
    }
    return;
  }

  void updateColliderSceneCollisionVertical2(IsometricCollider collider) {
    if (!scene.isInboundV3(collider)) {
      if (collider.z > -100) return;
      deactivateCollider(collider);
      if (collider is IsometricCharacter) {
        setCharacterStateDead(collider);
      }
      return;
    }

    final bottomZ = collider.z + 5;

    if (bottomZ >= scene.gridHeightLength) return;

    final nodeBottomIndex = scene.getNodeIndexXYZ(
      collider.x,
      collider.y,
      bottomZ,
    );
    final nodeBottomOrientation = scene.nodeOrientations[nodeBottomIndex];
    final nodeBottomType = scene.nodeTypes[nodeBottomIndex];

    if (nodeBottomOrientation == NodeOrientation.Solid) {
      final nodeTop = ((bottomZ ~/ Node_Height) * Node_Height) + Node_Height;
      if (nodeTop - bottomZ > IsometricPhysics.Max_Vertical_Collision_Displacement)
        return;
      collider.z = nodeTop;
      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * IsometricPhysics.Bounce_Friction;
          dispatchV3(GameEventType.Item_Bounce, collider,
              angle: -collider.velocityZ);
        } else {
          collider.velocityZ = 0;
        }
      }
      return;
    }

    if (nodeBottomOrientation != NodeOrientation.None) {
      final percX = ((collider.x % Node_Size) / Node_Size);
      final percY = ((collider.y % Node_Size) / Node_Size);
      final nodeBottom = (bottomZ ~/ Node_Height) * Node_Height;
      final nodeTop = nodeBottom +
          (NodeOrientation.getGradient(nodeBottomOrientation, percX, percY) *
              Node_Height);
      if (nodeTop <= bottomZ) {
        return;
      }

      if (nodeTop - bottomZ > IsometricPhysics.Max_Vertical_Collision_Displacement)
        return;

      collider.z = nodeTop;

      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * IsometricPhysics.Bounce_Friction;
          dispatchV3(GameEventType.Item_Bounce, collider,
              angle: -collider.velocityZ);
        } else {
          collider.velocityZ = 0;
        }
      }
      return;
    }

    if (nodeBottomType == NodeType.Water) {
      if (collider.z % Node_Height < Node_Height_Half) {
        internalOnColliderEnteredWater(collider);
      }
    }
  }

  void setNode({
    required int nodeIndex,
    required int nodeType,
    required int nodeOrientation,
  }) {
    assert (nodeIndex >= 0);

    if (nodeIndex >= scene.gridVolume) {
      throw Exception(
          "game.setNode(nodeIndex: $nodeIndex) - node index out of bounds");
    }
    if (
    nodeType == scene.nodeTypes[nodeIndex] &&
        nodeOrientation == scene.nodeOrientations[nodeIndex]
    ) return;

    if (!NodeType.supportsOrientation(nodeType, nodeOrientation)) {
      nodeOrientation = NodeType.getDefaultOrientation(nodeType);
    }
    // scene.dirty = true;
    scene.nodeOrientations[nodeIndex] = nodeOrientation;
    scene.nodeTypes[nodeIndex] = nodeType;
    for (final player in players) {
      player.writeNode(nodeIndex);
    }
  }

  void setCharacterTarget(IsometricCharacter character, IsometricPosition target) {
    if (character.target == target) return;
    character.target = target;
    if (character is IsometricPlayer) {
      character.endInteraction();
      character.writePlayerTargetCategory();
      character.writePlayerTargetPosition();
    }
  }

  void clearCharacterTarget(IsometricCharacter character) {
    if (character.target == null) return;
    character.target = null;
    character.setCharacterStateIdle();
    if (character is IsometricPlayer) {
      character.writePlayerTargetCategory();
    }
    if (character is IsometricAI) {
      character.clearDest();
      character.clearPath();
    }
  }

  static double getAngleBetweenV3(Position a, Position b) =>
      getAngle(a.x - b.x, a.y - b.y);

  void triggerSpawnPoints({int instances = 1}) {
    for (final index in scene.spawnPoints) {
      for (var i = 0; i < instances; i++) {
        customActionSpawnAIAtIndex(index);
      }
    }
  }

  /// safe to override
  /// spawn a new ai at the given index
  void customActionSpawnAIAtIndex(int index) {
    spawnAI(
      characterType: randomItem(const [
        CharacterType.Dog,
        CharacterType.Zombie,
        CharacterType.Template
      ]),
      nodeIndex: index,
      damage: 10,
      team: TeamType.Evil,
      health: 3,
    );
  }

  /// WARNING EXPENSIVE OPERATION
  void clearSpawnedAI() {
    for (var i = 0; i < characters.length; i++) {
      if (characters[i] is IsometricPlayer) continue;
      characters.removeAt(i);
      i--;
    }
  }

  /// FUNCTIONS
  static void setGridPosition(
      {required IsometricPosition position, required int z, required int row, required int column}) {
    position.x = row * Node_Size + Node_Size_Half;
    position.y = column * Node_Size + Node_Size_Half;
    position.z = z * Node_Size_Half;
  }

  static void setPositionZ(IsometricPosition position, int z) {
    position.z = z * Node_Size_Half;
  }

  static void setPositionColumn(IsometricPosition position, int column) {
    position.y = column * Node_Size + Node_Size_Half;
  }

  static void setPositionRow(IsometricPosition position, int row) {
    position.x = row * Node_Size + Node_Size_Half;
  }

  void playersDownloadScene() {
    for (final player in players) {
      player.downloadScene();
    }
  }

  void moveToRandomPlayerSpawnPoint(IsometricPosition value) {
    if (scene.spawnPointsPlayers.isEmpty) return;
    moveV3ToNodeIndex(value, randomItem(scene.spawnPointsPlayers));
  }

  void playersWriteGameStatus(int gameStatus) {
    playersWriteByte(ServerResponse.Game_Status);
    playersWriteByte(gameStatus);
  }

  void playersWriteByte(int byte) {
    for (final player in players) {
      player.writeByte(byte);
    }
  }

  bool sceneRaycastBetween(IsometricCollider a, IsometricCollider b) {
    // final distance = getDistanceBetweenV3(a, b);
    final distance = a.getDistance3(b);
    if (distance < Node_Size_Half) return false;
    final distanceX = (a.x - b.x).abs();
    final distanceY = (a.y - b.y).abs();
    final normalX = distanceX / distance;
    final normalY = distanceY / distance;
    final jumpX = normalX * Node_Size_Half;
    final jumpY = normalY * Node_Size_Half;
    final totalJumps = distance ~/ Node_Size_Half;
    var x = a.x;
    var y = a.y;
    var z = a.z + Character_Gun_Height;
    for (var i = 0; i < totalJumps; i++) {
      x += jumpX;
      y += jumpY;
      if (scene.getCollisionAt(x, y, z)) return true;
    }
    return false;
  }

  int getNodeIndexV3(IsometricPosition value) =>
      scene.getNodeIndex(value.indexZ, value.indexRow, value.indexColumn);

  int getNodeIndexXYZ(double x, double y, double z){
      return scene.getNodeIndexXYZ(x, y, z);
  }

  void customOnPlayerCollectGameObject(IsometricPlayer player,
      IsometricGameObject target) {

    var quantityRemaining = target.quantity > 0 ? target.quantity : 1;
    final maxQuantity = ItemType.getMaxQuantity(target.type);
    if (maxQuantity > 1) {
      for (var i = 0; i < player.inventory.length; i++) {
        if (player.inventory[i] != target.type) continue;
        if (player.inventoryQuantity[i] + quantityRemaining < maxQuantity) {
          player.inventoryQuantity[i] += quantityRemaining;
          player.inventoryDirty = true;
          deactivateCollider(target);
          player.writePlayerEventItemAcquired(target.type);
          clearCharacterTarget(player);
          return;
        }
        quantityRemaining -= maxQuantity - player.inventoryQuantity[i];
        player.inventoryQuantity[i] = maxQuantity;
        player.inventoryDirty = true;
      }
    }

    assert (quantityRemaining >= 0);
    if (quantityRemaining <= 0) return;

    final emptyInventoryIndex = player.getEmptyInventoryIndex();
    if (emptyInventoryIndex != null) {
      player.inventory[emptyInventoryIndex] = target.type;
      player.inventoryQuantity[emptyInventoryIndex] =
          min(quantityRemaining, maxQuantity);
      player.inventoryDirty = true;
      deactivateCollider(target);
      player.writePlayerEventItemAcquired(target.type);
      clearCharacterTarget(player);
    } else {
      clearCharacterTarget(player);
      player.writePlayerEventInventoryFull();
      return;
    }
    clearCharacterTarget(player);
    return;
  }

  void reset() {
    for (var i = 0; i < gameObjects.length; i++) {
      final gameObject = gameObjects[i];
      if (!gameObject.persistable) {
        gameObjects.removeAt(i);
        i--;
        continue;
      }
      gameObject.x = gameObject.startX;
      gameObject.y = gameObject.startY;
      gameObject.z = gameObject.startZ;
    }
  }

  /// Safe to override to provide custom logic
  int getPlayerWeaponDamage(IsometricPlayer player) =>
      const <int, int>{
        ItemType.Weapon_Ranged_Bow: 06,
        ItemType.Empty: 01,
        ItemType.Weapon_Ranged_Smg: 02,
        ItemType.Weapon_Ranged_Machine_Gun: 02,
        ItemType.Weapon_Ranged_Rifle: 04,
        ItemType.Weapon_Ranged_Sniper_Rifle: 12,
        ItemType.Weapon_Ranged_Musket: 04,
        ItemType.Weapon_Ranged_Bazooka: 10,
        ItemType.Weapon_Ranged_Flamethrower: 01,
        ItemType.Weapon_Ranged_Minigun: 01,
        ItemType.Weapon_Ranged_Handgun: 04,
        ItemType.Weapon_Ranged_Revolver: 06,
        ItemType.Weapon_Ranged_Desert_Eagle: 08,
        ItemType.Weapon_Ranged_Pistol: 07,
        ItemType.Weapon_Ranged_Plasma_Pistol: 05,
        ItemType.Weapon_Ranged_Plasma_Rifle: 02,
        ItemType.Weapon_Ranged_Shotgun: 04,
        ItemType.Weapon_Melee_Hammer: 03,
        ItemType.Weapon_Melee_Pickaxe: 05,
        ItemType.Weapon_Melee_Knife: 04,
        ItemType.Weapon_Melee_Crowbar: 05,
        ItemType.Weapon_Melee_Sword: 15,
        ItemType.Weapon_Melee_Axe: 04,
      } [player.weaponType] ?? 0;

  int getExperienceForLevel(int level) => (((level - 1) * (level - 1))) * 6;

  void writePlayerScoresAll() {
    for (final player in players) {
      player.writeApiPlayersAll();
    }
  }

  void destroyGameObject(IsometricGameObject gameObject) {
    if (!gameObject.active) return;
    dispatchGameEventGameObjectDestroyed(gameObject);
    deactivateCollider(gameObject);
    customOnGameObjectDestroyed(gameObject);
  }

  int getPlayerPowerTypeCooldownTotal(IsometricPlayer player) {
    if (player.perkType == PerkType.Power) {
      return Engine.Frames_Per_Second * 8;
    }
    return Engine.Frames_Per_Second * 10;
  }

  void deactivatePlayer(IsometricPlayer player) {
    if (!player.active) return;
    player.active = false;
    player.writePlayerEvent(PlayerEvent.Player_Deactivated);
  }

  T buildPlayer();

  @override
  T createPlayer() {
    final player = buildPlayer();
    player.sceneDownloaded = false;
    characters.add(player);
    customOnPlayerJoined(player);
    player.writePlayerAlive();
    return player;
  }
}