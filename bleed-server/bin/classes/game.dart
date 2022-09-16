import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../common/maths.dart';
import '../common/node_orientation.dart';
import '../common/spawn_type.dart';
import '../common/teams.dart';
import '../dispatch/dispatch_game_object_destroyed.dart';
import '../engine.dart';
import '../functions/withinRadius.dart';
import '../io/write_scene_to_file.dart';
import '../isometric/generate_node.dart';
import '../maths.dart';
import '../physics.dart';
import 'action.dart';
import 'ai.dart';
import 'ai_slime.dart';
import 'character.dart';
import 'collider.dart';
import 'components.dart';
import 'gameobject.dart';
import 'node.dart';
import 'npc.dart';
import 'player.dart';
import 'position3.dart';
import 'projectile.dart';
import 'rat.dart';
import 'scene.dart';
import 'weapon.dart';
import 'zombie.dart';

abstract class Game {
  var frame = 0;
  final Scene scene;
  final players = <Player>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];
  final actions = <Action>[];

  List<GameObject> get gameObjects => scene.gameObjects;

  /// Must override
  bool get full;
  /// In seconds
  int getTime();

  /// safe to override
  void customUpdate() { }
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
  void customOnPlayerJoined(Player player) { }
  /// safe to overridable
  void customOnPlayerDeath(Player player) { }
  /// safe to overridable
  void customOnNpcObjectivesCompleted(Character npc) { }
  /// safe to overridable
  void customOnPlayerLevelGained(Player player) { }
  /// safe to overridable
  void customOnPlayerAddCardToDeck(Player player, CardType cardType) { }
  /// safe to override
  void customOnCollisionBetweenColliders(Collider a, Collider b) { }
  /// safe to override
  void customOnAIRespawned(AI ai){  }

  /// CONSTRUCTOR
  Game(this.scene) {
    engine.onGameCreated(this); /// TODO Illegal external scope reference
  }

  /// ACTIONS

  void playerUseWeapon(Player player, Weapon weapon) {
    if (player.deadBusyOrPerforming) return;

    if (AttackType.requiresRounds(weapon.type)){
      if (weapon.rounds == 0) return;
      weapon.rounds--;
      player.writePlayerEventWeaponRounds();
    }
    player.performDuration = weapon.duration;

    switch (weapon.type) {
      case AttackType.Unarmed:
        return performAttackMelee(
          player: player,
          attackType: AttackType.Unarmed,
          distance: 40,
          attackRadius: 35,
          damage: weapon.damage,
        );
      case AttackType.Blade:
        return performAttackMelee(
          player: player,
          attackType: weapon.type,
          distance: weapon.range,
          attackRadius: 35, /// TODO read value from weapon
          damage: weapon.damage,
        );
      case AttackType.Crossbow:
        return player.performAttackTypeCrossBow();
      case AttackType.Teleport:
        return player.performAttackTypeTeleport();
      case AttackType.Handgun:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.mouseAngle,
        );
      case AttackType.Shotgun:
        return player.performAttackTypeShotgun();
      case AttackType.Assault_Rifle:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.mouseAngle,
        );
      case AttackType.Rifle:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.mouseAngle,
        );
      case AttackType.Fireball:
        return player.performAttackTypeFireball();
      case AttackType.Revolver:
        return characterFireWeapon(
          character: player,
          weapon: weapon,
          angle: player.mouseAngle,
        );
      case AttackType.Crowbar:
        return performAttackMelee(
          player: player,
          attackType: weapon.type,
          distance: weapon.range,
          attackRadius: 35, /// TODO read value from weapon
          damage: weapon.damage,
        );
      case AttackType.Bow:
        return player.performAttackTypeBow();
    }
  }

  void performAttackMelee({
    required Player player,
    required int attackType,
    required double distance,
    required double attackRadius,
    required int damage,
  }) {
    final angle = player. mouseAngle;
    final adj = getAdjacent(angle, distance);
    final opp = getOpposite(angle, distance);


    final performX = player.x + adj;
    final performY = player.y + opp;
    final performZ = player.z;

    player.performX = performX;
    player.performY = performY;
    player.performZ = performZ;
    player.performDuration = 20;

    /// TODO name arguments
    dispatchAttackPerformed(
        attackType,
        performX,
        performY,
        performZ,
        angle,
    );

    if (player.idling) {
      player.faceMouse();
    }

    for (final character in characters) {
      if (onSameTeam(player, character)) continue;
      if (character.distanceFromXYZ(
        performX, performY, performZ,
      ) > attackRadius) continue;
      applyHit(src: this, target: character, damage: damage);
    }

    for (final gameObject in gameObjects) {
      if (gameObject.distanceFromXYZ(
        performX,
        performY,
        performZ,
      ) >
          attackRadius) continue;

      if (gameObject is GameObjectStatic) {
        if (!gameObject.active) continue;
        if (gameObject.type == GameObjectType.Barrel) {
          gameObject.active = false;
          gameObject.collidable = false;
          gameObject.respawn = 200;
          /// TODO why is this external>
          dispatchGameObjectDestroyed(players, gameObject);
        }
      }
      if (gameObject is Velocity == false) continue;
      (gameObject as Velocity).applyForce(
        force: 5,
        angle: radiansV2(player, gameObject),
      );
    }

    final node = scene.getNodeXYZ(
      performX,
      performY,
      performZ,
    );
    if (node.isDestroyed) return;
    if (NodeType.isDestroyable(node.type)) {
      final z = performZ ~/ tileSizeHalf;
      final row = performX ~/ tileSize;
      final column = performY ~/ tileSize;
      setNode(z, row, column, NodeType.Empty, NodeOrientation.Destroyed);

      perform((){
        setNode(z, row, column, NodeType.Respawning, NodeOrientation.None);
      }, 300);

      perform((){
        setNode(z, row, column, node.type, node.orientation);
      }, 400);
    }
  }

  void characterFireWeapon({
    required Character character,
    required Weapon weapon,
    required double angle,
  }){
    spawnProjectile(
      src: character,
      accuracy: 0,
      angle: angle,
      speed: 8.0,
      range: weapon.range,
      projectileType: ProjectileType.Bullet,
      damage: weapon.damage,
    );
    /// Illegal game reference
    dispatchAttackPerformed(
        weapon.type,
        character.x,
        character.y,
        character.z,
        angle,
    );
  }

  void perform(Function action, int duration){
    actions.add(Action(duration, action)); /// TODO Recycle actions
  }

  void deactivateGameObject(GameObject gameObject){
     if (!gameObject.active) return;
     gameObject.active = false;
     gameObject.collidable = false;
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

  void setNode(int z, int row, int column, int type, int orientation) {
    if (scene.outOfBounds(z, row, column)) return;
    final previousNode = scene.getNode(z, row, column);
    if (previousNode.type == type && previousNode.orientation == orientation) {
      return;
    }
    scene.dirty = true;
    final node = generateNode(type);
    if (node is NodeOriented) {
      node.orientation = orientation;
    }
    if (node is NodeSpawn) {
      node.indexZ = z;
      node.indexRow = row;
      node.indexColumn = column;
      nodeSpawnInstancesCreate(node);
    }
    scene.grid[z][row][column] = node;
    onNodeChanged(z, row, column);
  }

  void onNodeChanged(int z, int row, int column) {
    final node = scene.grid[z][row][column];
    players.forEach((player) {
      player.writeByte(ServerResponse.Node);
      player.writeInt(z);
      player.writeInt(row);
      player.writeInt(column);
      player.writeByte(node.type);
      player.writeByte(node.orientation);
    });
    scene.dirty = true;
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

    for (var i = 0; i < actions.length; i++){
      final action = actions[i];
      if (action.frames-- > 0) continue;
      action.perform();
      actions.removeAt(i);
      i--;
    }

    customUpdate();
    updateCollisions();
    updateCharacters();
    updateGameObjects();
    updateProjectiles();
    updateProjectiles(); // called twice to fix collision detection
    updateCharacterFrames();
    sortGameObjects();
  }

  void updateStatus() {
    removeDisconnectedPlayers();
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

  void moveCharacterToGridNode(Character character, int type) {
    scene.findByType(type, (int z, int row, int column) {
      character.indexZ = z;
      character.indexRow = row;
      character.indexColumn = column;
    });
  }

  void revive(Player character) {
    character.setCharacterStateSpawning();
    character.health = character.maxHealth;
    character.collidable = true;
    customOnPlayerRevived(character);
  }

  int countAlive(List<Character> characters) {
    var total = 0;
    for (final character in characters) {
      if (character.alive) total++;
    }
    return total;
  }

  Player spawnPlayer();

  void onPlayerSelectCharacterType(Player player, CharacterSelection value) {}

  void playersWriteDeckCooldown() {
    for (final player in players) {
      player.writeDeckCooldown();
    }
  }

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
        where: (other) => other.alive && !onSameTeam(other, character));
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
    if (gameObject.active) return;
    gameObject.active = true;
  }

  void updateGameObjects(){
    for (final gameObject in gameObjects) {
      if (gameObject is Updatable) {
        (gameObject as Updatable).update(this);
      }
      if (gameObject is Velocity) {
        (gameObject as Velocity).applyFriction(0.95);
      }
    }
  }

  void applyDamageToCharacter({
    required dynamic src,
    required Character target,
    required int amount,
  }) {
    if (target.deadOrDying) return;
    final damage = min(amount, target.health);
    target.health -= damage;

    if (target.health <= 0) {
      setCharacterStateDying(target);
      customOnCharacterKilled(target, src);

      if (target is AI){
        onAIKilled(target);
      }

    } else {
      customOnCharacterDamageApplied(target, src, damage);
      target.setCharacterStateHurt();
    }
    dispatchGameEventCharacterHurt(target);

    if (target is AI) {
      onAIDamagedBy(target, src);
    }
  }

  /// unsafe to override
  void onAIKilled(AI ai){
    ai.clearTarget();
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
        if ((colliderJ.z - colliderI.z).abs() > tileHeight) continue;
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
        if ((a.z - b.z).abs() > tileHeight) continue;
        if (a == b) continue;
        internalOnCollisionBetweenColliders(a, b);
      }
    }
  }

  void internalOnCollisionBetweenColliders(Collider a, Collider b){
    assert (a.collidable);
    assert (b.collidable);
    assert (a != b);
    resolveCollisionPhysics(a, b);
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
    sort(characters);
    sort(projectiles);
    sort(gameObjects);
  }

  void sort(List<Position3> items) {
    var start = 0;
    var end = items.length;
    for (var pos = start + 1; pos < end; pos++) {
      var min = start;
      var max = pos;
      var element = items[pos];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (element.order <= items[mid].order) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      items.setRange(min + 1, pos + 1, items, min);
      items[min] = element;
    }
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
      character.clearTarget();
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

  void setCharacterStateDead(Character character) {
    if (character.state == CharacterState.Dead) return;

    dispatchGameEventCharacterDeath(character);
    character.health = 0;
    character.state = CharacterState.Dead;
    character.onCharacterStateChanged();
    character.collidable = false;

    for (final character in characters) {
      if (character.target != character) continue;
      character.clearTarget();
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
      projectile.x += projectile.xv;
      projectile.y += projectile.yv;
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
        var type = scene.getNodeXYZ(
            projectile.x,
            projectile.y,
            projectile.z
        ).type;
        if (type == NodeType.Tree_Bottom) {

        }
        deactivateProjectile(projectile);
      }
    }

    checkProjectileCollision(characters);
  }

  void refreshSpawns() {
    for (var i = 0; i < gameObjects.length; i++) {
      final gameObject = gameObjects[i];
      if (gameObject is GameObjectSpawn) {
        refreshSpawn(gameObject);
      }
    }

    for (final plane in scene.grid) {
      for (final row in plane) {
        for (final node in row) {
          if (node is NodeSpawn) nodeSpawnInstancesCreate(node);
        }
      }
    }
  }

  void nodeSpawnInstancesClear(NodeSpawn node) {
    for (var i = 0; i < characters.length; i++){
      final character = characters[i];
      if (character.spawn != node) continue;
      removeInstance(character);
      i--;
    }
    for (var i = 0; i < gameObjects.length; i++){
      final gameObject = gameObjects[i];
      if (gameObject.spawn != node) continue;
      removeInstance(gameObject);
      i--;
    }
  }

  void nodeSpawnInstancesCreate(NodeSpawn node) {
    for (var i = 0; i < node.spawnAmount; i++){
      spawnNodeInstance(node);
    }
  }

  void refreshSpawn(GameObjectSpawn spawn) {
    removeSpawnInstances(spawn);
    for (var i = 0; i < spawn.spawnAmount; i++) {
      spawnGameObject(spawn);
    }
  }

  void removeSpawnInstances(GameObjectSpawn spawn) {
    for (var i = 0; i < characters.length; i++) {
      final character = characters[i];
      if (character.spawn != spawn) continue;
      i--;
      removeInstance(character);
    }

    for (var i = 0; i < gameObjects.length; i++) {
      final gameObject = gameObjects[i];
      if (gameObject.spawn != spawn) continue;
      i--;
      removeInstance(gameObject);
    }
  }

  void removeInstance(dynamic instance) {
    if (instance == null) return;

    if (instance is Player) {
      instance.aimTarget = null;
      players.remove(instance);
    }
    if (instance is Character) {
      instance.spawn = null;
      characters.remove(instance);
      return;
    }
    if (instance is GameObject) {
      gameObjects.remove(instance);
      if (instance is GameObjectSpawn) {
        removeSpawnInstances(instance);
        scene.dirty = true;
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

    updatePlayerAttacking(player);

    if (player.framesSinceClientRequest > 10) {
      player.setCharacterStateIdle();
    }

    final target = player.target;
    if (target == null) return;
    if (!player.busy) {
      player.face(target);
    }

    final ability = player.ability;

    if (target is Collider) {
      if (!target.collidable) {
        player.target = null;
        return;
      }

      if (target is Npc && onSameTeam(player, target)) {
        if (withinRadius(player, target, 100)) {
          if (!target.deadOrBusy) {
            target.face(player);
          }
          final onInteractedWith = target.onInteractedWith;
          if (onInteractedWith != null) {
            onInteractedWith(player);
            player.interactingWithNpc = true;
            player.setInteractingNpcName(target.name);
            onInteractedWith(player);
          }
          player.target = null;
          player.setCharacterStateIdle();
          return;
        }
        setCharacterStateRunning(player);
        return;
      }

      if (ability != null) {
        if (withinRadius(player, target, ability.range)) {
          player.target = target;
          player.setCharacterStatePerforming(duration: ability.duration);
          return;
        }
        setCharacterStateRunning(player);
        return;
      }
      return;
    }

    if (ability != null) {
      if (!withinRadius(player, target, ability.range)) {
        setCharacterStateRunning(player);
        return;
      }
      player.setCharacterStatePerforming(duration: ability.duration);
      return;
    }

    if (player.distanceFromPos2(target) <= player.velocitySpeed) {
      player.target = null;
      player.setCharacterStateIdle();
      return;
    }
    setCharacterStateRunning(player);
  }

  void setCharacterStateRunning(Character character){
    character.setCharacterState(value: CharacterState.Running, duration: 0);
    if (character.stateDuration == 0) {
      dispatchV3(
        GameEventType.Spawn_Dust_Cloud,
        character,
        angle: character.velocityAngle,
      );
    }
  }

  void checkProjectileCollision(List<Collider> colliders) {
    final projectilesLength = projectiles.length;
    final collidersLength = colliders.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      final target = projectile.target;
      if (target != null) {
        if (withinRadius(projectile, target, 10.0)) {
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
        if (target != null && onSameTeam(projectile, collider)) continue;
        handleProjectileHit(projectile, collider);
        break;
      }
    }
  }

  void spawnGameObject(GameObjectSpawn spawn) {
    final distance = randomBetween(0, spawn.spawnRadius);
    final angle = randomAngle();
    final x = getAdjacent(angle, distance);
    final y = getOpposite(angle, distance);

    switch (spawn.spawnType) {
      case SpawnType.Chicken:
        final instance =
        GameObjectChicken(x: spawn.x + x, y: spawn.y + y, z: spawn.z);
        instance.wanderRadius = spawn.spawnRadius;
        instance.spawn = spawn;
        gameObjects.add(instance);

        return;
      case SpawnType.Jellyfish:
        final instance =
        GameObjectJellyfish(x: spawn.x + x, y: spawn.y + y, z: spawn.z);
        instance.spawn = spawn;
        gameObjects.add(instance);
        return;
      case SpawnType.Jellyfish_Red:
        final instance =
        GameObjectJellyfishRed(x: spawn.x + x, y: spawn.y + y, z: spawn.z);
        instance.spawn = spawn;
        gameObjects.add(instance);
        return;
      case SpawnType.Rat:
        final instance = Rat(
          z: spawn.indexZ,
          row: spawn.indexRow,
          column: spawn.indexColumn,
          game: this,
          team: Teams.evil,
        );
        instance.wanderRadius = spawn.spawnRadius;
        instance.spawn = spawn;
        characters.add(instance);
        break;
      case SpawnType.Butterfly:
        final instance =
        GameObjectButterfly(x: spawn.x, y: spawn.y, z: spawn.z);
        instance.spawn = spawn;
        instance.wanderRadius = spawn.spawnRadius;
        gameObjects.add(instance);
        break;
      case SpawnType.Zombie:
        final instance = Zombie(
          x: spawn.x + x,
          y: spawn.y + y,
          z: spawn.z,
          health: 10,
          damage: 1,
          game: this,
          team: Teams.evil,
        );
        instance.spawn = spawn;
        instance.wanderRadius = spawn.spawnRadius;
        characters.add(instance);
        break;
      case SpawnType.Slime:
        final instance = AISlime(
          x: spawn.x + x,
          y: spawn.y + y,
          z: spawn.z,
          health: 30,
          game: this,
          team: Teams.evil,
        );
        instance.spawn = spawn;
        instance.wanderRadius = spawn.spawnRadius;
        instance.setCharacterStateSpawning();
        characters.add(instance);
        break;
      case SpawnType.Template:
        final instance = Npc(
          game: this,
          x: spawn.x + x,
          y: spawn.y + y,
          z: spawn.z,
          health: 10,
          weapon: Weapon(
            type: AttackType.Bow,
            damage: 1,
            capacity: 0,
            duration: 10,
            range: 200,
          ),
          team: Teams.good,
          wanderRadius: 100,
          name: 'Bandit',
        );
        instance.spawn = spawn;
        instance.wanderRadius = spawn.spawnRadius;
        characters.add(instance);
        break;
      default:
        print("Warning: Unrecognized SpawnType ${spawn.spawnType}");
        break;
    }
  }

  void spawnNodeInstance(NodeSpawn node) {
    final distance = randomBetween(0, node.spawnRadius);
    final angle = randomAngle();
    final x = getAdjacent(angle, distance);
    final y = getOpposite(angle, distance);

    final radius = node.spawnRadius;

    switch (node.spawnType) {
      case SpawnType.Chicken:
        final instance =
        GameObjectChicken(x: node.x + x, y: node.y + y, z: node.z);
        instance.wanderRadius = radius;
        instance.spawn = node;
        gameObjects.add(instance);

        return;
      case SpawnType.Jellyfish:
        final instance =
        GameObjectJellyfish(x: node.x + x, y: node.y + y, z: node.z);
        instance.spawn = node;
        gameObjects.add(instance);
        return;
      case SpawnType.Jellyfish_Red:
        final instance =
        GameObjectJellyfishRed(x: node.x + x, y: node.y + y, z: node.z);
        instance.spawn = node;
        gameObjects.add(instance);
        return;
      case SpawnType.Rat:
        final instance = Rat(
          z: node.indexZ,
          row: node.indexRow,
          column: node.indexColumn,
          game: this,
          team: Teams.evil,
        );
        instance.wanderRadius = node.spawnRadius;
        instance.spawn = node;
        characters.add(instance);
        break;
      case SpawnType.Butterfly:
        final instance =
        GameObjectButterfly(x: node.x, y: node.y, z: node.z);
        instance.spawn = node;
        instance.wanderRadius = node.spawnRadius;
        gameObjects.add(instance);
        break;
      case SpawnType.Zombie:
        final instance = Zombie(
          x: node.x + x,
          y: node.y + y,
          z: node.z,
          health: 10,
          damage: 1,
          game: this,
          team: Teams.evil,
        );
        instance.spawn = node;
        instance.wanderRadius = node.spawnRadius;
        characters.add(instance);
        break;
      case SpawnType.Slime:
        final instance = AISlime(
          x: node.x + x,
          y: node.y + y,
          z: node.z,
          health: 30,
          game: this,
          team: Teams.evil,
        );
        instance.spawn = node;
        instance.wanderRadius = node.spawnRadius;
        instance.setCharacterStateSpawning();
        characters.add(instance);
        break;
      case SpawnType.Template:
        final instance = Npc(
          game: this,
          x: node.x + x,
          y: node.y + y,
          z: node.z,
          health: 10,
          weapon: Weapon(
            type: AttackType.Bow,
            damage: 1,
            capacity: 0,
            duration: 10,
            range: 200,
          ),
          team: Teams.good,
          wanderRadius: 100,
          name: 'Bandit',
        );
        instance.spawn = node;
        instance.wanderRadius = node.spawnRadius;
        characters.add(instance);
        break;
      default:
        print("Warning: Unrecognized SpawnType ${node.spawnType}");
        break;
    }
  }

  void handleProjectileHit(Projectile projectile, Position3 target) {
    projectile.active = false;
    if (target is Character) {
      applyHit(
        src: projectile.owner,
        target: target,
        damage: projectile.damage,
      );
    }
    projectile.owner = null;
    projectile.target = null;

    if (projectile.type == ProjectileType.Arrow) {
      dispatch(GameEventType.Arrow_Hit, target.x, target.y, target.z);
    }
    if (projectile.type == ProjectileType.Orb) {
      dispatch(
          GameEventType.Blue_Orb_Deactivated, target.x, target.y, target.z);
    }
  }

  void applyHit({
    required dynamic src,
    required Collider target,
    required int damage,
  }) {
    if (!target.collidable) return;
    if (target is Character) {
      if (onSameTeam(src, target)) return;
      if (target.deadOrDying) return;
    }

    // TODO Hack
    if (src is Zombie) {
      dispatchV3(GameEventType.Zombie_Strike, src);
    }
    target.onStruckBy(src);
    if (target is Character) {
      applyDamageToCharacter(src: src, target: target, amount: damage);
    }

    if (target is Velocity) {
      (target as Velocity).applyForce(
        force: 20,
        angle: radiansV2(src, target),
      );
    }
  }

  void updateCharacterStatePerforming(Character character) {
    final ability = character.ability;
    if (ability == null) {
      return updateCharacterStateAttacking(character);
    }
    if (character.stateDuration == 0) {
      ability.cooldownRemaining = ability.cooldown;
    }
    ability.onActivated(character, this);
  }

  void updateCharacter(Character character) {
    if (character.dead) {
      if (character is AI) {
        updateRespawnAI(character);
      }
      return;
    }

    if (character is AI){
      updateAI(character);
    }

    updateCharacterMovement(character);
    scene.resolveCharacterTileCollision(character, this);
    if (character.dying){
      if (character.stateDurationRemaining-- <= 0){
        setCharacterStateDead(character);
      }
      return;
    }

    updateCharacterState(character);
  }

  void updateAI(AI ai){
      if (ai.deadOrBusy) return;

      final target = ai.target;
      if (target != null) {
        if (ai.withinAttackRange(target)) {
          return ai.attackTarget(target);
        }
        if ((ai.getDistance(target) < 300)) {
          ai.destX = target.x;
          ai.destY = target.y;
        }
      }

      if (!ai.arrivedAtDest) {
        ai.faceAngle = ai.getDestinationAngle();
        return  setCharacterStateRunning(ai);
      }

      if (ai.pathIndex > 0){
        ai.pathIndex--;
        ai.destX = ai.pathX[ai.pathIndex];
        ai.destY = ai.pathY[ai.pathIndex];
        ai.faceAngle = ai.getDestinationAngle();
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


  void updateCharacterMovement(Character character) {
    const minVelocity = 0.005;
    if (character.velocitySpeed <= minVelocity) return;

    character.x += character.xv;
    character.y += character.yv;

    final nodeType = character.getNodeTypeInDirection(
      game: this,
      angle: character.velocityAngle,
      distance: character.radius,
    );

    if (nodeType == NodeType.Tree_Bottom || nodeType == NodeType.Torch) {
      final nodeCenterX = character.indexRow * tileSize + tileSizeHalf;
      final nodeCenterY = character.indexColumn * tileSize + tileSizeHalf;
      final dis = character.getDistanceXY(nodeCenterX, nodeCenterY);
      const treeRadius = 5;
      final overlap = dis - treeRadius - character.radius;
      if (overlap < 0) {
        character.x -= getAdjacent(character.velocityAngle, overlap);
        character.y -= getOpposite(character.velocityAngle, overlap);
      }
    }

    character.applyFriction(0.75);
  }

  void updateRespawnAI(AI ai) {
    assert(ai.dead);
    final spawn = ai.spawn;
    if (spawn == null) return;
    if (ai.respawn-- > 0) return;
    final distance = randomBetween(0, spawn.spawnRadius);
    final angle = randomAngle();
    ai.x = spawn.x + getAdjacent(angle, distance);
    ai.y = spawn.y + getOpposite(angle, distance);
    ai.z = ai.spawnZ;
    ai.clearDest();
    ai.clearTarget();
    ai.clearPath();
    ai.collidable = true;
    ai.health = ai.maxHealth;
    ai.target = null;
    ai.xv = 0;
    ai.xv = 0;
    ai.spawnX = ai.x;
    ai.spawnY = ai.y;
    ai.spawnZ = ai.z;
    ai.setCharacterStateSpawning();
    customOnAIRespawned(ai);
  }

  Projectile spawnProjectileOrb(Character src, {required int damage}) {
    dispatchV3(GameEventType.Blue_Orb_Fired, src);
    return spawnProjectile(
      src: src,
      accuracy: 0,
      speed: 4.5,
      range: src.equippedRange,
      target: src.target,
      projectileType: ProjectileType.Orb,
      angle: src.target != null ? null : src.faceAngle,
      damage: damage,
    );
  }

  Projectile spawnProjectileArrow(
      Character src, {
        required int damage,
        required double range,
        double accuracy = 0,
        Position3? target,
        double? angle,
      }) {
    dispatch(GameEventType.Arrow_Fired, src.x, src.y, src.z);
    return spawnProjectile(
      src: src,
      accuracy: accuracy,
      speed: 7,
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
      }) {
    dispatchAttackPerformed(
      AttackType.Fireball,
      src.x,
      src.y,
      src.z,
      angle ?? src.faceAngle,
    );
    return spawnProjectile(
      src: src,
      accuracy: 0,
      speed: 5,
      range: range,
      target: src.target,
      angle: angle,
      projectileType: ProjectileType.Fireball,
      damage: damage,
    );
  }

  Projectile spawnProjectileBullet({
    required Character src,
    double accuracy = 0,
    double speed = 12,
  }) {
    return spawnProjectile(
      src: src,
      accuracy: 0,
      angle: src.faceAngle,
      speed: speed,
      range: src.equippedRange,
      projectileType: ProjectileType.Bullet,
      damage: src.weapon.damage,
    );
  }

  void fireAssaultRifle(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      speed: 8.0,
      range: 300,
      projectileType: ProjectileType.Bullet,
      damage: 5,
    );
    dispatchAttackPerformed(AttackType.Assault_Rifle, src.x, src.y, src.z, angle);
  }

  void fireArrow(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      speed: 5.0,
      range: 300,
      projectileType: ProjectileType.Arrow,
      damage: 5,
    );
    dispatchAttackPerformed(AttackType.Bow, src.x, src.y, src.z, angle);
  }

  void fireRifle(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      speed: 15.0,
      range: 600,
      projectileType: ProjectileType.Bullet,
      damage: 10,
    );
    dispatchAttackPerformed(AttackType.Rifle, src.x, src.y, src.z, angle);
  }

  void fireFireball(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      speed: 3.0,
      range: 300,
      projectileType: ProjectileType.Fireball,
      damage: 5,
    );
    dispatchAttackPerformed(AttackType.Fireball, src.x, src.y, src.z, angle);
  }

  void fireHandgun(Character src, double angle) {
    spawnProjectile(
      src: src,
      accuracy: 0,
      angle: angle,
      speed: 8.0,
      range: 300,
      projectileType: ProjectileType.Bullet,
      damage: 5,
    );
    dispatchAttackPerformed(AttackType.Handgun, src.x, src.y, src.z, angle);
  }

  void fireShotgun(Character src, double angle) {
    for (var i = 0; i < 5; i++) {
      spawnProjectile(
        src: src,
        accuracy: 0,
        angle: angle + giveOrTake(0.25),
        speed: 8.0,
        range: 300,
        projectileType: ProjectileType.Bullet,
        damage: 5,
      );
    }
    dispatchAttackPerformed(AttackType.Shotgun, src.x, src.y, src.z, angle);
  }

  Projectile spawnProjectile({
    required Character src,
    required double speed,
    required double range,
    required int projectileType,
    required int damage,
    double accuracy = 0,
    double? angle = 0,
    Position3? target,
  }) {
    final projectile = getInstanceProjectile();
    var finalAngle = angle;
    if (finalAngle == null) {
      if (target != null && target is Collider) {
        finalAngle = src.getAngle(target);
      } else {
        finalAngle = src.faceAngle;
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
    projectile.z = src.z + tileHeightHalf;
    projectile.setVelocity(finalAngle + giveOrTake(accuracy), speed);
    projectile.faceAngle = finalAngle;
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

  Zombie spawnZombie({
    required double x,
    required double y,
    required double z,
    required int health,
    required int team,
    required int damage,
    double speed = RunSpeed.Regular,
    List<Vector2>? objectives,
    double wanderRadius = 100.0,
  }) {
    assert(team >= 0 && team <= 256);
    final zombie = getZombieInstance();
    zombie.team = team;
    zombie.state = CharacterState.Idle;
    zombie.stateDurationRemaining = 0;
    zombie.maxHealth = health;
    zombie.health = health;
    zombie.collidable = true;
    zombie.x = x;
    zombie.y = y;
    zombie.z = z;
    zombie.spawnX = x;
    zombie.spawnY = y;
    zombie.clearDest();
    zombie.wanderRadius = wanderRadius;
    return zombie;
  }

  Zombie getZombieInstance() {
    for (final character in characters) {
      if (character.alive) continue;
      if (character is Zombie) return character;
    }
    final zombie = Zombie(
      x: 0,
      y: 0,
      z: 0,
      health: 10,
      damage: 1,
      game: this,
      team: Teams.neutral,
    );
    characters.add(zombie);
    return zombie;
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
      team: Teams.evil,
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
      player.writeByte(attackType);
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
      final ai = character as AI;

      var target = character.target;
      if (target != null && !character.withinChaseRange(target)) {
        character.target = null;
        character.clearDest();
      }

      var targetDistance = 9999999.0;

      for (final other in characters) {
        if (!other.alive) continue;
        if (other == character) continue;
        if (onSameTeam(other, character)) continue;
        if (!character.withinViewRange(other)) continue;
        final npcDistance = character.getDistance(other);
        if (npcDistance >= targetDistance) continue;
        setNpcTarget(character, other);
        targetDistance = npcDistance;
      }
      target = character.target;
      if (target == null) continue;
      if (targetDistance < 100) continue;
      npcSetPathTo(character, target);
    }
  }

  void setNpcTarget(AI ai, Position3 value) {
    if (value is Team) {
      assert(!onSameTeam(ai, value));
    }
    assert(ai.alive);
    ai.target = value;
  }

  void removeDisconnectedPlayers() {
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.framesSinceClientRequest++ < 150) continue;
      if (!removePlayer(player)) continue;
      i--;
      playerLength--;
      print("Removed disconnected player");
    }
  }

  bool removePlayer(Player player) {
    if (!players.remove(player)) return false;
    characters.remove(player);
    customOnPlayerDisconnected(player);
    if (player.scene.dirty && player.scene.name.isNotEmpty) {
      writeSceneToFile(scene);
    }
    return true;
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
    final equippedDamage = character.equippedDamage;
    if (character is Zombie) {
      if (stateDuration != framePerformStrike) return;
      final attackTarget = character.target;
      if (attackTarget == null) return;
      if (attackTarget is Collider) {
        applyHit(
          src: character,
          target: attackTarget,
          damage: equippedDamage,
        );
        character.target = null;
      }
      return;
    }

    final weaponType = character.weapon.type;
    if (weaponType == AttackType.Blade) {
      if (stateDuration == 7) {
        dispatchV3(GameEventType.Sword_Woosh, character);
      }
    }
    if (weaponType == AttackType.Unarmed) {
      if (stateDuration == 7) {
        // dispatchV3(GameEventType.Arm_Swing, character);
      }
    }
    if (weaponType == AttackType.Handgun) {
      if (stateDuration == 1) {
        if (character.equippedIsEmpty) {
          // dispatchV3(GameEventType.Clip_Empty, character);
          return;
        }
        return;
      }
      if (stateDuration == 2) {
        if (character.equippedIsEmpty) {
          return;
        }
        spawnProjectileBullet(
          src: character,
          accuracy: 0,
          speed: 12.0,
        );
        return;
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
            speed: 12.0,
          );
        }
      }
    }

    if (character.equippedTypeIsBow && stateDuration == 1) {
      dispatchV3(GameEventType.Draw_Bow, character);
    }

    if (stateDuration != framePerformStrike) return;

    if (character.equippedTypeIsStaff) {
      spawnProjectileOrb(character, damage: equippedDamage);
      character.target = null;
      return;
    }

    if (character.equippedTypeIsBow) {
      dispatchV3(GameEventType.Release_Bow, character);
      spawnProjectileArrow(character,
          damage: equippedDamage,
          target: character.target,
          range: character.equippedRange);
      character.target = null;
      return;
    }
    if (character.equippedIsMelee) {
      spawnProjectile(
        src: character,
        speed: 3,
        range: character.equippedRange * 2,
        projectileType: ProjectileType.Wave,
        damage: 1,
        angle: character.faceAngle,
      );

      final attackTarget = character.target;
      if (attackTarget != null) {
        if (attackTarget is Collider && attackTarget.collidable) {
          applyHit(
              src: character, target: attackTarget, damage: equippedDamage);
          character.target = null;
          return;
        }
        character.target = null;
      }
      final zombieHit = raycastHit(
          character: character,
          colliders: characters,
          range: character.equippedRange);
      if (zombieHit != null) {
        applyHit(
          src: character,
          target: zombieHit,
          damage: equippedDamage,
        );
        return;
      }
      // final dynamicObjectHit = raycastHit(
      //     character: character,
      //     colliders: gameObjects,
      //     range: character.equippedRange
      // );
      // if (dynamicObjectHit != null) {
      //   applyHit(
      //     src: character,
      //     target: dynamicObjectHit,
      //     damage: equippedDamage,
      //   );
      // }
      return;
    }
  }

  Npc addNpc({
    required String name,
    required int row,
    required int column,
    required int z,
    required Weapon weapon,
    Function(Player player)? onInteractedWith,
    int head = HeadType.None,
    int armour = ArmourType.shirtCyan,
    int pants = PantsType.brown,
    int team = 1,
    int health = 10,
    double wanderRadius = 0,
  }) {
    final npc = Npc(
      name: name,
      onInteractedWith: onInteractedWith,
      x: 0,
      y: 0,
      z: 0,
      weapon: weapon,
      team: team,
      health: health,
      wanderRadius: wanderRadius,
      game: this,
    );
    npc.equippedHead = head;
    npc.equippedArmour = armour;
    npc.equippedPants = pants;
    npc.indexRow = row;
    npc.indexColumn = column;
    npc.indexZ = z;
    npc.spawnX = npc.x;
    npc.spawnY = npc.y;
    npc.clearDest();
    characters.add(npc);
    return npc;
  }

  void updatePlayerAttacking(Player player) {
    if (player.performDuration <= 0) return;
    player.performDuration--;
  }

  double angle2(double adjacent, double opposite) {
    if (adjacent > 0) {
      return pi2 - (atan2(adjacent, opposite) * -1);
    }
    return atan2(adjacent, opposite);
  }
}

