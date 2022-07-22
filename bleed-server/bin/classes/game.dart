import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../engine.dart';
import '../functions.dart';
import '../functions/withinRadius.dart';
import '../io/write_scene_to_file.dart';
import '../maths.dart';
import '../physics.dart';
import 'ai.dart';
import 'character.dart';
import 'collectable.dart';
import 'collider.dart';
import 'components.dart';
import 'enemy_spawn.dart';
import 'game_object.dart';
import 'item.dart';
import 'npc.dart';
import 'player.dart';
import 'position3.dart';
import 'projectile.dart';
import 'rat.dart';
import 'scene.dart';
import 'tile_node.dart';
import 'weapon.dart';
import 'zombie.dart';

abstract class Game {
  var frame = 0;
  final Scene scene;
  final players = <Player>[];
  final characters = <Character>[];
  final projectiles = <Projectile>[];
  final items = <Item>[];
  final collectables = <Collectable>[];

  Game(this.scene) {
    engine.onGameCreated(this);

    for (final enemySpawn in scene.enemySpawns){
      enemySpawn.init(this);
    }
  }

  void onGridChanged(){
    scene.refreshGridMetrics();
    for (final player in players){
      player.writeGrid();
    }
  }

  void setHourMinutes(int hour, int minutes){

  }

  bool get full;

  List<GameObject> get gameObjects => scene.gameObjects;

  // int get numberOfAlivePlayers => countAlive(players);

  // int get numberOfAliveZombies => countAlive(zombies);

  void updateStatus(){
    removeDisconnectedPlayers();
    updateInProgress();

    for (final player in players) {
      player.writeAndSendResponse();
    }
  }

  bool containsPlayerWithName(String name){
     for(final character in players){
         if (character.name == name) return true;
     }
     return false;
  }

  void onGameObjectsChanged() {
    sortVertically(gameObjects);
    for (final player in players){
      player.writeGameObjects();
    }
  }

  void onPlayerAddCardToDeck(Player player, CardType cardType){

  }

  void onKilled(dynamic target, dynamic src){

  }

  void onDamaged(dynamic target, dynamic src, int amount){

  }

  void moveCharacterToGridNode(Character character, int type){
    scene.findByType(type, (int z, int row, int column){
      character.indexZ = z;
      character.indexRow = row;
      character.indexColumn = column;
    });
  }

  void revive(Player character) {
    character.state = CharacterState.Idle;
    character.health = character.maxHealth;
    character.collidable = true;
    onPlayerRevived(character);
  }

  void onPlayerRevived(Player player){

  }

  /// In seconds
  int getTime();

  void onGameStarted() {}

  void onPlayerJoined(Player player) {}

  void onPlayerDeath(Player player) {}

  void onNpcObjectivesCompleted(Character npc) {}

  void onPlayerLevelGained(Player player){

  }

  /// Returning true will cause the item to be removed
  bool onPlayerItemCollision(Player player, Item item) {
    return true;
  }

  void changeGame(Player player, Game to) {
    if (player.game == to) return;


    player.changeGame(to);
  }

  int countAlive(List<Character> characters) {
    var total = 0;
    for (final character in characters) {
      if (character.alive) total++;
    }
    return total;
  }

  void update() {}

  void onPlayerDisconnected(Player player) {}

  void checkColliderCollision(
      List<Collider> collidersA, List<Collider> collidersB) {
    final totalColliders = collidersB.length;
    for (final a in collidersA) {
      if (!a.collidable) continue;
      final aRadius = a.radius;
      for (var i = 0; i < totalColliders; i++) {
        final b = collidersB[i];
        if (!b.collidable) continue;
        if ((a.z - b.z).abs() > tileSize) continue;
        final combinedRadius = aRadius + b.radius;
        final _distance = distanceV2(a, b);
        if (_distance > combinedRadius) continue;
        final overlap = combinedRadius - _distance;
        final r = radiansV2(a, b);
        a.x -= getAdjacent(r, overlap);
        a.y -= getOpposite(r, overlap);
        a.onCollisionWith(b);
        b.onCollisionWith(a);
      }
    }
  }

  Player spawnPlayer();

  void onPlayerSelectCharacterType(Player player, CharacterSelection value){

  }

  void playersWriteDeckCooldown(){
    for (final player in players){
      player.writeDeckCooldown();
    }
  }

  void playersWriteWeather() {
    for (final player in players) {
      player.writeWeather();
    }
  }
}

extension GameFunctions on Game {

  Character? getClosestEnemy({
    required double x,
    required double y,
    required Character character,
  }) {
    return findClosestVector2(
        positions: characters,
        x: x,
        y: y,
        z: character.z,
        where: (other) => other.alive && !onSameTeam(other, character));
  }

  Collider? getClosestCollider(double x, double y, Character character, {required double minDistance}) {
    return findClosestVector2<Character>(
        positions: characters,
        x: x,
        y: y,
        z: character.z,
        where: (other) => other.alive && other != character && other.distanceFromXYZ(x, y, character.z) < minDistance,
    );
  }

  void updateInProgress() {
    frame++;
    if (frame % 15 == 0) {
      // updateInteractableNpcTargets();
      updateAITargets();
    }

    for (final enemySpawner in scene.enemySpawns) {
       enemySpawner.update(this);
    }
    update();
    // updateCollectables();
    _updateCollisions();
    _updatePlayersAndNpcs();
    _updateProjectiles();
    _updateProjectiles(); // called twice to fix collision detection
    // _updateItems();
    _updateCharacterFrames();
    sortGameObjects();
  }

  void updateFrames(List<Character> character) {
    for (final character in character) {
      character.animationFrame = (character.animationFrame + 1) % 8;
    }
  }

  void applyDamage({
    required dynamic src,
    required Health target,
    required int amount,
  }) {
    if (target.dead) return;
    final damage = min(amount, target.health);
    target.health -= damage;

    if (src is Player && target is Position) {
      src.writeDamageApplied(target as Position, damage);
    }

    if (target is Velocity && target is Position) {
      final velocity = target as Velocity;
      const forceMultiplier = 3.0;
      velocity.accelerate(radiansV2(src, target as Position), damage / target.maxHealth * forceMultiplier);
    }

    final destroyed = target.dead;

    if (target is Material) {
      switch ((target as Material).material) {
        case MaterialType.Rock:
          dispatchV3(GameEventType.Material_Struck_Rock, target as Position3);
          break;
        case MaterialType.Wood:
          dispatchV3(GameEventType.Material_Struck_Wood, target as Position3);
          break;
        case MaterialType.Plant:
          dispatchV3(GameEventType.Material_Struck_Plant, target as Position3);
          break;
        case MaterialType.Flesh:
          dispatchV3(GameEventType.Material_Struck_Flesh,
              target as Position3, angle: radiansV2(src, target as Position3));
          break;
        case MaterialType.Metal:
          dispatchV3(GameEventType.Material_Struck_Metal, target as Position3);
          break;
      }
    }


    if (destroyed) {
      if (target is AI){
         target.enemySpawn?.count--;
      }

      if (target is Collider) {
        (target as Collider).collidable = false;
      }
      if (target is Character) {
        if (target.dead && target is Zombie) {
          dispatchV3(
            GameEventType.Zombie_Killed,
            target,
            angle: radiansV2(src, target),
          );
        }
      }

      for (final ai in characters) {
        if (ai.target != target) continue;
        ai.target = null;
      }

      for (final player in players) {
        if (player.aimTarget != target) continue;
        player.aimTarget = null;
      }

      onKilled(target, src);
    } else {
      onDamaged(target, src, damage);
    }

    if (target is Character) {
      final isZombie = target is Zombie;

      if (destroyed) {
        setCharacterStateDead(target);
        return;
      }
      if (isZombie && randomBool()) {
        dispatchV3(
          GameEventType.Zombie_Hurt,
          target,
        );
        target.setCharacterStateHurt();
      }
      if (target is AI) {
        final targetAITarget = target.target;
        if (targetAITarget == null) {
          target.target = src;
          return;
        }
        final aiTargetDistance = distanceV2(target, targetAITarget);
        final srcTargetDistance = distanceV2(src, target);
        if (srcTargetDistance < aiTargetDistance) {
          target.target = src;
        }
      }
      return;
    }

    if (target is GameObject) {
      switch (target.type) {
        case GameObjectType.Rock:
          if (src is Player) {
            // spawnCollectable(position: target, target: src, type: CollectableType.Stone, amount: damage);
          }
          break;
        case GameObjectType.Tree:
          if (src is Player) {
            // spawnCollectable(position: target, target: src, type: CollectableType.Wood, amount: damage);
          }
          break;
      }

      if (destroyed) {
        target.respawnDuration = 5000;

        if (target.type == GameObjectType.Pot) {
          dispatchV3(GameEventType.Object_Destroyed_Pot, target);
        } else if (target.type == GameObjectType.Rock) {
          dispatchV3(GameEventType.Object_Destroyed_Rock, target);
        } else if (target.type == GameObjectType.Tree) {
          dispatchV3(GameEventType.Object_Destroyed_Tree, target);
        } else if (target.type == GameObjectType.Chest) {
          dispatchV3(GameEventType.Object_Destroyed_Chest, target);
          for (var i = 0; i < 3; i++) {
            spawnCollectable(
                position: target,
                target: src,
                type: CollectableType.Gold,
                amount: 1
            );
          }
        }
      }
    }
  }

  void spawnCollectable({
    required Position position,
    required Position target,
    required int type,
    required int amount,
  }){
    if (amount <= 0) return;
    final collectable = Collectable();
    collectable.type = type;
    collectable.amount = amount;
    collectable.target = target;
    collectable.x = position.x;
    collectable.y = position.y;
    collectable.angle = randomAngle();
    collectable.speed = 3.0;
    collectables.add(collectable);
  }

  void _updatePlayersAndNpcs() {
    for (var i = 0; i < characters.length; i++){
      final character = characters[i];
      updateCharacter(character);
      if (character is Player) {
        updatePlayer(character);
      }
    }
  }

  void _updateCollisions() {
    updateCollisionBetween(characters);
  }

  void sortGameObjects() {
    sortSum(characters);
    sortSum(items);
    sortSum(projectiles);
  }

  void setCharacterStateDead(Character character) {
    if (character.state == CharacterState.Dead) return;
    character.state = CharacterState.Dead;
    character.onCharacterStateChanged();
    character.collidable = false;
    character.onDeath();

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
    if (character.dead) return;
    character.health += amount;
    if (character.health > 0) return;
    setCharacterStateDead(character);
  }

  void deactivateProjectile(Projectile projectile) {
    assert (projectile.active);
    projectile.active = false;
    switch (projectile.type) {
      case ProjectileType.Bullet:
        dispatch(GameEventType.Bullet_Hole, projectile.x, projectile.y, projectile.z);
        break;
      case ProjectileType.Orb:
        dispatch(GameEventType.Blue_Orb_Deactivated, projectile.x, projectile.y, projectile.z);
        break;
      default:
        break;
    }
  }

  void _updateProjectiles() {
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
        var type = scene.getGridBlockTypeAtXYZ(projectile.x, projectile.y, projectile.z);
        if (type == GridNodeType.Tree_Bottom){
          dispatch(GameEventType.Material_Struck_Wood, projectile.x, projectile.y, projectile.z);
        }
        deactivateProjectile(projectile);
      }
    }

    checkProjectileCollision(characters);
  }

  void updatePlayer(Player player) {
    player.framesSinceClientRequest++;

    if (player.textDuration > 0) {
      player.textDuration--;
      if (player.textDuration == 0) {
        player.text = "";
      }
    }

    if (player.dead) return;

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

      if (target is Npc) {
        if (withinRadius(player, target, 100)){
          if (!target.deadOrBusy){
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
        player.setCharacterStateRunning();
        return;
      }

      if (ability != null) {
        if (withinRadius(player, target, ability.range)) {
          player.target = target;
          player.setCharacterStatePerforming(duration: ability.duration);
          return;
        }
        player.setCharacterStateRunning();
        return;
      }
      if (withinAttackRadius(player, target)) {
        player.target = target;
        player.attackTarget(target);
        return;
      }
      player.setCharacterStateRunning();
      return;
    }

    if (ability != null) {
      if (!withinRadius(player, target, ability.range)){
        player.setCharacterStateRunning();
        return;
      }
      player.setCharacterStatePerforming(duration: ability.duration);
      return;
    }


    if (player.distanceFromPos2(target) <= player.speed) {
      player.target = null;
      player.setCharacterStateIdle();
      return;
    }
    player.setCharacterStateRunning();
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

    if (projectile.type == ProjectileType.Arrow){
      dispatch(GameEventType.Arrow_Hit, target.x, target.y, target.z);
    }
    if (projectile.type == ProjectileType.Orb){
      dispatch(GameEventType.Blue_Orb_Deactivated, target.x, target.y, target.z);
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
      if (target.dead) return;
    }

    if (target is Health) {
      final health = target as Health;
      if (src is Character && src is Zombie) {
        dispatchV3(GameEventType.Zombie_Strike, src);
      }
      target.onStruckBy(src);
      applyDamage(src: src, target: health, amount: damage);
    }
  }

  void updateCharacterStatePerforming(Character character) {
    final ability = character.ability;
    if (ability == null) {
      return updateCharacterStateAttacking(character);
    }
    if (character.stateDuration == 0){
       ability.cooldownRemaining = ability.cooldown;
    }
    ability.onActivated(character, this);
  }

  void updateCharacter(Character character) {
    character.updateCharacter(this);
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
      angle: src.target != null ? null : src.angle,
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
      angle: target != null ? null : angle ?? src.angle,
      projectileType: ProjectileType.Arrow,
      damage: damage,
    );
  }

  Projectile spawnProjectileFireball(Character src, {
    required int damage,
    required double range,
    double? angle,
  }) {
    dispatchV3(GameEventType.Projectile_Fired_Fireball, src);
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
  }){
    return spawnProjectile(
      src: src,
      accuracy: 0,
      angle: src.angle,
      speed: speed,
      range: src.equippedRange,
      projectileType: ProjectileType.Bullet,
      damage: src.equippedWeapon.damage,
    );
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
    final projectile = getAvailableProjectile();
    var finalAngle = angle;
    if (finalAngle == null){
      if (target != null && target is Collider){
        finalAngle = src.getAngle(target);
      } else {
        finalAngle = src.angle;
      }
    }
    projectile.damage = damage;
    projectile.collidable = true;
    projectile.active = true;
    if (target is Collider){
      projectile.target = target;
    }
    projectile.start.x = src.x;
    projectile.start.y = src.y;
    projectile.x = src.x;
    projectile.y = src.y;
    projectile.z = src.z + tileHeightHalf;
    projectile.angle = finalAngle + giveOrTake(accuracy);
    projectile.speed = speed;
    projectile.owner = src;
    projectile.range = range;
    projectile.type = projectileType;
    return projectile;
  }

  Projectile getAvailableProjectile() {
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
    zombie.movementSpeed = speed;
    zombie.wanderRadius = wanderRadius;
    return zombie;
  }

  Zombie getZombieInstance() {
    for (final character in characters) {
      if (character.alive) continue;
      if (character is Zombie)
        return character;
    }
    final zombie = Zombie(
      x: 0,
      y: 0,
      z: 0,
      health: 10,
      damage: 1,
    );
    characters.add(zombie);
    return zombie;
  }

  Rat getInstanceRat() {
    for (final character in characters) {
      if (character.alive) continue;
      if (character is Rat)
        return character;
    }
    final instance = Rat(
      z: 0,
      row: 0,
      column: 0,
      health: 10,
      damage: 1,
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

  void updateAITargets() {
    for (final character in characters) {
      if (character.dead) continue;
      if (character is AI == false) continue;
      final ai = character as AI;

      var target = character.target;
      if (
          target != null &&
          !character.withinChaseRange(target)
      ) {
        character.target = null;
        character.clearDest();
      }

      var targetDistance = 9999999.0;

      for (final other in characters) {
        if (other.dead) continue;
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
    if (value is Team){
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

  bool removePlayer(Player player){
    if (!players.remove(player)) return false;
    characters.remove(player);
    for (final character in characters) {
      character.onPlayerRemoved(player);
    }
    onPlayerDisconnected(player);
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

  void npcSetPathToTileNode(AI ai, Node node) {
    pathFindDestination = node;
    pathFindAI = ai;
    pathFindSearchID++;
    ai.pathIndex = -1;
    // scene.visitNodeFirst(scene.getNodeByPosition(ai));
  }

  void _updateCharacterFrames() {
    const characterFramesChange = 6;
    if (engine.frame % characterFramesChange != 0) return;
    updateFrames(characters);
  }

  void _updateItems() {
    var itemsLength = items.length;
    for (var i = 0; i < itemsLength; i++) {
      final item = items[i];
      if (item.duration-- > 0) continue;
      items.removeAt(i);
      itemsLength--;
    }
  }

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

    final weaponType = character.equippedWeapon.type;
    if (weaponType == WeaponType.Sword) {
      if (stateDuration == 7) {
        dispatchV3(GameEventType.Sword_Woosh, character);
      }
    }
    if (weaponType == WeaponType.Unarmed) {
      if (stateDuration == 7) {
        dispatchV3(GameEventType.Arm_Swing, character);
      }
    }
    if (weaponType == WeaponType.Handgun) {
      if (stateDuration == 1) {
        if (character.equippedIsEmpty) {
          dispatchV3(GameEventType.Clip_Empty, character);
          return;
        }
        dispatchV3(GameEventType.Handgun_Fired, character,
            angle: character.angle);
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
          dispatchV3(GameEventType.Ammo_Acquired, character);
          return;
        }
        dispatchV3(GameEventType.Shotgun_Fired, character);
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

    if (character.equippedTypeIsStaff){
      spawnProjectileOrb(character, damage: equippedDamage);
      character.target = null;
      return;
    }

    if (character.equippedTypeIsBow) {
      dispatchV3(GameEventType.Release_Bow, character);
      spawnProjectileArrow(character, damage: equippedDamage, target: character.target, range: character.equippedRange);
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
          angle: character.angle,
      );

      final attackTarget = character.target;
      if (attackTarget != null) {
        if (attackTarget is Collider && attackTarget.collidable) {
          applyHit(src: character, target: attackTarget, damage: equippedDamage);
          character.target = null;
          return;
        }
         character.target = null;
      }
      final zombieHit = raycastHit(
          character: character,
          colliders: characters,
          range: character.equippedRange
      );
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

  void updateCollectables() {
    collectables.forEach((collectable) => collectable.update());
  }

  void respawnDynamicObject(GameObject dynamicObject, {required int health}){
    assert(health > 0);
    for (final player in players) {
      dynamicObject.health = health;
      dynamicObject.collidable = true;
      player.writeDynamicObjectSpawned(dynamicObject);
    }
  }

  void addEnemySpawn({
    required int z,
    required int row,
    required int column,
    required int health, int max = 5,
    double wanderRadius = 200,
  }){
    final instance =         EnemySpawn(
      z: z,
      row: row,
      column: column,
      framesPerSpawn: 30,
      health: health,
      max: max,
      wanderRadius: wanderRadius,
    );
    scene.enemySpawns.add(instance);
    instance.init(this);
  }

  Npc addNpc({
    required String name,
    required int row,
    required int column,
    required int z,
    Function(Player player)? onInteractedWith,
    int weaponType = WeaponType.Unarmed,
    int weaponDamage = 1,
    int head = HeadType.None,
    int armour = ArmourType.shirtCyan,
    int pants = PantsType.brown,
    int team = 1,
    int health = 10,
    double wanderRadius = 0,
  }){
    final npc = Npc(
      name: name,
      onInteractedWith: onInteractedWith,
      x: 0,
      y: 0,
      z: 0,
      weapon: Weapon(type: weaponType, damage: weaponDamage),
      team: team,
      health: health,
      wanderRadius:  wanderRadius,
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
}

double angle2(double adjacent, double opposite) {
  if (adjacent > 0) {
    return pi2 - (atan2(adjacent, opposite) * -1);
  }
  return atan2(adjacent, opposite);
}

class ZombieSpawnPointsEmptyException implements Exception {}

class Teams {
  static const none = 0;
  static const west = 1;
  static const east = 2;
}

int calculateDamage({
  required MaterialType targetMaterialType,
  required int techType,
  required int level,
}){
  switch(targetMaterialType) {
    case MaterialType.Rock:
      if (techType == TechType.Pickaxe) return level + 1;
      if (techType == TechType.Unarmed) return 1;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      if (techType == TechType.Axe) return 1;
      if (techType == TechType.Hammer) return 1;
      return 0;
    case MaterialType.Wood:
      if (techType == TechType.Pickaxe) return 1;
      if (techType == TechType.Unarmed) return 1;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      if (techType == TechType.Axe) return level + 1;
      if (techType == TechType.Hammer) return 1;
      return 0;
    case MaterialType.Plant:
      if (techType == TechType.Pickaxe) return 1;
      if (techType == TechType.Unarmed) return 1;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      if (techType == TechType.Hammer) return 0;
      return 0;
    case MaterialType.Flesh:
      if (techType == TechType.Pickaxe) return level;
      if (techType == TechType.Unarmed) return level;
      if (techType == TechType.Shotgun) return level;
      if (techType == TechType.Handgun) return level;
      if (techType == TechType.Bow) return level;
      if (techType == TechType.Sword) return level;
      if (techType == TechType.Axe) return level;
      if (techType == TechType.Hammer) return level;
      return 0;
    case MaterialType.Metal:
      if (techType == TechType.Pickaxe) return 1;
      if (techType == TechType.Unarmed) return 1;
      if (techType == TechType.Axe) return 1;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      if (techType == TechType.Hammer) return level;
      return 0;
    default:
      return 0;
  }
}

