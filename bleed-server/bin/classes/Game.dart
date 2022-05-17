import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/card_type.dart';
import '../common/library.dart';
import '../engine.dart';
import '../enums.dart';
import '../functions.dart';
import '../functions/withinRadius.dart';
import '../maths.dart';
import '../physics.dart';
import '../utilities.dart';
import 'AI.dart';
import 'Character.dart';
import 'Collectable.dart';
import 'Collider.dart';
import 'DynamicObject.dart';
import 'EnvironmentObject.dart';
import 'InteractableNpc.dart';
import 'Item.dart';
import 'Player.dart';
import 'Projectile.dart';
import 'Scene.dart';
import 'SpawnPoint.dart';
import 'Structure.dart';
import 'TileNode.dart';
import 'components.dart';

abstract class Game {
  final items = <Item>[];
  final zombies = <AI>[];
  final npcs = <InteractableNpc>[];
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
  // final GameType gameType;
  final String id = (_id++).toString();
  final Scene scene;

  var playersCanAttackDynamicObjects = false;

  static int _id = 0;

  List<DynamicObject> get dynamicObjects => scene.objectsDynamic;

  List<StaticObject> get objectsStatic => scene.objectsStatic;

  List<Structure> get structures => scene.structures;

  bool get countingDown => status == GameStatus.Counting_Down;

  bool get inProgress => status == GameStatus.In_Progress;

  bool get finished => status == GameStatus.Finished;

  bool get awaitingPlayers => status == GameStatus.Awaiting_Players;

  int get numberOfAlivePlayers => countAlive(players);

  int get numberOfAliveZombies => countAlive(zombies);

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

  void onStaticObjectsChanged() {
    sortVertically(objectsStatic);
    for(final player in players){
      player.writeStaticObjects();
    }
  }

  void cancelCountDown() {
    status = GameStatus.Awaiting_Players;
    countDownFramesRemaining = 0;
  }

  void onPlayerChoseCard(Player player, CardType cardType){

  }

  void onKilled(dynamic target, dynamic src){

  }

  void onDamaged(dynamic target, dynamic src, int amount){

  }

  void revive(Player character) {
    character.state = CharacterState.Idle;
    character.health = character.maxHealth;
    character.collidable = true;
    final spawnPoint = getNextSpawnPoint();
    character.x = spawnPoint.x;
    character.y = spawnPoint.y;
  }

  /// In seconds
  int getTime();

  void onGameStarted() {}

  void onPlayerJoined(Player player) {}

  void onPlayerDeath(Player player) {}

  void onNpcObjectivesCompleted(Character npc) {}

  void updateNpcBehavior(Character npc) {}

  void onPlayerLevelGained(Player player){

  }

  Position getNextSpawnPoint() {
    if (scene.spawnPointPlayers.isEmpty){
      return getSceneCenter();
    }
    return randomItem(scene.spawnPointPlayers);
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

    for (final character in scene.characters) {
      if (character.type == CharacterType.Zombie) {
        zombies.add(AI(
          type: CharacterType.Zombie,
          x: character.x,
          y: character.y,
          health: 100,
          weapon: SlotType.Empty,
        ));
      } else {
        npcs.add(InteractableNpc(
          name: "Bob",
          onInteractedWith: (Player player) {},
          x: character.x,
          y: character.y,
          health: 100,
          weapon: SlotType.Empty,
        ));
      }
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
        a.x -= adj(r, overlap);
        a.y -= opp(r, overlap);
        a.onCollisionWith(b);
        b.onCollisionWith(a);
      }
    }
  }

  Player spawnPlayer();

  void onPlayerSelectCharacterType(Player player, CharacterSelection value){

  }
}

const secondsPerMinute = 60;
const minutesPerHour = 60;
const hoursPerDay = 24;
const secondsPerFrame = 5;

extension GameFunctions on Game {
  void spawnRandomOrb(double x, double y) {
    items.add(Item(type: randomItem(ItemType.orbs), x: x, y: y));
  }

  Vector2 getSceneCenter() =>
      getTilePosition(scene.numberOfRows ~/ 2, scene.numberOfColumns ~/ 2);

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

  DynamicObject? getClosestDynamicObject(double x, double y) {
    return findClosestVector2(
        positions: scene.objectsDynamic,
        x: x,
        y: y,
        where: (other) => other.collidable);
  }

  Collider? getClosestCollider(double x, double y, Character character) {
    final zombie =
        getClosestEnemy(x: x, y: y, character: character, characters: zombies);
    final player =
        getClosestEnemy(x: x, y: y, character: character, characters: players);
    final dynamicObject = playersCanAttackDynamicObjects ? getClosestDynamicObject(x, y) : null;
    final zombieDistance =
        zombie != null ? distanceBetween(x, y, zombie.x, zombie.y) : 99999;
    final playerDistance =
        player != null ? distanceBetween(x, y, player.x, player.y) : 99999;
    final dynamicDistance = dynamicObject != null
        ? distanceBetween(x, y, dynamicObject.x, dynamicObject.y)
        : 99999;

    if (zombieDistance < playerDistance) {
      if (zombieDistance < dynamicDistance) {
        return zombie;
      }
      return dynamicObject;
    }
    if (playerDistance < dynamicDistance) {
      return player;
    }
    return dynamicObject;
  }

  void updateInProgress() {
    frame++;
    if (frame % 15 == 0) {
      updateInteractableNpcTargets();
      updateZombieTargets();
      if (players.isEmpty) {
        disableCountDown++;
      } else {
        disableCountDown = 0;
      }
    }
    update();
    updateDynamicObjects();
    updateCollectables();
    updateStructures();
    _updateCollisions();
    _updatePlayersAndNpcs();
    _updateProjectiles();
    _updateProjectiles(); // called twice to fix collision detection
    _updateSpawnPointCollisions();
    _updateItems();
    _updateCharacterFrames();
    sortGameObjects();
  }

  void updateFrames(List<Character> character) {
    for (final character in character) {
      character.animationFrame = (character.animationFrame + 1) % 8;
    }
  }

  /// TODO Optimize
  /// calculates if there is a wall between two objects
  bool isVisibleBetween(Position a, Position b) {
    final angle = radiansV2(a, b);
    final vX = adj(angle, 48);
    final vY = opp(angle, 48);
    final jumps = distanceV2(a, b) ~/ 48;
    var x = a.x + vX;
    var y = a.y + vY;
    for (var i = 0; i < jumps; i++) {
      if (!isShootable(scene.tileAt(x, y))) {
        return false;
      }
      x += vX;
      y += vY;
    }
    return true;
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
          dispatchV2(GameEventType.Material_Struck_Rock, target as Position);
          break;
        case MaterialType.Wood:
          dispatchV2(GameEventType.Material_Struck_Wood, target as Position);
          break;
        case MaterialType.Plant:
          dispatchV2(GameEventType.Material_Struck_Plant, target as Position);
          break;
        case MaterialType.Flesh:
          dispatchV2(GameEventType.Material_Struck_Flesh,
              target as Position, angle: radiansV2(src, target as Position));
          break;
        case MaterialType.Metal:
          dispatchV2(GameEventType.Material_Struck_Metal, target as Position);
          break;
      }
    }


    if (destroyed) {
      if (target is Collider) {
        (target as Collider).collidable = false;
      }
      if (target is Character) {
        if (target.dead && target.type.isZombie) {
          dispatchV2(
            GameEventType.Zombie_Killed,
            target,
            angle: radiansV2(src, target),
          );
        }
      }

      onKilled(target, src);
    } else {
      onDamaged(target, src, damage);
    }

    if (target is Character) {
      final isZombie = target.type.isZombie;

      if (destroyed) {
        setCharacterStateDead(target);
        return;
      }
      if (isZombie && randomBool()) {
        dispatchV2(
          GameEventType.Zombie_Hurt,
          target,
        );
        setCharacterState(target, CharacterState.Hurt);
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

    if (destroyed && target is Structure) {
      final node = scene.tileNodeAt(target);
      node.open = true;
      node.obstructed = false;
    }

    if (target is DynamicObject) {
      switch (target.type) {
        case DynamicObjectType.Rock:
          if (src is Player) {
            // spawnCollectable(position: target, target: src, type: CollectableType.Stone, amount: damage);
          }
          break;
        case DynamicObjectType.Tree:
          if (src is Player) {
            // spawnCollectable(position: target, target: src, type: CollectableType.Wood, amount: damage);
          }
          break;
      }

      if (destroyed) {
        target.respawnDuration = 5000;
        notifyPlayersDynamicObjectDestroyed(target);

        if (target.type == DynamicObjectType.Pot) {
          dispatchV2(GameEventType.Object_Destroyed_Pot, target);
        } else if (target.type == DynamicObjectType.Rock) {
          dispatchV2(GameEventType.Object_Destroyed_Rock, target);
        } else if (target.type == DynamicObjectType.Tree) {
          dispatchV2(GameEventType.Object_Destroyed_Tree, target);
        } else if (target.type == DynamicObjectType.Chest) {
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
    collectable.setVelocity(randomAngle(), 3.0);
    collectables.add(collectable);
  }

  void _characterAttack(Character character, Collider target) {
    assert(character.withinAttackRange(target));
    assert(character.alive);
    character.face(target);
    setCharacterStatePerforming(character);
    character.attackTarget = target;
  }

  void _characterRunAt(Character character, Position target) {
    character.face(target);
    setCharacterState(character, CharacterState.Running);
  }

  void updateAI(AI ai) {
    if (ai.deadOrBusy) return;

    final target = ai.target;
    if (target != null) {
      if (ai.type.isZombie) {
        if (ai.withinAttackRange(target)) {
          _characterAttack(ai, target);
          return;
        }
        const runAtTargetDistance = 100;
        if ((ai.getDistance(target) < runAtTargetDistance)) {
          _characterRunAt(ai, target);
          return;
        }

      } else {
        // not zombie
        if (!ai.withinAttackRange(target)) return;
        if (!isVisibleBetween(ai, target)) return;
        _characterAttack(ai, target);
        return;
      }
    }

    if (ai.pathIndex >= 0) {
      if (ai.arrivedAtDest) {
        ai.nextPath();
        return;
      }
      // @on npc going to path
      ai.face(ai.dest);
      ai.state = CharacterState.Running;
      return;
    } else if (ai.idleDuration++ > 120) {
      ai.idleDuration = 0;
      // wander mode
      if (ai.objective == null) {
        npcSetRandomDestination(ai);
      }
    }

    ai.state = CharacterState.Idle;
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
    checkColliderCollision(players, structures);
    checkColliderCollision(zombies, structures);
    checkColliderCollision(players, scene.objectsStatic);
    checkColliderCollision(zombies, scene.objectsStatic);
    checkColliderCollision(players, scene.objectsDynamic);
    updateCollisionBetween(zombies);
    updateCollisionBetween(players);
    resolveCollisionBetween(zombies, players, resolveCollisionA);
    resolveCollisionBetween(players, npcs, resolveCollisionB);
    checkCollisionPlayerItem();
  }

  void sortGameObjects() {
    sortVertically(zombies);
    sortVertically(players);
    sortVertically(npcs);
    sortVertically(items);
    sortVertically(projectiles);
    sortVertically(structures);
  }

  void setCharacterStateRunning(Character character) {
    setCharacterState(character, CharacterState.Running);
  }

  void setCharacterStateDead(Character character) {
    if (character.state == CharacterState.Dead) return;
    character.state = CharacterState.Dead;
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
      if (player.attackTarget != character) continue;
      player.attackTarget = null;
    }
  }

  void setCharacterStatePerforming(Character character) {
    character.performing = character.ability;
    character.ability = null;
    setCharacterState(character, CharacterState.Performing);
  }

  void setCharacterState(Character character, int value) {
    assert(value >= 0);
    assert(value <= 5);
    if (character.dead) return;
    if (character.state == value) return;

    if (value == CharacterState.Dead) {
      setCharacterStateDead(character);
      return;
    }

    if (value == CharacterState.Hurt) {
      const duration = 10;
      character.stateDurationRemaining = duration;
      character.state = value;
      character.stateDuration = 0;
      character.animationFrame = 0;
      return;
    }

    if (character.busy) return;

    switch (value) {
      case CharacterState.Changing:
        character.stateDurationRemaining = 10;
        break;
      case CharacterState.Performing:
        character.stateDurationRemaining = 20;
        if (character is Player) {
          final ability = character.performing;
          if (ability == null) {
            character.stateDurationRemaining = character.equippedAttackDuration;
            break;
          }
          if (character.magic < ability.cost) {
            character.ability = null;
            character.attackTarget = null;
            break;
          }
          character.magic -= ability.cost;
        }
        break;
      default:
        break;
    }
    character.state = value;
    character.stateDuration = 0;
    character.animationFrame = 0;
  }

  void setCharacterStateIdle(Character character) {
    setCharacterState(character, CharacterState.Idle);
  }

  void changeCharacterHealth(Character character, int amount) {
    if (character.dead) return;
    character.health += amount;
    if (character.health > 0) return;
    setCharacterStateDead(character);
  }

  void deactivateProjectile(Projectile projectile) {
    if (!projectile.active) return;
    projectile.active = false;
    if (scene.waterAt(projectile.x, projectile.y)) return;
    switch (projectile.type) {
      case TechType.Handgun:
        dispatch(GameEventType.Bullet_Hole, projectile.x, projectile.y);
        break;
      case TechType.Shotgun:
        dispatch(GameEventType.Bullet_Hole, projectile.x, projectile.y);
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
      if (scene.projectileCollisionAt(projectile.x, projectile.y)) {
        deactivateProjectile(projectile);
      }
    }

    checkProjectileCollision(scene.objectsStatic);
    checkProjectileCollision(zombies);
    checkProjectileCollision(players);
    checkProjectileCollision(dynamicObjects);
  }

  void updatePlayer(Player player) {
    player.lastUpdateFrame++;

    if (player.textDuration > 0) {
      player.textDuration--;
      if (player.textDuration == 0) {
        player.text = "";
      }
    }

    if (player.lastUpdateFrame > 10) {
      setCharacterStateIdle(player);
    }

    final aimTarget = player.aimTarget;
    if (aimTarget is Character && aimTarget.dead) {
      player.aimTarget = null;
    }

    final target = player.target;
    if (target == null) return;
    player.face(target);

    if (target is Collider) {
      if (!target.collidable) {
        player.target = null;
        return;
      }

      final ability = player.ability;

      if (ability != null) {
        if (withinRadius(player, target, ability.range)) {
          player.attackTarget = target;
          setCharacterStatePerforming(player);
          player.target = null;
          return;
        }
        setCharacterStateRunning(player);
        return;
      }

      if (withinAttackRadius(player, target)) {
        player.attackTarget = target;
        setCharacterStatePerforming(player);
        player.target = null;
        return;
      }
    } else if (withinRadius(player, target, player.speed)) {
      player.target = null;
      return;
    }
    setCharacterStateRunning(player);
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

  void handleProjectileHit(Projectile projectile, Collider collider) {
    projectile.active = false;
    if (collider is Character) {
      applyHit(
          src: projectile.owner,
          target: collider,
          damage: projectile.damage,
      );
    }
    projectile.owner = null;
    projectile.target = null;
    dispatch(GameEventType.Arrow_Hit, collider.x, collider.y);
  }

  // void applyHit2({
  //   required dynamic src,
  //   required Collider target,
  // }){
  //   if (!target.collidable) return;
  //   if (target is Character) {
  //     if (onSameTeam(src, target)) return;
  //     if (target.dead) return;
  //   }
  //   if (target is Health == false) return;
  //
  //   if (src is Player) {
  //      applyDamage(src: src, target: target as Health, amount: src.getDamage());
  //   }
  // }

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

      applyDamage(src: src, target: health, amount: damage);
    }
  }

  void updateCharacterStatePerforming(Character character) {
    final ability = character.performing;
    if (ability == null) {
      updateCharacterStateAttacking(character);
      return;
    }
    const castFrame = 3;
    switch (ability.type) {
      case AbilityType.Explosion:
        break;
      case AbilityType.Blink:
        if (character.stateDurationRemaining == castFrame) {
          dispatch(GameEventType.Teleported, character.x, character.y);
          character.x = character.abilityTarget.x;
          character.y = character.abilityTarget.y;
          dispatch(GameEventType.Teleported, character.x, character.y);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.Fireball:
        if (character.stateDurationRemaining == castFrame) {
          // spawnFireball(character);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.Long_Shot:
        // if (character.stateDurationRemaining == castFrame) {
        //   final int damageMultiplier = 3;
        //   spawnArrow(
        //         character,
        //         damage: character.equippedDamage * damageMultiplier
        //   ).range = ability.range;
        //   character.attackTarget = null;
        //   character.performing = null;
        // }
        break;

      case AbilityType.Brutal_Strike:
        break;
      case AbilityType.Death_Strike:
        break;
      default:
        break;
    }
  }

  void updateCharacter(Character character) {
    if (character.dead) return;

    if (character is AI) {
      updateAI(character);
    }
    character.updateMovement();

    if (character.frozenDuration > 0) {
      character.frozenDuration--;
    }

    if (character.stateDurationRemaining > 0) {
      character.stateDurationRemaining--;
      if (character.stateDurationRemaining == 0) {
        setCharacterState(character, CharacterState.Idle);
      }
    }

    scene.resolveCharacterTileCollision(character);

    switch (character.state) {
      case CharacterState.Running:
        character.applyVelocity();
        break;

      case CharacterState.Performing:
        updateCharacterStatePerforming(character);
        break;
    }
    character.stateDuration++;
  }

  void updateCharacterTileCollision(Character character) {
    const tileCollisionResolve = 3;
    if (!scene.tileWalkableAt(character.left, character.y)) {
      character.x += tileCollisionResolve;
    } else if (!scene.tileWalkableAt(character.right, character.y)) {
      character.x -= tileCollisionResolve;
    }
    if (!scene.tileWalkableAt(character.x, character.top)) {
      character.y += tileCollisionResolve;
    } else if (!scene.tileWalkableAt(character.x, character.bottom)) {
      character.y -= tileCollisionResolve;
    }
  }

  Projectile spawnProjectileOrb(Character src, {required int damage}) {
    return spawnProjectile(
      src: src,
      accuracy: 0,
      speed: 4.5,
      range: src.equippedRange,
      target: src.attackTarget,
      projectileType: ProjectileType.Orb,
      damage: damage,
    );
  }

  Projectile spawnArrow(Position src, {
    required int damage,
    double accuracy = 0,
    Collider? target,
    double? angle,
  }) {
    dispatch(GameEventType.Arrow_Fired, src.x, src.y);
    if (src is Character) {
      return spawnProjectile(
        src: src,
        accuracy: accuracy,
        speed: 7,
        range: src.equippedRange,
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

  Projectile spawnProjectile({
    required Position src,
    required double speed,
    required double range,
    required int projectileType,
    required int damage,
    double? angle = 0,
    double accuracy = 0,
    Collider? target,
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
    projectile.xv = velX(finalAngle + giveOrTake(accuracy), speed);
    projectile.yv = velY(finalAngle + giveOrTake(accuracy), speed);
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
    zombie.yv = 0;
    zombie.xv = 0;
    zombie.setSpeed(speed);
    return zombie;
  }

  AI _getAvailableZombie() {
    for (final zombie in zombies) {
      if (zombie.alive) continue;
      return zombie;
    }
    final zombie = AI(
      type: CharacterType.Zombie,
      x: 0,
      y: 0,
      health: 10,
      weapon: SlotType.Empty,
    );
    zombies.add(zombie);
    return zombie;
  }

  AI spawnRandomZombie({
    int health = 10,
    int damage = 1,
    int experience = 1,
    int team = Teams.none,
    double speed = RunSpeed.Regular,
  }) {
    if (scene.spawnPointZombies.isEmpty) throw ZombieSpawnPointsEmptyException();
    final spawnPoint = randomItem(scene.spawnPointZombies);
    return spawnZombie(
        x: spawnPoint.x,
        y: spawnPoint.y,
        team: team,
        health: health,
        damage: damage,
        speed: speed,
    );
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
  void dispatchV2(int type, Position position, {double angle = 0}) {
    dispatch(type, position.x, position.y, angle);
  }

  /// GameEventType
  void dispatch(int type, double x, double y, [double angle = 0]) {
    for (final player in players) {
      player.writeGameEvent(type, x, y, angle);
    }
  }

  void notifyPlayersDynamicObjectDestroyed(DynamicObject dynamicObject){
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
      if (zombieAITarget != null && zombieAITarget != zombie.objective &&
          (zombieAITarget.dead || !zombie.withinChaseRange(zombieAITarget))) {
        zombie.target = zombie.objective;
      }

      var targetDistance = 9999999.0;

      for (final structure in structures) {
        if (structure.dead) continue;
        if (onSameTeam(structure, zombie)) continue;
        if (!zombie.withinViewRange(structure)) continue;
        final npcDistance = zombie.getDistance(structure);
        if (npcDistance >= targetDistance) continue;
        setNpcTarget(zombie, structure);
        targetDistance = npcDistance;
      }

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

  void setNpcTarget(AI ai, Health value) {
    assert(!onSameTeam(ai, value));
    assert(value.alive);
    assert(ai.alive);
    ai.target = value;
  }

  void removeDisconnectedPlayers() {
    var playerLength = players.length;
    for (var i = 0; i < playerLength; i++) {
      final player = players[i];

      if (player.lastUpdateFrame++ < 100) continue;

      for (final npc in zombies) {
        npc.clearTargetIf(player);
      }
      players.removeAt(i);
      i--;
      playerLength--;

      if (status == GameStatus.Awaiting_Players) {
        cancelCountDown();
      }
      if (status == GameStatus.In_Progress) {
        onPlayerDisconnected(player);
      }
    }
  }

  void npcSetRandomDestination(AI ai, {int radius = 10}) {
    final node = scene.tileNodeAt(ai);
    if (!node.open) return;
    final minColumn = max(0, node.column - radius);
    final maxColumn = min(scene.numberOfColumns, node.column + radius);
    final minRow = max(0, node.row - radius);
    final maxRow = min(scene.numberOfRows, node.row + radius);
    final randomColumn = randomInt(minColumn, maxColumn);
    final randomRow = randomInt(minRow, maxRow);
    final randomTile = scene.nodes[randomRow][randomColumn];
    npcSetPathToTileNode(ai, randomTile);
  }

  void npcSetPathTo(AI ai, Position position) {
    npcSetPathToTileNode(ai, scene.tileNodeAt(position));
  }

  void npcSetPathToTileNode(AI ai, Node node) {
    pathFindDestination = node;
    pathFindAI = ai;
    pathFindSearchID++;
    ai.pathIndex = -1;
    scene.visitNodeFirst(scene.tileNodeAt(ai));
  }

  void _updateSpawnPointCollisions() {
    if (spawnPoints.isEmpty) return;
    for (var i = 0; i < players.length; i++) {
      final player = players[i];
      for (final spawnPoint in spawnPoints) {
        const collisionRadius = 20;
        if (diffOver(player.x, spawnPoint.x, collisionRadius)) continue;
        if (diffOver(player.y, spawnPoint.y, collisionRadius)) continue;
        for (final point in spawnPoint.game.spawnPoints) {
          if (point.game != this) continue;
          changeGame(player, spawnPoint.game);
          final xDiff = spawnPoint.x - player.x;
          final yDiff = spawnPoint.y - player.y;
          player.x = point.x + xDiff * 1.25;
          player.y = point.y + yDiff * 1.25;
          i--;
          break;
        }
        break;
      }
    }
  }

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
    final damage = character.equippedDamage;
    if (character.type == CharacterType.Zombie) {
      if (stateDuration != framePerformStrike) return;
      final attackTarget = character.attackTarget;
      if (attackTarget == null) return;
      applyHit(
          src: character,
          target: attackTarget,
          damage: damage,
      );
      character.attackTarget = null;
      return;
    }

    final equipped = character.equippedType;

    if (SlotType.isSword(equipped)) {
      if (stateDuration == 7) {
        dispatchV2(GameEventType.Sword_Woosh, character);
      }
    }

    if (equipped == SlotType.Handgun) {
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
        character.reduceEquippedAmount();
        spawnProjectile(
            src: character,
            accuracy: 0,
            speed: 12.0,
            range: character.equippedRange,
            projectileType: ProjectileType.Bullet,
            damage: damage,
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
        character.reduceEquippedAmount();
        final totalBullets = 4;
        for (int i = 0; i < totalBullets; i++) {
          spawnProjectile(
              src: character,
              accuracy: 0.1,
              speed: 12.0,
              range: character.equippedRange,
              projectileType: ProjectileType.Bullet,
              damage: damage,
          );
        }
      }
    }

    if (character.equippedTypeIsBow && stateDuration == 1) {
      dispatchV2(GameEventType.Draw_Bow, character);
    }

    if (stateDuration != framePerformStrike) return;

    if (character.equippedType == TechType.Staff) {
      spawnProjectileOrb(character, damage: damage);
      return;
    }

    if (character.equippedTypeIsBow) {
      dispatchV2(GameEventType.Release_Bow, character);
      spawnArrow(character, damage: damage, target: character.attackTarget);

      if (character is Player){
        final split = character.numberOfCardsOfType(CardType.Passive_Bow_Split);

        for (var i = 0; i < split; i++) {
          const offset = pi * 0.0625;
          spawnArrow(character, damage: damage, angle: character.angle + giveOrTake(offset));
        }
      }

      return;
    }
    if (character.equippedIsMelee) {
      final attackTarget = character.attackTarget;
      if (attackTarget != null) {
        if (attackTarget.collidable) {
          applyHit(src: character, target: attackTarget, damage: damage);
          return;
        } else {
          character.attackTarget = null;
        }
      }
      final zombieHit = physics.raycastHit(
          character: character,
          colliders: zombies,
          range: character.equippedRange);
      if (zombieHit != null) {
        applyHit(
          src: character,
          target: zombieHit,
          damage: damage,
        );
        return;
      }
      final dynamicObjectHit = physics.raycastHit(
          character: character,
          colliders: dynamicObjects,
          range: character.equippedRange);
      if (dynamicObjectHit != null) {
        applyHit(
          src: character,
          target: dynamicObjectHit,
          damage: damage,
        );
      }
      return;
    }
  }

  void updateStructures() {
    for (final structure in structures) {
      if (!structure.isTower) continue;
      if (structure.dead) continue;
      if (structure.cooldown > 0) {
        structure.cooldown--;
        continue;
      }
      for (final zombie in zombies) {
        if (zombie.dead) continue;
        if (onSameTeam(structure, zombie)) continue;
        if (!structure.withinRange(zombie)) continue;
        spawnArrow(structure, target: zombie, damage: 1);
        structure.cooldown = structure.attackRate;
        break;
      }
    }
  }

  void updateCollectables() {
    collectables.forEach((collectable) => collectable.update());
  }

  void updateDynamicObjects() {
    final dynamicObjects = scene.objectsDynamic;
    for (final dynamicObject in dynamicObjects) {
      if (dynamicObject.respawnDuration <= 0) continue;
      if (dynamicObject.respawnDuration-- > 1) continue;
      respawnDynamicObject(dynamicObject, health: 10);
    }
  }

  void respawnDynamicObject(DynamicObject dynamicObject, {required int health}){
    assert(health > 0);
    for (final player in players) {
      dynamicObject.health = health;
      dynamicObject.collidable = true;
      player.writeDynamicObjectSpawned(dynamicObject);
    }
  }
}

void playerInteract(Player player) {
  for (InteractableNpc npc in player.game.npcs) {
    npc.onInteractedWith(player);
    return;
  }
  for (StaticObject environmentObject in player.game.scene.objectsStatic) {
    if (environmentObject.type == ObjectType.House02) {}
    ;
  }
}

void playerSetAbilityTarget(Player player, double x, double y) {
  final ability = player.ability;
  if (ability == null) return;

  final distance = getHypotenuse(player.x - x, player.y - y);

  if (distance > ability.range) {
    double rotation = pi2 - angle2(player.x - x, player.y - y);
    player.abilityTarget.x = player.x + adj(rotation, ability.range);
    player.abilityTarget.y = player.y + opp(rotation, ability.range);
  } else {
    player.abilityTarget.x = x;
    player.abilityTarget.y = y;
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