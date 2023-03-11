import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_server/src/classes/src/game_environment.dart';
import 'package:bleed_server/src/game_physics.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';
import '../../io/write_scene_to_file.dart';
import '../../maths/get_distance_between_v3.dart';
import 'game_time.dart';


abstract class Game {
  static final Cost_Map = <int, int>{ };

  final int gameType;
  var frame = 0;
  var _running = true;
  Scene scene;
  final players = <Player>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];
  final jobs = <GameJob>[];
  final scripts = <GameScript>[];
  final scriptReader = ByteReader();
  final GameOptions options;
  var _timerUpdateAITargets = 0;
  var gameObjectId = 0;
  var playerId = 0;


  GameEnvironment environment;
  GameTime time;

  bool get running => _running;

  set running(bool value){
    if (_running == value) return;
    _running = value;
    for (final player in players){
      player.writeGameProperties();
    }
  }

  GameScript performScript({required int timer}){
     for (final script in scripts) {
       if (script.timer > 0) continue;
       script.timer = timer;
       script.clear();
       return script;
     }
     final instance = GameScript();
     scripts.add(instance);
     instance.timer = timer;
     return instance;
  }

  /// In seconds
  void customInitPlayer(Player player) {}
  /// @override
  void customPlayerWrite(Player player){ }
  /// @override
  void customUpdatePlayer(Player player){ }
  /// @override
  void customOnPlayerInteractWithGameObject(Player player, GameObject gameObject){ }
  /// @override
  void customDownloadScene(Player player){ }
  /// @override
  void customUpdate() {}
  /// @override
  void customOnPlayerDisconnected(Player player) { }
  /// @override
  void customOnColliderDeactivated(Collider collider){ }
  /// @override
  void customOnColliderActivated(Collider collider){ }
  /// @override
  void customOnCharacterSpawned(Character character) { }
  /// @override
  void customOnCharacterKilled(Character target, dynamic src) { }
  /// @override
  void customOnCharacterDamageApplied(Character target, dynamic src, int amount) { }
  /// @override
  void customOnPlayerRevived(Player player) { }
  /// @override
  void customOnPlayerCreditsChanged(Player player){ }
  /// @override
  void customOnGameStarted() { }
  /// @override
  void customOnNpcObjectivesCompleted(Character npc) { }
  /// @override
  void customOnPlayerLevelGained(Player player) { }
  /// @override
  void customOnCollisionBetweenColliders(Collider a, Collider b) { }
  /// @override
  void customOnCollisionBetweenPlayerAndOther(Player player, Collider collider) { }
  /// @override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) { }
  /// @override
  void customOnAIRespawned(AI ai){  }
  /// @override
  void customOnPlayerWeaponChanged(Player player, int previousWeaponType, int newWeaponType){ }
  /// @override
  void customOnHitApplied({
    required Character srcCharacter,
    required Collider target,
    required int damage,
    required double angle,
    required int hitType,
    required double force,
  }) {}

  /// @override
  void customOnPlayerJoined(Player player) {}

  /// @override
  void customInit() { }
  /// @override
  void customOnGameObjectSpawned(GameObject gameObject){ }
  /// @override
  void customOnGameObjectDestroyed(GameObject gameObject) { }
  /// @override
  void customOnCharacterWeaponStateReady(Character character){ }

  /// @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    // default behavior is to respawn after a period however this can be safely overriden
    performJob(1000, (){
      setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
      );
    });
  }

  /// PROPERTIES
  List<GameObject> get gameObjects => scene.gameObjects;
  /// @override
  double get minAimTargetCursorDistance => 35;

  /// CONSTRUCTOR
  Game({
    required this.scene,
    required this.time,
    required this.environment,
    required this.gameType,
    required this.options,
  }) {
    engine.onGameCreated(this); /// TODO Illegal external scope reference
    gameObjectId = scene.gameObjects.length;
    customInit();

    for (final gameObject in gameObjects) {
      customOnGameObjectSpawned(gameObject);
    }
  }

  /// QUERIES

  GameObject? findGameObjectByType(int type){
    for (final gameObject in gameObjects){
       if (gameObject.type == type) return gameObject;
    }
    return null;
  }

  GameObject? findGameObjectById(int id){
    for (final gameObject in gameObjects){
       if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  /// ACTIONS

  void moveV3ToNodeIndex(Position3 vector3, int nodeIndex){
    vector3.x = scene.convertNodeIndexToPositionX(nodeIndex);
    vector3.y = scene.convertNodeIndexToPositionY(nodeIndex);
    vector3.z = scene.convertNodeIndexToPositionZ(nodeIndex);
  }

  void move(Position3 value, double angle, double distance){
    value.x += getAdjacent(angle, distance);
    value.y += getOpposite(angle, distance);
  }

  double getDistanceFromPlayerMouse(Player player, Position3 position) =>
     getDistanceV3(
         player.mouseGridX,
         player.mouseGridY,
         player.z,
         position.x,
         position.y,
         position.z,
     );

  void onPlayerUpdateRequestReceived({
    required Player player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keyShiftDown,
    required bool keySpaceDown,
    required double mouseX,
    required double mouseY,
    required double screenLeft,
    required double screenTop,
    required double screenRight,
    required double screenBottom,
  }) {
    player.framesSinceClientRequest = 0;
    player.screenLeft = screenLeft;
    player.screenTop = screenTop;
    player.screenRight = screenRight;
    player.screenBottom = screenBottom;
    player.mouse.x = mouseX;
    player.mouse.y = mouseY;

    if (player.deadOrBusy) return;

    playerUpdateAimTarget(player);

    if (!player.weaponStateBusy) {
      player.lookRadian = player.mouseAngle;
    }

    // switch (cursorAction) {
    //   case CursorAction.Set_Target:
    //     if (direction != Direction.None) {
    //       if (!player.weaponStateBusy){
    //         characterUseWeapon(player);
    //       }
    //     } else {
    //       final aimTarget = player.aimTarget;
    //       if (aimTarget == null){
    //         player.runToMouse();
    //       } else {
    //         setCharacterTarget(player, aimTarget);
    //       }
    //     }
    //     break;
    //   case CursorAction.Stationary_Attack_Cursor:
    //     if (!player.weaponStateBusy) {
    //       characterUseWeapon(player);
    //       // characterWeaponAim(player);
    //     }
    //     break;
    //   case CursorAction.Stationary_Attack_Auto:
    //     if (!player.weaponStateBusy){
    //       playerAutoAim(player);
    //       characterUseWeapon(player);
    //     }
    //     break;
    //   case CursorAction.Mouse_Left_Click:
    //       final aimTarget = player.aimTarget;
    //       if (aimTarget != null){
    //         if (aimTarget is GameObject && (aimTarget.collectable || aimTarget.interactable)){
    //           setCharacterTarget(player, aimTarget);
    //           break;
    //         }
    //         if (Collider.onSameTeam(player, aimTarget)){
    //           setCharacterTarget(player, aimTarget);
    //           break;
    //         }
    //       }
    //       characterUseWeapon(player);
    //     break;
    //   case CursorAction.Mouse_Right_Click:
    //     characterAttackMelee(player);
    //     break;
    //   case CursorAction.Key_Space:
    //     characterThrowGrenade(player);
    //     break;
    // }

    // if (cursorAction == CursorAction.Set_Target) {
    //   if (direction != Direction.None) {
    //     if (!player.weaponStateBusy){
    //       characterUseWeapon(player);
    //     }
    //   } else {
    //     final aimTarget = player.aimTarget;
    //     if (aimTarget == null){
    //       player.runToMouse();
    //     } else {
    //       setCharacterTarget(player, aimTarget);
    //     }
    //   }
    // }

    // if (cursorAction == CursorAction.Stationary_Attack_Cursor) {
    //   if (!player.weaponStateBusy) {
    //     characterUseWeapon(player);
    //     // characterWeaponAim(player);
    //   }
    // }

    // if (cursorAction == CursorAction.Stationary_Attack_Auto){
    //   if (!player.weaponStateBusy){
    //     playerAutoAim(player);
    //     characterUseWeapon(player);
    //   }
    // }

    // if (cursorAction == CursorAction.Throw_Grenade){
    //    characterThrowGrenade(player);
    // }

    playerRunInDirection(player, direction);
  }

  void changeGame(Player player, Game to){
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

  void playerUpdateAimTarget(Player player){
    var closestDistance = GameSettings.Pickup_Range_Squared;

    final mouseX = player.mouseGridX;
    final mouseY = player.mouseGridY;
    final mouseZ = player.z;

    Collider? closestCollider;

    for (final character in characters) {
      if (character.deadOrDying) continue;
      if ((mouseX - character.x).abs() > GameSettings.Pickup_Range) continue;
      if ((mouseY - character.y).abs() > GameSettings.Pickup_Range) continue;
      if ((mouseZ - character.z).abs() > GameSettings.Pickup_Range) continue;
      if (character == player) continue;
      final distance = getDistanceV3Squared(mouseX, mouseY, mouseZ, character.x, character.y, character.z);
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
      final distance = getDistanceV3Squared(mouseX, mouseY, mouseZ, gameObject.x, gameObject.y, gameObject.z);
      if (distance > closestDistance) continue;
      closestDistance = distance;
      closestCollider = gameObject;
    }

    player.aimTarget = closestCollider;
  }

  void playerRunInDirection(Player player, int direction) {
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
    ){
      return player.endInteraction();
    }
  }

  void characterWeaponAim(Character character) {
      character.weaponState = WeaponState.Aiming;
      character.weaponStateDurationTotal = 30;
  }

  void characterUseOrEquipWeapon({
    required Character character,
    required int weaponType,
    required bool characterStateChange,
  }){
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

  void playerEquipNextItemGroup(Player player, ItemGroup itemGroup){
     if (!player.canChangeEquipment) return;

     final equippedItemType = player.getEquippedItemGroupItem(itemGroup);

     if (equippedItemType == ItemType.Empty){
       playerEquipFirstItemTypeFromItemGroup(player, itemGroup);
       return;
     }

     final equippedWeaponItemGroup = ItemType.getItemGroup(player.weaponType);

     if (equippedWeaponItemGroup != itemGroup) {
        characterEquipItemType(player, player.getEquippedItemGroupItem(itemGroup));
        return;
     }

     final equippedItemIndex = player.getItemIndex(equippedItemType);
     assert (equippedItemType != -1);

     final itemEntries = player.item_level.entries.toList(growable: false);
     final itemEntriesLength = itemEntries.length;
     for (var i = equippedItemIndex + 1; i < itemEntriesLength; i++){
       final entry = itemEntries[i];
       if (entry.value <= 0) continue;
       final entryItemType = entry.key;
       final entryItemGroup = ItemType.getItemGroup(entryItemType);
       if (entryItemGroup != itemGroup) continue;
       characterEquipItemType(player, entryItemType);
       return;
     }

     for (var i = 0; i < equippedItemIndex; i++){
       final entry = itemEntries[i];
       if (entry.value <= 0) continue;
       final entryItemType = entry.key;
       final entryItemGroup = ItemType.getItemGroup(entryItemType);
       if (entryItemGroup != itemGroup) continue;
       characterEquipItemType(player, entryItemType);
       return;
     }
  }

  void playerEquipFirstItemTypeFromItemGroup(Player player, ItemGroup itemGroup){
    final itemEntries = player.item_level.entries.toList(growable: false);
    final itemEntriesLength = itemEntries.length;
    for (var i = 0 + 1; i < itemEntriesLength; i++){
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      characterEquipItemType(player, entryItemType);
      return;
    }
  }

  void characterEquipItemType(Character character, int itemType){
    if (!character.canChangeEquipment) return;

    if (options.items && character is Player){
      final itemAmount = character.item_level[itemType];
      if (itemAmount == null) return;
      if (itemAmount <= 0) return;
    }

    if (ItemType.isTypeWeapon(itemType)){
      characterEquipWeapon(
        character: character,
        weaponType: itemType,
        characterStateChange: true,
      );
      return;
    }

    if (ItemType.isTypeHead(itemType)){
      character.headType = itemType;
      setCharacterStateChanging(character);
      return;
    }

    if (ItemType.isTypeBody(itemType)){
      character.bodyType = itemType;
      setCharacterStateChanging(character);
      return;
    }

    if (ItemType.isTypeLegs(itemType)){
      character.legsType = itemType;
      setCharacterStateChanging(character);
      return;
    }

    throw Exception(
        "game.characterEquipItemType(${ItemType.getName(itemType)})"
    );
  }

  void characterEquipWeapon({
    required Character character,
    required int weaponType,
    required bool characterStateChange,
  }){
    if (!character.canChangeEquipment) return;
    if (character.weaponType == weaponType) return;
    character.weaponType = weaponType;
    if (characterStateChange){
      setCharacterStateChanging(character);
    }
  }

  void characterAimWeapon(Character character){
    if (character.deadBusyOrWeaponStateBusy && !character.weaponStateAiming) return;
    character.assignWeaponStateAiming();
  }

  void characterUseWeapon(Character character) {
    if (character.deadBusyOrWeaponStateBusy) return;

    final weaponType = character.weaponType;

    if (character is Player) {
      if (options.inventory) {
        final playerWeaponConsumeType = ItemType.getConsumeType(weaponType);

        if (playerWeaponConsumeType != ItemType.Empty) {
          final equippedWeaponQuantity = character.equippedWeaponQuantity;
          if (equippedWeaponQuantity == 0){
            playerReload(character);
            return;
          }
          character.inventorySetQuantityAtIndex(
            quantity: equippedWeaponQuantity - 1,
            index: character.equippedWeaponIndex,
          );
          if (character.weaponIsEquipped){
            character.writePlayerEquippedWeaponAmmunition();
          }
        }
      }

      if (options.items) {

        if (weaponType == ItemType.Empty){
          characterAttackMelee(character);
          return;
        }

        if (character.energy <= 0) {
          character.writeError('Insufficient Energy');
          return;
        }
        character.energy--;

        // final equippedQuantity = character.item_quantity[weaponType] ?? 0;
        // final nextQuantity = equippedQuantity - 1;
        // character.item_quantity[weaponType] = nextQuantity;
        // character.writePlayerWeaponQuantity();
        // if (character.buffInfiniteAmmo <= 0 && ItemType.isTypeWeaponFirearm(weaponType)){
        //   final equippedQuantity = character.item_quantity[weaponType] ?? 0;
        //
        //   if (equippedQuantity <= 0) {
        //     // character.writeError('No Ammo');
        //     if (character.weaponPrimary == weaponType){
        //       character.weaponPrimary = ItemType.Empty;
        //     }
        //     if (character.weaponSecondary == weaponType) {
        //       character.weaponSecondary = ItemType.Empty;
        //     }
        //     character.weaponType = ItemType.Empty;
        //     characterAttackMelee(character);
        //     return;
        //   }
        // }
      }

    } else if (character is AI){
      if (ItemType.isTypeWeaponFirearm(weaponType)){
        if (character.rounds <= 0){
          character.assignWeaponStateReloading();
          character.rounds = ItemType.getMaxQuantity(weaponType);
          return;
        }
        character.rounds--;
      }
    }

    if (weaponType == ItemType.Weapon_Thrown_Grenade){
      if (character is Player){
        playerThrowGrenade(character, damage: 10);
        return;
      }
      throw Exception('ai cannot throw grenades');
    }

    if (weaponType == ItemType.Weapon_Ranged_Flamethrower){
      if (character is Player){
        playerUseFlamethrower(character);
        return;
      }
      throw Exception('ai cannot use flamethrower');
    }

    if (weaponType == ItemType.Weapon_Ranged_Bazooka){
      if (character is Player){
        playerUseBazooka(character);
      }
      return;
    }

    if (weaponType == ItemType.Weapon_Ranged_Minigun){
      if (character is Player){
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
            damage: getItemTypeDamage(weaponType),
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
            damage: getItemTypeDamage(weaponType),
            range: ItemType.getRange(weaponType),
            angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        break;
    }
  }

  void playerReload(Player player) {
    final equippedWeaponAmmoType = player.equippedWeaponAmmunitionType;
    final totalAmmoRemaining = player.inventoryGetTotalQuantityOfItemType(equippedWeaponAmmoType);

    if (totalAmmoRemaining == 0) {
      player.writeError('No Ammunition');
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

  void playerThrowGrenade(Player player, {int damage = 10}) {
    if (player.deadBusyOrWeaponStateBusy) return;

    if (options.items){
      if (player.grenades <= 0) {
        player.writeError('No grenades left');
        return;
      }
      player.grenades--;
    }

    dispatchAttackPerformed(
      ItemType.Weapon_Thrown_Grenade,
      player.x + getAdjacent(player.lookRadian, 60),
      player.y + getOpposite(player.lookRadian, 60),
      player.z + Character_Gun_Height,
      player.lookRadian,
    );

    player.assignWeaponStateThrowing();


    final mouseDistance = getDistanceXY(player.x, player.y, player.mouseGridX, player.mouseGridY);
    final throwDistance = min(mouseDistance, GamePhysics.Max_Throw_Distance);
    final throwRatio = throwDistance / GamePhysics.Max_Throw_Distance;
    final velocity = GamePhysics.Max_Throw_Velocity * throwRatio;
    final velocityZ = GamePhysics.Max_Throw_Velocity_Z * throwRatio;

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
        ..strikable = true
        ..collectable = false
        ..interactable = false
        ..velocityZ = velocityZ
        ..owner = player
        ..damage = damage;

    performJob(GameSettings.Grenade_Cook_Duration, (){
      deactivateCollider(instance);
      final owner = instance.owner;
      if (owner == null) return;
      createExplosion(target: instance, srcCharacter: owner);
    });
  }

  void playerUseFlamethrower(Player player) {
    dispatchPlayerAttackPerformed(player);
    player.assignWeaponStateFiring();
    spawnProjectileFireball(player, damage: 3, range: player.weaponTypeRange);
  }

  void playerUseBazooka(Player player) {
    dispatchPlayerAttackPerformed(player);
    player.assignWeaponStateFiring();
    spawnProjectileRocket(player, damage: 3, range: player.weaponTypeRange);
  }

  void playerUseMinigun(Player player) {
    characterFireWeapon(player);
  }

  void positionToPlayerMouse(Position position, Player player){
    position.x = player.mouseGridX;
    position.y = player.mouseGridY;
  }

  void playerAutoAim(Player player) {
    if (player.deadOrBusy) return;
    var closestCharacterDistance = player.weaponTypeRange * 1.5;
    Character? closestCharacter = null;
    for (final character in characters) {
      if (character.deadOrDying) continue;
      if (Collider.onSameTeam(player, character)) continue;
      final distance = getDistanceBetweenV3(player, character);
      if (distance > closestCharacterDistance) continue;
      closestCharacter = character;
      closestCharacterDistance = distance;
    }
    if (closestCharacter != null) {
      player.lookAt(closestCharacter);
    }
  }

  void characterAttackMelee(Character character) {
    assert (character.active);
    assert (character.alive);
    assert (character.damage >= 0);

    if (character.deadBusyOrWeaponStateBusy) return;

    final angle = character.lookRadian;
    final attackRadius = ItemType.getMeleeAttackRadius(character.weaponType);

    if (attackRadius <= 0) {
      throw Exception('ItemType.getRange(${ItemType.getName(character.weaponType)})');
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

    Collider? nearest;
    var nearestDistance = 999.0;
    final areaOfEffect = ItemType.isMeleeAOE(character.weaponType);

    for (final other in characters) {
      if (!other.active) continue;
      if (!other.strikable) continue;
      if (Collider.onSameTeam(character, other)) continue;
      if (!other.withinDistance(
        performX,
        performY,
        performZ,
        attackRadiusHalf,
      )) continue;

      if (!areaOfEffect){
        final distance = getDistanceBetweenV3(character, other);
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
          hitType: HitType.Melee
      );
      attackHit = true;
    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.strikable) continue;
      if (!gameObject.withinDistance(
          performX,
          performY,
          performZ,
          attackRadiusHalf,
      )) continue;

      if (!areaOfEffect){
        final distance = getDistanceBetweenV3(character, gameObject);
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
        hitType: HitType.Melee
      );
      attackHit = true;
    }

    if (nearest != null) {
      applyHit(
          angle: radiansV2(character, nearest),
          target: nearest,
          damage: character.damage,
          srcCharacter: character,
          hitType: HitType.Melee);
    }

    if (!scene.isInboundXYZ(performX, performY, performZ)) return;
    final nodeIndex = scene.getNodeIndexXYZ(performX, performY, performZ);
    final nodeType = scene.nodeTypes[nodeIndex];

    if (!NodeType.isRainOrEmpty(nodeType)) {
      character.applyForce(
        force: 4.5,
        angle: angle + pi,
      );
      character.clampVelocity(GamePhysics.Max_Velocity);
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

    if (!attackHit){
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

  void destroyNode(int nodeIndex){
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


  bool characterMeleeAttackTargetInRange(Character character) {
    assert (character.active);
    assert (character.alive);
    assert (character.damage >= 0);

    if (character.deadBusyOrWeaponStateBusy) return false;

    final angle = character.lookRadian;
    final attackRadius = ItemType.getMeleeAttackRadius(character.weaponType);

    if (attackRadius <= 0) {
      throw Exception('ItemType.getRange(${ItemType.getName(character.weaponType)})');
    }

    final attackRadiusHalf = attackRadius * 0.5;
    final performX = character.x + getAdjacent(angle, attackRadiusHalf);
    final performY = character.y + getOpposite(angle, attackRadiusHalf);
    final performZ = character.z;

    for (final other in characters) {
      if (!other.active) continue;
      if (!other.strikable) continue;
      if (Collider.onSameTeam(character, other)) continue;
      if (other.withinDistance(
        performX,
        performY,
        performZ,
        attackRadiusHalf,
      )) return true;

    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.strikable) continue;
      if (gameObject.withinDistance(
          performX,
          performY,
          performZ,
          attackRadiusHalf,
      )) return true;
    }
    return false;
  }

  void characterFireWeapon(Character character){
    assert (!character.weaponStateBusy);
    final angle = (character is Player) ? character.lookRadian : character.faceAngle;

    if (character.weaponType == ItemType.Weapon_Ranged_Shotgun){
      characterFireShotgun(character, angle);
      return;
    }

    character.assignWeaponStateFiring();
    character.applyForce(
      force: 1.0,
      angle: angle + pi,
    );
    character.clampVelocity(GamePhysics.Max_Velocity);

    spawnProjectile(
      src: character,
      accuracy: character.accuracy,
      angle: angle,
      range: character.weaponTypeRange,
      projectileType: ProjectileType.Bullet,
      damage: character.damage,
    );

    if (character.buffDoubleDamage){
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

    if (character.buffDoubleDamage){
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

  void playerFaceMouse(Player player){
      player.faceXY(
          player.mouseGridX,
          player.mouseGridY,
      );
  }

  void activateCollider(Collider collider){
    if (collider.active) return;
    collider.active = true;
    if (collider is GameObject) {
      collider.dirty = true;
    }
    customOnColliderActivated(collider);
  }

  void onGridChanged() {
    scene.refreshGridMetrics();
    for (final player in players) {
      player.writeGrid();
    }
  }

  void deactivateCollider(Collider collider){
     if (!collider.active) return;
     collider.active = false;
     collider.velocityX = 0;
     collider.velocityY = 0;
     collider.velocityZ = 0;

     if (collider is GameObject){
       collider.dirty = true;
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

  void dispatchGameEventCharacterDeath(Character character){
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

  void dispatchGameEventGameObjectDestroyed(GameObject gameObject) {
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
    sortGameObjects();
  }

  void performJob(int timer, Function action){
    assert (timer > 0);
    for (final job in jobs) {
      if (job.timer > 0) continue;
      job.timer = timer;
      job.action = action;
      return;
    }
    final job = GameJob(timer, action);
    jobs.add(job);
  }

  void internalUpdateJobs() {
    for (var i = 0; i < jobs.length; i++){
      final job = jobs[i];
      if (job.timer <= 0) continue;
      job.timer--;
      if (job.timer > 0) continue;
      job.action();
    }
  }

  void internalUpdateScripts() {
    for (final script in scripts){
      if (script.timer <= 0) continue;
      script.timer--;
      if (script.timer > 0) continue;
      readGameScript(script.compile());
    }
  }

  void readGameScript(Uint8List script){
    scriptReader.values = script;
    scriptReader.index = 0;
    final length = script.length;
    while (scriptReader.index < length){
      switch (scriptReader.readUInt8()){
        case ScriptType.GameObject_Deactivate:
          final id = scriptReader.readUInt16();
          final instance = findGameObjectById(id);
          if (instance != null) {
            deactivateCollider(instance);
          }
          break;
        case ScriptType.Spawn_GameObject:
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
        case ScriptType.Spawn_AI:
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

  void updateColliderSceneCollisionHorizontal(Collider collider) {

    const Shifts = 5;
    final z = collider.z + Node_Height_Half;

    if (scene.getCollisionAt(collider.left, collider.y, z)) {
      if (collider.velocityX < 0) {
        collider.velocityX = -collider.velocityX;
      }
      for (var i = 0; i < Shifts; i++){
        collider.x++;
        if (!scene.getCollisionAt(collider.left, collider.y, z)) break;
      }

    }
    if (scene.getCollisionAt(collider.right, collider.y, z)) {
      if (collider.velocityX > 0){
        collider.velocityX = -collider.velocityX;
      }
      for (var i = 0; i < Shifts; i++){
        collider.x--;
        if (!scene.getCollisionAt(collider.right, collider.y, z)) break;
      }
    }
    if (scene.getCollisionAt(collider.x, collider.top, z)) {
      if (collider.y < 0){
        collider.velocityY = -collider.velocityY;
      }
      for (var i = 0; i < Shifts; i++){
        collider.y++;
        if (!scene.getCollisionAt(collider.x, collider.top, z)) break;
      }

    }
    if (scene.getCollisionAt(collider.x, collider.bottom, z)) {
      if (collider.y > 0){
        collider.velocityY = -collider.velocityY;
      }
      for (var i = 0; i < Shifts; i++){
        collider.y--;
        if (!scene.getCollisionAt(collider.x, collider.bottom, z)) break;
      }
    }
  }

  void updateGameObjects() {
    for (final gameObject in gameObjects) {
      updateColliderPhysics(gameObject);
      if (gameObject.positionDirty) {
        gameObject.dirty = true;
      }
      if (!gameObject.dirty) continue;
      gameObject.synchronizePrevious();
      for (final player in players) {
         player.writeGameObject(gameObject);
      }
      gameObject.dirty = false;
    }
  }

  void updateColliderPhysics(Collider collider) {
    if (!collider.active) return;

    collider.applyVelocity();
    collider.applyFriction();
    collider.applyGravity();

    if (collider.z < 0) {
      deactivateCollider(collider);
      return;
    }

    if (collider.physical && !collider.fixed) {
      updateColliderSceneCollision(collider);
    }
  }

  void createExplosion({
    required Position3 target,
    required Character srcCharacter,
    double radius = 100.0,
    int damage = 25,
  }){
    if (!scene.inboundsV3(target)) return;
    dispatchV3(GameEventType.Explosion, target);
    final length = characters.length;

    if (scene.inboundsXYZ(target.x, target.y, target.z - Node_Height_Half)) {
        dispatch(
            GameEventType.Node_Struck,
            target.x,
            target.y,
            target.z - Node_Height_Half,
        );
    }

    for (final gameObject in gameObjects) {
        if (!gameObject.active) continue;
        if (!gameObject.strikable) continue;
        if (!gameObject.withinRadius(target, radius)) continue;
        applyHit(
          angle: radiansV2(target, gameObject),
          target: gameObject,
          srcCharacter: srcCharacter,
          damage: damage,
          friendlyFire: true,
          hitType: HitType.Explosion,
        );
    }

    for (var i = 0; i < length; i++){
      final character = characters[i];
      if (!character.strikable) continue;
      if (!character.active) continue;
      if (character.dead) continue;
      if (!target.withinRadius(character, radius)) continue;
      applyHit(
          angle: radiansV2(target, character),
          target: character,
          srcCharacter: srcCharacter,
          damage: damage,
          friendlyFire: true,
          hitType: HitType.Explosion,
      );
    }
  }

  void updateStatus() {
    removeDisconnectedPlayers();
    if (players.length == 0) return;
    updateInProgress();

    for (var i = 0; i < players.length; i++){
      players[i].writeAndSendResponse();
    }
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
      if (character.animationFrame++ > 6){
        character.animationFrame = 0;
      }
    }
  }

  void revive(Player player) {
    activateCollider(player);
    player.setCharacterStateSpawning();
    player.health = player.maxHealth;
    player.energy = player.maxEnergy;
    clearCharacterTarget(player);

    if (player.inventoryOpen){
      player.interactMode = InteractMode.Inventory;
    }

    player.buffDoubleDamageTimer  = 0;
    player.buffNoRecoil           = 0;
    player.buffFast               = 0;
    player.buffInfiniteAmmo       = 0;
    player.buffInvincibleTimer    = 0;
    player.buffInvincible         = false;
    player.buffDoubleDamage       = false;
    player.writePlayerBuffs();

    customOnPlayerRevived(player);

    player.writePlayerMoved();
    player.writePlayerAlive();
    player.writePlayerStats();
    player.writePlayerCredits();
    player.writeGameTime(time.time);

    if (options.inventory) {
      player.writePlayerInventory();
    }
    if (options.items) {
      player.writePlayerItems();
      player.writePlayerWeapons();
    }

    player.health = player.maxHealth;

  }

  int countAlive(List<Character> characters) {
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

  Character? getClosestEnemy({
    required double x,
    required double y,
    required Character character,
  }) {
    return findClosestVector3(
        positions: characters,
        x: x,
        y: y,
        z: character.z,
        where: (other) => other.alive && !Collider.onSameTeam(other, character));
  }

  void applyDamageToCharacter({
    required Character src,
    required Character target,
    required int amount,
  }) {
    if (target.deadOrDying) return;
    if (target.buffInvincible) return;

    final damage = min(amount, target.health);
    target.health -= damage;

    if (target.health <= 0) {
      setCharacterStateDead(target);
      if (target is AI) {
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

    if (target is AI) {
      onAIDamagedBy(target, src);
    }
  }

  /// Can be safely overridden to customize behavior
  void onAIDamagedBy(AI ai, dynamic src){
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

  void dispatchGameEventCharacterHurt(Character character) {
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
    for (var i = 0; i < characters.length; i++) {
      final character = characters[i];
      updateCharacter(character);
      if (character is Player) {
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

  void resolveCollisions(List<Collider> colliders) {
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

  void resolveCollisionsBetween(
      List<Collider> collidersA,
      List<Collider> collidersB,
      ) {
    final aLength = collidersA.length;
    final bLength = collidersB.length;
    for (var indexA = 0; indexA < aLength; indexA++) {
      final colliderA = collidersA[indexA];
      if (!colliderA.active) continue;
      // if (!colliderA.strikable) continue;
      for (var indexB = 0; indexB < bLength; indexB++) {
        final colliderB = collidersB[indexB];
        if (!colliderB.active) continue;
        // if (!colliderB.strikable) continue;
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

  void internalOnCollisionBetweenColliders(Collider a, Collider b){
    assert (a.active);
    assert (b.active);
    // assert (a.strikable);
    // assert (b.strikable);
    assert (a != b);
    if (a.physical && b.physical){
      resolveCollisionPhysics(a, b);
    }

    if (a is Player) {
      if (b is GameObject) {
         customOnCollisionBetweenPlayerAndGameObject(a, b);
      }
      customOnCollisionBetweenPlayerAndOther(a, b);
    }
    if (b is Player) {
      if (a is GameObject) {
         customOnCollisionBetweenPlayerAndGameObject(b, a);
      }
      customOnCollisionBetweenPlayerAndOther(b, a);
    }
    customOnCollisionBetweenColliders(a, b);
  }

  void resolveCollisionPhysics(Collider a, Collider b) {
    resolveCollisionPhysicsRadial(a, b);
  }

  void resolveCollisionPhysicsRadial(Collider a, Collider b) {
    final combinedRadius = a.radius + b.radius;
    final totalDistance = getDistanceXY(a.x, a.y, b.x, b.y);
    final overlap = combinedRadius - totalDistance;
    if (overlap < 0) return;
    var xDiff = a.x - b.x;
    var yDiff = a.y - b.y;

    if (xDiff == 0 && yDiff == 0) {
      if (!a.fixed){
        a.x += 5;
        xDiff += 5;
      }
      if (!b.fixed){
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
    if (!a.fixed){
      a.x += targetX;
      a.y += targetY;
    }
    if (!b.fixed){
      b.x -= targetX;
      b.y -= targetY;
    }
  }


  void sortGameObjects() {
    Position3.sort(characters);
    Position3.sort(projectiles);
    // Position3.sort(gameObjects);
  }

  void setCharacterStateDying(Character character) {
    if (character.deadOrDying) return;
    character.health = 0;
    character.state = CharacterState.Dying;
    character.stateDurationRemaining = 10;
    character.onCharacterStateChanged();

    for (final character in characters) {
      if (character.target != character) continue;
      clearCharacterTarget(character);
    }

    for (final projectile in projectiles) {
      if (projectile.target != character) continue;
      projectile.target = null;
    }

    for (final player in players) {
      if (player.aimTarget != character) continue;
      player.aimTarget = null;
    }
  }

  void setCharacterStateChanging(Character character){
    if (!character.canChangeEquipment) return;
    character.assignWeaponStateChanging();
    dispatchV3(GameEventType.Character_Changing, character);
  }

  void setCharacterStateDead(Character character) {
    if (character.state == CharacterState.Dead) return;

    dispatchGameEventCharacterDeath(character);
    character.health = 0;
    character.state = CharacterState.Dead;
    character.stateDuration = 0;
    character.animationFrame = 0;
    deactivateCollider(character);
    clearCharacterTarget(character);

    if (character is Player) {
       character.interactMode = InteractMode.None;
       character.writePlayerAlive();
    }
  }

  void changeCharacterHealth(Character character, int amount) {
    if (character.deadOrDying) return;
    character.health += amount;
    if (character.health > 0) return;
    setCharacterStateDying(character);
  }

  void deactivateProjectile(Projectile projectile) {
    assert (projectile.active);
    switch (projectile.type) {
      case ProjectileType.Orb:
        dispatch(GameEventType.Blue_Orb_Deactivated, projectile.x, projectile.y,
            projectile.z);
        break;
      case ProjectileType.Rocket:
        final owner = projectile.owner;
        if (owner == null) return;
        createExplosion(target: projectile, srcCharacter: owner);
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
      if (!scene.getCollisionAt(projectile.x, projectile.y, projectile.z)) continue;
      deactivateProjectile(projectile);

      final velocityAngle = projectile.velocityAngle;
      final nodeType = scene.getNodeTypeXYZ(projectile.x, projectile.y, projectile.z);

      if (!NodeType.isRainOrEmpty(nodeType)){
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

    if (instance is Player) {
      instance.aimTarget = null;
      players.remove(instance);
    }
    if (instance is Character) {
      characters.remove(instance);
      return;
    }
    if (instance is GameObject) {
      gameObjects.remove(instance);
      for (final player in players) {
        player.writeUInt8(ServerResponse.GameObject_Deleted);
        player.writeUInt16(instance.id);
      }
      return;
    }
    if (instance is Projectile) {
      projectiles.remove(instance);
      return;
    }
    throw Exception();
  }

  void updatePlayer(Player player) {
    player.framesSinceClientRequest++;

    if (player.textDuration > 0) {
      player.textDuration--;
      if (player.textDuration == 0) {
        player.text = "";
      }
    }

    if (player.deadOrDying) return;

    if (player.energy < player.maxEnergy) {
      player.nextEnergyGain--;
      if (player.nextEnergyGain <= 0){
        player.energy++;
        player.nextEnergyGain = player.energyGainRate;
      }
    }


    if (player.idling && !player.weaponStateBusy){
      final diff = Direction.getDifference(player.lookDirection, player.faceDirection);
      if (diff >= 2){
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

    if (target is Collider) {
      if (target is GameObject) {
        if (!target.active) {
           clearCharacterTarget(player);
           return;
        }
        if (target.collectable || target.interactable) {
           if (getDistanceBetweenV3(player, target) > GameSettings.Interact_Radius) {
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
        if (!target.active || !target.strikable) {
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

      if (target is AI && player.targetIsAlly) {
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

  void setCharacterStateRunning(Character character){
    character.setCharacterState(value: CharacterState.Running, duration: 0);
  }

  void checkProjectileCollision(List<Collider> colliders) {
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      if (!projectile.strikable) continue;
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
        if (!collider.strikable) continue;
        final radius = collider.radius + projectile.radius;
        if ((collider.x - projectile.x).abs() > radius) continue;
        if ((collider.y - projectile.y).abs() > radius) continue;
        if (projectile.z + projectile.radius < collider.z) continue;
        if (projectile.z - projectile.radius > collider.z + Character_Height) continue;
        if (projectile.owner == collider) continue;
        if (Collider.onSameTeam(projectile, collider)) continue;
        handleProjectileHit(projectile, collider);
        break;
      }
    }
  }

  void handleProjectileHit(Projectile projectile, Position3 target) {
    assert (projectile.active);
    assert (projectile != target);
    assert (projectile.owner != target);

    final owner = projectile.owner;
    if (owner == null) return;

    if (target is Collider) {
      applyHit(
        angle: projectile.velocityAngle,
        srcCharacter: owner,
        target: target,
        damage: projectile.damage,
        hitType: HitType.Projectile,
      );
    }

    deactivateProjectile(projectile);

    if (projectile.type == ProjectileType.Arrow) {
      dispatch(GameEventType.Arrow_Hit, target.x, target.y, target.z);
    }
    if (projectile.type == ProjectileType.Orb) {
      dispatch(GameEventType.Blue_Orb_Deactivated, target.x, target.y, target.z);
    }
  }

  void applyHit({
    required Character srcCharacter,
    required Collider target,
    required int damage,
    required double angle,
    required int hitType,
    double force = 20,
    bool friendlyFire = false,
  }) {
    // assert (target.active);
    if (!target.strikable) return;
    if (!target.active) return;

    target.applyForce(
      force: force,
      angle: angle,
    );

    target.clampVelocity(GamePhysics.Max_Velocity);

    customOnHitApplied(
        srcCharacter: srcCharacter,
        target: target,
        damage: damage,
        angle: angle,
        force: force,
        hitType: hitType,
    );

    if (target is GameObject){
      if (ItemType.isMaterialMetal(target.type)){
        dispatch(GameEventType.Material_Struck_Metal, target.x, target.y, target.z, angle);
      }
      if (target.destroyable) {
         deactivateCollider(target);
         customOnGameObjectDestroyed(target);
      }
    }

    // TODO Hack
    if (srcCharacter.characterTypeZombie) {
      dispatchV3(GameEventType.Zombie_Strike, srcCharacter);
    }
    if (target is Character) {
      if (!friendlyFire && Collider.onSameTeam(srcCharacter, target)) return;
      if (target.deadOrDying) return;
      applyDamageToCharacter(src: srcCharacter, target: target, amount: damage);
    }
  }
  
  void updateCharacterStatePerforming(Character character) {
    if (character.isTemplate) {
      if (!character.weaponStateBusy){
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
    if (attackTarget is Collider) {
      applyHit(
        target: attackTarget,
        angle: radiansV2(character, attackTarget),
        srcCharacter: character,
        damage: character.damage,
        hitType: HitType.Projectile,
      );
      clearCharacterTarget(character);
    }
  }

  void updateCharacter(Character character) {
    if (character.dead) return;
    if (!character.active) return;

    if (!character.isPlayer) {
      character.lookRadian = character.faceAngle;
    }

    character.updateAccuracy();

    if (character.weaponStateDuration > 0) {
      character.weaponStateDuration--;

      if (character.weaponStateDuration <= 0){
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

    if (character is AI){
      character.updateAI();
      character.applyBehaviorWander(this);

      if (character.running){
        final frontX = character.x + getAdjacent(character.faceAngle, Node_Size_Three_Quarters);
        final frontY = character.y + getAdjacent(character.faceAngle, Node_Size_Three_Quarters);
        final nodeTypeInFront = scene.getNodeTypeXYZ(frontX, frontY, character.z - Node_Height_Half);
        if (nodeTypeInFront == NodeType.Water){
           character.setCharacterStateIdle();
        } else {
          final nodeOrientationInFrontAbove = scene.getNodeOrientationXYZ(frontX, frontY,  character.z + Node_Height_Half);
          if (nodeOrientationInFrontAbove == NodeOrientation.Solid){
            character.setCharacterStateIdle();
          }
        }
      }
    }
    updateColliderPhysics(character);

    if (character.dying){
      if (character.stateDurationRemaining-- <= 0){
        setCharacterStateDead(character);
      }
      return;
    }

    updateCharacterState(character);
  }

  void faceCharacterTowards(Character character, Position position){
    assert(!character.deadOrBusy);
    character.faceAngle = getAngleBetweenV3(character, position);
  }

  void updateCharacterState(Character character){
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
        character.applyForce(force: character.runSpeed, angle: character.faceAngle);
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
        if (character.stateDurationRemaining == 1){
          customOnCharacterSpawned(character);
        }
        if (character.stateDuration == 0 && character is Player) {
          // character.writePlayerEvent(PlayerEvent.Spawn_Started);
        }
        break;
    }
    character.stateDuration++;
  }

  void respawnAI(AI ai){
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

  Projectile spawnProjectileOrb({
    required Character src,
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
      angle: src.target != null ? null : (src is Player ? src.lookRadian : src.faceAngle),
      damage: damage,
    );
  }

  void spawnProjectileArrow({
    required Character src,
    required int damage,
    required double range,
    double accuracy = 0,
    Position3? target,
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

  Projectile spawnProjectileFireball(
      Character src, {
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

  Projectile spawnProjectileRocket(
      Character src, {
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

  void characterSpawnProjectileFireball(Character character, {
    required double angle,
    double speed = 3.0,
    double range = 300,
    int damage = 5,
  }) {
    spawnProjectile(
      src: character,
      projectileType: ProjectileType.Fireball,
      accuracy: 0, // TODO delete accuracy
      angle: angle,
      range: range,
      damage: damage,
    );
  }

  void characterFireShotgun(Character src, double angle) {
    src.applyForce(
      force: 6.0,
      angle: angle + pi,
    );
    src.clampVelocity(GamePhysics.Max_Velocity);
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

  Projectile spawnProjectile({
    required Character src,
    required double range,
    required int projectileType,
    required int damage,
    double accuracy = 0,
    double? angle = 0,
    Position3? target,
  }) {
    assert (range > 0);
    assert (damage > 0);
    final projectile = getInstanceProjectile();
    var finalAngle = angle;
    if (finalAngle == null) {
      if (target != null && target is Collider) {
        finalAngle = target.getAngle(src);
      } else {
        finalAngle = src is Player ? src.lookRadian : src.faceAngle;
      }
    }
    if (accuracy != 0) {
      const accuracyAngleDeviation = pi * 0.1;
      finalAngle += giveOrTake(accuracy * accuracyAngleDeviation);
    }
    projectile.damage = damage;
    projectile.strikable = true;
    projectile.active = true;
    if (target is Collider) {
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

  Projectile getInstanceProjectile() {
    for (final projectile in projectiles){
       if (projectile.active) continue;
       return projectile;
    }

    final projectile = Projectile();
    projectiles.add(projectile);
    return projectile;
  }

  AI spawnAIXYZ({
    required double x,
    required double y,
    required double z,
    required int characterType,
    int health = 10,
    int damage = 1,
    int team = TeamType.Evil,
    double wanderRadius = 200,
  }) {
    if (!scene.inboundsXYZ(x, y, z)) throw Exception('game.spawnAIXYZ() - out of bounds');

    final instance = AI(
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

  AI spawnAI({
    required int nodeIndex,
    required int characterType,
    int health = 10,
    int damage = 1,
    int team = TeamType.Evil,
    double wanderRadius = 200,
  }) {
    if (nodeIndex < 0) throw Exception('nodeIndex < 0');
    if (nodeIndex >= scene.gridVolume) {
      throw Exception('game.spawnZombieAtIndex($nodeIndex) \ni >= scene.gridVolume');
    }
    final instance = AI(
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

  void moveToIndex(Position3 position, int index){
    position.x = scene.convertNodeIndexToPositionX(index);
    position.y = scene.convertNodeIndexToPositionY(index);
    position.z = scene.convertNodeIndexToPositionZ(index);
  }

  GameObject spawnGameObjectAtIndex({required int index, required int type}) =>
      spawnGameObject(
        x: scene.convertNodeIndexToPositionX(index),
        y: scene.convertNodeIndexToPositionY(index),
        z: scene.convertNodeIndexToPositionZ(index),
        type: type,
    );

  void spawnGameObjectItemAtPosition({
    required Position3 position,
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
  }){
    assert (type != ItemType.Empty);
    assert (type != ItemType.Equipped_Legs);
    assert (type != ItemType.Equipped_Body);
    assert (type != ItemType.Equipped_Head);
    assert (type != ItemType.Equipped_Weapon);
    spawnGameObject(x: x, y: y, z: z, type: type)
      ..quantity = quantity;
  }

  GameObject spawnGameObjectAtPosition({
    required Position3 position,
    required int type,
  }) => spawnGameObject(
          x: position.x,
          y: position.y,
          z: position.z,
          type: type,
      );

  GameObject spawnGameObject({
    required double x,
    required double y,
    required double z,
    required int type,
  }){
    for (final gameObject in gameObjects) {
       if (gameObject.active) continue;
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
       gameObject.friction = GamePhysics.Friction;
       gameObject.synchronizePrevious();
       customOnGameObjectSpawned(gameObject);
       return gameObject;
    }
    final instance = GameObject(
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
  void dispatchV3(int type, Position3 position, {double angle = 0}) {
    dispatch(type, position.x, position.y, position.z, angle);
  }

  /// GameEventType
  void dispatch(int type, double x, double y, double z, [double angle = 0]) {
    for (final player in players) {
      player.writeGameEvent(type: type, x: x, y: y, z: z, angle: angle);
    }
  }

  void dispatchPlayerAttackPerformed(Player player) =>
      dispatchAttackPerformed(
          player.weaponType,
          player.x,
          player.y,
          player.z,
          player.lookRadian,
      );

  void dispatchAttackPerformed(int attackType, double x, double y, double z, double angle){
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

  void dispatchMeleeAttackPerformed(int attackType, double x, double y, double z, double angle){
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

  void dispatchAttackTypeEquipped(int attackType, double x, double y, double z, double angle){
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
      if (character is AI == false) continue;
      updateAITarget(character as AI);
    }
  }

  void updateAITarget(AI ai){
    assert (ai.alive);
    var target = ai.target;

    final targetSet = target != null;

    if (targetSet && !ai.withinChaseRange(target)) {
      clearCharacterTarget(ai);
    }

    var targetDistanceX = 9999.0;
    var targetDistanceY = 9999.0;

    for (final other in characters) {
      if (!other.alive) continue;
      if (Collider.onSameTeam(other, ai)) continue;
      final npcDistanceX = (ai.x - other.x).abs();
      if (targetDistanceX < npcDistanceX) continue;
      if (npcDistanceX > ai.viewRange) continue;
      final npcDistanceY = (ai.y - other.y).abs();
      if (targetDistanceY < npcDistanceY) continue;
      if (npcDistanceY > ai.viewRange) continue;
      // if (sceneRaycastBetween(ai, other)) continue;

      targetDistanceX = npcDistanceX;
      targetDistanceY = npcDistanceY;
      ai.target = other;
    }
    target = ai.target;
    if (target == null) return;
    if (!targetSet){
      dispatchGameEventAITargetAcquired(ai);
      npcSetPathTo(ai, target);
    }
  }

  void dispatchGameEventAITargetAcquired(AI ai){
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

  void removeDisconnectedPlayers() {
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.framesSinceClientRequest++ < 300) continue;
      if (!removePlayer(player)) continue;
      i--;
      playerLength--;
    }
  }

  bool removePlayer(Player player) {
    if (!players.remove(player)) return false;
    characters.remove(player);
    customOnPlayerDisconnected(player);
    return true;
  }

  // void saveSceneToFile() {
  //   assert(scene.name.isNotEmpty);
  //   writeSceneToFileJson(scene);
  // }

  void saveSceneToFileBytes(){
    assert(scene.name.isNotEmpty);
    writeSceneToFileBytes(scene);
  }

  void npcSetRandomDestination(AI ai, {int radius = 10}) {
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

  void npcSetPathTo(AI ai, Position3 position) {
    // npcSetPathToTileNode(ai, scene.getNodeByPosition(position));
  }

  // void npcSetPathToTileNode(AI ai, Node node) {
  //   pathFindDestination = node;
  //   pathFindAI = ai;
  //   pathFindSearchID++;
  //   ai.pathIndex = -1;
  //   // scene.visitNodeFirst(scene.getNodeByPosition(ai));
  // }

  AI addNpc({
    required String name,
    required int row,
    required int column,
    required int z,
    required int weaponType,
    required int headType,
    required int armour,
    required int pants,
    required int team,
    Function(Player player)? onInteractedWith,
    int health = 10,
    double speed = 3.0,
    double wanderRadius = 0,
    int damage = 1,
  }) {
    final npc = AI(
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

  void playerDeleteEditorSelectedGameObject(Player player){
    removeInstance(player.editorSelectedGameObject);
    playerDeselectEditorSelectedGameObject(player);
  }

  void playerDeselectEditorSelectedGameObject(Player player){
    if (player.editorSelectedGameObject == null) return;
    player.editorSelectedGameObject = null;
    player.writePlayerEvent(PlayerEvent.GameObject_Deselected);
  }

  void updateColliderSceneCollision(Collider collider){
    updateColliderSceneCollisionVertical(collider);
    updateColliderSceneCollisionHorizontal(collider);
  }

  void internalOnColliderEnteredWater(Collider collider) {
    deactivateCollider(collider);
    if (collider is Character) {
      setCharacterStateDead(collider);
    }
    dispatchV3(GameEventType.Splash, collider);
  }

  void updateColliderSceneCollisionVertical(Collider collider) {
    if (!scene.isInboundV3(collider)) {
      if (collider.z > -100) return;
      deactivateCollider(collider);
      if (collider is Character) {
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
      if (nodeTop - bottomZ > GamePhysics.Max_Vertical_Collision_Displacement) return;
      collider.z = nodeTop;
      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * GamePhysics.Bounce_Friction;
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

      if (nodeTop - bottomZ > GamePhysics.Max_Vertical_Collision_Displacement) return;

      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * GamePhysics.Bounce_Friction;
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

  void updateColliderSceneCollisionVertical2(Collider collider) {
    if (!scene.isInboundV3(collider)) {
      if (collider.z > -100) return;
      deactivateCollider(collider);
      if (collider is Character) {
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
      if (nodeTop - bottomZ > GamePhysics.Max_Vertical_Collision_Displacement) return;
      collider.z = nodeTop;
      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * GamePhysics.Bounce_Friction;
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

      if (nodeTop - bottomZ > GamePhysics.Max_Vertical_Collision_Displacement) return;

      collider.z = nodeTop;

      if (collider.velocityZ < 0) {
        if (collider.bounce) {
          collider.velocityZ =
              -collider.velocityZ * GamePhysics.Bounce_Friction;
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
      throw Exception("game.setNode(nodeIndex: $nodeIndex) - node index out of bounds");
    }
    if (
      nodeType == scene.nodeTypes[nodeIndex] &&
      nodeOrientation == scene.nodeOrientations[nodeIndex]
    ) return;

    if (!NodeType.supportsOrientation(nodeType, nodeOrientation)){
      nodeOrientation = NodeType.getDefaultOrientation(nodeType);
    }
    // scene.dirty = true;
    scene.nodeOrientations[nodeIndex] = nodeOrientation;
    scene.nodeTypes[nodeIndex] = nodeType;
    for (final player in players){
      player.writeNode(nodeIndex);
    }
  }

  void setCharacterTarget(Character character, Position3 target){
    if (character.target == target) return;
    character.target = target;
    if (character is Player) {
      character.endInteraction();
      character.writePlayerTargetCategory();
      character.writePlayerTargetPosition();
    }
  }

  void clearCharacterTarget(Character character){
    if (character.target == null) return;
    character.target = null;
    character.setCharacterStateIdle();
    if (character is Player){
      character.writePlayerTargetCategory();
    }
    if (character is AI){
      character.clearDest();
      character.clearPath();
    }
  }

  static double getAngleBetweenV3(Position a, Position b) => getAngle(a.x - b.x, a.y - b.y);

  void triggerSpawnPoints({int instances = 1}){
    for (final index in scene.spawnPoints) {
      for (var i = 0; i < instances; i++) {
        customActionSpawnAIAtIndex(index);
      }
    }
  }

  /// safe to override
  /// spawn a new ai at the given index
  void customActionSpawnAIAtIndex(int index){
    spawnAI(
      characterType: randomItem(const [CharacterType.Dog, CharacterType.Zombie, CharacterType.Template]),
      nodeIndex: index,
      damage: 10,
      team: TeamType.Evil,
      health: 3,
    );
  }

  /// WARNING EXPENSIVE OPERATION
  void clearSpawnedAI(){
      for (var i = 0; i < characters.length; i++){
         if (characters[i] is Player) continue;
         characters.removeAt(i);
         i--;
      }
  }

  /// FUNCTIONS
  static void setGridPosition({required Position3 position, required int z, required int row, required int column}){
    position.x = row * Node_Size + Node_Size_Half;
    position.y = column * Node_Size + Node_Size_Half;
    position.z = z * Node_Size_Half;
  }

  static void setPositionZ(Position3 position, int z){
    position.z = z * Node_Size_Half;
  }

  static void setPositionColumn(Position3 position, int column){
    position.y = column * Node_Size + Node_Size_Half;
  }

  static void setPositionRow(Position3 position, int row){
    position.x = row * Node_Size + Node_Size_Half;
  }

  void playersDownloadScene(){
    for (final player in players){
      player.downloadScene();
    }
  }

  void moveToRandomPlayerSpawnPoint(Position3 value) {
    if (scene.spawnPointsPlayers.isEmpty) return;
    moveV3ToNodeIndex(value, randomItem(scene.spawnPointsPlayers));
  }

  void playersWriteGameStatus(int gameStatus){
    playersWriteByte(ServerResponse.Game_Status);
    playersWriteByte(gameStatus);
  }

  void playersWriteByte(int byte){
    for (final player in players) {
      player.writeByte(byte);
    }
  }

  bool sceneRaycastBetween(Collider a, Collider b){
    final distance = getDistanceBetweenV3(a, b);
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

  int getNodeIndexV3(Position3 value) =>
      scene.getNodeIndex(value.indexZ, value.indexRow, value.indexColumn);


  void customOnPlayerCollectGameObject(Player player, GameObject target) {

    if (options.items) {
      deactivateCollider(target);
      player.writePlayerEventItemAcquired(target.type);
      clearCharacterTarget(player);
      return;
    }

    var quantityRemaining = target.quantity > 0 ? target.quantity : 1;
    final maxQuantity = ItemType.getMaxQuantity(target.type);
    if (maxQuantity > 1) {
      for (var i = 0; i < player.inventory.length; i++){
        if (player.inventory[i] != target.type) continue;
        if (player.inventoryQuantity[i] + quantityRemaining < maxQuantity){
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
    if (emptyInventoryIndex != null){
      player.inventory[emptyInventoryIndex] = target.type;
      player.inventoryQuantity[emptyInventoryIndex] = min(quantityRemaining, maxQuantity);
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
    for (var i = 0; i < gameObjects.length; i++){
      final gameObject = gameObjects[i];
      if (!gameObject.persistable){
         gameObjects.removeAt(i);
         i--;
         continue;
      }
      gameObject.x = gameObject.startX;
      gameObject.y = gameObject.startY;
      gameObject.z = gameObject.startZ;
    }
  }

  int getItemTypeDamage(int itemType, {int empty = 0, int level = 0}){
     assert (level >= 0);
     assert (level <= 4);

     if (itemType < 0) {
       return 0;
     }

     if (itemType == ItemType.Empty)
       return empty;
     if (options.inventory)
       return options.itemDamage[itemType] ?? 0;

     return options.itemTypeDamage[itemType]?[level] ?? 0;
  }

  // void playerEquipWeaponRanged(Player player){
  //   characterEquipWeapon(
  //     character: player,
  //     weaponType: player.weaponRanged,
  //     characterStateChange: true,
  //   );
  // }

  // void playerEquipWeaponMelee(Player player){
  //   characterEquipWeapon(
  //     character: player,
  //     weaponType: player.weaponMelee,
  //     characterStateChange: true,
  //   );
  // }

  void playerPurchaseItemType(Player player, int itemType, {required Side weaponSide}){
    if (player.dead) return;
    if (!options.itemTypes.contains(itemType)){
      player.writeError('${ItemType.getName(itemType)} cannot be purchased');
      return;
    }
    final currentLevel = player.item_level[itemType] ?? 0;

    if (currentLevel >= 4){
      player.writeError('${ItemType.getName(itemType)} max');
      return;
    }

    final cost = getItemPurchaseCost(itemType, currentLevel);
    if (player.credits < cost){
      player.writeError('insufficient credits');
      return;
    }
    final nextLevel = currentLevel + 1;

    final itemCapacity = options.itemTypeCapacity[itemType];

    if (itemCapacity == null){
      player.writeError('itemCapacity == null');
      return;
    }

    player.credits -= cost;
    player.item_level[itemType] = nextLevel;
    player.item_quantity[itemType] = itemCapacity[nextLevel];
    // player.writePlayerItems();
    player.writePlayerEventItemPurchased(itemType);
    characterEquipItemType(player, itemType);
    setCharacterStateChanging(player);
  }

  int getItemPurchaseCost(int itemType, int level){
    // assert (level > 0);
    assert (level < 6);
    if (options.items){
      return options.itemTypeCost[itemType]?[level] ?? 0;
    }
    return 0;
  }

  int getExperienceForLevel(int level){
    return (((level - 1) * (level - 1))) * 6;
  }

  void performPlayerActionPrimary(Player player) {

  }

  void performPlayerActionSecondary(Player player) {

  }

  void writePlayerScoresAll() {
    for (final player in players) {
      player.writeApiPlayersAll();
    }
  }
}

