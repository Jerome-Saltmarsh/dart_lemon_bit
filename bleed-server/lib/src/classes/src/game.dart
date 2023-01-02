import 'dart:math';

import 'package:bleed_server/src/dark_age/dark_age_environment.dart';
import 'package:lemon_math/library.dart';

import 'package:bleed_server/gamestream.dart';
import '../../constants/frames_per_second.dart';
import '../../io/write_scene_to_file.dart';
import '../../maths/get_distance_between_v3.dart';

class GameJob {
  int timer;
  Function action;

  GameJob(this.timer, this.action);
}

abstract class Game {

  static const Interact_Radius = 100.0;
  var aiRespawnDuration = framesPerSecond * 60 * 2; // 5 minutes

  var frame = 0;
  Scene scene;
  final players = <Player>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];
  final jobs = <GameJob>[];

  DarkAgeEnvironment environment;
  DarkAgeTime time;



  /// In seconds
  void customInitPlayer(Player player) {}
  /// @override
  void customPlayerWrite(Player player){ }
  /// @override
  void customUpdatePlayer(Player player){ }
  /// @override
  void customDownloadScene(Player player){ }
  /// @override
  void customUpdate() {}
  /// @override
  void customOnPlayerDisconnected(Player player) { }
  /// @override
  void customOnGameObjectDeactivated(GameObject gameObject){ }
  /// @override
  void customOnCharacterSpawned(Character character) { }
  /// @override
  void customOnCharacterKilled(Character target, dynamic src) { }
  /// @override
  void customOnCharacterDamageApplied(Character target, dynamic src, int amount) { }
  /// @override
  void customOnPlayerRevived(Player player) { }
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
  void customOnHitApplied(Character src, Collider target) {}
  /// @override
  void customOnPlayerJoined(Player player) {}
  
  /// PROPERTIES
  List<GameObject> get gameObjects => scene.gameObjects;
  /// @override
  double get minAimTargetCursorDistance => 35;

  bool get customPropMapVisible => false;
  int get gameType;

  /// CONSTRUCTOR
  Game({required this.scene, required this.time, required this.environment}) {
    engine.onGameCreated(this); /// TODO Illegal external scope reference
  }

  /// QUERIES

  GameObject? findGameObjectByType(int type){
    for (final gameObject in gameObjects){
       if (gameObject.type == type) return gameObject;
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

  void onPlayerUpdateRequestedReceived({
    required Player player,
    required int direction,
    required int cursorAction,
    /// Right Click
    required bool perform2,
    required bool perform3,
    required double mouseX,
    required double mouseY,
    required double screenLeft,
    required double screenTop,
    required double screenRight,
    required double screenBottom,
    required bool runToMouse,
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

    if (cursorAction == CursorAction.Set_Target) {
      if (direction != Direction.None) {
        if (!player.weaponStateBusy){
          characterUseWeapon(player);
        }
      } else {
        final aimTarget = player.aimTarget;
        if (aimTarget == null){
          player.runToMouse();
        } else {
          setCharacterTarget(player, aimTarget);
        }
      }
    }

    if (cursorAction == CursorAction.Stationary_Attack_Cursor){
      if (!player.weaponStateBusy){
        characterUseWeapon(player);
      }

    }

    if (cursorAction == CursorAction.Stationary_Attack_Auto){
      if (!player.weaponStateBusy){
        playerAutoAim(player);
        characterUseWeapon(player);
      }
    }

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
    var closestDistance = 9999.0;

    final mouseX = player.mouseGridX;
    final mouseY = player.mouseGridY;
    final mouseZ = player.z;

    Collider? closestCollider;

    for (final character in characters) {
      if (character.deadOrDying) continue;
      final distance = getDistanceV3(mouseX, mouseY, mouseZ, character.x, character.y, character.z);
      if (distance > closestDistance) continue;
      closestDistance = distance;
      closestCollider = character;
    }

    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      if (!gameObject.collectable && !gameObject.interactable) continue;
      final distance = getDistanceV3(mouseX, mouseY, mouseZ, gameObject.x, gameObject.y, gameObject.z);
      if (distance > closestDistance) continue;
      closestDistance = distance;
      closestCollider = gameObject;
    }

    if (closestDistance > 50) {
       player.aimTarget = null;
       return;
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

  void characterUseWeapon(Character character) {
    assert (character.alive);
    assert (!character.weaponStateBusy);

    if (character is Player) {
      final playerWeaponConsumeType = ItemType.getConsumeType(character.weaponType);

      if (playerWeaponConsumeType != ItemType.Empty) {
        final equippedWeaponQuantity = character.equippedWeaponQuantity;
        if (equippedWeaponQuantity == 0){
          final equippedWeaponAmmoType = character.equippedWeaponAmmunitionType;
          final totalAmmoRemaining = character.inventoryGetTotalQuantityOfItemType(equippedWeaponAmmoType);

          if (totalAmmoRemaining == 0) {
            character.writeError('no ammunition');
            return;
          }
          var total = min(totalAmmoRemaining, character.equippedWeaponCapacity);
          character.inventoryReduceItemTypeQuantity(
            itemType: equippedWeaponAmmoType,
            reduction: total,
          );
          character.inventorySetQuantityAtIndex(
            quantity: total,
            index: character.equippedWeaponIndex,
          );
          character.assignWeaponStateReloading();
          return;
        }
        character.inventorySetQuantityAtIndex(
          quantity: equippedWeaponQuantity - 1,
          index: character.equippedWeaponIndex,
        );
        character.writePlayerEquippedWeaponAmmunition();
      }
    } else if (character is AI){
      if (ItemType.isTypeWeaponFirearm(character.weaponType)){
        if (character.rounds <= 0){
          character.assignWeaponStateReloading();
          character.rounds = ItemType.getMaxQuantity(character.weaponType);
          return;
        }
        character.rounds--;
      }
    }

    if (character.weaponType == ItemType.Weapon_Thrown_Grenade){
      if (character is Player){
        playerThrowGrenade(character);
        return;
      }
      throw Exception('ai cannot throw grenades');
    }

    if (character.weaponType == ItemType.Weapon_Flamethrower){
      if (character is Player){
        playerUseFlamethrower(character);
        return;
      }
      throw Exception('ai cannot use flamethrower');
    }

    if (character.weaponType == ItemType.Weapon_Special_Bazooka){
      if (character is Player){
        playerUseBazooka(character);
      }
      return;
    }

    if (character.weaponType == ItemType.Weapon_Special_Minigun){
      if (character is Player){
        playerUseMinigun(character);
      }
      return;
    }

    if (ItemType.isTypeWeaponFirearm(character.weaponType)){
      characterFireWeapon(character);
      character.accuracy += ItemType.getAccuracy(character.weaponType);
      return;
    }

    if (ItemType.isTypeWeaponMelee(character.weaponType)) {
      characterAttackMelee(character);
      return;
    }

    switch (character.weaponType) {
      case ItemType.Weapon_Ranged_Crossbow:
        spawnProjectileArrow(
            damage: ItemType.getDamage(character.weaponType),
            range: ItemType.getRange(character.weaponType),
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
            damage: ItemType.getDamage(character.weaponType),
            range: ItemType.getRange(character.weaponType),
            angle: character.lookRadian,
        );
        character.assignWeaponStateFiring();
        break;
    }
  }

  void playerThrowGrenade(Player player) {
    dispatchPlayerAttackPerformed(player);
    player.assignWeaponStateFiring();

    final mouseDistance = getDistanceXY(player.x, player.y, player.mouseGridX, player.mouseGridY);

    gameObjects.add(
        GameObject(
            x: player.x,
            y: player.y,
            z: player.z + Character_Height,
            type: ItemType.GameObjects_Grenade,
        )
        ..setVelocity(player.lookRadian, mouseDistance * 0.1)
        ..collidable = false
        ..physical = false
        ..applyGravity = true
        ..quantity = 1
        ..velocityZ = -0.75
        ..timer = 40
        ..owner = player
        ..damage = 15
    );
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

  void playerTeleportToMouse(Player player){
    positionToPlayerMouse(player, player);
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
    if (character.deadBusyOrWeaponStateBusy) return;

    final angle = character.lookRadian;
    final distance = ItemType.getRange(character.weaponType);
    if (distance <= 0){
      throw Exception('ItemType.getRange(${ItemType.getName(character.weaponType)})');
    }
    if (character.damage <= 0){
      throw Exception('game.playerAttackMelee character.damage <= 0');
    }
    final attackRadius = character.weaponTypeRange;

    final performX = character.x + getAdjacent(angle, distance);
    final performY = character.y + getOpposite(angle, distance);
    final performZ = character.z;

    character.performX = performX;
    character.performY = performY;
    character.performZ = performZ;
    character.assignWeaponStateFiring();

    /// TODO name arguments
    dispatchAttackPerformed(
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

    if (character.idling) {
      // playerFaceMouse(player);
    }

    var attackHit = false;

    for (final other in characters) {
      if (!other.collidable) continue;
      if (Collider.onSameTeam(character, other)) continue;
      if (other.distanceFromXYZ(
        performX,
        performY,
        performZ,
      ) > attackRadius) continue;
      applyHit(src: character, target: other);
      attackHit = true;
       other.applyForce(
           force: 7.5,
           angle: getAngleBetween(other.x, other.y, other.x, other.y),
       );
    }

    for (final gameObject in gameObjects) {
      if (gameObject.distanceFromXYZ(
        performX,
        performY,
        performZ,
      ) >
          attackRadius) continue;

      gameObject.applyForce(
        force: 5,
        angle: radiansV2(character, gameObject),
      );

      attackHit = true;
    }

    if (!scene.getNodeInBoundsXYZ(performX, performY, performZ)) return;
    final nodeIndex = scene.getNodeIndexXYZ(performX, performY, performZ);
    final nodeType = scene.nodeTypes[nodeIndex];

    character.applyForce(
      force: 4.5,
      angle: angle + pi,
    );

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
      player.writeByte(nodeType);
    }

    if (NodeType.isDestroyable(nodeType)) {
      setNode(
          nodeIndex: nodeIndex,
          nodeType: NodeType.Empty,
          nodeOrientation: NodeOrientation.None,
      );
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
        player.writeByte(character.weaponType);
      }
    }
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

    spawnProjectile(
      src: character,
      accuracy: character.accuracy,
      angle: angle,
      range: character.weaponTypeRange,
      projectileType: ProjectileType.Bullet,
      damage: character.damage,
    );
    dispatchAttackPerformed(
        character.weaponType,
        character.x,
        character.y,
        character.z,
        angle,
    );
  }

  void playerFaceMouse(Player player){
      player.faceXY(
          player.mouseGridX,
          player.mouseGridY,
      );
  }

  void deactivateGameObject(GameObject gameObject){
     if (!gameObject.active) return;
     gameObject.active = false;
     gameObject.collidable = false;
     gameObject.timer = 0;
     customOnGameObjectDeactivated(gameObject);
  }

  void onGridChanged() {
    scene.refreshGridMetrics();
    for (final player in players) {
      player.writeGrid();
    }
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

  var _timerUpdateAITargets = 0;

  void updateInProgress() {

    frame++;
    if (_timerUpdateAITargets-- <= 0) {
      _timerUpdateAITargets = 15;
      updateAITargets();
    }

    internalUpdateJobs();

    customUpdate();
    updateGameObjects();
    updateCollisions();
    updateCharacters();
    updateProjectiles();
    updateProjectiles(); // called twice to fix collision detection
    updateProjectiles(); // called twice to fix collision detection
    updateCharacterFrames();
    sortGameObjects();
  }

  void performJob(int timer, Function action){
    assert (timer > 0);
    for (final job in jobs){
      if (job.timer < 0) continue;
      job.timer = timer;
      job.action = action;
    }
    final job = GameJob(timer, action);
    jobs.add(job);
  }

  void internalUpdateJobs() {
    for (final job in jobs){
      if (job.timer <= 0) continue;
         job.timer--;
         if (job.timer == 0){
           job.action();
         }
    }
  }

  void updateColliderPhysics(Collider collider){
    if (!collider.applyGravity) return;


    if (scene.getCollisionAt(collider.x, collider.y, collider.z)) {
      collider.z = ((collider.z ~/ Node_Height) * Node_Height) + Node_Height;
      if (collider.velocityZ > 0) {
        collider.velocityZ = -collider.velocityZ * 0.5;
      }
    }

    if (collider.velocityX < 0) {
      if (scene.getCollisionAt(collider.left, collider.y, collider.z)) {
        collider.velocityX = -collider.velocityX;
      }
    } else
    if (collider.velocityX > 0) {
      if (scene.getCollisionAt(collider.right, collider.y, collider.z)) {
        collider.velocityX = -collider.velocityX;
      }
    }
    if (collider.velocityY < 0) {
      if (scene.getCollisionAt(collider.x, collider.top, collider.z)) {
        collider.velocityY = -collider.velocityY;
      }
    } else
    if (collider.velocityY > 0) {
      if (scene.getCollisionAt(collider.x, collider.bottom, collider.z)) {
        collider.velocityY = -collider.velocityY;
      }
    }
  }

  void updateGameObjects() {
    gameObjects.forEach(updateGameObject);
  }

  void updateGameObject(GameObject gameObject){
    if (!gameObject.active) return;
    gameObject.updatePhysics();
    updateColliderPhysics(gameObject);

    if (gameObject.timer <= 0)
      return;
    gameObject.timer--;
    if (gameObject.timer > 0)
      return;

    deactivateGameObject(gameObject);
    dispatchV3(GameEventType.GameObject_Timeout, gameObject);

    if (gameObject.type == ItemType.GameObjects_Grenade) {
      createExplosion(gameObject);
      // dispatchV3(GameEventType.Explosion, gameObject);
      // for (var i = 0; i < characters.length; i++){
      //   if (characters[i].dead) continue;
      //   final character = characters[i];
      //   if (gameObject.withinRadius(character, 100)) {
      //     applyHit(src: gameObject, target: character);
      //   }
      // }
    }
  }

  void createExplosion(Position3 src){
    dispatchV3(GameEventType.Explosion, src);
    for (var i = 0; i < characters.length; i++){
      if (characters[i].dead) continue;
      final character = characters[i];
      if (src.withinRadius(character, 100)) {
        applyHit(src: src, target: character);
      }
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
    player.setCharacterStateSpawning();
    player.health = player.maxHealth;
    player.collidable = true;
    clearCharacterTarget(player);
    player.writePlayerMoved();
    player.writePlayerAlive();

    if (player.inventoryOpen){
      player.interactMode = InteractMode.Inventory;
    }
    customOnPlayerRevived(player);
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

  void activateGameObject(GameObject gameObject){
    gameObject.active = true;
    gameObject.collidable = true;
  }

  void applyDamageToCharacter({
    required Character src,
    required Character target,
    required int amount,
  }) {
    if (target.deadOrDying) return;
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

  /// un@override
  void onAIKilled(AI ai){
    ai.respawn = aiRespawnDuration;
    clearCharacterTarget(ai);
    ai.clearDest();
    ai.clearPath();
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
  }

  void resolveCollisions(List<Collider> colliders) {
    final numberOfColliders = colliders.length;
    final numberOfCollidersMinusOne = numberOfColliders - 1;
    for (var i = 0; i < numberOfCollidersMinusOne; i++) {
      final colliderI = colliders[i];
      if (!colliderI.collidable) continue;
      for (var j = i + 1; j < numberOfColliders; j++) {
        final colliderJ = colliders[j];
        if (!colliderJ.collidable) continue;
        if (colliderJ.top > colliderI.bottom) break;
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
      if (!colliderA.collidable) continue;
      for (var indexB = 0; indexB < bLength; indexB++) {
        final colliderB = collidersB[indexB];
        if (!colliderB.collidable) continue;
        if (colliderA.bottom < colliderB.top) break;
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
    assert (a.collidable);
    assert (b.collidable);
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
    final combinedRadius = a.radius + b.radius;
    final totalDistance = getDistanceXY(a.x, a.y, b.x, b.y);
    final overlap = combinedRadius - totalDistance;
    if (overlap < 0) return;
    var xDiff = a.x - b.x;
    var yDiff = a.y - b.y;

    if (xDiff == 0 && yDiff == 0) {
      if (a.moveOnCollision){
        a.x += 5;
        xDiff += 5;
      }
      if (b.moveOnCollision){
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
    if (a.moveOnCollision){
      a.x += targetX;
      a.y += targetY;
    }
    if (b.moveOnCollision){
      b.x -= targetX;
      b.y -= targetY;
    }
  }

  void sortGameObjects() {
    Position3.sort(characters);
    Position3.sort(projectiles);
    Position3.sort(gameObjects);
  }

  void setCharacterStateDying(Character character) {
    if (character.deadOrDying) return;
    character.health = 0;
    character.state = CharacterState.Dying;
    character.stateDurationRemaining = 10;
    character.onCharacterStateChanged();
    character.collidable = false;

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
    if (character.deadOrBusy) return;
    character.assignWeaponStateChanging();
    dispatchV3(GameEventType.Character_Changing, character);
    // character.setCharacterState(value: CharacterState.Changing, duration: 20);
  }

  void setCharacterStateDead(Character character) {
    if (character.state == CharacterState.Dead) return;

    dispatchGameEventCharacterDeath(character);
    character.health = 0;
    character.state = CharacterState.Dead;
    character.stateDuration = 0;
    character.animationFrame = 0;
    character.collidable = false;
    character.velocityX = 0;
    character.velocityY = 0;
    clearCharacterTarget(character);

    if (character is AI){
      character.respawn = aiRespawnDuration;
    }

    if (character is Player) {
       character.interactMode = InteractMode.None;
       character.writePlayerAlive();
    }

    for (final otherCharacter in characters) {
      if (otherCharacter.target != character) continue;
      clearCharacterTarget(otherCharacter);
    }

    for (final projectile in projectiles) {
      if (projectile.target != character) continue;
      projectile.target = null;
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
        createExplosion(projectile);
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
        projectile.setVelocityTowards(target);
      } else if (projectile.overRange) {
        deactivateProjectile(projectile);
      }
    }
    for (var i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      if (!scene.getCollisionAt(projectile.x, projectile.y, projectile.z)) continue;
      deactivateProjectile(projectile);
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

    if (player.idling && !player.weaponStateBusy){
      final diff = Direction.getDifference(player.lookDirection, player.faceDirection);
      if (diff >= 2){
        player.faceAngle += piQuarter;
      } else if (diff <= -3) {
        player.faceAngle -= piQuarter;
      }
    }

    if (player.framesSinceClientRequest > 10) {
      player.setCharacterStateIdle();
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
        if (target.collectable || target.interactable){
           if (getDistanceBetweenV3(player, target) > Interact_Radius){
             setCharacterStateRunning(player);
             return;
           }
           if (target.interactable){
             player.setCharacterStateIdle();
             onPlayerInteractedWithGameObject(player, target);
             return;
           }
           if (target.collectable){
             player.setCharacterStateIdle();
             playerPickup(player, target);
             return;
           }
        }
      } else {
        if (!target.collidable) {
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
        if (!collider.collidable) continue;
        if (!collider.physical) continue;
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

    if (target is Collider) {
      applyHit(
        src: projectile,
        target: target,
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
    required Position3 src,
    required Collider target,
  }) {

    Character? srcCharacter;
    var damage = 0;

    if (src is Character){
      srcCharacter = src;
      damage = src.damage;
      target.applyForce(
        force: 20,
        angle: radiansV2(src, target),
      );
    } else if (src is Projectile) {
      assert (src.owner != null);
      srcCharacter = src.owner;
      damage = src.damage;
      target.applyForce(
          force: 20,
          angle: src.velocityAngle,
      );
    } else if (src is GameObject){
      final srcOwner = src.owner;
      if (srcOwner is Character){
        srcCharacter = srcOwner;
      }
      damage = src.damage;
      target.applyForce(
        force: 20,
        angle: getAngleBetweenV3(target, src),
      );
    }

    if (srcCharacter == null){
      throw Exception("srcCharacter == null");
    }

    if (!target.collidable) return;
    if (target is Character) {
      if (Collider.onSameTeam(src, target)) return;
      if (target.deadOrDying) return;
    }

    // TODO Hack
    if (srcCharacter.characterTypeZombie) {
      dispatchV3(GameEventType.Zombie_Strike, srcCharacter);
    }
    if (target is Character) {
      applyDamageToCharacter(src: srcCharacter, target: target, amount: damage);
    }

    customOnHitApplied(srcCharacter, target);
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
    final attackTarget = character.target;
    if (attackTarget == null) return;
    if (attackTarget is Collider) {
      applyHit(
        src: character,
        target: attackTarget,
      );
      clearCharacterTarget(character);
    }
  }

  void updateCharacter(Character character) {

    if (character.dead) {
       if (character is AI){
         if (character.respawn-- > 0) return;
         respawnAI(character);
       }
       return;
    }

    if (character is! Player){
      character.lookRadian = character.faceAngle;
    }

    character.updateAccuracy();

    if (character.weaponStateDuration > 0) {
      character.weaponStateDuration--;

      if (character.weaponStateDuration <= 0){
        switch (character.weaponState) {
          case WeaponState.Firing:
            character.assignWeaponStateAiming();
            break;
          case WeaponState.Aiming:
            character.assignWeaponStateIdle();
            break;
          case WeaponState.Reloading:
            character.assignWeaponStateIdle();
            break;
          case WeaponState.Changing:
            character.assignWeaponStateIdle();
            break;
          case WeaponState.Idle:
            character.assignWeaponStateIdle();
            break;
        }
      }
    }

    if (character is AI){
      character.updateAI();
      character.applyBehaviorWander(this);
    }
    character.updateMovement();
    resolveCharacterTileCollision(character);
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
        character.applyForce(force: 1.0, angle: character.faceAngle);
        if (character.nextFootstep++ >= 10) {
          dispatch(
            GameEventType.Footstep,
            character.x,
            character.y,
            character.z,
          );
          character.nextFootstep = 0;
        }
        break;
      case CharacterState.Performing:
        updateCharacterStatePerforming(character);
        break;
      case CharacterState.Spawning:
        if (character.stateDurationRemaining == 1){
          customOnCharacterSpawned(character);
        }
        if (character.stateDuration == 0) {
          if (this is Player){
            (this as Player).writePlayerEvent(PlayerEvent.Spawn_Started);
          }
        }
        break;
    }
    character.stateDuration++;
  }

  void updateRespawnAI(AI ai) {
    assert(ai.dead);
    if (ai.respawn-- > 0) return;
    respawnAI(ai);
  }

  void respawnAI(AI ai){
    final distance = randomBetween(0, 100);
    final angle = randomAngle();
    ai.x = ai.spawnX + getAdjacent(angle, distance);
    ai.y = ai.spawnY + getOpposite(angle, distance);
    ai.z = ai.spawnZ;
    ai.respawn = aiRespawnDuration;
    ai.clearDest();
    clearCharacterTarget(ai);
    ai.clearPath();
    ai.collidable = true;
    ai.health = ai.maxHealth;
    ai.target = null;
    ai.velocityX = 0;
    ai.velocityX = 0;
    ai.setCharacterStateSpawning();
    customOnAIRespawned(ai);
  }

  Projectile spawnProjectileOrb({required Character src, required int damage}) {
    dispatchV3(GameEventType.Blue_Orb_Fired, src);
    return spawnProjectile(
      src: src,
      accuracy: 0,
      range: src.weaponTypeRange,
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

  Projectile spawnProjectileBullet({
    required Character src,
    required double speed,
    double accuracy = 0,
  }) =>
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: src.faceAngle,
      range: src.weaponTypeRange,
      projectileType: ProjectileType.Bullet,
      damage: src.damage,
    );

  void fireAssaultRifle(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      range: 300,
      projectileType: ProjectileType.Bullet,
      damage: 5,
    );
    dispatchAttackPerformed(src.weaponType, src.x, src.y, src.z, angle);
  }

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
    for (var i = 0; i < 5; i++) {
      spawnProjectile(
        src: src,
        accuracy: 0,
        angle: angle + giveOrTake(0.25),
        range: src.weaponTypeRange,
        projectileType: ProjectileType.Bullet,
        damage:src.damage,
      );
    }
    src.assignWeaponStateFiring();
    dispatchAttackPerformed(src.weaponType, src.x, src.y, src.z, angle);
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
    projectile.collidable = true;
    projectile.active = true;
    if (target is Collider) {
      projectile.target = target;
    }
    const r = 0.01;
    projectile.x = src.x + getAdjacent(finalAngle, r);
    projectile.y = src.y + getOpposite(finalAngle, r);
    projectile.z = src.z + Character_Gun_Height;
    projectile.start.x = projectile.x;
    projectile.start.y = projectile.y;
    projectile.setVelocity(finalAngle, ProjectileType.getSpeed(projectileType));
    projectile.owner = src;
    projectile.range = range;
    projectile.type = projectileType;
    projectile.radius = ProjectileType.getRadius(projectileType);
    return projectile;
  }

  Projectile getInstanceProjectile() {
    for (var i = 0; i < projectiles.length; i++) {
      if (projectiles[i].active) continue;
      return projectiles[i];
    }
    final projectile = Projectile();
    projectiles.add(projectile);
    return projectile;
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
    position.x = scene.convertNodeIndexToRow(index) * Node_Size;
    position.y = scene.convertNodeIndexToColumn(index) * Node_Size;
    position.z = scene.convertNodeIndexToZ(index) * Node_Height;
  }

  GameObject spawnGameObjectAtIndex({required int index, required int type}){
    final instance = GameObject(
      x: 0,
      y: 0,
      z: 0,
      type: type,
    );
    moveV3ToNodeIndex(instance, index);
    gameObjects.add(instance);
    return instance;
  }

  void spawnGameObjectItemAtPosition({
    required Position3 position,
    required int type,
    int quantity = 1,
    int timer = 0,
  }) =>
    spawnGameObjectItem(
        x: position.x,
        y: position.y,
        z: position.z,
        type: type,
        quantity: quantity,
        timer: timer,
    );

  void spawnGameObjectItem({
        required double x,
        required double y,
        required double z,
        required int type,
        int quantity = 1,
        int timer = 0,
  }){
    assert (type != ItemType.Empty);
    assert (type != ItemType.Equipped_Legs);
    assert (type != ItemType.Equipped_Body);
    assert (type != ItemType.Equipped_Head);
    assert (type != ItemType.Equipped_Weapon);
    spawnGameObject(x: x, y: y, z: z, type: type)
      ..quantity = quantity
      ..timer = timer;
  }

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
       gameObject.velocityX = 0;
       gameObject.velocityY = 0;
       gameObject.velocityZ = 0;
       gameObject.type = type;
       gameObject.active = true;
       gameObject.collidable = ItemType.isCollidable(type);
       return gameObject;
    }
    final instance = GameObject(
      x: x,
      y: y,
      z: z,
      type: type,
    );
    instance.collidable = ItemType.isCollidable(type);
    gameObjects.add(instance);
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

  void resolveCharacterTileCollision(Character character) {
    const distance = 3;
    final stepHeight = character.z + Node_Height_Half;

    if (scene.getCollisionAt(character.left, character.top, stepHeight)) {
      character.x += distance;
      character.y += distance;
    }
    else
    if (scene.getCollisionAt(character.right, character.bottom, stepHeight)) {
      character.x -= distance;
      character.y -= distance;
    }
    if (scene.getCollisionAt(character.left, character.bottom, stepHeight)) {
      character.x += distance;
      character.y -= distance;
    } else
    if (scene.getCollisionAt(character.right, character.top, stepHeight)) {
      character.x -= distance;
      character.y += distance;
    }

    if (scene.getNodeInBoundsXYZ(character.x, character.y, character.z)) {
      final nodeAtFeetIndex = scene.getNodeIndexXYZ(character.x, character.y, character.z);
      final nodeAtFeetOrientation = scene.nodeOrientations[nodeAtFeetIndex];

      if (nodeAtFeetOrientation == NodeOrientation.Solid){
        // character.z += (character.z % Node_Size);
        character.z = ((character.z ~/ Node_Height) * Node_Height) + Node_Height;
        character.velocityZ = 0;
      } else
      if (nodeAtFeetOrientation != NodeOrientation.None) {
        final bottom = (character.z ~/ Node_Height) * Node_Height;
        final percX = ((character.x % Node_Size) / Node_Size);
        final percY = ((character.y % Node_Size) / Node_Size);
        final nodeTop = bottom + (NodeOrientation.getGradient(nodeAtFeetOrientation, percX, percY) * Node_Height);
        if (nodeTop > character.z){
          character.z = nodeTop;
          character.velocityZ = 0;
        }
      }
    } else {
      if (character.z < -100){
        setCharacterStateDead(character);
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
        spawnAI(
          characterType: randomItem(const [CharacterType.Dog, CharacterType.Zombie, CharacterType.Template]),
          nodeIndex: index,
          damage: 10,
          team: TeamType.Evil,
          health: 3,
        );
      }
    }
  }

  /// WARNING EXPENSIVE OPERATION
  void clearSpawnedAI(){
      for (var i = 0; i < characters.length; i++){
         if (characters[i].characterTypeZombie) {
           characters.removeAt(i);
           i--;
         }
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

  void playerPickup(Player player, GameObject target) {
    var quantityRemaining = target.quantity;
    final maxQuantity = ItemType.getMaxQuantity(target.type);
    if (maxQuantity > 1) {
      for (var i = 0; i < player.inventory.length; i++){
        if (player.inventory[i] != target.type) continue;
        if (player.inventoryQuantity[i] + quantityRemaining < maxQuantity){
          player.inventoryQuantity[i] += quantityRemaining;
          player.inventoryDirty = true;
          deactivateGameObject(target);
          player.writePlayerEvent(PlayerEvent.Item_Picked_Up);
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
      deactivateGameObject(target);
      player.writePlayerEvent(PlayerEvent.Item_Picked_Up);
      clearCharacterTarget(player);
    } else {
      clearCharacterTarget(player);
      player.writePlayerEventInventoryFull();
      return;
    }
    clearCharacterTarget(player);
    return;
  }


  void onPlayerInteractedWithGameObject(Player player, GameObject gameObject){
  }
}

