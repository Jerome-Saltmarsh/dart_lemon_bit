import 'dart:math';

import 'package:lemon_math/library.dart';

import '../common/MaterialType.dart';
import '../common/library.dart';
import '../engine.dart';
import '../enums.dart';
import '../enums/npc_mode.dart';
import '../functions.dart';
import '../functions/withinRadius.dart';
import '../maths.dart';
import '../physics.dart';
import '../settings.dart';
import '../utilities.dart';
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
  final structures = <Structure>[];
  final colliders = <Collider>[];
  final items = <Item>[];
  final zombieSpawnPoints = <Vector2>[];
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
  var compiledTiles = "";
  var compiledEnvironmentObjects = "";
  var debugMode = false;
  var countDownFramesRemaining = engine.framesPerSecond * 3;
  var disableCountDown = 0;
  late GameStatus status;
  final GameType gameType;
  final String id = (_id++).toString();
  final Scene scene;

  static int _id = 0;

  List<DynamicObject> get dynamicObjects => scene.dynamicObjects;

  bool get countingDown => status == GameStatus.Counting_Down;

  bool get inProgress => status == GameStatus.In_Progress;

  bool get finished => status == GameStatus.Finished;

  bool get awaitingPlayers => status == GameStatus.Awaiting_Players;

  int get numberOfAlivePlayers => countAlive(players);

  int get numberOfAliveZombies => countAlive(zombies);

  void cancelCountDown() {
    status = GameStatus.Awaiting_Players;
    countDownFramesRemaining = 0;
  }

  void onCharacterKilled(Character killed, dynamic by) {}

  void onDynamicObjectDestroyed(DynamicObject dynamicObject) {}

  /// In seconds
  int getTime();

  void onGameStarted() {}

  void onPlayerDeath(Player player) {}

  void onNpcObjectivesCompleted(Character npc) {}

  void updateNpcBehavior(Character npc) {}

  Position getNextSpawnPoint() {
    return getSceneCenter();
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
        this.gameType = GameType.MMO,
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
          mode: NpcMode.Aggressive,
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

    for (final environmentObject in scene.environment) {
      if (environmentObject.radius <= 0) continue;
      colliders.add(Collider(
          x: environmentObject.x,
          y: environmentObject.y,
          radius: environmentObject.radius));
    }

    for (var rowIndex = 0; rowIndex < scene.numberOfRows; rowIndex++) {
      final row = scene.tiles[rowIndex];
      for (var columnIndex = 0;
          columnIndex < scene.numberOfColumns;
          columnIndex++) {
        switch (row[columnIndex]) {
          case Tile.Zombie_Spawn:
            zombieSpawnPoints.add(getTilePosition(rowIndex, columnIndex));
            break;
          default:
            break;
        }
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
}

const secondsPerMinute = 60;
const minutesPerHour = 60;
const hoursPerDay = 24;
const secondsPerFrame = 5;

final characterRadius = settings.radius.character;

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
        colliders: characters,
        x: x,
        y: y,
        predicate: (other) => other.dead || sameTeam(other, character));
  }

  DynamicObject? getClosestDynamicObject(double x, double y) {
    return findClosestVector2(
        colliders: scene.dynamicObjects,
        x: x,
        y: y,
        predicate: (other) => !other.collidable);
  }

  Collider? getClosestEnemyCollider(double x, double y, Character character) {
    final zombie =
        getClosestEnemy(x: x, y: y, character: character, characters: zombies);
    final player =
        getClosestEnemy(x: x, y: y, character: character, characters: players);
    final dynamicObject = getClosestDynamicObject(x, y);
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

    final killed = target.dead;

    if (target is Character) {
      final isZombie = target.type.isZombie;

      if (killed) {
        onCharacterKilled(target, src);
        setCharacterStateDead(target);
        if (isZombie) {
          spawnCollectable(position: target, target: src, type: CollectableType.Gold, amount: 1);
          // spawnCollectable(position: target, target: src, type: CollectableType.Experience, amount: 1);
          // spawnCollectable(position: target, target: src, type: CollectableType.Experience, amount: 1);
        }
        return;
      }
      if (isZombie) {
        // spawnCollectable(position: target, target: src, type: CollectableType.Experience, amount: amount);
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

    if (killed && target is Structure) {
      target.collidable = false;
      final node = scene.tileNodeAt(target);
      node.open = true;
      node.obstructed = false;
    }

    if (target is DynamicObject) {

      switch (target.type) {
        case DynamicObjectType.Chest:
          dispatchV2(GameEventType.Object_Struck, target);
          break;
        case DynamicObjectType.Rock:
          dispatchV2(GameEventType.Rock_Struck, target);
          if (src is Player) {
            // final spawns = killed ? 3 : 1;
            spawnCollectable(position: target, target: src, type: CollectableType.Stone, amount: damage);
          }
          break;
        case DynamicObjectType.Tree:
          dispatchV2(GameEventType.Tree_Struck, target);
          if (src is Player) {
            spawnCollectable(position: target, target: src, type: CollectableType.Wood, amount: damage);
          }
          break;
      }

      if (killed) {
        target.collidable = false;
        target.respawnDuration = 150;
        if (target.type == DynamicObjectType.Pot) {
          dispatchV2(GameEventType.Pot_Destroyed, target);
        } else if (target.type == DynamicObjectType.Rock) {
          dispatchV2(GameEventType.Rock_Destroyed, target);
        } else if (target.type == DynamicObjectType.Tree) {
          dispatchV2(GameEventType.Tree_Destroyed, target);
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
        onDynamicObjectDestroyed(target);
      }
    }
  }

  void spawnCollectable({
    required Position position,
    required Position target,
    required int type,
    required int amount,
  }){
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
    } else if (ai.mode == NpcMode.Aggressive && ai.idleDuration++ > 120) {
      ai.idleDuration = 0;
      npcSetRandomDestination(ai);
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
    checkColliderCollision(players, colliders);
    checkColliderCollision(zombies, colliders);
    checkColliderCollision(players, scene.dynamicObjects);
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
    sortVertically(scene.dynamicObjects);
    sortVertically(structures);
  }

  void setCharacterStateRunning(Character character) {
    setCharacterState(character, CharacterState.Running);
  }

  void setCharacterStateDead(Character character) {
    if (character.dead) return;
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

    checkProjectileCollision(scene.environment);
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
      }
      for (var j = 0; j < collidersLength; j++) {
        final collider = colliders[j];
        if (!collider.collidable) continue;
        if (projectile.right < collider.left) continue;
        if (projectile.left > collider.right) continue;
        if (projectile.top > collider.bottom) continue;
        if (projectile.bottom < collider.top) continue;
        if (projectile.owner == collider) continue;
        if (target != null && sameTeam(projectile, collider)) continue;
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
          techType: projectile.type,
          level: projectile.level,
      );
    }
    dispatch(GameEventType.Arrow_Hit, collider.x, collider.y);
  }

  void applyHit({
    required dynamic src,
    required Collider target,
    required int techType,
    required int level,
  }) {
    if (!target.collidable) return;
    if (target is Character) {
      if (sameTeam(src, target)) return;
      if (target.dead) return;
    }

    final damage = target is Material ? calculateDamage(
        targetMaterialType: (target as Material).material,
        techType: techType,
        level: level
    ) : 0;

    if (target is Health) {
      final health = target as Health;
      applyDamage(src: src, target: health, amount: damage);
    }

    final angleBetweenSrcAndTarget = radiansV2(src, target);
    if (target is Velocity) {
      final velocity = target as Velocity;
      if (target is Health) {
         const forceMultiplier = 3.0;
         final health = target as Health;
         velocity.accelerate(angleBetweenSrcAndTarget, damage / health.maxHealth * forceMultiplier);
      } else {
        velocity.accelerate(angleBetweenSrcAndTarget, damage.toDouble());
      }
    }

    if (target is Character) {
      dispatchV2(
          GameEventType.Character_Struck,
          target,
          angle: angleBetweenSrcAndTarget
      );

      if (target.dead && target.type.isZombie) {
        dispatchV2(
          GameEventType.Zombie_Killed,
          target,
          angle: angleBetweenSrcAndTarget,
        );
      }
    }
  }

  void updateCharacterStatePerforming(Character character) {
    const castFrame = 3;
    final ability = character.performing;
    if (ability == null) {
      updateCharacterStateAttacking(character);
      return;
    }
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
      case AbilityType.Split_Arrow:
        if (character.stateDurationRemaining == castFrame) {
          Projectile arrow1 = spawnArrow(character);
          const piSixteenth = pi / 16.0;
          double angle = piSixteenth;
          arrow1.target = null;
          setProjectileAngle(arrow1, character.angle - angle);
          Projectile arrow2 = spawnArrow(character);
          arrow2.target = null;
          Projectile arrow3 = spawnArrow(character);
          arrow3.target = null;
          setProjectileAngle(arrow3, character.angle + angle);
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

  void casteSlowingCircle(Character character, double x, double y) {}

  Projectile spawnArrow(Position src, {Collider? target}) {
    dispatch(GameEventType.Arrow_Fired, src.x, src.y);

    if (src is Character) {
      return spawnProjectile(
        src: src,
        accuracy: 0,
        speed: settings.projectileSpeed.arrow,
        range: settings.range.arrow,
        target: src.attackTarget,
        angle: src.angle,
        techType: TechType.Bow,
        level: src.equippedLevel,
      );
    }

    return spawnProjectile(
      src: src,
      accuracy: 0,
      speed: settings.projectileSpeed.arrow,
      range: settings.range.arrow,
      target: target,
      techType: TechType.Bow,
      level: 1 // TODO for structures
    );
  }

  Projectile spawnProjectile({
    required Position src,
    required double speed,
    required double range,
    required int techType,
    required int level,
    double angle = 0,
    double accuracy = 0,
    Collider? target,
  }) {
    final projectile = getAvailableProjectile();
    if (src is Character) {
      angle = src.angle;
    }
    projectile.level = level;
    projectile.collidable = true;
    projectile.active = true;
    projectile.target = target;
    projectile.start.x = src.x;
    projectile.start.y = src.y;
    projectile.x = src.x;
    projectile.y = src.y;
    projectile.xv = velX(angle + giveOrTake(accuracy), speed);
    projectile.yv = velY(angle + giveOrTake(accuracy), speed);
    projectile.speed = speed;
    projectile.owner = src;
    projectile.range = range;
    projectile.type = techType;
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

  Character spawnZombie({
    required double x,
    required double y,
    required int health,
    required int team,
    required int damage,
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
    zombie.x = x + giveOrTake(radius.zombieSpawnVariation);
    zombie.y = y + giveOrTake(radius.zombieSpawnVariation);
    zombie.yv = 0;
    zombie.xv = 0;
    return zombie;
  }

  Character _getAvailableZombie() {
    for (final zombie in zombies) {
      if (zombie.alive) continue;
      return zombie;
    }
    final zombie = AI(
      type: CharacterType.Zombie,
      x: 0,
      y: 0,
      mode: NpcMode.Aggressive,
      health: settings.health.zombie,
      weapon: SlotType.Empty,
    );
    zombies.add(zombie);
    return zombie;
  }

  Character spawnRandomZombie({
    int health = 10,
    int damage = 1,
    int experience = 1,
    int team = Teams.none,
  }) {
    if (zombieSpawnPoints.isEmpty) throw ZombieSpawnPointsEmptyException();
    final spawnPoint = randomItem(zombieSpawnPoints);
    return spawnZombie(
        x: spawnPoint.x,
        y: spawnPoint.y,
        team: team,
        health: health,
        damage: damage);
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
      player.onGameEvent(type, x, y, angle);
    }
  }

  void updateZombieTargets() {
    for (final zombie in zombies) {
      if (zombie.dead) continue;
      final zombieAITarget = zombie.target;
      if (zombieAITarget != null &&
          (zombieAITarget.dead || !zombie.withinChaseRange(zombieAITarget))) {
        zombie.target = null;
      }

      num targetDistance = 9999999.0;

      for (final otherZombie in zombies) {
        if (otherZombie.dead) continue;
        if (zombie.team == otherZombie.team) continue;
        if (!zombie.withinViewRange(otherZombie)) continue;
        final npcDistance = zombie.getDistance(otherZombie);
        if (npcDistance >= targetDistance) continue;
        if (!isVisibleBetween(zombie, otherZombie)) continue;
        setNpcTarget(zombie, otherZombie);
        targetDistance = npcDistance;
      }

      for (final player in players) {
        if (player.dead) continue;
        if (sameTeam(player, zombie)) continue;
        if (!zombie.withinViewRange(player)) continue;
        final npcDistance = zombie.getDistance(player);
        if (npcDistance >= targetDistance) continue;
        setNpcTarget(zombie, player);
        targetDistance = npcDistance;
        break;
      }
      final target = zombie.target;
      if (target != null) {
        if (targetDistance > 100) {
          npcSetPathTo(zombie, target);
        }
      }
    }
  }

  void updateInteractableNpcTargets() {
    for (final npc in npcs) {
      if (npc.mode == NpcMode.Ignore) return;
      Character? closest;
      var closestDistance = 99999.0;
      for (final zombie in zombies) {
        if (!zombie.alive) continue;
        if (sameTeam(npc, zombie)) continue;
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

  void setNpcTarget(AI ai, Character value) {
    assert(!sameTeam(ai, value));
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

  void revive(Character character) {
    character.state = CharacterState.Idle;
    character.health = character.maxHealth;
    character.collidable = true;

    if (character is Player) {
      character.magic = character.maxMagic;
    }

    final spawnPoint = getNextSpawnPoint();
    character.x = spawnPoint.x;
    character.y = spawnPoint.y;
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
    final randomTile = scene.tileNodes[randomRow][randomColumn];
    npcSetPathToTileNode(ai, randomTile);
  }

  void npcSetPathTo(AI ai, Position position) {
    npcSetPathToTileNode(ai, scene.tileNodeAt(position));
  }

  void npcSetPathToTileNode(AI ai, TileNode node) {
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

  void updateCharacterStateAttacking(Character character) {
    const framePerformStrike = 10;
    final stateDuration = character.stateDuration;

    if (character.type == CharacterType.Zombie) {
      if (stateDuration != framePerformStrike) return;
      final attackTarget = character.attackTarget;
      if (attackTarget == null) return;
      applyHit(
          src: character,
          target: attackTarget,
          techType: character.equipped,
          level: character.equippedLevel,
      );
      character.attackTarget = null;
      return;
    }

    final equipped = character.equipped;

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
            techType: TechType.Handgun,
            level: character.equippedLevel,
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
              techType: TechType.Shotgun,
              level: character.equippedLevel,
          );
        }
      }
    }

    if (character.equippedTypeIsBow) {
      if (character.stateDuration == 1) {
        dispatchV2(GameEventType.Draw_Bow, character);
      }
    }

    if (character.stateDuration == framePerformStrike) {
      if (character.equippedTypeIsBow) {
        dispatchV2(GameEventType.Release_Bow, character);
        spawnArrow(character);
        character.attackTarget = character.attackTarget;
        return;
      }
      if (character.equippedIsMelee) {
        final attackTarget = character.attackTarget;
        if (attackTarget != null) {
          if (attackTarget.collidable) {
            applyHit(
                src: character,
                target: attackTarget,
                techType: character.equipped,
                level: character.equippedLevel
            );
            return;
          } else {
            character.attackTarget = null;
          }
        }
        final zombieHit = physics.raycastHit(
            character: character, colliders: zombies, range: character.equippedRange);
        if (zombieHit != null) {
          applyHit(
              src: character,
              target: zombieHit,
              techType: character.equipped,
              level: character.equippedLevel
          );
          return;
        }
        final dynamicObjectHit = physics.raycastHit(
            character: character, colliders: dynamicObjects, range: character.equippedRange);
        if (dynamicObjectHit != null) {
          applyHit(
              src: character,
              target: dynamicObjectHit,
              techType: character.equipped,
              level: character.equippedLevel,
          );
        }
        return;
      }
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
        if (sameTeam(structure, zombie)) continue;
        if (!structure.withinRange(zombie)) continue;
        spawnArrow(structure, target: zombie);
        structure.cooldown = structure.attackRate;
        break;
      }
    }
  }

  void updateCollectables() {
    collectables.forEach((collectable) => collectable.update());
  }

  void updateDynamicObjects() {
    final dynamicObjects = scene.dynamicObjects;
    for (final dynamicObject in dynamicObjects) {
      if (dynamicObject.respawnDuration <= 0) continue;
      if (dynamicObject.respawnDuration-- > 1) continue;
      dynamicObject.collidable = true;
      dynamicObject.health = 12;
    }
  }
}

void playerInteract(Player player) {
  for (InteractableNpc npc in player.game.npcs) {
    if (diffOver(npc.x, player.x, radius.interact)) continue;
    if (diffOver(npc.y, player.y, radius.interact)) continue;
    npc.onInteractedWith(player);
    return;
  }

  for (EnvironmentObject environmentObject in player.game.scene.environment) {
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

void selectCharacterType(Player player, CharacterType value) {
  player.type = value;
  player.level = 1;
  player.abilityPoints = 1;
  player.magic = player.maxMagic;
  player.health = player.maxHealth;
}

class CustomGame extends Game {
  int timeInSeconds = calculateTime(hour: 12);
  int secondsPerFrame = 1;

  CustomGame(Scene scene) : super(scene) {
    if (scene.startHour != null) {
      // timeInSeconds = scene.startHour! * secondsPerHour;
    }
    if (scene.secondsPerFrames != null) {
      secondsPerFrame = scene.secondsPerFrames!;
    }
  }

  @override
  void update() {
    // timeInSeconds = (timeInSeconds + secondsPerFrame) % secondsPerDay;
  }

  @override
  int getTime() {
    return timeInSeconds;
  }

  Player playerJoin() {
    return Player(game: this, y: 500, weapon: SlotType.Empty);
  }
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
      return 0;
    case MaterialType.Wood:
      if (techType == TechType.Pickaxe) return 1;
      if (techType == TechType.Unarmed) return 1;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      if (techType == TechType.Axe) return level + 1;
      return 0;
    case MaterialType.Plant:
      if (techType == TechType.Pickaxe) return 1;
      if (techType == TechType.Unarmed) return 1;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      return 0;
    case MaterialType.Flesh:
      if (techType == TechType.Pickaxe) return level;
      if (techType == TechType.Unarmed) return level;
      if (techType == TechType.Shotgun) return level;
      if (techType == TechType.Handgun) return level;
      if (techType == TechType.Bow) return level;
      if (techType == TechType.Sword) return level;
      if (techType == TechType.Axe) return level;
      return 0;
    case MaterialType.Metal:
      if (techType == TechType.Pickaxe) return level;
      if (techType == TechType.Unarmed) return level;
      if (techType == TechType.Axe) return level;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      return 0;
    case MaterialType.Other:
      if (techType == TechType.Pickaxe) return level;
      if (techType == TechType.Unarmed) return level;
      if (techType == TechType.Shotgun) return 0;
      if (techType == TechType.Handgun) return 0;
      if (techType == TechType.Bow) return 0;
      return 0;
    default:
      return 0;
  }
}