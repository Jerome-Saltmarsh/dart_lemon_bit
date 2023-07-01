import 'dart:math';
import 'dart:typed_data';

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/core/game.dart';
import 'package:gamestream_server/gamestream.dart';
import 'package:lemon_byte/byte_reader.dart';
import 'package:lemon_math/src.dart';

import 'isometric_character.dart';
import 'isometric_collider.dart';
import 'isometric_environment.dart';
import 'isometric_gameobject.dart';
import 'isometric_hit_type.dart';
import 'isometric_physics.dart';
import 'isometric_player.dart';
import 'isometric_position.dart';
import 'isometric_projectile.dart';
import 'isometric_scene.dart';
import 'isometric_script.dart';
import 'isometric_script_type.dart';
import 'isometric_settings.dart';
import 'isometric_time.dart';

abstract class IsometricGame<T extends IsometricPlayer> extends Game<T> {

  IsometricScene scene;
  IsometricEnvironment environment;
  IsometricTime time;

  var _running = true;
  var timerUpdateAITargets = 0;

  var frame = 0;
  var gameObjectId = 0;

  final characters = <IsometricCharacter>[];
  final projectiles = <IsometricProjectile>[];
  final scripts = <IsometricScript>[];
  final scriptReader = ByteReader();

  void spawn(IsometricCollider value){
    if (value is IsometricCharacter){
       characters.add(value);
       return;
    }
    if (value is IsometricGameObject){
       gameObjects.add(value);
       return;
    }
    if (value is IsometricProjectile){
      projectiles.add(value);
      return;
    }
  }

  /// CONSTRUCTOR
  IsometricGame({
    required this.scene,
    required this.time,
    required this.environment,
    required super.gameType,
  }) {
    IsometricPosition.sort(gameObjects);

    gameObjectId = scene.gameObjects.length;
    customInit();

    for (final gameObject in gameObjects) {
      customOnGameObjectSpawned(gameObject);
    }
  }

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
  void customUpdatePlayer(T player) {}

  /// @override
  void customOnPlayerInteractWithGameObject(T player,
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
  void customOnPlayerRevived(T player) {}

  /// @override
  void customOnCharacterDead(IsometricCharacter character) {}

  /// @override
  void customOnPlayerDead(T player) {}

  /// @override
  void customOnGameStarted() {}

  /// @override
  void customOnCollisionBetweenColliders(IsometricCollider a, IsometricCollider b) {}

  /// @override
  void customOnCollisionBetweenPlayerAndOther(T player,
      IsometricCollider collider) {}

  /// @override
  void customOnCollisionBetweenPlayerAndGameObject(T player,
      IsometricGameObject gameObject) {}

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
  void customOnPlayerJoined(T player) {}

  /// @override
  void customInit() {}

  /// @override
  void customOnGameObjectSpawned(IsometricGameObject gameObject) {}

  /// @override
  void customOnGameObjectDestroyed(IsometricGameObject gameObject) {}

  /// @override
  void customOnPlayerAimTargetChanged(IsometricPlayer player,
      IsometricCollider? collider) {}

  /// @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    // default behavior is to respawn after a period however this can be safely overriden
    addJob(seconds: 1000, action: () {
      setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        nodeOrientation: nodeOrientation,
      );
    });
  }

  List<IsometricGameObject> get gameObjects => scene.gameObjects;

  /// @override
  double get minAimTargetCursorDistance => 35;

  IsometricGameObject? findGameObjectByType(int type) {
    for (final gameObject in gameObjects) {
      if (gameObject.type == type) return gameObject;
    }
    return null;
  }

  /// throws and exception if the given type is not found
  IsometricGameObject findGameObjectByTypeOrFail(int type) {
    for (final gameObject in gameObjects) {
      if (gameObject.type == type) return gameObject;
    }
    throw Exception('findGameObjectByTypeOrFail(${ItemType.getName(type)})');
  }

  IsometricGameObject? findGameObjectById(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  /// ACTIONS

  void moveV3ToNodeIndex(IsometricPosition vector3, int nodeIndex) {
    vector3.x = scene.getNodePositionX(nodeIndex);
    vector3.y = scene.getNodePositionY(nodeIndex);
    vector3.z = scene.getNodePositionZ(nodeIndex);
  }

  void move(IsometricPosition value, double angle, double distance) {
    value.x += adj(angle, distance);
    value.y += opp(angle, distance);
  }

  double getDistanceFromPlayerMouse(IsometricPlayer player,
      IsometricPosition position) =>
      getDistanceXYZ(
        player.mouseGridX,
        player.mouseGridY,
        player.z,
        position.x,
        position.y,
        position.z,
      );

  /// @inputTypeKeyboard keyboard = true, touchscreen = false
  void onPlayerUpdateRequestReceived({
    required T player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool inputTypeKeyboard,
  }) {
    if (player.deadOrBusy) return;

    if (inputTypeKeyboard) {
      characterRunInDirection(player, IsometricDirection.fromInputDirection(direction));
    } else {
      if (mouseLeftDown) {
        player.setDestinationToMouse();
      }
    }
  }

  void _updateIsometricPlayerAimTarget(IsometricPlayer player) {
    var closestDistance = IsometricSettings.Pickup_Range_Squared;

    final mouseX = player.mouseGridX;
    final mouseY = player.mouseGridY;
    final mouseZ = player.z;

    IsometricCollider? closestCollider;

    for (final character in characters) {
      if (character.dead) continue;
      if ((mouseX - character.x).abs() > IsometricSettings.Pickup_Range) continue;
      if ((mouseY - character.y).abs() > IsometricSettings.Pickup_Range) continue;
      if ((mouseZ - character.z).abs() > IsometricSettings.Pickup_Range) continue;
      if (character == player) continue;
      final distance = getDistanceXYZSquared(
          mouseX, mouseY, mouseZ, character.x, character.y, character.z,
      );
      if (distance > closestDistance) continue;
      closestDistance = distance;
      closestCollider = character;
    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.collectable && !gameObject.interactable) continue;
      if ((mouseX - gameObject.x).abs() > IsometricSettings.Pickup_Range) continue;
      if ((mouseY - gameObject.y).abs() > IsometricSettings.Pickup_Range) continue;
      if ((mouseZ - gameObject.z).abs() > IsometricSettings.Pickup_Range) continue;
      final distance = getDistanceXYZSquared(
          mouseX, mouseY, mouseZ, gameObject.x, gameObject.y, gameObject.z,
      );
      if (distance > closestDistance) continue;
      closestDistance = distance;
      closestCollider = gameObject;
    }

    player.aimTarget = closestCollider;
  }

  void characterRunInDirection(IsometricCharacter character, int direction) {
    if (direction == IsometricDirection.None && character.target == null) {
      character.setCharacterStateIdle();
      return;
    }

    if (character.targetSet) {
      if (direction == IsometricDirection.None) {
        return;
      }
      clearCharacterTarget(character);
      character.setCharacterStateIdle();
      return;
    } else if (direction == IsometricDirection.None) {
      clearCharacterTarget(character);
      character.setCharacterStateIdle();
      return;
    }
    character.faceDirection = direction;
    setCharacterStateRunning(character);
    clearCharacterTarget(character);
  }

  void characterUseWeapon(IsometricCharacter character) {
    if (character.deadBusyOrWeaponStateBusy) return;

    final weaponType = character.weaponType;

    if (weaponType == ItemType.Weapon_Thrown_Grenade) {
      if (character is IsometricPlayer) {
        playerThrowGrenade(character, damage: 10);
        return;
      }
      throw Exception('ai cannot throw grenades');
    }

    if (weaponType == ItemType.Weapon_Ranged_Flamethrower) {
      characterUseFlamethrower(character);
      return;
    }

    if (weaponType == ItemType.Weapon_Ranged_Bazooka) {
      characterUseBazooka(character);
      return;
    }

    if (weaponType == ItemType.Weapon_Ranged_Minigun) {
      characterUseMinigun(character);
      return;
    }

    if (ItemType.isTypeWeaponFirearm(weaponType)) {
      characterFireWeapon(character);
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
          damage: character.weaponDamage,
          range: character.weaponRange,
          src: character,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        return;
      case ItemType.Weapon_Melee_Staff:
        spawnProjectileFireball(
          src: character,
          angle: character.lookRadian,
          damage: character.weaponDamage,
          range: character.weaponRange,
        );
        character.assignWeaponStateFiring();
        break;
      case ItemType.Weapon_Ranged_Bow:
        spawnProjectileArrow(
          src: character,
          damage: character.weaponDamage,
          range: character.weaponRange,
          angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        break;
    }
  }

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
    final r = angleBetween(character.x, character.y, x, y);
    var completed = false;

    if (!character.withinRadiusXYZ(x, y, z, range)) {
      x = character.x + adj(r, range);
      y = character.y + opp(r, range);
    }

    final nodeIndex = scene.getIndexXYZ(x, y, z);
    final nodeOrientation = scene.shapes[nodeIndex];

    if (!completed && nodeOrientation == NodeOrientation.None) {
      character.x = x;
      character.y = y;
      completed = true;
    }

    if (!completed && z + Node_Height < scene.heightLength) {
      final aboveNodeIndex = scene.getIndexXYZ(x, y, z + Node_Height);
      final aboveNodeOrientation = scene.shapes[aboveNodeIndex];
      if (aboveNodeOrientation == NodeOrientation.None) {
        character.x = x;
        character.y = y;
        character.z = z + Node_Height;
        completed = true;
      }
    }

    if (!completed) {
      final distance = character.getDistanceXY(x, y);
      final jumps = distance ~/ Node_Size_Half;
      final jumpX = adj(r, Node_Size_Half);
      final jumpY = opp(r, Node_Size_Half);

      for (var i = 0; i < jumps; i++) {
        x -= jumpX;
        y -= jumpY;
        final frontNodeIndex = scene.getIndexXYZ(x, y, z);
        final frontNodeOrientation = scene.shapes[frontNodeIndex];
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

  void playerThrowGrenade(IsometricPlayer player, {int damage = 10}) {
    if (player.deadBusyOrWeaponStateBusy) return;

    dispatchAttackPerformed(
      ItemType.Weapon_Thrown_Grenade,
      player.x + adj(player.lookRadian, 60),
      player.y + opp(player.lookRadian, 60),
      player.z + Character_Gun_Height,
      player.lookRadian,
    );

    player.assignWeaponStateThrowing();

    final mouseDistance = player.getDistanceXY(player.mouseGridX, player.mouseGridY);
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
      ..weaponDamage = damage;

    addJob(seconds: IsometricSettings.Grenade_Cook_Duration, action: () {
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

  void characterUseFlamethrower(IsometricCharacter character) {
    dispatchAttackPerformedCharacter(character);
    character.assignWeaponStateFiring();

    spawnProjectileFireball(
      src: character,
      angle: character.lookRadian,
      damage: character.weaponDamage,
      range: character.weaponRange,
    );
  }

  void characterUseBazooka(IsometricCharacter character) {
    dispatchAttackPerformedCharacter(character);
    character.assignWeaponStateFiring();
    spawnProjectileRocket(character, damage: 3, range: character.weaponRange);
  }

  void characterUseMinigun(IsometricCharacter player) {
    characterFireWeapon(player);
  }

  void positionToPlayerMouse(Position position, IsometricPlayer player) {
    position.x = player.mouseGridX;
    position.y = player.mouseGridY;
  }

  void playerAutoAim(IsometricPlayer player) {
    if (player.deadOrBusy) return;
    var closestTargetDistance = player.weaponRange * 1.5;
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
    assert (character.weaponDamage >= 0);

    if (character.deadBusyOrWeaponStateBusy) return;

    final angle = character.lookRadian;
    final attackRadius = ItemType.getMeleeAttackRadius(character.weaponType);

    if (attackRadius <= 0) {
      throw Exception(
          'ItemType.getRange(${ItemType.getName(character.weaponType)})');
    }

    final attackRadiusHalf = attackRadius * 0.5;
    final performX = character.x + adj(angle, attackRadiusHalf);
    final performY = character.y + opp(angle, attackRadiusHalf);
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
      if (!other.withinRadiusXYZ(
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
          angle: character.getAngle(other),
          target: other,
          damage: character.weaponDamage,
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
      if (!gameObject.withinRadiusXYZ(
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
          angle: character.getAngle(gameObject),
          target: gameObject,
          damage: character.weaponDamage,
          srcCharacter: character,
          hitType: IsometricHitType.Melee
      );
      attackHit = true;
    }

    if (nearest != null) {
      applyHit(
          angle: character.getAngle(nearest),
          target: nearest,
          damage: character.weaponDamage,
          srcCharacter: character,
          hitType: IsometricHitType.Melee);
    }

    if (!scene.inboundsXYZ(performX, performY, performZ)) return;
    final nodeIndex = scene.getIndexXYZ(performX, performY, performZ);
    final nodeType = scene.types[nodeIndex];

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
    final nodeOrientation = scene.shapes[nodeIndex];
    if (nodeOrientation == NodeOrientation.Destroyed) return;
    final nodeType = scene.types[nodeIndex];
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
    assert (character.weaponDamage >= 0);

    if (character.deadBusyOrWeaponStateBusy) return false;

    final angle = character.lookRadian;
    final attackRadius = ItemType.getMeleeAttackRadius(character.weaponType) *
        0.75;

    if (attackRadius <= 0) {
      return false;
    }

    final attackRadiusHalf = attackRadius * 0.5;
    final performX = character.x + adj(angle, attackRadiusHalf);
    final performY = character.y + opp(angle, attackRadiusHalf);
    final performZ = character.z;

    for (final other in characters) {
      if (!other.active) continue;
      if (!other.hitable) continue;
      if (IsometricCollider.onSameTeam(character, other)) continue;
      if (other.withinRadiusXYZ(
        performX,
        performY,
        performZ,
        attackRadiusHalf,
      )) return true;
    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;
      if (gameObject.withinRadiusXYZ(
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
      range: character.weaponRange,
      projectileType: ProjectileType.Bullet,
      damage: character.weaponDamage,
    );

    dispatchAttackPerformed(
      character.weaponType,
      character.x + adj(angle, 70),
      character.y + opp(angle, 70),
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
    scene.refreshMetrics();
    for (final player in players) {
      player.writeScene();
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

  void setHourMinutes(int hour, int minutes) {
    time.time = (hour * 60 * 60) + (minutes * 60);
    playersWriteWeather();
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
        if (gameObject.recyclable && !gameObject.available) {
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
      if (!gameObject.withinRadiusXYZ(x, y, z, radius)) continue;
      applyHit(
        angle: angleBetween(x, y, gameObject.x, gameObject.y),
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
      if (!character.withinRadiusXYZ(x, y, z, radius)) continue;
      applyHit(
        angle: angleBetween(x, y, character.x, character.y),
        target: character,
        srcCharacter: srcCharacter,
        damage: damage,
        friendlyFire: true,
        hitType: IsometricHitType.Explosion,
      );
    }
  }

  /// called while running is false
  void customNotRunningUpdate(){

  }

  void update() {
    if (!running) {
      customNotRunningUpdate();
      return;
    }
    if (players.isEmpty) return;

    frame++;
    time.update();
    environment.update();

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

  void revive(T player) {
    if (player.aliveAndActive) return;

    player.setCharacterStateSpawning();
    activateCollider(player);
    player.health = player.maxHealth;
    clearCharacterTarget(player);

    customOnPlayerRevived(player);

    player.writePlayerMoved();
    player.writeApiPlayerSpawned();
    player.writePlayerAlive();
    player.writePlayerStats();
    player.writeGameTime();
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
      player.writeGameTime();
      player.writeEnvironmentLightningFlashing(environment.lightningFlashing);
    }
  }

  IsometricCharacter? getClosestEnemy({
    required double x,
    required double y,
    required IsometricCharacter character,
  }) {
    return IsometricPhysics.findClosestVector3(
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

    final damage = min(amount, target.health);
    target.health -= damage;

    if (target.health <= 0) {
      setCharacterStateDead(target);
      customOnCharacterKilled(target, src);
      return;
    }
    customOnCharacterDamageApplied(target, src, damage);
    target.setCharacterStateHurt();
    dispatchGameEventCharacterHurt(target);
  }

  /// Can be safely overridden to customize behavior

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
    for (var i = 0; i < characters.length; i++) {
      updateCharacter(characters[i]);
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
      if (!colliderI.collidable) continue;
      for (var j = i + 1; j < numberOfColliders; j++) {
        final colliderJ = colliders[j];
        if (!colliderJ.active) continue;
        if (!colliderI.collidable) continue;
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
    assert (a != b);
    if (a.physical && b.physical) {
      resolveCollisionPhysics(a, b);
    }

    if (a is T) {
      if (b is IsometricGameObject) {
        customOnCollisionBetweenPlayerAndGameObject(a, b);
      }
      customOnCollisionBetweenPlayerAndOther(a, b);
    }
    if (b is T) {
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
    final totalDistance = a.getDistanceXY(b.x, b.y);
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

    final ratio = 1.0 / hyp2(xDiff, yDiff);
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
      {int duration = Gamestream.Frames_Per_Second * 2}) {
    if (character.dead) return;
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
    character.clearPath();
    clearCharacterTarget(character);
    character.customOnDead();
    customOnCharacterDead(character);
    if (character is T) {
      customOnPlayerDead(character);
      character.writePlayerAlive();
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
      final nodeType = scene.getTypeXYZ(
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

  void updatePlayer(T player) {
    player.framesSinceClientRequest++;

    if (player.dead) return;
    if (!player.active) return;

    _updateIsometricPlayerAimTarget(player);

    if (!player.deadOrBusy) {
      player.lookRadian = player.mouseAngle;
    }

    if (player.idling && !player.weaponStateBusy) {
      final diff = IsometricDirection.getDifference(
          player.lookDirection, player.faceDirection);
      if (diff >= 2) {
        player.faceAngle += piQuarter;
      } else if (diff <= -3) {
        player.faceAngle -= piQuarter;
      }
    }
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
        if (projectile.withinRadiusPosition(target, projectile.radius)) {
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
        if (!projectile.isEnemy(collider) && !projectile.friendlyFire) continue;
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
        damage: projectile.weaponDamage,
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
    required int hitType,
    double force = 20,
    double? angle,
    bool friendlyFire = false,
  }) {
    if (!target.hitable) return;
    if (!target.active) return;

    if (angle == null){
      angle = srcCharacter.getAngle(target);
    }

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

  void updateCharacter(IsometricCharacter character) {

    if (character.dead) return;
    if (!character.active) return;

    // TODO INVALID LOCATION
    if (!character.isPlayer) {
      character.lookRadian = character.faceAngle;
    }

    character.update();
    updateCharacterState(character);
    updateColliderPhysics(character);

    if (character.autoTarget && character.autoTargetTimer-- <= 0){
      character.autoTargetTimer = character.autoTargetTimerDuration;
      character.target = findNearestEnemy(character, radius: character.autoTargetRange);
    }

    if (character.runToDestinationEnabled) {
      if (character.deadBusyOrWeaponStateBusy || character.runDestinationWithinRadiusRunSpeed){
        character.setCharacterStateIdle();
      } else {
        character.runToDestination();
      }
    }

    if (character.pathFindingEnabled) {

      if (character.pathIndex >= 0 && getNodeIndexV3Unsafe(character) == character.pathNodeIndex){
        character.pathIndex--;
        if (character.pathIndex <= 0 && getNodeIndexV3Unsafe(character) == character.pathTargetIndex){
          character.clearPath();
          character.setCharacterStateIdle();
          character.setDestinationToCurrentPosition();
        }
      }

      if (character.shouldUpdatePath){
        updateCharacterPath(character);
      }

      if (character.pathIndex >= 0){
        setDestinationToPathNodeIndex(character);
      }

      final target = character.target;

      if (target != null) {

        if (character.targetWithinRadius(Node_Size)) {
          character.setDestinationToTarget();
        }

        if (character.shouldAttackTarget() && characterTargetIsPerceptible(character)) {
          character.attackTargetEnemy(this);
        }

        character.pathTargetIndex = scene.getIndexPosition(target);
      }
    }


    if (character is T) {
      updatePlayer(character);
      customUpdatePlayer(character);
    }

    character.customOnUpdate();
  }

  void updateCharacterState(IsometricCharacter character) {
    if (character.stateDurationRemaining > 0) {
      character.stateDurationRemaining--;
      if (character.stateDurationRemaining == 0) {
        character.setCharacterStateIdle();
        return;
      }
    }
    switch (character.state) {
      case CharacterState.Idle:
        break;
      case CharacterState.Running:
        character.applyForce(
            force: character.runSpeed,
            angle: character.faceAngle,
        );
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
        // updateCharacterStatePerforming(character);
        break;
      case CharacterState.Spawning:
        if (character.stateDurationRemaining == 1) {
          customOnCharacterSpawned(character);
        }
        break;
    }
    character.stateDuration++;
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

  IsometricProjectile spawnProjectileFireball({
    required IsometricCharacter src,
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
        range: src.weaponRange,
        projectileType: ProjectileType.Bullet,
        damage: src.weaponDamage,
      );
    }
    src.assignWeaponStateFiring();
    dispatchAttackPerformed(
      src.weaponType,
      src.x + adj(angle, 60),
      src.y + opp(angle, 60),
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
    projectile.weaponDamage = damage;
    projectile.hitable = true;
    projectile.active = true;
    if (target is IsometricCollider) {
      projectile.target = target;
    }
    // final r = 10.0 + (src.isTemplate ? ItemType.getWeaponLength(src.weaponType) : 0);
    final r = 5.0;
    projectile.x = src.x + adj(finalAngle, r);
    projectile.y = src.y + opp(finalAngle, r);
    projectile.z = src.z + Character_Gun_Height;
    projectile.startX = projectile.x;
    projectile.startY = projectile.y;
    projectile.startZ = projectile.z;
    projectile.setVelocity(finalAngle, ProjectileType.getSpeed(projectileType));
    projectile.owner = src;
    projectile.team = src.team;
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

  void moveToIndex(IsometricPosition position, int index) {
    position.x = scene.getNodePositionX(index);
    position.y = scene.getNodePositionY(index);
    position.z = scene.getNodePositionZ(index);
  }

  IsometricGameObject spawnGameObjectAtIndex({required int index, required int type}) =>
      spawnGameObject(
        x: scene.getNodePositionX(index),
        y: scene.getNodePositionY(index),
        z: scene.getNodePositionZ(index),
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
      if (!gameObject.recyclable) continue;
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
      id: generateId(),
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

  void dispatchAttackPerformedCharacter(IsometricCharacter character) =>
      dispatchAttackPerformed(
        character.weaponType,
        character.x,
        character.y,
        character.z,
        character.lookRadian,
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

  void removePlayer(IsometricPlayer player) {
    if (!players.remove(player));
    characters.remove(player);
    customOnPlayerDisconnected(player);
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
    final nodeBottomIndex = scene.getIndexXYZ(
      collider.x,
      collider.y,
      bottomZ,
    );
    final nodeBottomOrientation = scene.shapes[nodeBottomIndex];
    final nodeBottomType = scene.types[nodeBottomIndex];

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

    if (bottomZ >= scene.heightLength) return;

    final nodeBottomIndex = scene.getIndexXYZ(
      collider.x,
      collider.y,
      bottomZ,
    );
    final nodeBottomOrientation = scene.shapes[nodeBottomIndex];
    final nodeBottomType = scene.types[nodeBottomIndex];

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

    if (nodeIndex >= scene.volume) {
      throw Exception(
          "game.setNode(nodeIndex: $nodeIndex) - node index out of bounds");
    }
    if (
    nodeType == scene.types[nodeIndex] &&
        nodeOrientation == scene.shapes[nodeIndex]
    ) return;

    if (!NodeType.supportsOrientation(nodeType, nodeOrientation)) {
      nodeOrientation = NodeType.getDefaultOrientation(nodeType);
    }
    // scene.dirty = true;
    scene.shapes[nodeIndex] = nodeOrientation;
    scene.types[nodeIndex] = nodeType;
    for (final player in players) {
      player.writeNode(nodeIndex);
    }
  }

  void setCharacterTarget(IsometricCharacter character, IsometricPosition target) {
    if (character.target == target) return;
    character.target = target;

    // TODO
    if (character is IsometricPlayer) {
      character.writePlayerTargetCategory();
      character.writePlayerTargetPosition();
    }
  }

  void clearCharacterTarget(IsometricCharacter character) {
    if (character.target == null) return;
    character.target = null;
    character.setCharacterStateIdle();
    // TODO
    if (character is IsometricPlayer) {
      character.writePlayerTargetCategory();
    }
  }

  void triggerSpawnPoints({int instances = 1}) {
    // for (final index in scene.spawnPoints) {
    //   for (var i = 0; i < instances; i++) {
    //     customActionSpawnAIAtIndex(index);
    //   }
    // }
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
      scene.getIndex(value.indexZ, value.indexRow, value.indexColumn);

  int getNodeIndexV3Unsafe(IsometricPosition value) =>
      scene.getIndexUnsafe(value.indexZ, value.indexRow, value.indexColumn);

  int getNodeIndexXYZ(double x, double y, double z){
      return scene.getIndexXYZ(x, y, z);
  }

  void customOnPlayerCollectGameObject(T player,
      IsometricGameObject target) {}

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

  void destroyGameObject(IsometricGameObject gameObject) {
    if (!gameObject.active) return;
    dispatchGameEventGameObjectDestroyed(gameObject);
    deactivateCollider(gameObject);
    customOnGameObjectDestroyed(gameObject);
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
    player.setDestinationToCurrentPosition();
    player.sceneDownloaded = false;
    characters.add(player);
    customOnPlayerJoined(player);
    player.writePlayerAlive();
    return player;
  }

  @override
  void customWriteGame() {
    if (!environment.onChanged) return;
    environment.onChanged = false;
    playersWriteWeather();
  }

  int generateId() => gameObjectId++;

  IsometricCharacter? getNearestCharacter(double x, double y, double z, {double maxRadius = 10000}){
    IsometricCharacter? nearestCharacter;
    var nearestCharacterDistanceSquared = maxRadius * maxRadius;
    for (final character in characters){
      if (!character.active) continue;
      final distanceSquared = character.getDistanceSquaredXYZ(x, y, z);
      if (distanceSquared > nearestCharacterDistanceSquared) continue;
      nearestCharacterDistanceSquared = distanceSquared;
      nearestCharacter = character;
    }
    return nearestCharacter;
  }

  double clampX(double value)=> clamp(value, 0, scene.rowLength);

  double clampY(double value)=> clamp(value, 0, scene.columnLength);

  double clampZ(double value)=> clamp(value, 0, scene.heightLength);

  IsometricCollider? findNearestEnemy(IsometricCollider src, {double radius = 1000}){
    IsometricCollider? nearestEnemy;
    var nearestEnemyDistanceSquared = radius * radius;
    for (final character in characters){
      if (!src.isEnemy(character)) continue;
      final distanceSquared = src.getDistanceSquared(character);
      if (distanceSquared > nearestEnemyDistanceSquared) continue;
      nearestEnemyDistanceSquared = distanceSquared;
      nearestEnemy = character;
    }
    return nearestEnemy;
  }

  void setCharacterPathToTarget(IsometricCharacter character){
    final target = character.target;
    if (target == null) {
      return;
    }
    character.pathTargetIndex = scene.getIndexPosition(target);
  }

  void updateCharacterPath(IsometricCharacter character) {
    character.pathTargetIndexPrevious = character.pathTargetIndex;

    if (character.pathTargetIndex == -1){
      character.clearPath();
      return;
    }

    final startIndex = scene.getIndexPosition(character);

    if (character.pathTargetIndex == startIndex){
      character.clearPath();
      return;
    }

    final path = character.path;
    var endPath = scene.findPath(
        startIndex, character.pathTargetIndex,
        max: character.path.length,
    );
    var totalPathLength = 0;
    while (endPath != startIndex) {
      IsometricScene.compiledPath[totalPathLength++] = endPath;
      endPath = scene.path[endPath];
    }

    final length = min(path.length, totalPathLength);

    if (length < 0) return;

    character.pathIndex = length;
    for (var i = 0; i < length; i++){
      path[i] = IsometricScene.compiledPath[totalPathLength - length + i];
    }

    if (character.pathIndex > 0){
      character.pathIndex--;
    }
    character.pathStart = character.pathIndex;
  }

  void setDestinationToPathNodeIndex(IsometricCharacter character) {
    if (character.pathIndex < 0) return;

    final pathNodeIndex = character.pathNodeIndex;
    character.runX = scene.getNodePositionX(pathNodeIndex);
    character.runY = scene.getNodePositionY(pathNodeIndex);
  }

  bool characterTargetIsPerceptible(IsometricCharacter character) {
    final target = character.target;

    if (target == null)
      return false;

    return scene.isPerceptible(character, target);
  }
}