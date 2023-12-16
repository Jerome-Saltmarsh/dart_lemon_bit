import 'dart:math';

import '../isometric_engine.dart';
import '../consts/isometric_settings.dart';

abstract class IsometricGame<T extends IsometricPlayer> {

  Scene scene;
  IsometricEnvironment environment;
  IsometricTime time;

  var _id = 0;
  var attackAlwaysHitsTarget = false;
  var playerId = 0;
  var timerUpdateAITargets = 0;
  var frame = 0;
  var gameObjectId = 0;
  var _running = true;

  final List<T> players = [];
  final jobs = <GameJob>[];
  final gameObjects = <GameObject>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];

  IsometricGame({
    required this.scene,
    required this.time,
    required this.environment,
  }) {

    for (final gameObject in scene.gameObjects){
      gameObjects.add(
        gameObject.copy()
      );
    }

    gameObjects.sort();
    gameObjectId = gameObjects.length;
    customInit();

    for (final gameObject in gameObjects) {
      onGameObjectSpawned(gameObject);
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

  int generateUniqueId() => _id++;

  void writePlayerResponses() {
    final players = this.players;
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      player.writePlayerGame();
      customWriteGame();
    }
  }

  void addJob({
    required num seconds,
    required Function action,
    bool repeat = false,
  }) {
    final frames = (fps * seconds).toInt();
    for (final job in jobs) {
      if (!job.available) continue;
      job.remaining = frames;
      job.duration = frames;
      job.action = action;
      job.repeat = repeat;
      job.available = false;
      return;
    }
    jobs.add(GameJob(frames, action, repeat: repeat));
  }

  void updateJobs() {
    final jobs = this.jobs;
    for (var i = 0; i < jobs.length; i++) {
      final job = jobs[i];
      if (job.remaining <= 0) continue;
      job.remaining--;
      if (job.remaining > 0) continue;
      job.action();
      if (job.repeat) {
        job.remaining = job.duration;
      } else {
        job.action = _clearJob;
        job.duration = 0;
        job.remaining = 0;
        job.available = true;
      }
    }
  }

  void _clearJob(){}

  void removePlayer(T player){
    player.aimTarget = null;
    player.target = null;
    if (players.remove(player)) {
      onPlayerRemoved(player);
    }
    characters.remove(player);
  }

  void add(Collider value){
    if (value is Character){
       characters.add(value);
    }
    if (value is GameObject){
      if (gameObjects.contains(value)){
        return;
      }
      gameObjects.add(value);
      onGameObjectedAdded(value);
    }
    if (value is Projectile){
      projectiles.add(value);
    }
    if (value is T) {
      players.add(value);
      onPlayerJoined(value);
    }
  }

  /// In seconds
  void customInitPlayer(IsometricPlayer player) {}

  /// @override
  void customOnPlayerInteractWithGameObject(T player,
      GameObject gameObject) {}

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
  void customOnCharacterDamageApplied(Character target, dynamic src,
      int amount) {}

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
  void customInit() {}

  /// @override
  void onGameObjectSpawned(GameObject gameObject) {}

  /// @override
  void customOnGameObjectDestroyed(GameObject gameObject) {}

  /// @override
  void customOnPlayerAimTargetChanged(IsometricPlayer player,
      Collider? collider) {}

  /// @override
  void customOnNodeDestroyed(int nodeType, int nodeIndex, int nodeOrientation) {
    // default behavior is to respawn after a period however this can be safely overriden
    addJob(seconds: 1000, action: () {
      setNode(
        nodeIndex: nodeIndex,
        nodeType: nodeType,
        orientation: nodeOrientation,
      );
    });
  }

  GameObject? findGameObjectByType(int type) {
    for (final gameObject in gameObjects) {
      if (gameObject.type == type) return gameObject;
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

    if (
      player.deadOrBusy ||
      !player.active ||
      player.debugging ||
      !player.controlsEnabled
    ) return;


    final mouseLeftClicked = mouseLeftDown && player.mouseLeftDownDuration == 0;
    // final mouseRightClicked = mouseRightDown && player.mouseRightDownDuration == 0;

    if (mouseRightDown){
      player.mouseRightDownDuration++;
    } else {
      player.mouseRightDownDuration = 0;
    }

    // if (mouseRightClicked){
    //   if (player is AmuletPlayer){
    //     if (player.activatedPowerIndex == -1){
    //       player.performForceAttack();
    //       return;
    //     } else {
    //       player.deselectActivatedPower();
    //     }
    //   }
    //   return;
    // }

    if (keyDownShift){
      player.setCharacterStateIdle();
    }

    if (mouseLeftDown) {
      player.mouseLeftDownDuration++;
    } else {
      player.mouseLeftDownDuration = 0;
      player.mouseLeftDownIgnore = false;
    }

    // if (mouseLeftClicked &&
    //     player is AmuletPlayer &&
    //     player.activatedPowerIndex != -1
    // ) {
    //   player.useActivatedPower();
    //   player.mouseLeftDownIgnore = true;
    //   return;
    // }

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
          setCharacterTarget(player, null);
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
      if (character.dead || !character.active) continue;
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
      if (!gameObject.active) continue;
      if (!gameObject.collectable &&
          !gameObject.interactable &&
          !gameObject.hitable
          // !gameObject.physical
      ) continue;

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

  bool isMeleeAOE(int weaponType){
    return false;
  }

  void performAbilityMelee(Character character){


    dispatchGameEventPosition(
      GameEvent.Melee_Attack_Performed,
      character,
    );

    final target = character.target;
    if (target is Collider){
      if (character.withinAttackRangeAndAngle(target)){
        applyHit(
          target: target,
          damage: character.weaponDamage,
          srcCharacter: character,
        );
        return;
      }
    }

    final angle = character.angle;
    final attackRadius = character.weaponRange;
    var attackHit = false;
    var nearestDistance = attackRadius;
    Collider? nearest;
    final areaOfEffect = isMeleeAOE(character.weaponType);

    for (final other in characters) {
      if (!other.active) continue;
      if (!other.hitable) continue;
      if (character.onSameTeam(other)) continue;
      if (!character.withinAttackRangeAndAngle(other)) {
        continue;
      }

      if (!areaOfEffect) {
        final distance = character.getDistance(other) - other.radius;
        if (distance > nearestDistance) continue;
        nearest = other;
        nearestDistance = distance;
        attackHit = true;
        continue;
      }

      applyHit(
        target: other,
        damage: character.weaponDamage,
        srcCharacter: character,
      );
      attackHit = true;
    }

    final gameObjectsLength = gameObjects.length;
    for (var i = 0; i < gameObjectsLength; i++) {
      final gameObject = gameObjects[i];
      if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;

      if (!character.withinAttackRangeAndAngle(gameObject)) {
        continue;
      }

      if (!areaOfEffect) {
        final distance = character.getDistance(gameObject);
        if (distance > nearestDistance) continue;
        nearest = gameObject;
        nearestDistance = distance;
        attackHit = true;
        continue;
      }

      applyHit(
        target: gameObject,
        damage: character.weaponDamage,
        srcCharacter: character,
      );
      attackHit = true;
    }

    if (nearest != null) {
      applyHit(
        target: nearest,
        damage: character.weaponDamage,
        srcCharacter: character,
      );
    }

    final attackRadiusHalf = attackRadius * 0.5;
    final performX = character.x + adj(angle, attackRadiusHalf);
    final performY = character.y + opp(angle, attackRadiusHalf);
    final performZ = character.z;

    if (!scene.inboundsXYZ(performX, performY, performZ)) {
      return;
    }

    final nodeIndex = scene.getIndexXYZ(performX, performY, performZ);
    final nodeType = scene.types[nodeIndex];

    if (!NodeType.isRainOrEmpty(nodeType)) {
      character.applyForce(
        force: 4.5,
        angle: angle + pi,
      );
      character.clampVelocity(Physics.Max_Velocity);
      attackHit = true;
      for (final player in players) {
        if (!player.onScreen(performX, performY)) continue;
        player.writeGameEvent(
          type: GameEvent.Node_Struck,
          x: performX,
          y: performY,
          z: performZ,
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
          type: GameEvent.Attack_Missed,
          x: performX,
          y: performY,
          z: performZ,
        );
        player.writeUInt16(character.weaponType);
      }
    }
  }

  void destroyNode(int nodeIndex) {
    final orientation = scene.shapes[nodeIndex];
    final nodeType = scene.types[nodeIndex];
    if (nodeType == NodeType.Empty) return;
    setNode(
      nodeIndex: nodeIndex,
      nodeType: NodeType.Empty,
      orientation: NodeOrientation.None,
    );
    customOnNodeDestroyed(nodeType, nodeIndex, orientation);
  }

  void activate(Collider collider) {
    if (collider.active) return;
    collider.active = true;
    if (collider is GameObject) {
      collider.dirty = true;
    }
    if (collider is IsometricPlayer) {
      collider.writePlayerActive();
    }
    onActivated(collider);
  }

  void onGridChanged() {
    scene.refreshMetrics();
    for (final player in players) {
      player.writeScene();
    }
  }

  void deactivate(Collider collider) {
    if (!collider.active) return;
    collider.deactivate();
    onDeactivated(collider);
  }

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
    final totalGameObjects = gameObjects.length;
    for (var i = 0; i < totalGameObjects; i++) {
      final gameObject = gameObjects[i];
      if (!gameObject.active) {
        if (gameObject.recyclable && !gameObject.available) {
          gameObject.available = true;
        }
      } else {
        updateColliderPhysics(gameObject);
      }

      if (gameObject.positionDirty) {
        gameObject.dirty = true;
      }

      if (gameObject.deactivationTimer > 0) {
        gameObject.deactivationTimer--;
        if (gameObject.deactivationTimer <= 0){
          deactivate(gameObject);
        }
      }

      if (!gameObject.dirty) {
        continue;
      }

      if (i > 0){
        final previousGameObject = gameObjects[i - 1];
        if (previousGameObject.order > gameObject.order){
          sortRequired = true;
        }
      }

      if (!sortRequired && i < totalGameObjects - 1){
        final nextGameobject = gameObjects[i + 1];
        if (nextGameobject.order < gameObject.order){
          sortRequired = true;
        }
      }

      gameObject.dirty = false;
      gameObject.synchronizePrevious();
      for (final player in players) {
        player.writeGameObject(gameObject);
      }
    }

    if (sortRequired) {
      sortGameObjects();
    }
  }

  void sortGameObjects(){
    playersWriteByte(NetworkResponse.Scene);
    playersWriteByte(NetworkResponseScene.Sort_GameObjects);
    gameObjects.sort();
  }

  void updateCharacterTarget(Character character){

    if (!character.autoTarget){
      return;
    }

    if (character.autoTargetTimer-- > 0){
      return;
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
    assert (collider.active);

    collider.updateVelocity();

    if (collider.z < 0) {
      if (collider is Character) {
        setCharacterStateDead(collider);
        return;
      }
      deactivate(collider);
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
    double radius = 100.0,
    int damage = 25,
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
      if (!gameObject.active) continue;
      if (!gameObject.hitable) continue;
      if (!gameObject.withinRadiusXYZ(x, y, z, radius)) continue;
      applyHit(
        angle: angleBetween(x, y, gameObject.x, gameObject.y),
        target: gameObject,
        srcCharacter: srcCharacter,
        damage: damage,
        friendlyFire: true,
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
    sortColliders();
  }

  void revive(T player) {
    if (player.aliveAndActive) return;

    player.setCharacterStateSpawning();
    activate(player);
    player.physical = true;
    player.hitable = true;
    player.health = player.maxHealth;
    clearCharacterTarget(player);
    customOnPlayerRevived(player);
    player.writePlayerMoved();
    player.writePlayerAlive();
    player.writePlayerEvent(PlayerEvent.Spawned);
    player.writePlayerHealth();
    player.writeGameTime();
    player.health = player.maxHealth;
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

  void applyDamageToCharacter({
    required Character src,
    required Character target,
    required int amount,
  }) {
    if (target.dead || target.invincible) return;

    final damage = min(amount, target.health);
    target.health -= damage;

    if (target.health <= 0) {
      target.facePosition(src, force: true);
      setCharacterStateDead(target);
      customOnCharacterKilled(target, src);
      return;
    }
    if (target.target == null && target.autoTarget) {
      setCharacterTarget(target, src);
    }
    customOnCharacterDamageApplied(target, src, damage);
    target.setCharacterStateHurt();
    dispatchGameEventCharacterHurt(target);
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
      if (!colliderI.active || !colliderI.collidable) continue;
      final colliderIOrder = colliderI.order;
      final colliderIRadius = colliderI.radius;
      final colliderIBoundsBottom = colliderI.boundsBottom;
      final colliderIBoundsRight = colliderI.boundsRight;
      final colliderIBoundsLeft = colliderI.boundsLeft;
      final colliderIZ = colliderI.z;

      for (var j = i + 1; j < numberOfColliders; j++) {
        final colliderJ = colliders[j];
        if (!colliderJ.active || !colliderJ.collidable) {
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

  void resolveCollisionsBetween(List<Collider> collidersA,
      List<Collider> collidersB,) {
    final aLength = collidersA.length;
    final bLength = collidersB.length;

    var bStart = 0;
    for (var indexA = 0; indexA < aLength; indexA++) {
      final colliderA = collidersA[indexA];
      if (!colliderA.active || !colliderA.collidable) continue;
      final colliderAOrder = colliderA.order;
      final colliderARadius = colliderA.radius;
      final colliderATop = colliderA.boundsTop;
      final colliderABottom = colliderA.boundsBottom;
      final colliderARight = colliderA.boundsRight;
      final colliderALeft = colliderA.boundsLeft;
      for (var indexB = bStart; indexB < bLength; indexB++) {
        final colliderB = collidersB[indexB];
        if (!colliderB.active || !colliderB.collidable) continue;
        final colliderBOrder = colliderB.order;

        final orderDiff = colliderBOrder - colliderAOrder;

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
    character.characterState = CharacterState.Dead;
    character.actionDuration = 0;
    character.frame = 0;
    character.physical = false;
    character.hitable = false;
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

  void deactivateProjectile(Projectile projectile) {
    assert (projectile.active);
    switch (projectile.type) {
      case ProjectileType.Orb:
        break;
      case ProjectileType.Rocket:
        final owner = projectile.parent;
        if (owner == null) return;
        createExplosion(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          srcCharacter: owner,
        );
        break;
      case ProjectileType.Bullet:
        dispatchGameEvent(
          GameEvent.Bullet_Deactivated,
          projectile.x,
          projectile.y,
          projectile.z,
        );
        break;
      default:
        break;
    }
    projectile.active = false;
    projectile.parent = null;
    projectile.target = null;
  }

  void updateProjectiles() {
    final projectiles = this.projectiles;
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
      if (!scene.getCollisionAt(projectile.x, projectile.y, projectile.z)) {
        continue;
      }
      deactivateProjectile(projectile);

      final nodeType = scene.getTypeXYZ(
          projectile.x, projectile.y, projectile.z);

      if (!NodeType.isRainOrEmpty(nodeType)) {
        final players = this.players;
        for (final player in players) {
          if (!player.onScreen(projectile.x, projectile.y)) continue;
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

    for (final character in characters){
      if (character.target == instance){
        character.clearTarget();
      }
    }

    if (instance is T) {
     
      removePlayer(instance);
    }

    if (instance is Character) {
      instance.target = null;
      characters.remove(instance);
      return;
    }

    if (instance is GameObject) {
      instance.active = false;
      gameObjects.remove(instance);
      for (final player in players) {
        player.writeUInt8(NetworkResponse.Scene);
        player.writeUInt8(NetworkResponseScene.GameObject_Deleted);
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

  void setCharacterStateSpawning(Character character) {
    character.setCharacterStateSpawning();
  }

  void checkProjectileCollision(List<Collider> colliders) {
    final projectiles = this.projectiles;
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

      final projectileX = projectile.x;
      final projectileY = projectile.y;
      final projectileRadius = projectile.radius;

      assert (target == null);
      for (var j = 0; j < colliders.length; j++) {
        final collider = colliders[j];
        if (!collider.active) continue;
        if (!collider.hitable) continue;
        final radius = collider.radius + projectileRadius;
        if ((collider.x - projectileX).abs() > radius) continue;
        if ((collider.y - projectileY).abs() > radius) continue;
        if (projectile.z + projectileRadius < collider.z) continue;
        if (projectile.z - projectileRadius > collider.z + Character_Height) {
          continue;
        }
        if (projectile.parent == collider) continue;
        if (!projectile.isEnemy(collider) && !projectile.friendlyFire) continue;
        handleProjectileHit(projectile, collider);
        break;
      }
    }
  }

  void handleProjectileHit(Projectile projectile, Position target) {
    assert (projectile.active);
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
      );
    }

    deactivateProjectile(projectile);
    if (projectile.type == ProjectileType.Arrow) {
      dispatchGameEvent(GameEvent.Arrow_Hit, target.x, target.y, target.z);
    }
  }

  void applyHit({
    required Character srcCharacter,
    required Collider target,
    required int damage,
    double? angle,
    bool friendlyFire = false,
  }) {
    if (!target.hitable) return;
    if (!target.active) return;

    angle ??= target.getAngle(srcCharacter);

    target.applyForce(
      force: srcCharacter.weaponHitForce,
      angle: angle,
    );

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
      applyDamageToCharacter(src: srcCharacter, target: target, amount: damage);
      return;
    }
  }

  void updateCharacter(Character character) {

    if (!character.active){
      return;
    }

    if (character.dead) {
      if (character.animationFrame < Character.maxAnimationDeathFrames){
        character.frame++;
      }
      return;
    }

    updateCharacterTarget(character);
    updateCharacterTargetPerceptible(character);
    updateColliderPhysics(character);
    updateCharacterAction(character);
    updateCharacterPath(character);
    updateCharacterState(character);
    character.update();
  }

  void performCharacterAction(Character character){
    character.actionFrame = -1;

    final weaponType = character.weaponType;

    if (WeaponType.isMelee(weaponType)) {
      if (attackAlwaysHitsTarget) {
        final target = character.target;
        if (target is Collider) {
          applyHit(
            srcCharacter: character,
            target: target,
            damage: character.weaponDamage,
          );
        }
        return;
      }
      performAbilityMelee(character);
      return;
    }

    if (weaponType == WeaponType.Bow) {
      dispatchGameEvent(
        GameEvent.Bow_Released,
        character.x,
        character.y,
        character.z,
      );
      spawnProjectileArrow(
        src: character,
        damage: character.weaponDamage,
        range: character.weaponRange,
        angle: character.angle,
      );
      return;
    }
  }

  void updateCharacterState(Character character) {

    if (character.shouldPerformAction) {
      performCharacterAction(character);
      if (character.clearTargetOnPerformAction) {
        character.clearTarget();
      }
    }

    if (
      character.actionDuration > 0 &&
      character.frame >= character.actionDuration
    ) {
      endCharacterAction(character);
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

    character.frame++;
  }

  void endCharacterAction(Character character) {
    if (character.dead) {
      return;
    }

    character.clearAction();
  }

  Projectile spawnProjectileOrb({
    required Character src,
    required int damage,
    required double range,
  }) {
    dispatchGameEventPosition(GameEvent.Blue_Orb_Fired, src);
    return spawnProjectile(
      src: src,
      range: range,
      target: src.target,
      projectileType: ProjectileType.Orb,
      angle: src.target != null ? null : (src is IsometricPlayer ? src
          .angle : src.angle),
      damage: damage,
    );
  }

  void spawnProjectileArrow({
    required Character src,
    required int damage,
    required double range,
    Position? target,
    double? angle,
  }) {
    assert (range > 0);
    assert (damage > 0);
    dispatchGameEvent(GameEvent.Arrow_Fired, src.x, src.y, src.z);
    spawnProjectile(
      src: src,
      range: range,
      target: target,
      angle: target != null ? null : angle ?? src.angle,
      projectileType: ProjectileType.Arrow,
      damage: damage,
    );
  }

  Projectile spawnProjectileFireball({
    required Character src,
    required int damage,
    required double range,
    double? angle,
  }) =>
      spawnProjectile(
        src: src,
        range: range,
        target: src.target,
        angle: angle,
        projectileType: ProjectileType.Fireball,
        damage: damage,
      );

  Projectile spawnProjectileRocket(Character src, {
    required int damage,
    required double range,
    double? angle,
  }) =>
      spawnProjectile(
        src: src,
        range: range,
        target: src.target,
        angle: angle,
        projectileType: ProjectileType.Rocket,
        damage: damage,
      );

  void spawnProjectileBullet({
    required Character src,
    required double range,
    required int damage,
    double accuracy = 0,
    double? angle = 0,
    Position? target,
  })=> spawnProjectile(
        projectileType: ProjectileType.Bullet,
        src: src,
        damage: damage,
        range: range,
        angle: angle,
      );

  Projectile spawnProjectile({
    required Character src,
    required double range,
    required int projectileType,
    required int damage,
    double? angle = 0,
    Position? target,
  }) {
    assert (range > 0);
    assert (damage > 0);
    final projectile = getInstanceProjectile();
    var finalAngle = angle;
    if (finalAngle == null) {
      if (target != null && target is Collider) {
        finalAngle = target.getAngle(src);
      } else {
        finalAngle = src.angle;
      }
    }
    projectile.damage = damage;
    projectile.hitable = true;
    projectile.active = true;
    if (target is Collider) {
      projectile.target = target;
    }
    // final r = 10.0 + (src.isTemplate ? ItemType.getWeaponLength(src.weaponType) : 0);
    final r = 5.0;
    projectile.x = src.x + adj(finalAngle, r);
    projectile.y = src.y + opp(finalAngle, r);
    projectile.z = src.z + Character_Gun_Height;
    projectile.startPositionX = projectile.x;
    projectile.startPositionY = projectile.y;
    projectile.startPositionZ = projectile.z;
    projectile.setVelocity(finalAngle, ProjectileType.getSpeed(projectileType));
    projectile.parent = src;
    projectile.team = src.team;
    projectile.range = range;
    projectile.type = projectileType;
    projectile.radius = ProjectileType.getRadius(projectileType);

    return projectile;
  }

  Projectile getInstanceProjectile() {
    for (final projectile in projectiles) {
      if (projectile.active) continue;
      return projectile;
    }

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

  GameObject spawnGameObjectAtIndex({
    required int index,
    required int type,
    required int subType,
    required int team,
  }) {
    final scene = this.scene;
    return spawnGameObject(
        x: scene.getIndexX(index),
        y: scene.getIndexY(index),
        z: scene.getIndexZ(index),
        type: type,
        subType: subType,
        team: team,
      );
  }

  GameObject spawnGameObject({
    required double x,
    required double y,
    required double z,
    required int type,
    required int subType,
    required int team,
  }) {
    final gameObjects = this.gameObjects;
    for (final gameObject in gameObjects) {
      if (gameObject.active) continue;
      if (!gameObject.recyclable) continue;
      if (!gameObject.available) continue;
      gameObject.x = x;
      gameObject.y = y;
      gameObject.z = z;
      gameObject.startPositionX = x;
      gameObject.startPositionY = y;
      gameObject.startPositionZ = z;
      gameObject.velocityX = 0;
      gameObject.velocityY = 0;
      gameObject.velocityZ = 0;
      gameObject.type = type;
      gameObject.subType = subType;
      gameObject.active = true;
      gameObject.dirty = true;
      gameObject.physicsFriction = Physics.Friction;
      gameObject.team = team;
      gameObject.synchronizePrevious();
      onGameObjectSpawned(gameObject);
      return gameObject;
    }
    final instance = GameObject(
      x: x,
      y: y,
      z: z,
      type: type,
      subType: subType,
      id: generateId(),
      team: team,
    );
    instance.active = true;
    instance.dirty = true;
    gameObjects.add(instance);
    onGameObjectSpawned(instance);
    return instance;
  }

  void dispatchByte(int byte){
    if (byte < 0 || byte > 255){
      throw Exception('dispatchByte($byte)');
    }

    final players = this.players;
    for (final player in players) {
      player.writeByte(byte);
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
    remove(player.editorSelectedGameObject);
    playerDeselectEditorSelectedGameObject(player);
  }

  void playerDeselectEditorSelectedGameObject(IsometricPlayer player) {
    if (player.editorSelectedGameObject == null) return;
    player.editorSelectedGameObject = null;
    player.writePlayerEvent(PlayerEvent.GameObject_Deselected);
  }

  void updateColliderSceneCollision(Collider collider) {
    updateColliderSceneCollisionVertical(collider);
    updateColliderSceneCollisionHorizontal(collider);
  }

  void internalOnColliderEnteredWater(Collider collider) {
    deactivate(collider);
    if (collider is Character) {
      setCharacterStateDead(collider);
    }
    dispatchGameEventPosition(GameEvent.Splash, collider);
  }

  void updateColliderSceneCollisionVertical(Collider collider) {
    final scene = this.scene;
    if (!scene.isInboundV3(collider)) {
      if (collider.z > -100) return;
      deactivate(collider);
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
    final nodeBottomOrientation = scene.shapes[nodeBottomIndex];
    final nodeBottomType = scene.types[nodeBottomIndex];

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
      deactivate(collider);
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
    final nodeBottomOrientation = scene.shapes[nodeBottomIndex];
    final nodeBottomType = scene.types[nodeBottomIndex];

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

    if (nodeIndex >= scene.types.length) {
      throw Exception(
          "game.setNode(nodeIndex: $nodeIndex) - node index out of bounds"
      );
    }

    nodeType ??= scene.types[nodeIndex];

    orientation ??= scene.shapes[nodeIndex];

    variation ??= scene.variations[nodeIndex];

    if (!NodeType.supportsOrientation(nodeType, orientation)) {
      orientation = NodeType.getDefaultOrientation(nodeType);
    }

    scene.shapes[nodeIndex] = orientation;
    scene.types[nodeIndex] = nodeType;
    scene.variations[nodeIndex] = variation;
    scene.clearCompiled();

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
    for (var i = 0; i < gameObjects.length; i++) {
      final gameObject = gameObjects[i];
      if (!gameObject.persistable) {
        gameObjects.removeAt(i);
        i--;
        continue;
      }
      gameObject.x = gameObject.startPositionX;
      gameObject.y = gameObject.startPositionY;
      gameObject.z = gameObject.startPositionZ;
    }
  }

  void destroyGameObject(GameObject gameObject) {
    if (!gameObject.active) return;
    dispatchGameEventGameObjectDestroyed(gameObject);
    deactivate(gameObject);
    customOnGameObjectDestroyed(gameObject);
  }

  void deactivatePlayer(IsometricPlayer player) {
    if (!player.active) return;
    player.active = false;
    player.writePlayerEvent(PlayerEvent.Player_Deactivated);
  }

  // T createPlayer() {
  //   final player = buildPlayer();
  //   player.setDestinationToCurrentPosition();
  //   player.sceneDownloaded = false;
  //   characters.add(player);
  //   customOnPlayerJoined(player);
  //   player.writePlayerAlive();
  //   player.writePlayerEvent(PlayerEvent.Player_Moved);
  //   player.writePlayerEvent(PlayerEvent.Game_Joined);
  //   return player;
  // }

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

  int generateId() => gameObjectId++;

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
      if (!character.active) continue;
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
      if (!gameObject.active) continue;
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
      Scene.compiledPath[totalPathLength++] = endPath;
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
      path[i] = Scene.compiledPath[totalPathLength - length + i];
    }

    if (character.pathCurrent > 0){
      character.pathCurrent--;
    }
    character.pathStart = character.pathCurrent;
  }

  // idle
  // wander
  // attack
  void updateCharacterAction(Character character) {

    if (character.busy) {
      return;
    }

    if (character.forceAttack){
      characterGoalForceAttack(character);
      return;
    }

    if (characterConditionKillTarget(character)) {
      characterGoalKillTarget(character);
      return;
    }

    if (characterConditionInteractWithTarget(character)){
      characterGoalInteractWithTarget(character);
      return;
    }

    if (characterConditionCollectTarget(character)){
      characterGoalCollectTarget(character);
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

  void characterGoalCollectTarget(Character character){
    character.goal = CharacterGoal.Collect_Target;

    if (characterConditionCollectTargetGameObject(character)){
      characterActionCollectTargetGameObject(character);
      return;
    }

    if (characterConditionRunTowardsCollectTarget(character)){
      characterActionRunTowardsTarget(character);
      return;
    }

    if (characterConditionFollowPathToCollectTarget(character)){
      characterActionFollowPathToTarget(character);
      return;
    }

    character.action = CharacterAction.Stuck;
  }

  void characterActionCollectTargetGameObject(Character character){
    final target = character.target;

    assert (target is GameObject);
    if (target is! GameObject) {
      return;
    }

    character.action = CharacterAction.Collect_Target;
    onCharacterCollectedGameObject(character, target);
    characterActionIdle(character);
    clearCharacterTarget(character);
  }

  void onCharacterCollectedGameObject(Character character, GameObject gameObject){
    remove(gameObject);
  }

  bool characterConditionKillTarget(Character character) =>
      character.isEnemy(character.target);

  bool shouldCharacterPerformAttackOnTarget(Character character) =>
      character.target != null &&
      character.targetWithinAttackRange &&
      (!character.pathFindingEnabled || character.targetPerceptible);

  void characterGoalKillTarget(Character character){
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
    character.faceRunDestination();
    character.setCharacterStateRunning();
  }

  bool characterShouldRunToTarget(Character character) {
    final target = character.target;
    if (target == null) return false;

    if (!character.pathFindingEnabled) {
      if (character.isEnemy(target)) {
        return !character.withinAttackRange(target);
      }
      if (character.isAlly(target)){
        return !character.withinInteractRange(target);
      }
      return !character.withinRadiusPosition(target, 7);
    }

    if (scene.isPerceptible(character, target)) {
      if (character.isEnemy(target)) {
        return !character.withinAttackRange(target);
      }
      if (character.isAlly(target)){
        return !character.withinInteractRange(target);
      }
    }
    return false;
  }

  bool characterConditionInteractWithTarget(Character character) =>
      character.isAlly(character.target);

  bool characterConditionCollectTarget(Character character) {
    final target = character.target;
    return target is GameObject && target.collectable;
  }

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

    if (target is! Character) {
      return;
    }
      // throw Exception();

    if (character.targetWithinRadius(IsometricSettings.Interact_Radius)){
        customOnInteraction(character, target);
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

  void customOnInteraction(Character character, Character target) {}

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
      player.downloadSceneMarks();
    }
  }

  void notifyPlayersSceneKeysChanged() {
    for (final player in players){
      player.writeSceneKeys();
    }
  }

  void notifyPlayersSceneChanged() {
    scene.compiled = null;
    for (final player in players){
      player.writeScene();
    }
  }

  void onGameObjectedAdded(GameObject value) {}

  void onPlayerJoined(T player) {
    player.game = this;
    player.sceneDownloaded = false;
    player.downloadScene();
  }

  void onDeactivated(Collider collider) {
    final characters = this.characters;
    for (final character in characters) {
      if (character.target == collider) {
        clearCharacterTarget(character);
      }
    }

    final projectiles = this.projectiles;
    for (final projectile in projectiles) {
      if (projectile.target == collider) continue;
      projectile.target = null;
    }
  }

  void applyChangesToScene(){
    final gameObjects = this.gameObjects;
    final sceneGameObjects = scene.gameObjects;
    sceneGameObjects.clear();
    for (final gameObject in gameObjects){
      if (!gameObject.persistable) {
        continue;
      }
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
}