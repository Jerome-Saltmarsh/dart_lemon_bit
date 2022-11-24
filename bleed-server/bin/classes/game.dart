import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../constants/frames_per_second.dart';
import '../engine.dart';
import '../io/write_scene_to_file.dart';
import '../maths.dart';
import '../maths/get_distance_between_v3.dart';
import '../physics.dart';
import 'ai.dart';
import 'character.dart';
import 'collider.dart';
import 'gameobject.dart';
import 'npc.dart';
import 'player.dart';
import 'position3.dart';
import 'projectile.dart';
import 'rat.dart';
import 'scene.dart';
import 'zombie.dart';

abstract class Game {
  var frame = 0;
  final Scene scene;
  final players = <Player>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];

  static const AI_Respawn_Duration = framesPerSecond * 60 * 2; // 5 minutes

  List<GameObject> get gameObjects => scene.gameObjects;

  /// In seconds
  void customInitPlayer(Player player) {}
  /// safe to override
  void customPlayerWrite(Player player){ }
  /// safe to override
  void customUpdatePlayer(Player player){ }
  /// safe to override
  void customDownloadScene(Player player){ }
  /// safe to override
  void customUpdate();
  /// safe to override
  void customOnPlayerDisconnected(Player player) { }
  /// safe to override
  void customOnGameObjectDeactivated(GameObject gameObject){ }
  /// safe to override
  void customOnCharacterSpawned(Character character) { }
  /// safe to override
  void customOnCharacterKilled(Character target, dynamic src) { }
  /// safe to override
  void customOnCharacterDamageApplied(Character target, dynamic src, int amount) { }
  /// safe to overridable
  void customOnPlayerRevived(Player player) { }
  /// safe to overridable
  void customOnGameStarted() { }
  /// safe to overridable
  void customOnNpcObjectivesCompleted(Character npc) { }
  /// safe to overridable
  void customOnPlayerLevelGained(Player player) { }
  /// safe to override
  void customOnCollisionBetweenColliders(Collider a, Collider b) { }
  /// safe to override
  void customOnCollisionBetweenPlayerAndOther(Player player, Collider collider) { }
  /// safe to override
  void customOnCollisionBetweenPlayerAndGameObject(Player player, GameObject gameObject) { }
  /// safe to override
  void customOnAIRespawned(AI ai){  }
  /// safe to override
  void customOnPlayerRequestPurchaseWeapon(Player player, int type){ }
  /// safe to override
  void customOnPlayerWeaponChanged(Player player, int previousWeaponType, int newWeaponType){ }
  /// once the player has finished striking then reequip the weapon
  void customOnPlayerWeaponReady(Player player) {  }
  /// PROPERTIES

  /// Safe to override
  double get minAimTargetCursorDistance => 35;

  bool get customPropMapVisible => false;
  int get gameType;


  /// CONSTRUCTOR
  Game(this.scene) {
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
    vector3.x = scene.convertNodeIndexToXPosition(nodeIndex);
    vector3.y = scene.convertNodeIndexToYPosition(nodeIndex);
    vector3.z = scene.convertNodeIndexToZPosition(nodeIndex);
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

    if (player.weaponDurationRemaining <= 0) {
      player.lookRadian = player.mouseAngle;
    }

    if (cursorAction == CursorAction.Set_Target) {
      if (direction != Direction.None) {
        playerUseWeapon(player);
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
      playerUseWeapon(player);
    }

    if (cursorAction == CursorAction.Stationary_Attack_Auto){
      playerAutoAim(player);
      playerUseWeapon(player);
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
      if (!gameObject.collectable) continue;
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

  void playerUseWeapon(Player player) {
    if (player.deadBusyOrUsingWeapon) return;

    if (player.equippedWeaponUsesAmmunition){
      final currentAmmunition = player.equippedWeaponQuantity;
      if (currentAmmunition > 0){
         player.inventorySetQuantityAtIndex(
             quantity: currentAmmunition - 1,
             index: player.equippedWeaponIndex,
         );
         player.writePlayerEquippedWeaponAmmunition();
      } else {
        player.writeError('no ammunition');
        return;
      }
    }

    final weaponType = player.weaponType;

    if (ItemType.isTypeWeaponMelee(weaponType)) {
      playerAttackMelee(player: player);
      return;
    }

    if (ItemType.isTypeWeaponHandgun(weaponType)) {
      characterFireWeapon(player);
      return;
    }

    if (ItemType.isTypeWeaponRifle(weaponType)) {
      characterFireWeapon(player);
      return;
    }

    if (ItemType.isTypeWeaponShotgun(weaponType)) {
      characterFireShotgun(player, player.lookRadian);
      return;
    }

    switch (weaponType) {
      case ItemType.Weapon_Ranged_Crossbow:
        spawnProjectileArrow(
            damage: ItemType.getDamage(weaponType),
            range: ItemType.getRange(weaponType),
            src: player,
            angle: player.lookRadian,
        );
        return;
      case ItemType.Weapon_Melee_Staff:
        characterSpawnProjectileFireball(
            player,
            angle: player.lookRadian,
        );
        break;
      case ItemType.Weapon_Ranged_Bow:
        spawnProjectileArrow(
            src: player,
            damage: ItemType.getDamage(weaponType),
            range: ItemType.getRange(weaponType),
            angle: player.lookRadian,
        );
        player.weaponDurationRemaining = ItemType.getCooldown(player.weaponType);
        assert(player.weaponDurationRemaining > 0);
        break;
    }
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

  void playerAttackMelee({
    required Player player,
  }) {
    if (player.deadBusyOrUsingWeapon) return;

    final angle = player.lookRadian;
    final distance = ItemType.getRange(player.weaponType);
    if (distance <= 0){
      throw Exception('ItemType.getRange(${ItemType.getName(player.weaponType)})');
    }
    if (player.damage <= 0){
      throw Exception('game.playerAttackMelee player.damage <= 0');
    }
    final attackRadius = 35.0;

    final performX = player.x + getAdjacent(angle, distance);
    final performY = player.y + getOpposite(angle, distance);
    final performZ = player.z;

    player.performX = performX;
    player.performY = performY;
    player.performZ = performZ;
    player.weaponDurationRemaining = ItemType.getCooldown(player.weaponType);
    assert (player.weaponDurationRemaining  > 0);

    /// TODO name arguments
    dispatchAttackPerformed(
        player.weaponType,
        performX,
        performY,
        performZ,
        angle,
    );

    player.applyForce(
      force: 2.5,
      angle: angle,
    );

    if (player.idling) {
      // playerFaceMouse(player);
    }

    var attackHit = false;

    for (final character in characters) {
      if (!character.collidable) continue;
      if (Collider.onSameTeam(player, character)) continue;
      if (character.distanceFromXYZ(
        performX,
        performY,
        performZ,
      ) > attackRadius) continue;
      applyHit(src: player, target: character);
      attackHit = true;
       player.applyForce(
           force: 7.5,
           angle: getAngleBetween(player.x, player.y, character.x, character.y),
       );
    }

    for (final gameObject in gameObjects) {
      if (gameObject.distanceFromXYZ(
        performX,
        performY,
        performZ,
      ) >
          attackRadius) continue;

      // if (gameObject is Collider == false) continue;
      gameObject.applyForce(
        force: 5,
        angle: radiansV2(player, gameObject),
      );

      attackHit = true;
    }

    if (!scene.getNodeInBoundsXYZ(performX, performY, performZ)) return;
    final nodeIndex = scene.getNodeIndexXYZ(performX, performY, performZ);
    final nodeType = scene.nodeTypes[nodeIndex];

    player.applyForce(
      force: 4.5,
      angle: angle + pi,
    );

    attackHit = true;
    for (final player in players) {
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
        player.writeGameEvent(
          type: GameEventType.Attack_Missed,
          x: performX,
          y: performY,
          z: performZ,
          angle: angle,
        );
        player.writeByte(player.weaponType);
      }
    }
  }

  void characterFireWeapon(Character character){
    final angle = (character is Player) ? character.lookRadian : character.faceAngle;

    character.weaponDurationRemaining = ItemType.getCooldown(character.weaponType);
    assert(character.weaponDurationRemaining > 0);
    character.weaponState = AttackState.Firing;
    character.applyForce(
      force: 1.0,
      angle: angle + pi,
    );

    spawnProjectile(
      src: character,
      accuracy: 0,
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

  void deactivateGameObject(GameObject gameObject, {int duration = 0}){
     if (!gameObject.active) return;
     gameObject.active = false;
     gameObject.collidable = false;
     gameObject.timer = duration;
     customOnGameObjectDeactivated(gameObject);
  }

  void onGridChanged() {
    scene.refreshGridMetrics();
    scene.dirty = true;
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
      player.writeByte(character.type);
    }
  }

  void removeFromEngine() {
    print("removeFromEngine()");
    engine.games.remove(this);
  }

  void setHourMinutes(int hour, int minutes) {}

  /// UPDATE

  var _timerUpdateAITargets = 0;

  void updateInProgress() {

    frame++;
    if (_timerUpdateAITargets-- <= 0) {
      _timerUpdateAITargets = 15;
      updateAITargets();
    }

    customUpdate();
    updateGameObjects();
    updateCollisions();
    updateCharacters();
    updateProjectiles();
    updateProjectiles(); // called twice to fix collision detection
    updateCharacterFrames();
    sortGameObjects();
  }

  void updateGameObjects() {
    for (final gameObject in gameObjects){
       if (!gameObject.active) continue;
       if (gameObject.timer <= 0) continue;
       gameObject.timer--;
       if (gameObject.timer > 0) continue;
       deactivateGameObject(gameObject);
       dispatchV3(GameEventType.GameObject_Timeout, gameObject);
    }
  }

  void updateStatus() {
    removeDisconnectedPlayers();
    if (players.length == 0) return;
    updateInProgress();
    for (final player in players) {
      player.writeAndSendResponse();
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
    customOnPlayerRevived(player);
  }

  int countAlive(List<Character> characters) {
    var total = 0;
    for (final character in characters) {
      if (character.alive) total++;
    }
    return total;
  }

  Player spawnPlayer();

  void playersWriteWeather() {
    for (final player in players) {
      player.writeWeather();
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

  Collider? getClosestCollider(double x, double y, Character character,
      {required double minDistance}) {
    return findClosestVector3<Character>(
      positions: characters,
      x: x,
      y: y,
      z: character.z,
      where: (other) =>
      other.alive &&
          other != character &&
          other.distanceFromXYZ(x, y, character.z) < minDistance,
    );
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

  /// unsafe to override
  void onAIKilled(AI ai){
    ai.respawn = AI_Respawn_Duration;
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
      player.writeByte(character.type);
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
      final colliderIBottom = colliderI.bottom;
      for (var j = i + 1; j < numberOfColliders; j++) {
        final colliderJ = colliders[j];
        if (!colliderJ.collidable) continue;
        if (colliderJ.top > colliderIBottom) break;
        if (colliderJ.left > colliderI.right) continue;
        if (colliderJ.bottom < colliderI.top) continue;
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
    for (var i = 0; i < aLength; i++) {
      final a = collidersA[i];
      if (!a.collidable) continue;
      for (var j = 0; j < bLength; j++) {
        final b = collidersB[j];
        if (!b.collidable) continue;
        if (a.bottom < b.top) continue;
        if (a.top > b.bottom) continue;
        if (a.right < b.left) continue;
        if (a.left > b.right) continue;
        if ((a.z - b.z).abs() > Node_Height) continue;
        if (a == b) continue;
        internalOnCollisionBetweenColliders(a, b);
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
    dispatchV3(GameEventType.Character_Changing, character);
    character.setCharacterState(value: CharacterState.Changing, duration: 20);
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
      character.respawn = AI_Respawn_Duration;
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
    assert(projectile.active);
    projectile.active = false;
    switch (projectile.type) {
      case ProjectileType.Orb:
        dispatch(GameEventType.Blue_Orb_Deactivated, projectile.x, projectile.y,
            projectile.z);
        break;
      default:
        break;
    }
  }

  void updateProjectiles() {
    var projectilesLength = projectiles.length;
    for (var i = 0; i < projectilesLength; i++) {
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
    projectilesLength = projectiles.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      if (projectile.collideWithEnvironment) continue;
      if (scene.getCollisionAt(projectile.x, projectile.y, projectile.z)) {
        deactivateProjectile(projectile);
      }
    }

    checkProjectileCollision(characters);
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

    if (player.idling && !player.usingWeapon){
      final diff = Direction.getDifference(player.lookDirection, player.faceDirection);
      if (diff >= 2){
        player.faceAngle += piQuarter;
      } else if (diff <= -3) {
        player.faceAngle -= piQuarter;
      }
    }

    if (player.weaponDurationRemaining > 0) {
      player.weaponDurationRemaining--;
      if (player.weaponDurationRemaining <= 0){
        player.weaponState = AttackState.Idle;
        player.lookRadian = player.mouseAngle;
        customOnPlayerWeaponReady(player);
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
      if (target is GameObject){
        if (!target.active) {
           clearCharacterTarget(player);
           return;
        }

        if (target.collectable){
           if (getDistanceBetweenV3(player, target) > 50){
             setCharacterStateRunning(player);
             return;
           } else {
             final emptyInventoryIndex = player.getEmptyInventoryIndex();
             if (emptyInventoryIndex != null){
                player.inventory[emptyInventoryIndex] = target.type;
                player.inventoryQuantity[emptyInventoryIndex] = target.quantity;
                player.inventoryDirty = true;
                deactivateGameObject(target);
                player.writePlayerEvent(PlayerEvent.Item_Picked_Up);
                clearCharacterTarget(player);
             }
             clearCharacterTarget(player);
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
          playerUseWeapon(player);
          clearCharacterTarget(player);
          return;
        }
        setCharacterStateRunning(player);
        return;
      }

      if (target is Npc && player.targetIsAlly) {
        if (player.withinRadius(target, 100)) {
          if (!target.deadOrBusy) {
            target.face(player);
          }
          final onInteractedWith = target.onInteractedWith;
          if (onInteractedWith != null) {
            player.interactMode = InteractMode.Talking;
            player.setInteractingNpcName(target.name);
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

    // if (player.runningToTarget) {
    //   player.face(player.runTarget);
    // }

    setCharacterStateRunning(player);
  }

  void setCharacterStateRunning(Character character){
    character.setCharacterState(value: CharacterState.Running, duration: 0);
  }

  void checkProjectileCollision(List<Collider> colliders) {
    final projectilesLength = projectiles.length;
    final collidersLength = colliders.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      final target = projectile.target;
      if (target != null) {
        if (projectile.withinRadius(target, 10.0)) {
          handleProjectileHit(projectile, target);
          continue;
        }
        continue;
      }
      for (var j = 0; j < collidersLength; j++) {
        final collider = colliders[j];
        if (!collider.collidable) continue;
        if (projectile.right < collider.left) continue;
        if (projectile.left > collider.right) continue;
        if (projectile.top > collider.bottom) continue;
        if (projectile.bottom < collider.top) continue;
        if (projectile.owner == collider) continue;
        if (target != null && Collider.onSameTeam(projectile, collider)) continue;
        handleProjectileHit(projectile, collider);
        break;
      }
    }
  }

  int getRandomWeaponIndex() =>
    randomItem([
      ItemType.Weapon_Rifle_Assault,
      ItemType.Weapon_Ranged_Bow,
    ]);

  void handleProjectileHit(Projectile projectile, Position3 target) {
    projectile.active = false;
    if (target is Character) {
      applyHit(
        src: projectile,
        target: target,
      );
    }
    projectile.owner = null;
    projectile.target = null;

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
      srcCharacter = src.owner;
      damage = src.damage;
      target.applyForce(
          force: 20,
          angle: src.velocityAngle,
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
    if (srcCharacter is Zombie) {
      dispatchV3(GameEventType.Zombie_Strike, srcCharacter);
    }
    if (target is Character) {
      applyDamageToCharacter(src: srcCharacter, target: target, amount: damage);
    }
  }

  void updateCharacterStatePerforming(Character character) {
    updateCharacterStateAttacking(character);
  }

  void updateCharacter(Character character) {

    if (character.dead) {
       if (character is AI){
         if (character.respawn-- > 0) return;
         respawnAI(character);
       }
       return;
    }

    if (character is AI){
      updateAI(character);
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

  void updateAI(AI ai){
      if (ai.busy) return;

      final target = ai.target;
      if (target != null) {
        if (ai.withinAttackRange(target)) {
          faceCharacterTowards(ai, target);
          ai.setCharacterStatePerforming(duration: ai.equippedAttackDuration);
          return;
        }
        ai.destX = target.x;
        ai.destY = target.y;
      }

      if (!ai.arrivedAtDest) {
        ai.faceDestination();
        setCharacterStateRunning(ai);

        // if (target != null){
        //    if (ai.nextTeleport-- <= 0){
        //       ai.nextTeleport = randomInt(500, 1000);
        //       final angle = randomAngle();
        //       final distanceFromTarget = getDistanceBetweenV3(ai, target);
        //       final x = target.x + getAdjacent(angle, distanceFromTarget);
        //       final y = target.y + getOpposite(angle, distanceFromTarget);
        //       final z = ai.z;
        //
        //       if (scene.getNodeInBoundsXYZ(x, y, z)) {
        //            final nodeType = scene.getNodeTypeXYZ(x, y, z);
        //            if (nodeType == NodeType.Empty){
        //              ai.x = x;
        //              ai.y = y;
        //              ai.z = z;
        //            }
        //       }
        //    }
        // }

        return;
      }

      if (ai.pathIndex > 0){
        ai.pathIndex--;
        ai.destX = ai.pathX[ai.pathIndex].toDouble();
        ai.destY = ai.pathY[ai.pathIndex].toDouble();
        ai.faceDestination();
        setCharacterStateRunning(ai);
        return;
      }
      ai.state = CharacterState.Idle;
      ai.applyBehaviorWander(this);
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
        if (character.stateDuration % 10 == 0) {
          dispatch(
            GameEventType.Footstep,
            character.x,
            character.y,
            character.z,
          );
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
    ai.respawn = AI_Respawn_Duration;
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
      range: src.equippedRange,
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

  Projectile spawnProjectileBullet({
    required Character src,
    required double speed,
    double accuracy = 0,
  }) =>
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: src.faceAngle,
      range: src.equippedRange,
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

  void fireRifle(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      range: 600,
      projectileType: ProjectileType.Bullet,
      damage: 10,
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
    src.weaponDurationRemaining = ItemType.getCooldown(src.weaponType);
    assert(src.weaponDurationRemaining > 0);
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
    projectile.damage = damage;
    projectile.collidable = true;
    projectile.active = true;
    if (target is Collider) {
      projectile.target = target;
    }
    projectile.start.x = src.x;
    projectile.start.y = src.y;
    projectile.x = src.x;
    projectile.y = src.y;
    projectile.z = src.z + Node_Height_Half;
    projectile.setVelocity(finalAngle + giveOrTake(accuracy), ProjectileType.getSpeed(projectileType));
    projectile.owner = src;
    projectile.range = range;
    projectile.type = projectileType;
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

  void spawnAtIndexZombies({
    required int index,
    int total = 2,
    int health = 10,
    int damage = 1,
    int team = TeamType.Evil,
  }) {
    for (var j = 0; j < total; j++) {
      spawnAtIndexZombie(
          index: index,
          health: health,
          damage: damage,
          team: team,
      );
    }
  }

  Zombie spawnAtIndexZombie({
    required int index,
    int health = 10,
    int damage = 1,
    int team = TeamType.Evil,
  }) {
    if (index >= scene.gridVolume) {
      throw Exception('game.spawnZombieAtIndex($index) \ni >= scene.gridVolume');
    }

    final indexZ = scene.convertNodeIndexToZ(index);
    final indexRow = scene.convertNodeIndexToRow(index);
    final indexColumn = scene.convertNodeIndexToColumn(index);
    final posX = indexRow * Node_Size;
    final posY = indexColumn * Node_Size;
    final posZ = indexZ * Node_Height;

    final instance = Zombie(
      x: posX,
      y: posY,
      z: posZ,
      health: health,
      damage: damage,
      team: team,
    );
    characters.add(instance);
    instance.spawnNodeIndex = index;
    return instance;
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

  Rat getInstanceRat() {
    for (final character in characters) {
      if (character.alive) continue;
      if (character is Rat) return character;
    }
    final instance = Rat(
      z: 0,
      row: 0,
      column: 0,
      health: 10,
      damage: 1,
      game: this,
      team: TeamType.Evil,
    );
    characters.add(instance);
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

  void dispatchAttackPerformed(int attackType, double x, double y, double z, double angle){
    for (final player in players) {
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
    var target = ai.target;
    final targetSet = target != null;
    if (target != null && !ai.withinChaseRange(target)) {
      ai.target = null;
      ai.clearDest();
    }

    var targetDistance = 9999999.0;

    for (final other in characters) {
      if (!other.alive) continue;
      if (Collider.onSameTeam(other, ai)) continue;
      if (!ai.withinViewRange(other)) continue;
      final npcDistance = ai.getDistance(other);
      if (npcDistance >= targetDistance) continue;
      setNpcTarget(ai, other);
      targetDistance = npcDistance;
    }
    target = ai.target;
    if (target == null) return;
    if (targetDistance < 100) return;
    npcSetPathTo(ai, target);
    if (!targetSet){
      dispatchGameEventAITargetAcquired(ai);
    }
  }

  void dispatchGameEventAITargetAcquired(AI ai){
    for (final player in players) {
      player.writeGameEvent(
        type: GameEventType.AI_Target_Acquired,
        x: ai.x,
        y: ai.y,
        z: ai.z,
        angle: 0,
      );
      player.writeByte(ai.type);
    }
  }

  void setNpcTarget(AI ai, Position3 value) {
    if (value is Collider) {
      assert(!Collider.onSameTeam(ai, value));
    }
    assert(ai.alive);
    ai.target = value;
  }

  void removeDisconnectedPlayers() {
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.framesSinceClientRequest++ < 300) continue;
      if (!removePlayer(player)) continue;
      i--;
      playerLength--;
      // print("Removed disconnected player");
    }
  }

  bool removePlayer(Player player) {
    if (!players.remove(player)) return false;
    characters.remove(player);
    customOnPlayerDisconnected(player);
    if (player.scene.dirty && player.scene.name.isNotEmpty) {
      saveSceneToFile();
    }
    return true;
  }

  void saveSceneToFile() {
    assert(scene.name.isNotEmpty);
    writeSceneToFile(scene);
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

  /// This represents a standard attack from the character, no powers
  void updateCharacterStateAttacking(Character character) {
    const framePerformStrike = 10;
    final stateDuration = character.stateDuration;
    if (character is Zombie) {
      if (stateDuration != framePerformStrike) return;
      final attackTarget = character.target;
      if (attackTarget == null) return;
      if (attackTarget is Collider) {
        applyHit(
          src: character,
          target: attackTarget,
        );
        clearCharacterTarget(character);
      }
      return;
    }

    final weaponType = character.weaponType;
    if (weaponType == ItemType.Weapon_Melee_Sword) {
      if (stateDuration == 7) {
        dispatchV3(GameEventType.Sword_Woosh, character);
      }
    }
    if (weaponType == ItemType.Empty) {
      if (stateDuration == 7) {
        // dispatchV3(GameEventType.Arm_Swing, character);
      }
    }

    if (character.equippedTypeIsShotgun) {
      if (stateDuration == 1) {
        if (character.equippedIsEmpty) {
          // dispatchV3(GameEventType.Ammo_Acquired, character);
          return;
        }
        // dispatchV3(GameEventType.Shotgun_Fired, character);
        final totalBullets = 4;
        for (int i = 0; i < totalBullets; i++) {
          spawnProjectileBullet(
            src: character,
            accuracy: 0,
            speed: 15.0,
          );
        }
      }
    }

    if (character.equippedTypeIsBow && stateDuration == 1) {
      dispatchV3(GameEventType.Draw_Bow, character);
    }

    if (stateDuration != framePerformStrike)
      return;

    if (character.equippedTypeIsStaff) {
      // spawnProjectileOrb(src: character, damage: equippedDamage);
      clearCharacterTarget(character);
      return;
    }

    if (character.equippedTypeIsBow) {
      dispatchV3(GameEventType.Release_Bow, character);
         spawnProjectileArrow(
          src: character,
          damage: character.damage,
          target: character.target,
          range: character.equippedRange,
         );
      clearCharacterTarget(character);
      return;
    }
    if (character.equippedIsMelee) {

      final attackTarget = character.target;
      if (attackTarget != null) {
        if (attackTarget is Collider && attackTarget.collidable) {
          applyHit(src: character, target: attackTarget);
          clearCharacterTarget(character);
          return;
        }
        clearCharacterTarget(character);
      }
      final zombieHit = raycastHit(
          character: character,
          colliders: characters,
          range: character.equippedRange);
      if (zombieHit != null) {
        applyHit(
          src: character,
          target: zombieHit,
        );
        return;
      }
      return;
    }
  }

  Npc addNpc({
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
    final npc = Npc(
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
      speed: speed,
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
        character.z = ((character.z ~/ Node_Height) * Node_Height) + Node_Height;
        character.zVelocity = 0;
      } else
      if (nodeAtFeetOrientation != NodeOrientation.None) {
        final bottom = (character.z ~/ Node_Height) * Node_Height;
        final percX = ((character.x % Node_Size) / Node_Size);
        final percY = ((character.y % Node_Size) / Node_Size);
        final nodeTop = bottom + (NodeOrientation.getGradient(nodeAtFeetOrientation, percX, percY) * Node_Height);
        if (nodeTop > character.z){
          character.z = nodeTop;
          character.zVelocity = 0;
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
    scene.dirty = true;
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

  void triggerSpawnPoints({int instances = 2}){
    for (final index in scene.spawnPoints){
      spawnAtIndexZombies(
          index: index,
          total: instances,
          damage: 10,
          team: TeamType.Evil,
          health: 15,
      );
    }
  }

  /// WARNING EXPENSIVE OPERATION
  void clearSpawnedAI(){
      for (var i = 0; i < characters.length; i++){
         if (characters[i] is Zombie){
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
}

