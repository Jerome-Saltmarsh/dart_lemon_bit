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
import 'enemy_spawn.dart';
import 'position3.dart';
import 'card_abilities.dart';
import 'character.dart';
import 'collectable.dart';
import 'collider.dart';
import 'game_object.dart';
import 'npc.dart';
import 'item.dart';
import 'player.dart';
import 'projectile.dart';
import 'scene.dart';
import 'spawn_point.dart';
import 'tile_node.dart';
import 'components.dart';
import 'weapon.dart';
import 'zombie.dart';

abstract class Game {
  Player? owner;
  final items = <Item>[];
  final zombies = <Zombie>[];
  final npcs = <Npc>[];
  final players = <Player>[];
  final projectiles = <Projectile>[];
  final collectables = <Collectable>[];
  var spawnPoints = <SpawnPoint>[];
  var shadeMax = Shade.Bright;
  var frame = 0;
  var teamSize = 1;
  var numberOfTeams = 2;
  var countDownFramesRemaining = 45 * 5;
  var disableCountDown = 0;
  late GameStatus status;
  final String id = (_id++).toString();
  final Scene scene;

  var playersCanAttackDynamicObjects = false;

  // WEATHER
  var _raining = Rain.None;
  var _breezy = false;
  var _lightning = Lightning.Off;
  var _wind = 0;
  var _timePassing = true;

  bool get hasOwner => owner != null;

  void setHourMinutes(int hour, int minutes){

  }

  set wind(int value){
    if (_wind == value) return;
    if (value < windIndexCalm) return;
    if (value > windIndexStrong) return;
     _wind = value;
    playersWriteWeather();
  }

  set raining(Rain value) {
     if (_raining == value) return;
     _raining = value;
     playersWriteWeather();
  }

  set breezy(bool value){
     if(_breezy == value) return;
     _breezy = value;
     playersWriteWeather();
  }

  set lightning(Lightning value){
    if(_lightning == value) return;
    _lightning = value;
    playersWriteWeather();
  }

  set timePassing(bool value) {
    if(_timePassing == value) return;
    _timePassing = value;
    playersWriteWeather();
  }

  void toggleBreeze(){
    breezy = !breezy;
  }

  void toggleWind(){
    wind = (_wind + 1) % 3;
  }

  void toggleTimePassing(){
    timePassing = !timePassing;
  }

  Lightning get lightning => _lightning;
  Rain get raining => _raining;
  bool get breezy => _breezy;
  bool get timePassing => _timePassing;
  int get wind => _wind;

  static int _id = 0;

  bool get full;

  List<GameObject> get gameObjects => scene.gameObjects;

  bool get countingDown => status == GameStatus.Counting_Down;

  bool get inProgress => status == GameStatus.In_Progress;

  bool get finished => status == GameStatus.Finished;

  bool get awaitingPlayers => status == GameStatus.Awaiting_Players;

  int get numberOfAlivePlayers => countAlive(players);

  int get numberOfAliveZombies => countAlive(zombies);

  void updateStatus(){
    removeDisconnectedPlayers();
    switch (status) {

      case GameStatus.In_Progress:
        updateInProgress();
        break;

      case GameStatus.Awaiting_Players:
        for (int i = 0; i < players.length; i++) {
          final player = players[i];
          player.lastUpdateFrame++;
          if (player.lastUpdateFrame > 100) {
            players.removeAt(i);
            i--;
          }
        }
        break;

      case GameStatus.Counting_Down:
        countDownFramesRemaining--;
        if (countDownFramesRemaining <= 0) {
          setGameStatus(GameStatus.In_Progress);
          onGameStarted();
        }
        break;

      default:
        break;
    }

    for (final player in players) {
      player.writeAndSendResponse();
    }
  }

  void updateAIPath(){
    for (final zombie in zombies) {
      if (zombie.deadOrBusy) continue;
      final target = zombie.target;
      if (target == null) continue;
      npcSetPathTo(zombie, target);
    }
  }

  void regenCharacters() {
    for (final player in players) {
      if (player.dead) continue;
      player.health++;
      player.magic++;
    }
  }

  bool containsPlayerWithName(String name){
     for(final player in players){
       if (player.name == name) return true;
     }
     return false;
  }

  void setGameStatus(GameStatus value){
    if (status == value) return;
    status = value;
    players.forEach((player) => player.writeGameStatus());
  }

  void onGameObjectsChanged() {
    sortVertically(gameObjects);
    for (final player in players){
      player.writeGameObjects();
    }
  }

  void cancelCountDown() {
    status = GameStatus.Awaiting_Players;
    countDownFramesRemaining = 0;
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
    moveCharacterToGridNode(character, GridNodeType.Player_Spawn);
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

    players.remove(player);

    for (final zombie in player.game.zombies) {
      if (zombie.target != player) continue;
      zombie.target = null;
    }

    to.players.add(player);
    player.game = to;
    to.disableCountDown = 0;
    player.sceneChanged = true;
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

  Game(this.scene, {
        this.shadeMax = Shade.Bright,
        this.status = GameStatus.In_Progress
      }) {
    engine.onGameCreated(this);
  }

  void spawnExplosion({
    required Character src,
    required Position3 target,
    required int damage
  }) {
    dispatchV2(GameEventType.Explosion, target);
    for (final character in zombies) {
       if (onSameTeam(src, target)) continue;
       if (character.getDistance(src) > 50) continue;
       applyHit(src: src, target: character, damage: damage);
    }
  }

  void checkCollisionPlayerItem() {
    var itemLength = items.length;
    for (final player in players) {
      if (player.dead) continue;
      for (var i = 0; i < itemLength; i++) {
        final item = items[i];
        if (item.top > player.bottom) break;
        if (item.bottom < player.top) continue;
        if (item.right < player.left) continue;
        if (item.left > player.right) continue;
        if (!onPlayerItemCollision(player, item)) continue;
        items.removeAt(i);
        i--;
        itemLength--;
      }
    }
  }

  void checkColliderCollision(
      List<Collider> collidersA, List<Collider> collidersB) {
    final totalColliders = collidersB.length;
    for (final a in collidersA) {
      if (!a.collidable) continue;
      final aRadius = a.radius;
      for (var i = 0; i < totalColliders; i++) {
        final b = collidersB[i];
        if (!b.collidable) continue;
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
    required List<Character> characters,
  }) {
    return findClosestVector2(
        positions: characters,
        x: x,
        y: y,
        where: (other) => other.alive && !onSameTeam(other, character));
  }

  Character? getClosestNpc({
    required double x,
    required double y,
    required Character character,
    required List<Character> characters,
  }) {
    return findClosestVector2(
        positions: npcs,
        x: x,
        y: y,
        where: (other) => other.alive);
  }

  GameObject? getClosestGameObject(double x, double y) {
    return findClosestVector2(
        positions: gameObjects,
        x: x,
        y: y,
        where: (other) => other.collidable
    );
  }

  Collider? getClosestCollider(double x, double y, Character character, {double? minDistance}) {
    Collider? closestCollider = null;
    var closestDistance = 99999.0;
    final closestZombie = getClosestEnemy(
        x: x,
        y: y,
        character: character,
        characters: zombies
    );
    if (closestZombie != null) {
      assert(closestZombie.alive);
      closestCollider = closestZombie;
      closestDistance = distanceBetween(x, y, closestZombie.x, closestZombie.y);
    }
    final closestPlayer = getClosestEnemy(
        x: x,
        y: y,
        character: character,
        characters: players
    );
    if (closestPlayer != null){
      assert(closestPlayer.alive);
      final playerDistance = distanceBetween(x, y, closestPlayer.x, closestPlayer.y);
      if (playerDistance < closestDistance) {
         closestCollider = closestPlayer;
         closestDistance = playerDistance;
      }
    }
    final closestNpc = getClosestNpc(x: x, y: y, character: character, characters: npcs);
    if (closestNpc != null){
        final npcDistance = distanceBetween(x, y, closestNpc.x, closestNpc.y);
        if (npcDistance < closestDistance) {
           closestCollider = closestNpc;
           closestDistance = npcDistance;
        }
    }
    if (minDistance != null && closestDistance > minDistance) return null;

    return closestCollider;
  }

  void updateInProgress() {
    frame++;
    if (frame % 15 == 0) {
      // updateInteractableNpcTargets();
      updateZombieTargets();
      if (players.isEmpty) {
        disableCountDown++;
      } else {
        disableCountDown = 0;
      }
    }

    for (final enemySpawner in scene.enemySpawns) {
       enemySpawner.update(this);
    }
    update();
    updateCollectables();
    _updateCollisions();
    _updatePlayersAndNpcs();
    _updateProjectiles();
    _updateProjectiles(); // called twice to fix collision detection
    _updateItems();
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
          dispatchV2(GameEventType.Material_Struck_Rock, target as Position3);
          break;
        case MaterialType.Wood:
          dispatchV2(GameEventType.Material_Struck_Wood, target as Position3);
          break;
        case MaterialType.Plant:
          dispatchV2(GameEventType.Material_Struck_Plant, target as Position3);
          break;
        case MaterialType.Flesh:
          dispatchV2(GameEventType.Material_Struck_Flesh,
              target as Position3, angle: radiansV2(src, target as Position3));
          break;
        case MaterialType.Metal:
          dispatchV2(GameEventType.Material_Struck_Metal, target as Position3);
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
          dispatchV2(
            GameEventType.Zombie_Killed,
            target,
            angle: radiansV2(src, target),
          );
        }
      }

      for (final ai in zombies) {
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
        dispatchV2(
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
        notifyPlayersDynamicObjectDestroyed(target);

        if (target.type == GameObjectType.Pot) {
          dispatchV2(GameEventType.Object_Destroyed_Pot, target);
        } else if (target.type == GameObjectType.Rock) {
          dispatchV2(GameEventType.Object_Destroyed_Rock, target);
        } else if (target.type == GameObjectType.Tree) {
          dispatchV2(GameEventType.Object_Destroyed_Tree, target);
        } else if (target.type == GameObjectType.Chest) {
          dispatchV2(GameEventType.Object_Destroyed_Chest, target);
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
    final playersLength = players.length;
    for (var i = 0; i < playersLength; i++) {
      final player = players[i];
      updatePlayer(player);
      updateCharacter(player);
    }

    final zombiesLength = zombies.length;
    for (var i = 0; i < zombiesLength; i++) {
      updateCharacter(zombies[i]);
    }

    final npcsLength = npcs.length;
    for (var i = 0; i < npcsLength; i++) {
      updateCharacter(npcs[i]);
    }
  }

  void _updateCollisions() {
    checkColliderCollision(players, gameObjects);
    checkColliderCollision(zombies, gameObjects);
    checkColliderCollision(players, gameObjects);
    updateCollisionBetween(zombies);
    updateCollisionBetween(players);
    resolveCollisionBetween(zombies, players, resolveCollisionA);
    resolveCollisionBetween(players, npcs, resolveCollisionB);
    checkCollisionPlayerItem();
  }

  void sortGameObjects() {
    sortSum(zombies);
    sortSum(players);
    sortSum(npcs);
    sortSum(items);
    sortSum(projectiles);
  }

  void setCharacterStateDead(Character character) {
    if (character.state == CharacterState.Dead) return;
    character.state = CharacterState.Dead;
    character.onCharacterStateChanged();
    character.collidable = false;

    if (character is AI) {
      character.target = null;
      character.pathIndex = -1;
    }

    if (character is Player) {
      dispatchV2(GameEventType.Player_Death, character);
      onPlayerDeath(character);
    }

    for (final npc in zombies) {
      if (npc.target != character) continue;
      npc.target = null;
    }

    for (final projectile in projectiles) {
      if (projectile.target != character) continue;
      projectile.target = null;
    }

    for (final player in players) {
      if (player.target != character) continue;
      player.target = null;
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
        deactivateProjectile(projectile);
      }
    }

    checkProjectileCollision(gameObjects);
    checkProjectileCollision(zombies);
    checkProjectileCollision(players);
  }

  void updatePlayer(Player player) {
    player.lastUpdateFrame++;

    if (player.textDuration > 0) {
      player.textDuration--;
      if (player.textDuration == 0) {
        player.text = "";
      }
    }

    if (!player.designed) {
       player.angle = (player.angle + 0.05) % pi2;
    }

    if (player.dead) return;

    if (player.lastUpdateFrame > 10) {
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
          target.onInteractedWith?.call(player);
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

    if (withinRadius(player, target, player.speed)) {
      player.target = null;
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

      if (src is Player) {
        const chancePerCard = 0.075;
        final critical = src.numberOfCardsOfType(CardType.Passive_General_Critical_Hit) * chancePerCard;
        if (random.nextDouble() < critical) {
          damage += damage;
        }
      }

      if (src is Character && src is Zombie){
        dispatchV2(GameEventType.Zombie_Strike, src);
      }

      applyDamage(src: src, target: health, amount: damage);
    }
  }

  void updateCharacterStatePerforming(Character character) {
    final ability = character.ability;
    if (ability == null) {
      updateCharacterStateAttacking(character);
      return;
    }
    final stateDuration = character.stateDuration;

    if (stateDuration == 0){
       ability.cooldownRemaining = ability.cooldown;
    }

    if (ability is CardAbilityBowVolley && stateDuration == 5) {
      final total = 3 + (ability.level * 2);
      for (var i = 0; i < total; i++) {
        spawnProjectileArrow(character, damage: ability.damage, range: ability.range, accuracy: 0.2);
      }
      character.target = null;
    }

    if (ability is CardAbilityBowLongShot && stateDuration == 5) {
      spawnProjectileArrow(
          character,
          damage: ability.damage,
          angle: character.angle,
          range: 9999
      );
      character.target = null;
    }

    if (stateDuration == 10 && ability is CardAbilityExplosion){
      final target = character.target;
      if (target != null) {
        spawnExplosion(src: character, target: target, damage: ability.damage);
        character.target = null;
      }
    }

    if (stateDuration == 10 && ability is CardAbilityFireball) {
      final target = character.target;
      if (target != null) {
        spawnFireball(character, damage: ability.damage, range: ability.range);
        character.target = null;
      }
    }
  }

  void updateCharacter(Character character) {
    if (character.dead) return;
    character.updateCharacter(this);
  }

  Projectile spawnProjectileOrb(Character src, {required int damage}) {
    dispatchV2(GameEventType.Blue_Orb_Fired, src);
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

  Projectile spawnProjectileArrow(Position3 src, {
    required int damage,
    required double range,
    double accuracy = 0,
    Position3? target,
    double? angle,
  }) {
    dispatch(GameEventType.Arrow_Fired, src.x, src.y, src.z);
    if (src is Character) {
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

    return spawnProjectile(
      src: src,
      accuracy: 0,
      speed: 7,
      range: 300,
      target: target,
      projectileType: ProjectileType.Arrow,
      damage: damage,
    );
  }

  Projectile spawnFireball(Position3 src, {
    required int damage,
    required double range,
    double accuracy = 0,
    Position3? target,
    double? angle,
  }) {
    dispatch(GameEventType.Projectile_Fired_Fireball, src.x, src.y, src.y);
    if (src is Character) {
      return spawnProjectile(
        src: src,
        accuracy: accuracy,
        speed: 7,
        range: range,
        target: target,
        angle: target != null ? null : angle ?? src.angle,
        projectileType: ProjectileType.Fireball,
        damage: damage,
      );
    }

    return spawnProjectile(
      src: src,
      accuracy: 0,
      speed: 7,
      range: range,
      target: target,
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
    required Position3 src,
    required double speed,
    required double range,
    required int projectileType,
    required int damage,
    double accuracy = 0,
    double? angle = 0,
    Position3? target,
  }) {
    assert (angle != null || target != null);
    assert (angle == null || target == null);

    final projectile = getAvailableProjectile();
    final finalAngle = angle ?? src.getAngle(target!);
    projectile.damage = damage;
    projectile.collidable = true;
    projectile.active = true;
    projectile.target = target;
    projectile.start.x = src.x;
    projectile.start.y = src.y;
    projectile.x = src.x;
    projectile.y = src.y;
    projectile.z = src.z;
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

  AI spawnZombie({
    required double x,
    required double y,
    required double z,
    required int health,
    required int team,
    required int damage,
    double speed = RunSpeed.Regular,
    List<Vector2>? objectives,
  }) {
    assert(team >= 0 && team <= 256);
    final zombie = _getAvailableZombie();
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
    return zombie;
  }

  AI _getAvailableZombie() {
    for (final zombie in zombies) {
      if (zombie.alive) continue;
      return zombie;
    }
    final zombie = Zombie(
      x: 0,
      y: 0,
      z: 0,
      health: 10,
      damage: 1,
    );
    zombies.add(zombie);
    return zombie;
  }

  int get zombieCount {
    var count = 0;
    for (final zombie in zombies) {
      if (!zombie.alive) continue;
      count++;
    }
    return count;
  }

  /// GameEventType
  void dispatchV2(int type, Position3 position, {double angle = 0}) {
    dispatch(type, position.x, position.y, position.z, angle);
  }

  /// GameEventType
  void dispatch(int type, double x, double y, double z, [double angle = 0]) {
    for (final player in players) {
      player.writeGameEvent(type: type, x: x, y: y, z: z, angle: angle);
    }
  }

  void notifyPlayersDynamicObjectDestroyed(GameObject dynamicObject){
    for (final player in players) {
      player.writeDynamicObjectDestroyed(dynamicObject);
    }
  }

  void updateZombieTargets() {
    for (final zombie in zombies) {
      if (zombie.dead) continue;

      if (zombie.target == null) {
        zombie.target = zombie.objective;
      }

      final zombieAITarget = zombie.target;
      if (
          zombieAITarget != null &&
          !zombie.withinChaseRange(zombieAITarget)
      ) {
        zombie.target = zombie.objective;
      }

      var targetDistance = 9999999.0;

      for (final player in players) {
        if (player.dead) continue;
        if (onSameTeam(player, zombie)) continue;
        if (!zombie.withinViewRange(player)) continue;
        final npcDistance = zombie.getDistance(player);
        if (npcDistance >= targetDistance) continue;
        setNpcTarget(zombie, player);
        targetDistance = npcDistance;
      }
      final target = zombie.target;
      if (target == null) continue;
      if (targetDistance < 100) continue;
      npcSetPathTo(zombie, target);
    }
  }

  void updateInteractableNpcTargets() {
    for (final npc in npcs) {
      Character? closest;
      var closestDistance = 99999.0;
      for (final zombie in zombies) {
        if (!zombie.alive) continue;
        if (onSameTeam(npc, zombie)) continue;
        var distance2 = distanceV2(zombie, npc);
        if (distance2 > closestDistance) continue;
        closest = zombie;
        closestDistance = distance2;
      }
      if (closest == null || closestDistance > npc.equippedRange) {
        npc.target = null;
        npc.state = CharacterState.Idle;
        continue;
      }
      setNpcTarget(npc, closest);
    }
  }

  void setNpcTarget(AI ai, Position3 value) {
    if (value is Team){
      assert(!onSameTeam(ai, value));
    }
    assert(ai.alive);
    ai.target = value;
  }

  bool removePlayer(Player player){
    if (!players.remove(player)) return false;
    for (final npc in zombies) {
      npc.clearTargetIf(player);
    }
    onPlayerDisconnected(player);
    if (player.scene.dirty && player.ownsGame && player.scene.name.isNotEmpty) {
       writeSceneToFile(scene);
    }
    if (status == GameStatus.Awaiting_Players) {
      cancelCountDown();
    }
    return true;
  }

  void removeDisconnectedPlayers() {
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];
      if (player.lastUpdateFrame++ < 100) continue;
      if (!removePlayer(player)) continue;
      i--;
      playerLength--;
    }
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

  // void _updateSpawnPointCollisions() {
  //   if (spawnPoints.isEmpty) return;
  //   for (var i = 0; i < players.length; i++) {
  //     final player = players[i];
  //     for (final spawnPoint in spawnPoints) {
  //       const collisionRadius = 20;
  //       if (diffOver(player.x, spawnPoint.x, collisionRadius)) continue;
  //       if (diffOver(player.y, spawnPoint.y, collisionRadius)) continue;
  //       for (final point in spawnPoint.game.spawnPoints) {
  //         if (point.game != this) continue;
  //         changeGame(player, spawnPoint.game);
  //         final xDiff = spawnPoint.x - player.x;
  //         final yDiff = spawnPoint.y - player.y;
  //         player.x = point.x + xDiff * 1.25;
  //         player.y = point.y + yDiff * 1.25;
  //         i--;
  //         break;
  //       }
  //       break;
  //     }
  //   }
  // }

  void _updateCharacterFrames() {
    const characterFramesChange = 6;
    if (engine.frame % characterFramesChange != 0) return;
    updateFrames(players);
    updateFrames(zombies);
    updateFrames(npcs);
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
        dispatchV2(GameEventType.Sword_Woosh, character);
      }
    }
    if (weaponType == WeaponType.Unarmed) {
      if (stateDuration == 7) {
        dispatchV2(GameEventType.Arm_Swing, character);
      }
    }
    if (weaponType == WeaponType.Handgun) {
      if (stateDuration == 1) {
        if (character.equippedIsEmpty) {
          dispatchV2(GameEventType.Clip_Empty, character);
          return;
        }
        dispatchV2(GameEventType.Handgun_Fired, character,
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
          dispatchV2(GameEventType.Ammo_Acquired, character);
          return;
        }
        dispatchV2(GameEventType.Shotgun_Fired, character);
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
      dispatchV2(GameEventType.Draw_Bow, character);
    }

    if (stateDuration != framePerformStrike) return;

    if (character.equippedWeapon == WeaponType.Staff) {
      spawnProjectileOrb(character, damage: equippedDamage);
      character.target = null;
      return;
    }

    if (character.equippedTypeIsBow) {
      dispatchV2(GameEventType.Release_Bow, character);
      spawnProjectileArrow(character, damage: equippedDamage, target: character.target, range: character.equippedRange);
      character.target = null;
      return;
    }
    if (character.equippedIsMelee) {
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
          colliders: zombies,
          range: character.equippedRange);
      if (zombieHit != null) {
        applyHit(
          src: character,
          target: zombieHit,
          damage: equippedDamage,
        );
        return;
      }
      final dynamicObjectHit = raycastHit(
          character: character,
          colliders: gameObjects,
          range: character.equippedRange
      );
      if (dynamicObjectHit != null) {
        applyHit(
          src: character,
          target: dynamicObjectHit,
          damage: equippedDamage,
        );
      }
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

  void addEnemySpawn({required int z, required int row, required int column, required int health}){
    scene.enemySpawns.add(
        EnemySpawn(
          z: z,
          row: row,
          column: column,
          framesPerSpawn: 30,
          health: health,
        )
    );
  }

  Npc addNpc({
    required String name,
    required double x,
    required double y,
    required double z,
    Function(Player player)? onInteractedWith,
    int weaponType = WeaponType.Unarmed,
    int weaponDamage = 1,
    int head = HeadType.None,
    int armour = ArmourType.shirtCyan,
    int pants = PantsType.brown,
    int team = 1,
    int health = 10,
  }){
    final npc = Npc(
      name: name,
      onInteractedWith: onInteractedWith,
      x: x,
      y: y,
      z: z,
      weapon: Weapon(type: weaponType, damage: weaponDamage),
      team: team,
      health: health,
    );
    npc.equippedHead = head;
    npc.equippedArmour = armour;
    npc.equippedPants = pants;
    npcs.add(npc);
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

