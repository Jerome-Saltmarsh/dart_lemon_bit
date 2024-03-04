import 'dart:math';

import 'package:amulet_engine/isometric/consts/frames_per_second.dart';
import 'package:amulet_engine/isometric/consts/physics.dart';
import 'package:amulet_engine/isometric/enums/damage_type.dart';
import 'package:amulet_engine/isometric/functions/copy_gameobjects.dart';
import 'package:amulet_engine/src.dart';
import 'package:lemon_lang/src.dart';
import 'package:lemon_math/src.dart';

import '../../common/src.dart';
import '../consts/isometric_settings.dart';
import 'character.dart';
import 'collider.dart';
import 'gameobject.dart';
import 'isometric_environment.dart';
import 'isometric_player.dart';
import 'isometric_time.dart';
import 'position.dart';
import 'projectile.dart';
import 'scene.dart';

abstract class IsometricGame<T extends IsometricPlayer> {

  Scene scene;
  IsometricEnvironment environment;
  IsometricTime time;

  var attackAlwaysHitsTarget = false;
  var playerId = 0;
  var timerUpdateAITargets = 0;
  var frame = 0;
  var _running = true;
  var gameObjectsOrderDirty = false;

  final List<T> players = [];
  // final jobs = <GameJob>[];
  final gameObjects = <GameObject>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];

  IsometricGame({
    required this.scene,
    required this.time,
    required this.environment,
  });

  void loadGameObjectsFromScene() {
    setGameObjects(copyGameObjects(scene.gameObjects));
  }

  void setGameObjects(List<GameObject> values){
    clearGameObjects();
    addAll(values);
  }

  void clearGameObjects(){
    gameObjects.clear();

    for (final player in players) {
      player.editorDeselectGameObject();
    }

    playersWriteByte(NetworkResponse.Scene);
    playersWriteByte(NetworkResponseScene.GameObjects_Cleared);
  }

  void markGameObjectsAsDirty() {
    for (final gameObject in gameObjects){
      gameObject.dirty = true;
    }
  }

  int get maxPlayers;

  bool get isFull => players.length >= maxPlayers;

  int get fps => Frames_Per_Second;

  double get minAimTargetCursorDistance => 35;

  bool get running => _running;

  set running(bool value) {
    if (_running == value) return;
    _running = value;
    for (final player in players) {
      player.writeGameRunning();
    }
  }

  void writePlayerResponses() {
    final players = this.players;
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      player.writePlayerGame();
      customWriteGame();
    }
  }

  void removePlayer(T player){
    player.aimTarget = null;
    player.target = null;
    player.aimNodeIndex = null;
    player.arrivedAtDestination = true;
    player.clearVelocity();
    player.setDestinationToCurrentPosition();
    if (players.remove(player)) {
      onPlayerRemoved(player);
    }
    characters.remove(player);
  }

  void addAll<J extends Collider>(List<J> colliders){
     for (final collider in colliders){
       add(collider);
     }
  }

  void add(Collider value){
    if (value is Character){
      if (characters.contains(value)){
        return;
      }
      characters.add(value);
    }
    if (value is GameObject){
      if (gameObjects.contains(value)){
        return;
      }
      gameObjects.add(value);
      if (value.id < 0 || findGameObjectById(value.id) != null){
        value.id = generateUniqueGameObjectId();
      }
      value.dirty = true;
      gameObjectsOrderDirty = true;
      onAddedGameObject(value);
    }
    if (value is Projectile){
      if (projectiles.contains(value)){
        return;
      }
      projectiles.add(value);
      onAddedProjectile(value);
    }
    if (value is T) {
      if (players.contains(value)){
        return;
      }
      players.add(value);
      onAddedPlayer(value);
    }
  }

  /// In seconds
  void customInitPlayer(IsometricPlayer player) {}

  // /// @override
  // void customOnCharacterInteractWithGameObject(
  //     Character character,
  //     GameObject gameObject,
  // ) {}

  /// @override
  void customDownloadScene(IsometricPlayer player) {}

  /// @override
  void customUpdate() {}

  /// @override
  void customOnPlayerDisconnected(IsometricPlayer player) {}

  /// @override
  void onActivated(Collider collider) {}

  /// @override
  void customOnCharacterKilled(Character target, dynamic src) {}

  /// @override
  void customOnPlayerRevived(T player) {}

  /// @override
  void customOnCharacterDead(Character character) {}

  /// @override
  void customOnPlayerDead(T player) {}

  /// @override
  void customOnGameStarted() {}

  /// @override
  void customOnCollisionBetweenColliders(Collider a, Collider b) {}

  /// @override
  void customOnCollisionBetweenPlayerAndOther(T player,
      Collider collider) {}

  /// @override
  void customOnCollisionBetweenPlayerAndGameObject(T player,
      GameObject gameObject) {}

  /// @override
  void customOnPlayerWeaponChanged(IsometricPlayer player,
      int previousWeaponType, int newWeaponType) {}

  /// @override
  void customOnPlayerJoined(T player) {}

  /// @override
  void customOnGameObjectDestroyed(GameObject gameObject) {}

  /// @override
  void customOnPlayerAimTargetChanged(IsometricPlayer player,
      Collider? collider) {}

  /// @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    // default behavior is to respawn after a period however this can be safely overriden
    // addJob(seconds: 1000, action: () {
    //   setNode(
    //     nodeIndex: nodeIndex,
    //     nodeType: nodeType,
    //     orientation: nodeOrientation,
    //   );
    // });
  }

  GameObject? findGameObjectByType(int type) {
    for (final gameObject in gameObjects) {
      if (gameObject.itemType == type) return gameObject;
    }
    return null;
  }

  GameObject? findGameObjectById(int id) {
    final gameObjects = this.gameObjects;
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  /// ACTIONS

  void movePlayerToSpawnPoint(Position position){

  }

  void movePositionToIndex(Position position, int index) =>
      scene.movePositionToIndex(position, index);

  void move(Position value, double angle, double distance) {
    value.x += adj(angle, distance);
    value.y += opp(angle, distance);
  }

  void onPlayerUpdateRequestReceived({
    required T player,
    required int direction,
    required bool mouseLeftDown,
    required bool mouseRightDown,
    required bool keySpaceDown,
    required bool keyDownShift
  }) {

    // if (
    //   player.deadOrBusy ||
    //   // !player.active ||
    //   player.debugging ||
    //   !player.controlsEnabled
    // ) return;
    //
    //
    // final mouseLeftClicked = mouseLeftDown && player.mouseLeftDownDuration == 0;
    // // final mouseRightClicked = mouseRightDown && player.mouseRightDownDuration == 0;
    //
    // if (mouseRightDown){
    //   player.mouseRightDownDuration++;
    // } else {
    //   player.mouseRightDownDuration = 0;
    // }
    //
    // // if (mouseRightClicked){
    // //   if (player is AmuletPlayer){
    // //     if (player.activatedPowerIndex == -1){
    // //       player.performForceAttack();
    // //       return;
    // //     } else {
    // //       player.deselectActivatedPower();
    // //     }
    // //   }
    // //   return;
    // // }
    //
    // if (keyDownShift){
    //   player.setCharacterStateIdle();
    // }
    //
    // if (mouseLeftDown) {
    //   player.mouseLeftDownDuration++;
    // } else {
    //   player.mouseLeftDownDuration = 0;
    // }
    //
    // // if (mouseLeftClicked &&
    // //     player is AmuletPlayer &&
    // //     player.activatedPowerIndex != -1
    // // ) {
    // //   player.useActivatedPower();
    // //   player.mouseLeftDownIgnore = true;
    // //   return;
    // // }
    //
    // if (mouseLeftDown && !player.mouseLeftDownIgnore) {
    //   final aimTarget = player.aimTarget;
    //
    //   if (aimTarget == null || (player.isEnemy(aimTarget) && !player.controlsCanTargetEnemies)){
    //     if (keyDownShift){
    //       player.performForceAttack();
    //       return;
    //     } else {
    //       player.setDestinationToMouse();
    //       player.runToDestinationEnabled = true;
    //       player.pathFindingEnabled = false;
    //       setCharacterTarget(player, null);
    //     }
    //   } else if (mouseLeftClicked) {
    //     player.target = aimTarget;
    //     player.runToDestinationEnabled = true;
    //     player.pathFindingEnabled = false;
    //   }
    //   return;
    // }
  }

  void updatePlayerAimTarget(IsometricPlayer player) {
    var anyFound = false;
    var closestDistanceSquared = IsometricSettings.Pickup_Range_Squared;

    final mouseX = player.mouseSceneX;
    final mouseY = player.mouseSceneY;
    final mouseZ = player.mouseSceneZ;

    Collider? closestCollider;

    const Min_Radius = IsometricSettings.Pickup_Range;
    final characters = this.characters;

    for (final character in characters) {
      if (character.dead) continue;
      final radius = max(Min_Radius, character.radius);
      if ((mouseX - character.x).abs() > radius) continue;
      if ((mouseY - character.y).abs() > radius) continue;
      if ((mouseZ - character.z).abs() > radius) continue;
      if (character == player) continue;
      final distanceSquared = getDistanceXYZSquared(
          mouseX, mouseY, mouseZ, character.x, character.y, character.z,
      );
      if (anyFound && distanceSquared > closestDistanceSquared) continue;
      anyFound = true;
      closestDistanceSquared = distanceSquared;
      closestCollider = character;
    }

    final gameObjects = this.gameObjects;
    for (final gameObject in gameObjects) {
      if (gameObject.ignorePointer) continue;

      final radius = max(Min_Radius, gameObject.radius);
      if ((mouseX - gameObject.x).abs() > radius) continue;
      if ((mouseY - gameObject.y).abs() > radius) continue;
      if ((mouseZ - gameObject.z).abs() > radius) continue;
      final distance = getDistanceXYZSquared(
          mouseX, mouseY, mouseZ, gameObject.x, gameObject.y, gameObject.z,
      );
      if (anyFound && distance > closestDistanceSquared) continue;
      anyFound = true;
      closestDistanceSquared = distance;
      closestCollider = gameObject;
    }

    player.aimTarget = closestCollider;
  }

  /// returns a number between 0.0 and 1.0
  double calculateHitRate({
    required double angle,
    required double maxAngle,
    required double distance,
    required double maxDistance,
  }) {
    if (
      angle > maxAngle ||
      distance > maxDistance ||
      maxAngle <= 0 ||
      maxDistance <= 0
    ){
      return 0;
    }

    return (inverseProportion(angle, maxAngle) +
           inverseProportion(distance, maxDistance)) / 2.0;
  }

  /// @areaDamage a value between 0.0 and 1.0
  void applyHitMelee({
    required Character character,
    required DamageType damageType,
    required double range,
    required double damage,
    required int ailmentDuration,
    required double ailmentDamage,
    required double maxHitRadian,
    required double areaDamage,
  }){
    areaDamage = areaDamage.clamp(0, 1);

    final characterAngle = character.angle;
    var attackHit = false;
    Collider? hitTarget = null;

    dispatchGameEventPosition(
      GameEvent.Melee_Attack_Performed,
      character,
    );

    if (damage <= 0) {
      dispatchAttackHitNothing(
        character.x,
        character.y,
        character.z,
        character,
      );
      return;
    }

    var highestHitRate = 0.0;

    final characters = this.characters;
    for (final other in characters) {

      final otherDistance = character.getDistance(other) - other.radius;
      final otherFaceAngleDiff = character.getFaceAngleDiff(other).abs();

      final otherHitRate = calculateHitRate(
        angle: otherFaceAngleDiff,
        distance: otherDistance,
        maxAngle: maxHitRadian,
        maxDistance: range,
      );

      if (
        otherHitRate <= 0 ||
        otherHitRate < highestHitRate ||
        other.invincible ||
        other.dead ||
        !other.hitable ||
        // !other.active ||
        character.onSameTeam(other)
      ) continue;

      highestHitRate = otherHitRate;
      hitTarget = other;
    }

    final gameObjects = this.gameObjects;
    final gameObjectsLength = gameObjects.length;

    for (var i = 0; i < gameObjectsLength; i++) {
      final gameObject = gameObjects[i];
      final gameObjectDistance = character.getDistance(gameObject) - gameObject.radius;
      final otherFaceAngleDiff = character.getFaceAngleDiff(gameObject).abs();

      final otherHitRate = calculateHitRate(
        angle: otherFaceAngleDiff,
        distance: gameObjectDistance,
        maxAngle: maxHitRadian,
        maxDistance: range,
      );

      if (
        otherHitRate <= 0 ||
        otherHitRate < highestHitRate ||
        // !gameObject.active ||
        !gameObject.hitable
      ) continue;

      highestHitRate = otherHitRate;
      hitTarget = gameObject;
    }

    if (hitTarget != null) {
      applyHit(
        target: hitTarget,
        damage: damage,
        srcCharacter: character,
        damageType: DamageType.Melee,
        ailmentDuration: ailmentDuration,
        ailmentDamage: ailmentDamage,
      );
    }

    if (areaDamage > 0) {
      for (final other in characters) {
        if (other == hitTarget) continue;

        final otherDistance = character.getDistance(other) - other.radius;
        final otherFaceAngleDiff = character.getFaceAngleDiff(other).abs();

        final otherHitRate = calculateHitRate(
          angle: otherFaceAngleDiff,
          distance: otherDistance,
          maxAngle: maxHitRadian,
          maxDistance: range,
        );

        if (
            otherHitRate <= 0 ||
            other.invincible ||
            other.dead ||
            !other.hitable ||
            // !other.active ||
            character.onSameTeam(other)
        ) continue;

        final finalRate = areaDamage * otherHitRate;
        final finalDamage = damage * finalRate;

        if (finalDamage <= 0) continue;

        attackHit = true;
        applyHit(
          srcCharacter: character,
          target: other,
          damage: finalDamage,
          damageType: damageType,
          ailmentDuration: (ailmentDuration * finalRate).toInt(),
          ailmentDamage: ailmentDamage * finalRate,
        );
      }
    }

    if (attackHit) return;

    final attackRadiusHalf = range * 0.5;
    final performX = character.x + adj(characterAngle, attackRadiusHalf);
    final performY = character.y + opp(characterAngle, attackRadiusHalf);
    final performZ = character.z;

    if (!scene.inboundsXYZ(performX, performY, performZ)) {
      return;
    }

    final nodeIndex = scene.getIndexXYZ(performX, performY, performZ);
    final nodeType = scene.nodeTypes[nodeIndex];

    if (!NodeType.isRainOrEmpty(nodeType)) {
      attackHit = true;
      for (final player in players) {
        if (!player.withinRadiusEventDispatch(performX, performY)) continue;
        player.writeGameEvent(
          type: GameEvent.Node_Struck,
          x: performX,
          y: performY,
          z: performZ,
        );
      }
    }

    if (NodeType.isDestroyable(nodeType)) {
      destroyNode(nodeIndex);
      attackHit = true;
    }

    if (attackHit) return;
    dispatchAttackHitNothing(
      performX,
      performY,
      performZ,
      character,
    );
  }

  void dispatchAttackHitNothing(
      double performX,
      double performY,
      double performZ,
      Character character,
  ) {
    for (final player in players) {
      if (!player.withinRadiusEventDispatch(performX, performY)) continue;
      player.writeGameEvent(
        type: GameEvent.Attack_Hit_Nothing,
        x: performX,
        y: performY,
        z: performZ,
      );
      player.writeUInt16(character.weaponType);
    }
  }

  void destroyNode(int nodeIndex) {
    final orientation = scene.nodeOrientations[nodeIndex];
    final nodeType = scene.nodeTypes[nodeIndex];
    if (nodeType == NodeType.Empty) return;
    setNode(
      nodeIndex: nodeIndex,
      nodeType: NodeType.Empty,
      orientation: NodeOrientation.None,
    );
    customOnNodeDestroyed(nodeType, nodeIndex, orientation);
  }

  // void activate(Collider collider) {
  //   // if (collider.active) return;
  //   // collider.active = true;
  //   if (collider is GameObject) {
  //     collider.dirty = true;
  //   }
  //   if (collider is IsometricPlayer) {
  //     collider.writePlayerActive();
  //   }
  //   onActivated(collider);
  // }

  void onGridChanged() {
    scene.refreshMetrics();
    dispatchDownloadScene();
  }

  // void deactivate(Collider collider) {
  //   if (!collider.active) return;
  //   collider.deactivate();
  //   clearTarget(collider);
  // }

  void dispatchGameEventCharacterDeath(Character character) {
    final players = this.players;
    for (final player in players) {
      player.writeGameEvent(
        type: GameEvent.Character_Death,
        x: character.x,
        y: character.y,
        z: character.z,
      );
      player.writeAngle(character.velocityAngle);
      player.writeByte(character.characterType);
    }
  }

  void dispatchGameEventGameObjectDestroyed(GameObject gameObject) {
    final players = this.players;
    for (final player in players) {
      player.writeGameEventGameObjectDestroyed(gameObject);
    }
  }

  void setSecondsPerFrame(int value){
    if (value < 0){
      return;
    }
    time.secondsPerFrame = value;
    dispatchByte(NetworkResponse.Isometric);
    dispatchByte(NetworkResponseIsometric.Seconds_Per_Frame);
    dispatchUInt16(value);
  }

  void setHourMinutes(int hour, int minutes) {
    time.time = (hour * 60 * 60) + (minutes * 60);
    playersWriteWeather();
  }

  void updateColliderSceneCollisionHorizontal(Collider collider) {
    const Shifts = 5;
    final z = collider.z + Node_Height_Half;
    final scene = this.scene;

    if (scene.getCollisionAt(collider.boundsLeft, collider.y, z)) {
      if (collider.velocityX < 0) {
        collider.velocityX = -collider.velocityX;
      }
      final colliderY = collider.y;
      for (var i = 0; i < Shifts; i++) {
        collider.x++;
        if (!scene.getCollisionAt(collider.boundsLeft, colliderY, z)) break;
      }
    }
    if (scene.getCollisionAt(collider.boundsRight, collider.y, z)) {
      if (collider.velocityX > 0) {
        collider.velocityX = -collider.velocityX;
      }
      final colliderY = collider.y;
      for (var i = 0; i < Shifts; i++) {
        collider.x--;
        if (!scene.getCollisionAt(collider.boundsRight, colliderY, z)) break;
      }
    }
    if (scene.getCollisionAt(collider.x, collider.boundsTop, z)) {
      if (collider.y < 0) {
        collider.velocityY = -collider.velocityY;
      }
      final colliderX = collider.x;
      for (var i = 0; i < Shifts; i++) {
        collider.y++;
        if (!scene.getCollisionAt(colliderX, collider.boundsTop, z)) break;
      }
    }
    if (scene.getCollisionAt(collider.x, collider.boundsBottom, z)) {
      if (collider.y > 0) {
        collider.velocityY = -collider.velocityY;
      }
      final colliderX = collider.x;
      for (var i = 0; i < Shifts; i++) {
        collider.y--;
        if (!scene.getCollisionAt(colliderX, collider.boundsBottom, z)) break;
      }
    }
  }

  void updateGameObjects() {
    var sortRequired = false;
    final gameObjects = this.gameObjects;
    for (var i = 0; i < gameObjects.length; i++) {
      final gameObject = gameObjects[i];
      updateColliderPhysics(gameObject);

      if (gameObject.deactivationTimer > 0) {
        gameObject.deactivationTimer--;
        if (gameObject.deactivationTimer <= 0){
          remove(gameObject);
          continue;
        }
      }

      if (!gameObject.dirty) {
        continue;
      }

      if (gameObject.z < 0){
        destroyGameObject(gameObject);
        continue;
      }

      sortRequired = true;
      cleanGameObject(gameObject);
    }

    if (sortRequired) {
      sortGameObjects();
    }
  }

  void cleanGameObject(GameObject gameObject){
    gameObject.dirty = false;
    for (final player in players) {
      player.writeGameObject(gameObject);
    }
  }

  void sortGameObjects(){
    gameObjects.sort();
    playersWriteByte(NetworkResponse.Scene);
    playersWriteByte(NetworkResponseScene.Sort_GameObjects);
  }

  void updateCharacterTarget(Character character){

    if (character.busy || !character.autoTarget){
      return;
    }

    if (character.autoTargetTimer-- > 0){
      return;
    }

    if (character.target != null && character.autoTarget){
      if (character.distanceFromStartSquared > pow(character.maxFollowDistance, 2)){
        character.setCharacterStateIdle(duration: 20);
        character.clearTarget();
        character.setRunDestinationToStart();
        return;
      }
    }

    character.autoTargetTimer = character.autoTargetTimerDuration;

    if (randomChance(character.chanceOfSetTarget)){
      setCharacterTarget(character, findNearestEnemy(
        character,
        radius: character.autoTargetRange,
      ));
    }
  }

  void updateColliderPhysics(Collider collider) {
    // assert (collider.active);

    collider.updateVelocity();

    if (collider.z < 0) {
      if (collider is Character) {
        setCharacterStateDead(collider);
        return;
      }
      // deactivate(collider);
      return;
    }

    if (!collider.fixed) {
      updateColliderSceneCollision(collider);
    }
  }

  void createExplosion({
    required double x,
    required double y,
    required double z,
    required Character srcCharacter,
    required double radius,
    required double damage,
    required int ailmentDuration,
    required double ailmentDamage,
  }) {
    if (!scene.inboundsXYZ(x, y, z)) return;
    dispatchGameEvent(GameEvent.Explosion, x, y, z);
    final length = characters.length;

    if (scene.inboundsXYZ(x, y, z - Node_Height_Half)) {
      dispatchGameEvent(
        GameEvent.Node_Struck,
        x,
        y,
        z - Node_Height_Half,
      );
    }

    final gameObjectsLength = gameObjects.length;
    for (var i = 0; i < gameObjectsLength; i++) {
      final gameObject = gameObjects[i];
      // if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;
      if (!gameObject.withinRadiusXYZ(x, y, z, radius)) continue;
      applyHit(
        angle: gameObject.getAngleXY(x, y),
        target: gameObject,
        srcCharacter: srcCharacter,
        damage: damage,
        friendlyFire: true,
        damageType: DamageType.Fire,
        ailmentDamage: ailmentDamage,
        ailmentDuration: ailmentDuration,
      );
    }

    for (var i = 0; i < length; i++) {
      final character = characters[i];
      if (!character.hitable) continue;
      // if (!character.active) continue;
      if (character.dead) continue;
      if (!character.withinRadiusXYZ(x, y, z, radius)) continue;
      applyHit(
        angle: character.getAngleXY(x, y),
        target: character,
        srcCharacter: srcCharacter,
        damage: damage,
        friendlyFire: true,
        damageType: DamageType.Fire,
        ailmentDamage: ailmentDamage,
        ailmentDuration: ailmentDuration,
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

    customUpdate();
    updateGameObjects();
    updateCollisions();
    updateCharacters();
    updateProjectiles(); // called twice to fix collision detection
    updateProjectiles(); // called twice to fix collision detection
    updateProjectiles(); // called twice to fix collision detection

    if (gameObjectsOrderDirty){
      sortGameObjects();
      gameObjectsOrderDirty = false;
    }

    sortColliders();
  }

  void revive(Character player) {
    if (player.aliveAndActive) return;

    player.setCharacterStateSpawning();
    player.physical = true;
    player.hitable = true;
    player.health = player.maxHealth;
    clearCharacterTarget(player);

    if (player is T){
      customOnPlayerRevived(player);
      player.writePlayerMoved();
      player.writePlayerAlive();
      player.writePlayerEvent(PlayerEvent.Spawned);
      player.writePlayerHealth();
      player.writeGameTime();
      player.health = player.maxHealth;
    }
  }

  void playersWriteWeather() {
    for (final player in players) {
      player.writeWeather();
      player.writeGameTime();
      player.writeEnvironmentLightningFlashing();
    }
  }

  void writeLightningFlashing(){
    if (!environment.lightningFlashing) {
      return;
    }

    for (final player in players) {
      player.writeEnvironmentLightningFlashing();
    }
  }

  double getCharacterDamageTypeResistance(Character character, DamageType damageType){
     return 0;
  }

  void applyDamageToCharacter({
    required Character src,
    required Character target,
    required double amount,
    required DamageType damageType,
    required int ailmentDuration,
    required double ailmentDamage,
  }) {
    if (target.dead || target.invincible) return;

    final resistance = getCharacterDamageTypeResistance(target, damageType).clamp01();
    final resistanceInverted = 1.0 - resistance;
    final resistedAmount = amount * resistanceInverted;
    final resistedAilmentDuration = (ailmentDuration * resistanceInverted).toInt();

    if (resistedAilmentDuration > 0){
      if (damageType == DamageType.Ice) {
        target.conditionColdDuration += resistedAilmentDuration;
      }
      if (damageType == DamageType.Fire) {
        target.conditionBurningDuration += resistedAilmentDuration;
        target.ailmentBurningSrc = src;
        target.conditionBurningDamage = ailmentDamage;
      }
    }


    final damage = min(resistedAmount, target.health);
    target.health -= damage;
    onDamageApplied(
      src: src,
      target: target,
      amount: damage,
    );

    if (target.health <= 0) {
      target.facePosition(src, force: true);
      setCharacterStateDead(target);
      customOnCharacterKilled(target, src);
      return;
    }

    if (target.target == null && target.autoTarget) {
      setCharacterTarget(target, src);
    }

    target.setCharacterStateHurt();
    dispatchGameEventCharacterHurt(target);
  }

  void onDamageApplied({
    required Character src,
    required Character target,
    required double amount,
  }) {

  }

  /// Can be safely overridden to customize behavior

  void dispatchGameEventCharacterHurt(Character character) {
    for (final player in players) {
      final targetVelocityAngle = character.velocityAngle;
      player.writeGameEvent(
        type: GameEvent.Character_Hurt,
        x: character.x,
        y: character.y,
        z: character.z,
      );
      player.writeAngle(targetVelocityAngle);
      player.writeByte(character.characterType);
    }
  }

  void updateCharacters() {
    final characters = this.characters;
    for (var i = 0; i < characters.length; i++) {
      updateCharacter(characters[i]);
    }
  }

  void updateCollisions() {
    resolveCollisions(characters);
    resolveCollisions(gameObjects);
    resolveCollisionsBetween(characters, gameObjects);
  }

  void resolveCollisions(List<Collider> colliders) {
    final numberOfColliders = colliders.length;
    final numberOfCollidersMinusOne = numberOfColliders - 1;
    for (var i = 0; i < numberOfCollidersMinusOne; i++) {
      final colliderI = colliders[i];
      if (!colliderI.collidable) continue;
      final colliderIOrder = colliderI.order;
      final colliderIRadius = colliderI.radius;
      final colliderIBoundsBottom = colliderI.boundsBottom;
      final colliderIBoundsRight = colliderI.boundsRight;
      final colliderIBoundsLeft = colliderI.boundsLeft;
      final colliderIZ = colliderI.z;

      for (var j = i + 1; j < numberOfColliders; j++) {
        final colliderJ = colliders[j];
        if (!colliderJ.collidable) {
          continue;
        }
        if (colliderJ.order - colliderIOrder > (colliderIRadius + colliderJ.radius)){
          break;
        }
        if (colliderJ.boundsTop > colliderIBoundsBottom) {
          continue;
        }

        final colliderJX = colliderJ.x;
        final colliderJRadius = colliderJ.radius;
        final colliderJBoundsLeft = colliderJX - colliderJRadius;

        if (colliderJBoundsLeft > colliderIBoundsRight){
          continue;
        }

        final colliderJBoundsRight = colliderJX + colliderJRadius;

        if (
          colliderJBoundsRight < colliderIBoundsLeft ||
          (colliderJ.z - colliderIZ).abs() > Node_Height
        ) continue;
        internalOnCollisionBetweenColliders(colliderJ, colliderI);
      }
    }
  }

  void resolveCollisionsBetween(
      List<Collider> collidersA,
      List<Collider> collidersB,
  ) {
    var bStart = 0;
    for (var indexA = 0; indexA < collidersA.length; indexA++) {
      final colliderA = collidersA[indexA];
      if (!colliderA.collidable) continue;
      final colliderAOrder = colliderA.order;
      final colliderARadius = colliderA.radius;
      final colliderATop = colliderA.boundsTop;
      final colliderABottom = colliderA.boundsBottom;
      final colliderARight = colliderA.boundsRight;
      final colliderALeft = colliderA.boundsLeft;
      for (var indexB = bStart; indexB < collidersB.length; indexB++) {
        final colliderB = collidersB[indexB];
        if (!colliderB.collidable) continue;
        final colliderBorder = colliderB.order;

        final orderDiff = colliderBorder - colliderAOrder;

        if (orderDiff < -colliderARadius - colliderB.radius) {
          bStart++;
          continue;
        }

        if (orderDiff > colliderARadius + colliderB.radius) {
          break;
        }

        if (colliderABottom < colliderB.boundsTop) continue;
        if (colliderATop > colliderB.boundsBottom) continue;
        if (colliderARight < colliderB.boundsLeft) continue;
        if (colliderALeft > colliderB.boundsRight) continue;
        if ((colliderA.z - colliderB.z).abs() > Node_Height) continue;
        if (colliderA == colliderB) continue;
        internalOnCollisionBetweenColliders(colliderA, colliderB);
      }
    }
  }

  void internalOnCollisionBetweenColliders(Collider a, Collider b) {
    assert (a != b);
    if (a.physical && b.physical) {
      resolveCollisionPhysics(a, b);
    }

    if (a is T) {
      if (b is GameObject) {
        customOnCollisionBetweenPlayerAndGameObject(a, b);
      }
      customOnCollisionBetweenPlayerAndOther(a, b);
    }
    if (b is T) {
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
    characters.sort();
    projectiles.sort();
  }

  void setCharacterStateChanging(Character character) {
    if (!character.canChangeEquipment) return;
    character.characterState = CharacterState.Changing;
    dispatchGameEventPosition(GameEvent.Character_Changing, character);
  }

  void setCharacterStateDead(Character character) {
    if (character.characterState == CharacterState.Dead) return;

    final characters = this.characters;
    for (final otherCharacter in characters){
      if (otherCharacter.target == character) {
        otherCharacter.onTargetDead();
      }
    }

    dispatchGameEventCharacterDeath(character);
    character.health = 0;
    character.conditionColdDuration = 0;
    character.characterState = CharacterState.Dead;
    character.actionDuration = 0;
    character.physical = false;
    character.hitable = false;
    character.actionFrame = -1;
    character.clearFrame();
    character.clearPath();
    character.setDestinationToCurrentPosition();
    clearCharacterTarget(character);
    customOnCharacterDead(character);

    if (character is T) {
      customOnPlayerDead(character);
      character.writePlayerAlive();
    }
  }

  void changeCharacterHealth(Character character, int amount) {
    if (character.dead) return;
    character.health += amount;
    if (character.health > 0) return;
    setCharacterStateDead(character);
  }

  // void deactivateProjectile(Projectile projectile) {
  //   // assert (projectile.active);
  //   // projectile.active = false;
  //   projectile.parent = null;
  //   projectile.target = null;
  //
  // }

  void updateProjectiles() {
    final projectiles = this.projectiles;
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      // if (!projectile.active) continue;
      projectile.x += projectile.velocityX;
      projectile.y += projectile.velocityY;
      final target = projectile.target;
      if (target != null) {
        projectile.reduceDistanceZFrom(target);
      } else if (projectile.overRange) {
        // deactivateProjectile(projectile);
        remove(projectile);
      }
    }
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      // if (!projectile.active) continue;
      if (!scene.getCollisionAt(projectile.x, projectile.y, projectile.z)) {
        continue;
      }
      remove(projectile);

      final nodeType = scene.getTypeXYZ(
          projectile.x, projectile.y, projectile.z);

      if (!NodeType.isRainOrEmpty(nodeType)) {
        final players = this.players;
        for (final player in players) {
          if (!player.withinRadiusEventDispatchPos(projectile)) continue;
          player.writeGameEvent(
            type: GameEvent.Node_Struck,
            x: projectile.x,
            y: projectile.y,
            z: projectile.z,
          );
        }
      }
    }

    checkProjectileCollision(characters);
    checkProjectileCollision(gameObjects);
  }

  void remove(Position? instance) {
    if (instance == null) return;

    clearTarget(instance);

    if (instance is T) {
      removePlayer(instance);
    }

    if (instance is Character) {
      instance.target = null;
      characters.remove(instance);
      return;
    }

    if (instance is GameObject) {
      gameObjects.remove(instance);
      for (final player in players) {

        if (player.editState.selectedGameObject == instance){
          player.editorDeselectGameObject();
        }

        player.writeGameObjectDeleted(instance);
      }
      return;
    }

    if (instance is Projectile) {
      instance.parent = null;
      instance.target = null;
      projectiles.remove(instance);
      return;
    }

    throw Exception();
  }

  void clearTarget(Position position){
    final characters = this.characters;
    for (final character in characters){
      if (character.target != position) continue;
      character.clearTarget();
    }
    final projectiles = this.projectiles;
    for (final projectile in projectiles) {
      if (projectile.target == position) continue;
      projectile.clearTarget();
    }
  }

  void setCharacterStateSpawning(Character character) =>
      character.setCharacterStateSpawning();

  void checkProjectileCollision(List<Collider> colliders) {
    final projectiles = this.projectiles;
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      // if (!projectile.active) continue;
      if (!projectile.hitable) continue;
      final target = projectile.target;
      if (target != null) {
        if (projectile.withinRadiusPosition(target, projectile.radius)) {
          handleProjectileHit(projectile, target);
        }
        continue;
      }

      final projectileX = projectile.x;
      final projectileY = projectile.y;
      final projectileZ = projectile.z;
      final projectileRadius = projectile.radius;
      final projectileParent = projectile.parent;

      assert (target == null);
      for (var j = 0; j < colliders.length; j++) {
        final collider = colliders[j];
        if (projectileParent == collider) continue;
        // if (!collider.active) continue;
        if (!collider.hitable) continue;
        final combinedRadius = collider.radius + projectileRadius;
        if ((collider.x - projectileX).abs() > combinedRadius) continue;
        if ((collider.y - projectileY).abs() > combinedRadius) continue;
        if ((projectile.z - projectileZ).abs() > combinedRadius) continue;
        if (projectile.isAlly(collider) && !projectile.friendlyFire) continue;
        handleProjectileHit(projectile, collider);
        break;
      }
    }
  }

  void handleProjectileHit(Projectile projectile, Position target) {
    // assert (projectile.active);
    assert (projectile != target);
    assert (projectile.parent != target);

    final owner = projectile.parent;
    if (owner == null) return;

    if (target is Collider) {
      applyHit(
        angle: projectile.velocityAngle,
        srcCharacter: owner,
        target: target,
        damage: projectile.damage,
        damageType: projectile.damageType,
        ailmentDuration: projectile.ailmentDuration,
        ailmentDamage: projectile.ailmentDamage
      );
    }

    remove(projectile);
    if (projectile.type == ProjectileType.Arrow) {
      dispatchGameEvent(GameEvent.Arrow_Hit, target.x, target.y, target.z);
    }
  }

  void applyHit({
    required Character srcCharacter,
    required Collider target,
    required double damage,
    required DamageType damageType,
    required int ailmentDuration,
    required double ailmentDamage,
    double? angle,
    double force = 0,
    bool friendlyFire = false,
  }) {
    if (!target.hitable) return;

    if (force > 0) {
      target.applyForce(
        force: force,
        angle: angle ?? target.getAngle(srcCharacter),
      );
    }


    target.clampVelocity(Physics.Max_Velocity);

    dispatchGameEventPosition(
        GameEvent.Material_Struck,
        target,
    );
    dispatchByte(target.materialType);

    if (target is GameObject){
      if (target.healthMax > 0){
        target.health = clamp(target.health - damage, 0, target.healthMax);
        target.dirty = true;
        if (target.health <= 0) {
          destroyGameObject(target);
        }
      }
      return;
    }

    if (target is Character) {
      if (!friendlyFire && srcCharacter.onSameTeam(target)) return;
      if (target.dead) return;
      applyDamageToCharacter(
          src: srcCharacter,
          target: target,
          amount: damage,
          damageType: damageType,
          ailmentDuration: ailmentDuration,
          ailmentDamage: ailmentDamage,
      );
      return;
    }
  }

  void updateCharacter(Character character) {

    if (character.dead) {
      character.updateAilments();

      if (character.animationFrame < Character.maxAnimationDeathFrames){
        character.applyFrameVelocity();
      }

      if (character.reviveTimer > 0){
        character.reviveTimer--;
        if (character.reviveTimer <= 0) {
           revive(character);
        }
      }

      return;
    }

    if (character.conditionIsBurning) {
       if (frame % fps == 0) {
         final burnRadius = character.conditionBurningRadius;
         final src = character.ailmentBurningSrc ?? (throw Exception('character.ailmentBurningSrc is null'));
         for (final otherCharacter in characters) {
           if (!otherCharacter.withinRadiusPosition(character, burnRadius)) continue;
           applyDamageToCharacter(
             src: src,
             target: character,
             amount: character.conditionBurningDamage,
             damageType: DamageType.Fire,
             ailmentDuration: 0,
             ailmentDamage: 0,
           );
         }
       }
    }

    updateCharacterTarget(character);
    updateCharacterTargetPerceptible(character);
    updateColliderPhysics(character);
    updateCharacterAction(character);
    updateCharacterPath(character);
    updateCharacterState(character);
    character.update();
  }

  void updateCharacterState(Character character) {

    if (character.shouldPerformStart) {
      performCharacterStart(character);
    }

    if (character.shouldPerformAction) {
      performCharacterAction(character);

      if (character is IsometricPlayer) {
        character.clearTarget();
      }
    }

    if (character.shouldPerformEnd) {
      performCharacterEnd(character);
    }

    if (character.running) {
      character.applyForce(
        force: character.runSpeed,
        angle: character.angle,
      );
      if (character.frame % 10 == 0) {
        dispatchGameEvent(
          GameEvent.Footstep,
          character.x,
          character.y,
          character.z,
        );
        character.velocityZ += 1;
      }
    } else if (character.firing) {
      if (character.frame == 0){
        dispatchGameEvent(
          GameEvent.Bow_Drawn,
          character.x,
          character.y,
          character.z,
        );
      }
    }

    character.applyFrameVelocity();
  }

  void performCharacterStart(Character character){

  }

  void performCharacterAction(Character character){
    final weaponType = character.weaponType;
    if (WeaponType.valuesMelee.contains(weaponType)) {
      if (attackAlwaysHitsTarget) {
        final target = character.target;
        if (target is Collider) {
          applyHit(
            srcCharacter: character,
            target: target,
            damage: character.attackDamage,
            damageType: DamageType.Melee,
            ailmentDamage: 0,
            ailmentDuration: 0,
          );
        }
        return;
      }
      applyHitMelee(
        character: character,
        damageType: DamageType.Melee,
        range: character.attackRange,
        damage: character.attackDamage,
        areaDamage: 0,
        ailmentDuration: 0,
        ailmentDamage: 0,
        maxHitRadian: 90 * degreesToRadians,
      );
      return;
    }

    if (WeaponType.isBow(weaponType)) {
      dispatchGameEvent(
        GameEvent.Bow_Released,
        character.x,
        character.y,
        character.z,
      );
      spawnProjectileArrow(
        src: character,
        damage: character.attackDamage,
        range: character.attackRange,
        angle: character.angle,
      );
      return;
    }
  }

  void performCharacterEnd(Character character) {
    if (character.dead) {
      return;
    }

    character.clearAction();
  }

  void spawnProjectileArrow({
    required Character src,
    required double damage,
    required double range,
    Position? target,
    double? angle,
  }) {
    assert (range > 0);
    assert (damage > 0);
    spawnProjectile(
      src: src,
      range: range,
      target: target,
      angle: target != null ? null : angle ?? src.angle,
      projectileType: ProjectileType.Arrow,
      damage: damage,
      ailmentDuration: 0,
      ailmentDamage: 0,
    );
  }

  void spawnProjectileIceArrow({
    required Character src,
    required double damage,
    required double range,
    required int ailmentDuration,
    required double ailmentDamage,
    Position? target,
    double? angle,

  }) {
    assert (range > 0);
    assert (damage > 0);
    spawnProjectile(
      src: src,
      range: range,
      target: target,
      angle: target != null ? null : angle ?? src.angle,
      projectileType: ProjectileType.Ice_Arrow,
      damage: damage,
      ailmentDuration: ailmentDuration,
      ailmentDamage: ailmentDamage,
    );
  }

  void spawnProjectileFireArrow({
    required Character src,
    required double damage,
    required double range,
    required int ailmentDuration,
    required double ailmentDamage,
    Position? target,
    double? angle,
  }) {
    assert (range > 0);
    assert (damage > 0);
    spawnProjectile(
      src: src,
      range: range,
      target: target,
      angle: target != null ? null : angle ?? src.angle,
      projectileType: ProjectileType.Fire_Arrow,
      damage: damage,
      ailmentDuration: ailmentDuration,
      ailmentDamage: ailmentDamage
    );
  }

  Projectile spawnProjectile({
    required Character src,
    required double range,
    required int projectileType,
    required double damage,
    required int ailmentDuration,
    required double ailmentDamage,
    double? angle = 0,
    Position? target,
  }) {
    assert (range > 0);
    assert (damage > 0);
    final projectile = getInstanceProjectile();

    dispatchGameEvent(GameEvent.Projectile_Fired, src.x, src.y, src.z);
    dispatchByte(projectileType);

    var finalAngle = angle;
    if (finalAngle == null) {
      finalAngle = target != null ? src.getAngle(target) : src.angle;
    }
    projectile.ailmentDuration = ailmentDuration;
    projectile.ailmentDamage = ailmentDamage;
    projectile.damage = damage;
    projectile.hitable = true;
    // projectile.active = true;
    if (target is Position) {
      projectile.target = target;
    }
    final r = 5.0;
    projectile.x = src.x + adj(finalAngle, r);
    projectile.y = src.y + opp(finalAngle, r);
    projectile.z = src.z + Character_Gun_Height;
    projectile.startPositionX = projectile.x;
    projectile.startPositionY = projectile.y;
    projectile.startPositionZ = projectile.z;
    projectile.parent = src;
    projectile.team = src.team;
    projectile.range = range;
    projectile.type = projectileType;
    projectile.radius = ProjectileType.getRadius(projectileType);
    projectile.setVelocity(finalAngle, ProjectileType.getSpeed(projectileType));

    return projectile;
  }

  Projectile getInstanceProjectile() {
    final projectile = Projectile(
      x: 0,
      y: 0,
      z: 0,
      team: 0,
      materialType: MaterialType.None,
    );
    projectiles.add(projectile);
    return projectile;
  }

  void actionMovePositionToIndex(Position position, int index) {
    final scene = this.scene;
    position.x = scene.getIndexX(index);
    position.y = scene.getIndexY(index);
    position.z = scene.getIndexZ(index);
  }

  // GameObject spawnGameObject({
  //   required double x,
  //   required double y,
  //   required double z,
  //   required int type,
  //   required int subType,
  //   required int team,
  //   required int health,
  //   required bool interactable,
  //   required int deactivationTimer,
  // }) {
  //   final instance = GameObject(
  //     x: x,
  //     y: y,
  //     z: z,
  //     itemType: type,
  //     subType: subType,
  //     id: generateUniqueGameObjectId(),
  //     team: team,
  //     health: health,
  //     interactable: interactable,
  //     deactivationTimer: deactivationTimer,
  //   );
  //
  //   instance.dirty = true;
  //   gameObjects.add(instance);
  //   onGameObjectSpawned(instance);
  //   return instance;
  // }

  void dispatchByte(int byte){
    if (byte < 0 || byte > 255){
      throw Exception('dispatchByte($byte)');
    }

    final players = this.players;
    for (final player in players) {
      player.writeByte(byte);
    }
  }

  void dispatchUInt16(int value){
    final players = this.players;
    for (final player in players) {
      player.writeUInt16(value);
    }
  }

  void dispatchDouble(double value){
    final players = this.players;
    for (final player in players) {
      player.writeDouble(value);
    }
  }

  void dispatchGameEventPosition(int gameEventType, Position position) =>
      dispatchGameEvent(
          gameEventType,
          position.x,
          position.y,
          position.z,
      );

  void dispatchGameEventIndex(int gameEventType, int index) =>
      dispatchGameEvent(
          gameEventType,
          scene.getIndexX(index),
          scene.getIndexY(index),
          scene.getIndexZ(index),
      );

  void dispatchGameEvent(int gameEvent, double x, double y, double z) {
    final players = this.players;
    for (final player in players) {
      player.writeGameEvent(
          type: gameEvent,
          x: x,
          y: y,
          z: z,
      );
    }
  }

  void onPlayerRemoved(IsometricPlayer player) {
    players.remove(player);
    characters.remove(player);
    customOnPlayerDisconnected(player);
  }

  void playerDeleteEditorSelectedGameObject(IsometricPlayer player) {
    remove(player.editState.selectedGameObject);
  }

  void updateColliderSceneCollision(Collider collider) {
    updateColliderSceneCollisionVertical(collider);
    updateColliderSceneCollisionHorizontal(collider);
  }

  void internalOnColliderEnteredWater(Collider collider) {
    // deactivate(collider);
    if (collider is Character) {
      setCharacterStateDead(collider);
    }
    dispatchGameEventPosition(GameEvent.Splash, collider);
  }

  void updateColliderSceneCollisionVertical(Collider collider) {
    final scene = this.scene;
    if (!scene.isInboundV3(collider)) {
      if (collider.z > -100) return;
      // deactivate(collider);
      if (collider is Character) {
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
    final nodeBottomOrientation = scene.nodeOrientations[nodeBottomIndex];
    final nodeBottomType = scene.nodeTypes[nodeBottomIndex];

    if (nodeBottomOrientation == NodeOrientation.Solid) {
      final nodeTop = ((bottomZ ~/ Node_Height) * Node_Height) + Node_Height;
      if (nodeTop - bottomZ > Physics.Max_Vertical_Collision_Displacement) {
        return;
      }
      collider.z = nodeTop;
      if (collider.velocityZ < 0) {
        if (collider.physicsBounce) {
          collider.velocityZ =
              -collider.velocityZ * Physics.Bounce_Friction;
          dispatchGameEventPosition(
              GameEvent.Item_Bounce,
              collider,
          );
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

      if (nodeTop - bottomZ > Physics.Max_Vertical_Collision_Displacement) {
        return;
      }

      if (collider.velocityZ < 0) {
        if (collider.physicsBounce) {
          collider.velocityZ =
              -collider.velocityZ * Physics.Bounce_Friction;
          dispatchGameEventPosition(
              GameEvent.Item_Bounce,
              collider,
          );
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
      // deactivate(collider);
      if (collider is Character) {
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
    final nodeBottomOrientation = scene.nodeOrientations[nodeBottomIndex];
    final nodeBottomType = scene.nodeTypes[nodeBottomIndex];

    if (nodeBottomOrientation == NodeOrientation.Solid) {
      final nodeTop = ((bottomZ ~/ Node_Height) * Node_Height) + Node_Height;
      if (nodeTop - bottomZ > Physics.Max_Vertical_Collision_Displacement) {
        return;
      }
      collider.z = nodeTop;
      if (collider.velocityZ < 0) {
        if (collider.physicsBounce) {
          collider.velocityZ =
              -collider.velocityZ * Physics.Bounce_Friction;
          dispatchGameEventPosition(
              GameEvent.Item_Bounce,
              collider,
          );
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

      if (nodeTop - bottomZ > Physics.Max_Vertical_Collision_Displacement) {
        return;
      }

      collider.z = nodeTop;

      if (collider.velocityZ < 0) {
        if (collider.physicsBounce) {
          collider.velocityZ =
              -collider.velocityZ * Physics.Bounce_Friction;
          dispatchGameEventPosition(
              GameEvent.Item_Bounce,
              collider,
          );
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

  void setNodeEmpty(int index) =>
    setNode(
      nodeIndex: index,
      nodeType: NodeType.Empty,
      orientation: NodeOrientation.None,
    );

  void setNode({
    required int nodeIndex,
    int? nodeType,
    int? orientation,
    int? variation,
  }) {
    assert (nodeIndex >= 0);

    if (nodeIndex >= scene.nodeTypes.length) {
      throw Exception(
          "game.setNode(nodeIndex: $nodeIndex) - node index out of bounds"
      );
    }

    nodeType ??= scene.nodeTypes[nodeIndex];

    orientation ??= scene.nodeOrientations[nodeIndex];

    variation ??= scene.variations[nodeIndex];

    if (!NodeType.supportsOrientation(nodeType, orientation)) {
      orientation = NodeType.getDefaultOrientation(nodeType);
    }

    scene.nodeOrientations[nodeIndex] = orientation;
    scene.nodeTypes[nodeIndex] = nodeType;
    scene.variations[nodeIndex] = variation;

    final players = this.players;
    for (final player in players) {
      player.writeNode(
        index: nodeIndex,
        type: nodeType,
        shape: orientation,
        variation: variation,
      );
    }
  }

  void clearCharacterTarget(Character character) {
    if (character.target == null) return;
    setCharacterTarget(character, null);
    character.setCharacterStateIdle();
  }

  /// WARNING EXPENSIVE OPERATION
  void clearSpawnedAI() {
    final characters = this.characters;
    for (var i = 0; i < characters.length; i++) {
      if (characters[i] is IsometricPlayer) continue;
      characters.removeAt(i);
      i--;
    }
  }

  /// FUNCTIONS
  static void setGridPosition(
      {required Position position, required int z, required int row, required int column}) {
    position.x = row * Node_Size + Node_Size_Half;
    position.y = column * Node_Size + Node_Size_Half;
    position.z = z * Node_Size_Half;
  }

  static void setPositionZ(Position position, int z) {
    position.z = z * Node_Size_Half;
  }

  static void setPositionColumn(Position position, int column) {
    position.y = column * Node_Size + Node_Size_Half;
  }

  static void setPositionRow(Position position, int row) {
    position.x = row * Node_Size + Node_Size_Half;
  }

  void playersDownloadScene() {
    for (final player in players) {
      player.downloadScene();
    }
  }

  void playersWriteByte(int byte) {
    for (final player in players) {
      player.writeByte(byte);
    }
  }

  bool sceneRaycastBetween(Collider a, Collider b) {
    final distance = a.getDistance(b);
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

  int getNodeIndexV3(Position value) =>
      scene.getIndex(value.indexZ, value.indexRow, value.indexColumn);

  int getNodeIndexV3Unsafe(Position value) =>
      scene.getIndexUnsafe(value.indexZ, value.indexRow, value.indexColumn);

  int getNodeIndexXYZ(double x, double y, double z){
      return scene.getIndexXYZ(x, y, z);
  }

  void customOnPlayerCollectGameObject(T player,
      GameObject target) {}

  void reset() {
    for (final gameObject in gameObjects) {
      gameObject.x = gameObject.startPositionX;
      gameObject.y = gameObject.startPositionY;
      gameObject.z = gameObject.startPositionZ;
    }
  }

  void destroyGameObject(GameObject gameObject) {
    dispatchGameEventGameObjectDestroyed(gameObject);
    remove(gameObject);
    customOnGameObjectDestroyed(gameObject);
  }

  void customWriteGame() {
    notifyPlayersEnvironmentChanged();
    writeLightningFlashing();
  }

  void notifyPlayersEnvironmentChanged(){
    if (!environment.onChanged) {
      return;
    }

    environment.onChanged = false;
    playersWriteWeather();
  }

  int generateUniqueGameObjectId() {
     var i = 0;

     while (true) {
       if (gameObjects.any((element) => element.id == i)){
         i++;
         continue;
       }
       return i;
     }
  }

  Collider? getNearestCollider({
    required double x,
    required double y,
    required double z,
    required double maxRadius,
  }) {

    final nearestCharacter = getNearestCharacter(x, y, z, maxRadius: maxRadius);
    final nearestGameObject = getNearestGameObject(x: x, y: y, z: z, maxRadius: maxRadius);

    if (nearestCharacter == null){
      return nearestGameObject;
    }

    if (nearestGameObject == null){
      return nearestCharacter;
    }

    return
      nearestCharacter.getDistanceSquaredXYZ(x, y, z) <
      nearestGameObject.getDistanceSquaredXYZ(x, y, z) ?
        nearestCharacter : nearestGameObject;
  }

  Character? getNearestCharacter(double x, double y, double z, {double maxRadius = 10000}){
    Character? nearestCharacter;
    var nearestCharacterDistanceSquared = maxRadius * maxRadius;
    for (final character in characters){
      // if (!character.active) continue;
      final distanceSquared = character.getDistanceSquaredXYZ(x, y, z);
      if (distanceSquared > nearestCharacterDistanceSquared) continue;
      nearestCharacterDistanceSquared = distanceSquared;
      nearestCharacter = character;
    }
    return nearestCharacter;
  }

  GameObject? getNearestGameObject({
    required double x,
    required double y,
    required double z,
    double maxRadius = 10000,
  }){
    GameObject? nearestGameObject;
    var nearestGameObjectDistanceSquared = maxRadius * maxRadius;
    for (final gameObject in gameObjects){
      // if (!gameObject.active) continue;
      final distanceSquared = gameObject.getDistanceSquaredXYZ(x, y, z);
      if (distanceSquared > nearestGameObjectDistanceSquared) continue;
      nearestGameObjectDistanceSquared = distanceSquared;
      nearestGameObject = gameObject;
    }
    return nearestGameObject;
  }

  double clampX(double value)=> clamp(value, 0, scene.rowLength);

  double clampY(double value)=> clamp(value, 0, scene.columnLength);

  double clampZ(double value)=> clamp(value, 0, scene.heightLength);

  Collider? findNearestEnemy(Collider src, {double radius = 1000}){
    Collider? nearestEnemy;
    var nearestEnemyDistanceSquared = radius * radius;
    final characters = this.characters;
    for (final character in characters){
      if (!src.isEnemy(character) || character.invincible) continue;
      final distanceSquared = src.getDistanceSquared(character);
      if (distanceSquared > nearestEnemyDistanceSquared) continue;
      nearestEnemyDistanceSquared = distanceSquared;
      nearestEnemy = character;
    }
    return nearestEnemy;
  }

  void setCharacterPathToTarget(Character character){
    final target = character.target;
    if (target == null) {
      return;
    }
    character.pathTargetIndex = scene.getIndexPosition(target);
  }

  void updateCharacterPath(Character character) {
    if (!character.pathFindingEnabled) {
      return;
    }

    final scene = this.scene;
    final pathChanged = character.pathTargetIndexPrevious != character.pathTargetIndex;

    character.pathTargetIndexPrevious = character.pathTargetIndex;

    if (scene.outOfBoundsPosition(character) || character.pathTargetIndex == -1) {
      character.clearPath();
      return;
    }

    final characterIndex = scene.getIndexPosition(character);

    if (character.pathCurrent >= 0 &&
        characterIndex == character.pathCurrentIndex
    ){
      character.pathCurrent--;
    }

    if (!pathChanged && character.pathCurrent > 0) {
      return;
    }

    if (characterIndex == character.pathTargetIndex) {
      character.clearPath();
      return;
    }

    character.pathCurrent = -1;
    character.pathStart = -1;

    final path = character.path;
    var endPath = scene.findPath(
        characterIndex, character.pathTargetIndex,
        max: character.path.length,
    );
    if (endPath == -1) {
      return;
    }
    var totalPathLength = 0;
    while (endPath != characterIndex) {
      scene.compiledPath[totalPathLength++] = endPath;
      endPath = scene.path[endPath];
      if (endPath == -1){
        // TODO FIX
        return;
      }
    }
    final length = min(path.length, totalPathLength);

    if (length < 0) return;

    character.pathCurrent = length;
    for (var i = 0; i < length; i++){
      path[i] = scene.compiledPath[totalPathLength - length + i];
    }

    if (character.pathCurrent > 0){
      character.pathCurrent--;
    }
    character.pathStart = character.pathCurrent;
  }

  void updateCharacterAction(Character character) {

    if (character.busy) {
      return;
    }

    if (character.forceAttack){
      characterGoalForceAttack(character);
      return;
    }

    if (characterConditionAttackTarget(character)) {
      characterGoalAttackTarget(character);
      return;
    }

    if (updateCharacterGoalTargetNodeIndex(character)) {
      return;
    }

    if (characterConditionInteractWithTarget(character)){
      characterGoalInteractWithTarget(character);
      return;
    }

    if (characterConditionFollowPath(character)){
      characterActionFollowPath(character);
      return;
    }

    if (characterConditionRunToDestination(character)) {
      character.goal = CharacterGoal.Run_To_Destination;
      characterActionRunToDestination(character);
      return;
    }

    if (characterConditionShouldWander(character)){
      character.goal = CharacterGoal.Wander;
      characterActionWander(character);
      return;
    }

    if (!character.idling) {
      characterActionIdle(character);
    }
  }

  void characterGoalForceAttack(Character character) {
    character.goal = CharacterGoal.Force_Attack;
    character.faceTarget();
    character.attack();
    character.forceAttack = false;
  }

  void characterActionIdle(Character character) {
    character.goal = CharacterGoal.Idle;
    character.action = CharacterAction.Idle;
    character.setCharacterStateIdle();
  }

  void characterRunToTarget(Character character){
    character.runStraightToTarget();
  }

  void onCharacterCollectedGameObject(Character character, GameObject gameObject){
    remove(gameObject);
  }

  bool characterConditionAttackTarget(Character character) {
     final target = character.target;

     if (target == null) {
       return false;
     }

     if (target is Character){
       return character.isEnemy(target);
     }

     if (target is GameObject){
       return !target.interactable;
     }

     return false;
  }

  bool shouldCharacterPerformAttackOnTarget(Character character) =>
      character.target != null &&
      character.targetWithinAttackRange &&
      (!character.pathFindingEnabled || character.targetPerceptible);

  void characterGoalAttackTarget(Character character){
    character.goal = CharacterGoal.Kill_Target;

    if (shouldCharacterPerformAttackOnTarget(character)){
      actionCharacterPerformAttack(character);
      return;
    }

    if (shouldCharacterRunTowardsEnemy(character)){
      actionCharacterRunTowardsEnemy(character);
      return;
    }

    if (shouldCharacterFollowPathToEnemy(character)){
      actionCharacterFollowPathToEnemy(character);
      return;
    }
  }

  void actionCharacterPerformAttack(Character character){
    character.attackTargetEnemy(this);
  }

  bool characterConditionFollowPath(Character character) =>
      character.pathFindingEnabled && character.pathCurrent >= 0 ;

  void characterActionFollowPath(Character character) {
    if (!character.pathSet) {
      return;
    }

    characterSetDestinationToPathNodeIndex(character);
    characterActionRunToDestination(character);
  }

  void characterSetDestinationToPathNodeIndex(Character character) {
    final pathNodeIndex = character.pathCurrentIndex;
    assert (pathNodeIndex >= 0);
    character.setRunDestination(
        scene.getIndexX(pathNodeIndex),
        scene.getIndexY(pathNodeIndex),
        scene.getIndexZ(pathNodeIndex),
    );
  }

  bool characterConditionRunToDestination(Character character) =>
      character.runToDestinationEnabled &&
      !character.arrivedAtDestination;

  void characterActionRunToDestination(Character character) {
    character.action = CharacterAction.Run_To_Destination;
    character.faceRunPosition();
    character.setCharacterStateRunning();
  }

  bool characterShouldRunToTarget(Character character) {
    final target = character.target;
    if (target == null) return false;

    if (!character.pathFindingEnabled) {
      if (character.isEnemy(target)) {
        return !character.withinWeaponRange(target);
      }
      if (character.isAlly(target)){
        return !character.withinInteractRange(target);
      }
      return !character.withinRadiusPosition(target, 7);
    }

    if (scene.isPerceptible(character, target)) {
      if (character.isEnemy(target)) {
        return !character.withinWeaponRange(target);
      }
      if (character.isAlly(target)){
        return !character.withinInteractRange(target);
      }
    }
    return false;
  }

  bool characterConditionInteractWithTarget(Character character) {
    final target = character.target;
    if (target is Character) {
      return character.isAlly(character.target);
    }
    if (target is GameObject) {
      return target.interactable;
    }
    return false;
  }

  // bool characterConditionCollectTarget(Character character) {
  //   final target = character.target;
  //   return target is GameObject && target.collectable;
  // }

  void setPathTargetIndexToTarget(Character character){
    final target = character.target;
    if (target != null) {
      character.pathTargetIndex = scene.getIndexPosition(target);
    }
  }

  void updateCharacterTargetPerceptible(Character character) {
     final target = character.target;
     if (target == null) {
       character.targetPerceptible = false;
       return;
     }
     character.targetPerceptible = scene.isPerceptible(character, target);
  }

  bool shouldCharacterRunTowardsEnemy(Character character) =>
       character.runToDestinationEnabled &&
       (!character.pathFindingEnabled || character.targetPerceptible) &&
       !character.targetWithinAttackRange;

  bool characterConditionRunTowardsCollectTarget(Character character) =>
       character.runToDestinationEnabled &&
       (!character.pathFindingEnabled || character.targetPerceptible) &&
       !character.targetWithinCollectRange;

  void actionCharacterRunTowardsEnemy(Character character) {
    character.runStraightToTarget();
  }

  void characterActionRunTowardsTarget(Character character) {
    character.runStraightToTarget();
  }

  bool shouldCharacterFollowPathToEnemy(Character character) {
     if (!character.pathFindingEnabled ||
         character.target == null
     ){
       return false;
     }
     return !character.targetPerceptible;
  }

  void actionCharacterFollowPathToEnemy(Character character) =>
      characterActionFollowPathToTarget(character);

  void setCharacterPathTargetIndex(Character character, int value){
    final target = character.target;
    if (target == null) {
      throw Exception();
    }

    final pathTargetIndex = scene.getIndexPosition(target);
    character.pathTargetIndex = pathTargetIndex;

    if (pathTargetIndex == -1) {
      notifyTargetIsOutOfBounds(character);
      return;
    }
  }

  void characterActionFollowPathToTarget(Character character) {
    final target = character.target;
    if (target == null) {
      throw Exception();
    }

    final pathTargetIndex = scene.getIndexPosition(target);
    character.pathTargetIndex = pathTargetIndex;

    if (pathTargetIndex == -1) {
      notifyTargetIsOutOfBounds(character);
      return;
    }

    if (character.pathSet){
      characterActionFollowPath(character);
    }
  }

  void notifyTargetIsOutOfBounds(Character character){

  }

  void setCharacterPathTarget(Character character) {
    final target = character.target;
    if (target == null) {
      throw Exception();
    }

    character.pathTargetIndex = scene.getIndexPosition(target);
  }

  void characterGoalInteractWithTarget(Character character) {
    character.goal = CharacterGoal.Interact_With_Target;

    final target = character.target;

    if (character.interacting) {
      character.setCharacterStateIdle();
      character.setDestinationToCurrentPosition();
      return;
    }

    if (target == null){
      throw Exception();
    }

    if (character.withinInteractRange(target)) {
      handleInteraction(character, target);
      // if (target is Character) {
      //   customOnInteraction(character, target);
      // }
      // if (target is GameObject) {
      //   customOnCharacterInteractWithGameObject(character, target);
      //   // target.onInteract?.call(character);
      // }
      character.setCharacterStateIdle();
      character.setDestinationToCurrentPosition();
      return;
    }

    if (character.targetPerceptible || !character.pathFindingEnabled){
        characterActionRunTowardsTarget(character);
        return;
    }

    characterActionFollowPathToTarget(character);
    return;


  }

  void handleInteraction(Character src, Position target){

  }

  bool characterConditionFollowPathToCollectTarget(Character character) {
     return character.pathFindingEnabled;
  }

  bool characterConditionCollectTargetGameObject(Character character) {
     final target = character.target;
     if (target == null) {
       return false;
     }
     return character.targetWithinCollectRange;
  }

  // void customOnInteraction(Character character, Character target) {}

  bool characterConditionShouldWander(Character character) {
     if (!character.roamEnabled || character.target != null) {
       return false;
     }

     if (!character.idling) {
       return false;
     }

     return character.roamNext-- <= 0;
  }

  void characterActionWander(Character character) {
    character.goal = CharacterGoal.Wander;
    character.roamNext = randomInt(300, 500);
    character.pathTargetIndex = scene.findRandomNodeTypeAround(
      z: character.indexZ,
      row: character.indexRow,
      column: character.indexColumn,
      radius: character.roamRadius,
      type: NodeType.Empty,
    );
  }

  // void characterAttack(Character character) {
  //   character.clearPath();
  //
  //   if (character.weaponType == WeaponType.Bow) {
  //     character.setCharacterStateFire(
  //       duration: 20, // TODO
  //     );
  //   } else {
  //     character.setCharacterStateStriking(
  //       duration: 20, // TODO
  //     );
  //   }
  // }

  void sortMarksAndDispatch() {
    scene.sortMarks();
    for (final player in players) {
      player.writeSceneMarks();
    }
  }

  void notifyPlayersSceneKeysChanged() {
    for (final player in players){
      player.writeNetworkResponseSceneKeys();
    }
  }

  void dispatchDownloadScene(){
    for (final player in players){
      player.sceneDownloaded = false;
    }
  }

  void onAddedGameObject(GameObject value) {}

  void onAddedPlayer(T player) {
    player.game = this;
    // player.active = true;
    player.sceneDownloaded = false;
    player.downloadScene();
  }

  void applyChangesToScene(){
    final gameObjects = this.gameObjects;
    final sceneGameObjects = scene.gameObjects;
    sceneGameObjects.clear();
    for (final gameObject in gameObjects) {
      if (gameObject.isAmuletItem) continue;
      sceneGameObjects.add(gameObject);
    }
  }

  void setCharacterTarget(
    Character character,
    Position? value,
  ) {
    if (character.target == value){
      return;
    }
    character.target = value;
    onCharacterTargetChanged(character, value);
  }

  void onCharacterTargetChanged(Character character, Position? value) {

  }

  bool characterResistsDamageType(Character character, DamageType damageType){
    return false;
  }

  bool updateCharacterGoalTargetNodeIndex(Character character) {

    final targetNodeIndex = character.targetNodeIndex;

    if (targetNodeIndex == null){
      return false;
    }

    final nodeX = scene.getIndexX(targetNodeIndex);
    final nodeY = scene.getIndexY(targetNodeIndex);
    final nodeZ = scene.getIndexZ(targetNodeIndex);

    if (character.withinRadiusXYZ(
        nodeX,
        nodeY,
        nodeZ,
        IsometricSettings.Interact_Radius,
    )){
      handleCharacterInteractWithTargetNode(character);
      character.targetNodeIndex = null;
      character.setCharacterStateIdle();
      return true;
    }

    return false;
  }

  void handleCharacterInteractWithTargetNode(Character character) {

  }

  void onAddedProjectile(Projectile value) {}
}


