import 'dart:math';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/abs.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/hypotenuse.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/randomItem.dart';

import '../bleed/zombie_health.dart';
import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/GameEventType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/GemSpawn.dart';
import '../common/ItemType.dart';
import '../common/OrbType.dart';
import '../common/PlayerEvent.dart';
import '../common/SlotType.dart';
import '../common/Tile.dart';
import '../common/configuration.dart';
import '../common/constants.dart';
import '../common/enums/ObjectType.dart';
import '../common/enums/ProjectileType.dart';
import '../common/enums/Shade.dart';
import '../constants.dart';
import '../engine.dart';
import '../enums.dart';
import '../enums/npc_mode.dart';
import '../functions.dart';
import '../functions/applyForce.dart';
import '../functions/withinRadius.dart';
import '../maths.dart';
import '../physics.dart';
import '../settings.dart';
import '../utilities.dart';
import 'Character.dart';
import 'Collider.dart';
import 'Crate.dart';
import 'EnvironmentObject.dart';
import 'GameEvent.dart';
import 'GameObject.dart';
import 'Grenade.dart';
import 'InteractableNpc.dart';
import 'Item.dart';
import 'Player.dart';
import 'Projectile.dart';
import 'Scene.dart';
import 'SpawnPoint.dart';
import 'TileNode.dart';

final teams = _Teams();

typedef void OnKilled(Game game, Character src, Character by, int damage);

class _Teams {
  final none = 0;
  final west = 1;
  final east = 2;
}

class _GameEvents {
  List<OnKilled> onKilled = [];
}

// constants
const _none = -1;
const castFrame = 3;
const tileCollisionResolve = 3;
const framePerformStrike = 10;
const gameEventDuration = 4;
const _aiWanderPauseDuration = 120;

// This should be OpenWorldScene
abstract class Game {

  final _cursorRadius = 50.0;
  final _characterRadius = 10.0;

  static int _id = 0;
  final String id = (_id++).toString();
  final Scene scene;

  // late bool started;
  late GameStatus status;
  GameType gameType;


  final _GameEvents events = _GameEvents();

  bool get countingDown => status == GameStatus.Counting_Down;

  bool get inProgress => status == GameStatus.In_Progress;

  bool get finished => status == GameStatus.Finished;

  bool get awaitingPlayers => status == GameStatus.Awaiting_Players;

  void cancelCountDown() {
    status = GameStatus.Awaiting_Players;
    countDownFramesRemaining = 0;
  }

  void onNpcKilled(Character npc, Character src) {}

  void onCharacterKilled(Character killed, Character by){

  }

  final List<Collider> colliders = [];
  final List<Item> items = [];
  final List<Vector2> zombieSpawnPoints = [];
  int shadeMax = Shade.Bright;
  int duration = 0;
  int teamSize = 1;
  int numberOfTeams = 2;
  List<Character> zombies = [];
  List<InteractableNpc> npcs = [];
  List<SpawnPoint> spawnPoints = [];
  List<Player> players = [];
  List<Projectile> projectiles = [];
  List<Grenade> grenades = [];
  List<GameEvent> gameEvents = [];
  List<Crate> crates = [];
  bool cratesDirty = false;
  int spawnPointIndex = 0;
  // String compiled = "";
  String compiledTiles = "";
  String compiledEnvironmentObjects = "";
  bool debugMode = false;
  Map<int, StringBuffer> compiledTeamText = {};
  int countDownFramesRemaining = engine.framesPerSecond * 3;

  /// In seconds
  int getTime();

  void onGameStarted() {}

  void onPlayerDeath(Player player) {}

  void onNpcObjectivesCompleted(Character npc) {}

  void updateNpcBehavior(Character npc) {}

  Vector2 getNextSpawnPoint() {
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
      final ai = zombie.ai;
      if (ai == null) continue;
      if (ai.target != player) continue;
      ai.target = null;
    }

    to.players.add(player);
    player.game = to;
    player.sceneChanged = true;
  }

  int get numberOfAlivePlayers {
    var playersRemaining = 0;
    for (final player in players) {
      if (player.alive) playersRemaining++;
    }
    return playersRemaining;
  }

  int get numberOfAliveZombies {
    var count = 0;
    for (final zombie in zombies) {
      if (zombie.alive) count++;
    }
    return count;
  }

  void update() {}

  void onPlayerDisconnected(Player player) {}

  GameEvent _getAvailableGameEvent() {
    for (final gameEvent in gameEvents) {
      if (gameEvent.frameDuration <= 0) {
        gameEvent.frameDuration = gameEventDuration;
        gameEvent.assignNewId();
        return gameEvent;
      }
    }
    final empty = GameEvent(
      type: GameEventType.Sword_Woosh,
      x: 0,
      y: 0,
    );
    gameEvents.add(empty);
    return empty;
  }

  Game(this.scene, {
      this.gameType = GameType.MMO,
      this.shadeMax = Shade.Bright,
      this.status = GameStatus.In_Progress
  }) {
    this.crates.clear();
    engine.onGameCreated(this);

    for (final crate in scene.crates) {
      crates.add(Crate(x: crate.x, y: crate.y));
    }

    for (final character in scene.characters) {
      if (character.type == CharacterType.Zombie) {
        zombies.add(Character(
            type: CharacterType.Zombie,
            x: character.x,
            y: character.y,
            health: 100,
            ai: AI(mode: NpcMode.Aggressive),
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
      colliders.add(
        Collider(
          environmentObject.x,
          environmentObject.y,
          environmentObject.radius
        )
      );
    }

    for (var rowIndex = 0; rowIndex < scene.rows; rowIndex++) {
      final row = scene.tiles[rowIndex];
      for (var columnIndex = 0; columnIndex < scene.columns; columnIndex++) {
        switch (row[columnIndex]) {
          case Tile.ZombieSpawn:
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

}

const secondsPerMinute = 60;
const minutesPerHour = 60;
const hoursPerDay = 24;
const secondsPerDay = secondsPerMinute * minutesPerHour * hoursPerDay;
const secondsPerFrame = 5;
const secondsPerHour = secondsPerMinute * minutesPerHour;
const characterFramesChange = 4;
const characterMaxFrames = 10;
final characterRadius = settings.radius.character;

extension GameFunctions on Game {
  void spawnRandomOrb(double x, double y) {
    items.add(Item(type: randomItem(orbItemTypes), x: x, y: y));
  }

  Vector2 getSceneCenter() =>
      getTilePosition(scene.rows ~/ 2, scene.columns ~/ 2);

  int getFirstAlivePlayerEnemyIndex(Character character) {
    final numberOfPlayers = players.length;
    for (var i = 0; i < numberOfPlayers; i++) {
      final player = players[i];
      if (player.dead) continue;
      if (sameTeam(character, player)) continue;
      return i;
    }
    return -1;
  }

  Character? getClosestEnemyZombie({
      required double x,
      required double y,
      required Character character,
      required double radius
  }) {
    final top = y - radius - characterRadius;
    final bottom = y + radius + characterRadius;
    final left = x - radius - characterRadius;
    final right = x + radius + characterRadius;
    Character? closest = null;
    var closestNull = true;
    var distance = -1.0;
    for (final zombie in zombies) {
      if (sameTeam(zombie, character)) continue;
      if (zombie.y < top) continue;
      if (zombie.y > bottom) break;
      if (zombie.x < left) continue;
      if (zombie.x > right) continue;
      if (zombie.dead) continue;
      if (!zombie.active) continue;
      final zombieDistance = diff(zombie.x, x) + diff(zombie.y, y);
      if (closestNull || zombieDistance < distance) {
        closest = zombie;
        distance = zombieDistance.toDouble();
        closestNull = false;
        continue;
      }
    }
    return closest;
  }

  Character? getClosestEnemyPlayer(double x, double y, Character character) {
    final aliveEnemyIndex = getFirstAlivePlayerEnemyIndex(character);
    if (aliveEnemyIndex == -1) return null;

    final top = y - _cursorRadius - settings.radius.character;
    final bottom = x + _cursorRadius + settings.radius.character;
    Character closest = players[aliveEnemyIndex];
    var closestX = diff(x, closest.x);
    var closestY = diff(y, closest.y);
    var close = min(closestX, closestY);
    for (final player in players) {
      // if (sameTeam(player, b)) continue;
      if (player.dead) continue;
      if (!player.active) continue;
      if (player.y < top) continue;
      if (player.y > bottom) break;
      var closestX2 = diff(x, player.x);
      var closestY2 = diff(y, player.y);
      var closes2 = min(closestX2, closestY2);
      if (closes2 >= close) continue;
      closest = player;
      close = closes2;
    }
    return closest;
  }

  Character? getClosestEnemy(double x, double y, Character character) {
    final zombie = getClosestEnemyZombie(
        x: x,
        y: y,
        character: character,
        radius: _cursorRadius,
    );
    final player = getClosestEnemyPlayer(x, y, character);

    if (zombie == null) {
      return player;
    }
    if (player == null) {
      return zombie;
    }

    final zombieDistance = diff(zombie.x, x) + diff(zombie.y, y);
    final playerDistance = diff(player.x, x) + diff(player.y, y);
    return zombieDistance < playerDistance ? zombie : player;
  }

  void updateInProgress() {
    duration++;

    if (duration % 15 == 0){
      updateInteractableNpcTargets();
      updateZombieTargets();
    }

    update();
    _updatePlayersAndNpcs();
    _updateCollisions();
    _updateProjectiles();
    _updateProjectiles(); // called twice to fix collision detection
    _updateGameEvents();
    _updateSpawnPointCollisions();
    _updateItems();
    _updateCharacterFrames();
    sortGameObjects();
  }

  void updateFrames(List<Character> character) {
    for (final character in character) {
      character.animationFrame =
          (character.animationFrame + 1) % characterMaxFrames;
    }
  }

  /// TODO Optimize
  /// calculates if there is a wall between two objects
  bool isVisibleBetween(Vector2 a, Vector2 b) {
    final angle = radiansV2(a, b);
    final distance = distanceV2(a, b);
    final vX = adj(angle, tileSize);
    final vY = opp(angle, tileSize);
    final jumps = distance ~/ tileSize;
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

  void applyDamage(Character src, Character target, int amount) {
    if (target.dead) return;
    if (target.invincible) return;
    changeCharacterHealth(target, -amount);

    if (target.alive) {
      if (target.type.isZombie){
        setCharacterState(target, CharacterState.Hurt);
      }
      return;
    }

    onCharacterKilled(target, src);

    if (src is Player) {
      src.gemSpawns.add(GemSpawn(x: target.x, y: target.y, type: OrbType.Ruby));
    }

    final targetAI = target.ai;
    if (targetAI != null) {
      target.active = false;
      onNpcKilled(target, src);
    }

    events.onKilled.forEach((onKilledHandler) {
      onKilledHandler(this, src, target, amount);
    });

    if (target.alive && targetAI != null) {
      if (targetAI.target == null) {
        targetAI.target = src;
      }
    }
  }

  void playerGainExperience(Player player, int experience) {
    if (player.level >= maxPlayerLevel) return;
    player.experience += experience;
    while (player.experience >= levelExperience[player.level]) {
      // on player level increased
      player.experience -= levelExperience[player.level];
      player.level++;
      player.abilityPoints++;
      player.events.add(PlayerEvent.Level_Up);
      player.maxHealth += settings.levelUpHealthIncrease;
      player.maxMagic += settings.levelUpMagicIncrease;
      player.health = player.maxHealth;
      player.magic = player.maxMagic;
      if (player.level >= maxPlayerLevel) {
        player.experience = 0;
        return;
      }
    }
  }

  void _characterAttack(Character character, Character target){
    if (!targetWithinAttackRange(character, target)) return;
    characterFaceV2(character, target);
    setCharacterStatePerforming(character);
    character.attackTarget = target;
  }

  void _characterRunAt(Character character, Vector2 target){
    characterFaceV2(character, target);
    setCharacterState(character, stateRunning);
  }

  int get someNumber {
    return 5;
  }

  void _updateCharacterAI(Character character) {
    if (character.deadOrBusy) return;
    if (character.inactive) return;
    final ai = character.ai;
    if (ai == null) return;

    final target = ai.target;
    if (target != null) {
      if (character.type.isZombie) {
        if (targetWithinAttackRange(character, target)){
          _characterAttack(character, target);
          return;
        }
        const runAtTargetDistance = 100;
        if (cheapDistance(character, target) < runAtTargetDistance) {
          _characterRunAt(character, target);
          return;
        }
      } else { // not zombie
        if (!targetWithinAttackRange(character, target)) return;
        if (!isVisibleBetween(character, target)) return;
        _characterAttack(character, target);
        return;
      }
    }


    if (ai.pathIndex >= 0) {
      if (ai.arrivedAtDest) {
        ai.pathIndex--;
        if (ai.pathIndex < 0) {
          character.state = stateIdle;
          return;
        }
      }
      // @on npc going to path
      characterFace(character, ai.destX, ai.destY);
      character.state = stateRunning;
      return;
    } else if (ai.mode == NpcMode.Aggressive && ai.idleDuration++ > _aiWanderPauseDuration){
      ai.idleDuration = 0;
      npcSetRandomDestination(ai);
    }

    character.state = stateIdle;
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

    for (final character in players) {
      for (final collider in colliders) {
        final combinedRadius = character.radius + collider.radius;
        if (diffOver(character.x, collider.x, combinedRadius)) continue;
        if (diffOver(character.y, collider.y, combinedRadius)) continue;
        final _distance = distanceV2(character, collider);
        if (_distance > combinedRadius) continue;
        final overlap = combinedRadius - _distance;
        final r = radiansV2(character, collider);
        character.x -= adj(r, overlap);
        character.y -= opp(r, overlap);
      }
    }
  }

  void _updateCollisions() {
    sortGameObjects();
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
  }

  void setCharacterStateRunning(Character character) {
    setCharacterState(character, stateRunning);
  }

  void setCharacterStateDead(Character character) {
    if (character.dead) return;
    character.state = CharacterState.Dead;
    character.collidable = false;
    character.ai?.onDeath();

    if (character is Player) {
      dispatchV2(GameEventType.Player_Death, character);
      onPlayerDeath(character);
    }

    for (final npc in zombies) {
      final npcAI = npc.ai;
      if (npcAI == null) continue;
      if (npcAI.target != character) continue;
      npcAI.target = null;
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

  void setCharacterStatePerforming(Character character){
    character.performing = character.ability;
    character.ability = null;
    setCharacterState(character, CharacterState.Performing);
  }

  void setCharacterState(Character character, CharacterState value) {
    if (character.dead) return;
    if (character.state == value) return;

    character.stateDuration = 0;
    character.animationFrame = 0;

    if (value == CharacterState.Dead){
      setCharacterStateDead(character);
      return;
    }

    if (value == CharacterState.Hurt) {
      const duration = 10;
      character.stateDurationRemaining = duration;
      character.state = value;
      return;
    }

    if (character.busy) return;

    switch (value) {
      case CharacterState.Changing:
        const duration = 10;
        character.stateDurationRemaining = duration;
        break;
      case CharacterState.Performing:
        const duration = 20;
        character.stateDurationRemaining = duration;
        if (character is Player) {
          final ability = character.performing;
          if (ability == null) {
            character.stateDurationRemaining = character.slots.weapon.type.duration;
            break;
          }
          if (character.magic < ability.cost) {
            character.ability = null;
            character.attackTarget = null;
            return;
          }
          character.magic -= ability.cost;
        }
        break;
      default:
        break;
    }
    character.state = value;
  }

  void setCharacterStateIdle(Character character) {
    const idle = CharacterState.Idle;
    setCharacterState(character, idle);
  }

  void changeCharacterHealth(Character character, int amount) {
    if (character.dead) return;
    character.health += amount;
    if (character.health > 0) return;
    setCharacterStateDead(character);
  }

  bool overlapping(GameObject a, GameObject b) {
    if (a.right < b.left) return false;
    if (a.left > b.right) return false;
    if (a.bottom < b.top) return false;
    if (a.top > b.bottom) return false;
    return true;
  }

  void deactivateProjectile(Projectile projectile) {
    if (!projectile.active) return;
    projectile.active = false;
    if (scene.waterAt(projectile.x, projectile.y)) return;
    switch (projectile.type) {
      case ProjectileType.Bullet:
        dispatch(GameEventType.Bullet_Hole, projectile.x, projectile.y);
        break;
      case ProjectileType.Fireball:
        spawnExplosion(src: projectile.owner, x: projectile.x, y: projectile.y);
        break;
      case ProjectileType.Arrow:
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
        setVelocityTowards(projectile, target, projectile.speed);
      } else if (projectile.overRange) {
        deactivateProjectile(projectile);
      }
    }
    projectilesLength = projectiles.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (projectile.collideWithEnvironment) continue;
      if (scene.projectileCollisionAt(projectile.x, projectile.y)) {
        deactivateProjectile(projectile);
      }
    }

    sortVertically(projectiles);
    checkProjectileCollision(zombies);
    checkProjectileCollision(players);
    final environments = scene.environment;
    projectilesLength = projectiles.length;

    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      if (!projectile.collideWithEnvironment) continue;

      final projectileLeft = projectile.left;
      final projectileTop = projectile.top;
      final projectileRight = projectile.right;
      final projectileBottom = projectile.bottom;

      for (final environmentObject in environments) {
        if (!environmentObject.collidable) continue;
        if (projectileBottom < environmentObject.top) continue;
        if (projectileLeft > environmentObject.right) continue;
        if (projectileRight < environmentObject.left) continue;
        if (projectileTop > environmentObject.bottom) break;
        deactivateProjectile(projectile);
        break;
      }
    }
  }

  void spawnFreezeRing({required Character src, int duration = 100, int damage = 1}){
    dispatchV2(GameEventType.FreezeCircle, src);
    for (final zombie in zombies) {
      if (zombie.dead) continue;
      if (!withinRadius(zombie, src, SpellRadius.Freeze_Ring)) continue;
      applyStrike(src, zombie, damage);
      zombie.frozenDuration += duration;
    }
  }

  void spawnExplosion({
    required Character src,
    required double x,
    required double y
  }) {
    dispatch(GameEventType.Explosion, x, y);
    for (final zombie in zombies) {
      if (!withinDistance(zombie, x, y, settings.radius.explosion)) continue;
      final rotation = radiansBetween2(zombie, x, y);
      final magnitude = 10.0;
      applyForce(zombie, rotation + pi, magnitude);

      if (zombie.dead) continue;
      applyDamage(src, zombie, settings.damage.grenade);
    }

    for (final player in players) {
      if (hypotenuse(player.x - x, player.y - y) > settings.radius.explosion)
        continue;
      final rotation = radiansBetween2(player, x, y);
      final magnitude = 10.0;
      applyForce(player, rotation + pi, magnitude);

      if (player.alive) {
        changeCharacterHealth(player, -settings.damage.grenade);
      }
    }
  }

  void updatePlayer(Player player) {
    player.lastUpdateFrame++;

    if (player.textDuration > 0) {
      player.textDuration--;
      if (player.textDuration == 0) {
        player.text = "";
      }
    }

    if (player.lastUpdateFrame > 5) {
      setCharacterStateIdle(player);
    }

    final aimTarget = player.aimTarget;
    if (aimTarget != null && aimTarget.dead){
      player.aimTarget = null;
    }

    final target = player.target;
    if (target == null) return;
    characterFaceV2(player, target);



    if (target is Character){
      if (target.dead) {
        player.target = null;
        return;
      }

      final ability = player.ability;

      if (ability != null){
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
    } else if (withinRadius(player, target, player.speed)){
        player.target = null;
        return;
    }
    setCharacterStateRunning(player);
  }

  void checkProjectileCollision(List<Character> characters) {
    int s = 0;
    final projectilesLength = projectiles.length;
    for (var i = 0; i < projectilesLength; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      final target = projectile.target;
      if (target != null) {
        if (withinRadius(projectile, target, _characterRadius)){
          handleProjectileHit(projectile, target);
          return;
        }
      }
      for (int j = s; j < characters.length; j++) {
        final character = characters[j];
        if (!character.active) continue;
        if (character.dead) continue;
        if (character.left > projectile.right) continue;
        if (projectile.left > character.right) continue;
        if (projectile.top > character.bottom) continue;
        if (projectile.bottom < character.top) continue;
        handleProjectileHit(projectile, character);
        break;
      }
    }
  }

  void handleProjectileHit(Projectile projectile, Character character) {
    projectile.active = false;
    applyStrike(projectile.owner, character, projectile.damage);
    dispatch(GameEventType.Arrow_Hit, character.x, character.y);
  }

  void applyStrike(Character src, Character target, int damage) {
    if (sameTeam(src, target)) return;
    if (target.dead) return;
    applyDamage(src, target, damage);
    final angleBetweenSrcAndTarget = radiansV2(src, target);
    final healthPercentage = damage / target.maxHealth;
    // if (target.type.isZombie){
    //   target.angle = radiansV2(target, src);
    // }
    final forceMultiplier = 3.0;
    applyForce(target, angleBetweenSrcAndTarget, healthPercentage * forceMultiplier);

    dispatch(
        GameEventType.Character_Struck,
        target.x,
        target.y,
        angleBetweenSrcAndTarget
    );

    if (target.dead) {
      if (target.type.isZombie){
        dispatch(
            GameEventType.Zombie_Killed,
            target.x,
            target.y,
            src.aimAngle
        );
      }
    }
  }

  void updateCharacterStatePerforming(Character character) {
    final ability = character.performing;
    if (ability == null) {
      _updateCharacterStateAttacking(character);
      return;
    }
    switch (ability.type) {
      case AbilityType.Explosion:
        if (character.stateDurationRemaining == castFrame) {
          spawnExplosion(
              src: character,
              x: character.abilityTarget.x,
              y: character.abilityTarget.y);
          character.performing = null;
        }
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
          spawnFireball(character);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.Split_Arrow:
        if (character.stateDurationRemaining == castFrame) {
          Projectile arrow1 = spawnArrow(character, damage: character.weapon.damage);
          double angle = piSixteenth;
          arrow1.target = null;
          setProjectileAngle(arrow1, character.aimAngle - angle);
          Projectile arrow2 = spawnArrow(character, damage: character.weapon.damage);
          arrow2.target = null;
          Projectile arrow3 = spawnArrow(character, damage: character.weapon.damage);
          arrow3.target = null;
          setProjectileAngle(arrow3, character.aimAngle + angle);
          character.performing = null;
          character.attackTarget = null;
        }
        break;

      case AbilityType.Long_Shot:
        if (character.stateDurationRemaining == castFrame) {
          final int damageMultiplier = 3;
          spawnArrow(character, damage: character.weapon.damage * damageMultiplier)
              .range = ability.range;
          character.attackTarget = null;
          character.performing = null;
        }
        break;

      case AbilityType.Brutal_Strike:
        final int castFrame = 8;
        if (character.stateDurationRemaining == castFrame) {
          character.performing = null;
          // const damageMultiplier = 2;
          for (final zombie in zombies) {
            // if (distanceV2(zombie, character) < character.attackRange) {
            //   applyStrike(
            //       character, zombie, character.weapon.damage * damageMultiplier);
            // }
          }
          character.attackTarget = null;
          character.performing = null;
        }
        break;
      case AbilityType.Death_Strike:
        final int castFrame = 8;
        const damageMultiplier = 3;
        if (character.stateDurationRemaining == castFrame) {
          Character? attackTarget = character.attackTarget;
          if (attackTarget != null) {
            applyStrike(
                character, attackTarget, character.weapon.damage * damageMultiplier);
          }
          character.attackTarget = null;
          character.performing = null;
        }
        break;
      default:
        break;
    }
  }

  void updateCharacter(Character character) {
    if (!character.active) return;

    _updateCharacterAI(character);

    if (abs(character.xv) > settings.minVelocity) {
      character.x += character.xv;
      character.y += character.yv;
      character.xv *= settings.velocityFriction;
      character.yv *= settings.velocityFriction;
    }

    if (character.dead) return;


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
        _updateCharacterStateRunning(character);
        break;

      case CharacterState.Performing:
        updateCharacterStatePerforming(character);
        break;
    }


    character.stateDuration++;
  }

  void _updateCharacterStateRunning(Character character) {
    final speed = character.speed;
    final angle = character.angle;
    character.x += adj(angle, speed);
    character.y += opp(angle, speed);
  }

  void updateCharacterTileCollision(Character character) {
    if (!scene.tileWalkableAt(character.left, character.y)) {
      character.x += tileCollisionResolve;
    } else if (!scene.tileWalkableAt(character.right, character.y)){
      character.x -= tileCollisionResolve;
    }
    if (!scene.tileWalkableAt(character.x, character.top)) {
      character.y += tileCollisionResolve;
    } else if (!scene.tileWalkableAt(character.x, character.bottom)){
      character.y -= tileCollisionResolve;
    }
  }

  Projectile spawnFireball(Character character) {
    return spawnProjectile(
        character: character,
        accuracy: 0,
        speed: settings.projectileSpeed.fireball,
        damage: 100,
        range: settings.range.firebolt,
        type: ProjectileType.Fireball,
        target: character.attackTarget,
    );
  }

  Projectile spawnBlueOrb(Character character) {
    dispatch(GameEventType.Blue_Orb_Fired, character.x, character.y);
    return spawnProjectile(
        character: character,
        accuracy: 0,
        speed: settings.projectileSpeed.fireball,
        damage: 1,
        range: settings.range.firebolt,
        target: character.attackTarget,
        type: ProjectileType.Blue_Orb);
  }

  void casteSlowingCircle(Character character, double x, double y) {}

  Projectile spawnArrow(Character character, {required int damage}) {
    dispatch(GameEventType.Arrow_Fired, character.x, character.y);
    return spawnProjectile(
        character: character,
        accuracy: 0,
        speed: settings.projectileSpeed.arrow,
        damage: damage,
        range: settings.range.arrow,
        target: character.attackTarget,
        type: ProjectileType.Arrow);
  }

  Projectile spawnProjectile({
    required Character character,
    required double accuracy,
    required double speed,
    required double range,
    required int damage,
    required ProjectileType type,
    Character? target,
  }) {
    final spawnDistance = character.radius + 20;
    final projectile = getAvailableProjectile();
    if (target != null && target.alive && target.active) {
      projectile.target = target;
    } else {
      projectile.target = null;
    }
    projectile.active = true;
    projectile.xStart = character.x + adj(character.aimAngle, spawnDistance);
    projectile.yStart = character.y + opp(character.aimAngle, spawnDistance);
    projectile.x = projectile.xStart;
    projectile.y = projectile.yStart;
    projectile.xv = velX(character.aimAngle + giveOrTake(accuracy), speed);
    projectile.yv = velY(character.aimAngle + giveOrTake(accuracy), speed);
    projectile.speed = hypotenuse(projectile.xv, projectile.yv);
    projectile.owner = character;
    projectile.range = range;
    projectile.damage = damage;
    projectile.type = type;
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
    zombie.active = true;
    zombie.state = CharacterState.Idle;
    zombie.stateDurationRemaining = 0;
    zombie.maxHealth = health;
    zombie.health = health;
    zombie.collidable = true;
    zombie.x = x + giveOrTake(radius.zombieSpawnVariation);
    zombie.y = y + giveOrTake(radius.zombieSpawnVariation);
    zombie.yv = 0;
    zombie.xv = 0;

    final zombieAI = zombie.ai;

    if (zombieAI != null){
      if (objectives != null) {
        zombieAI.objectives = objectives;
      } else {
        zombieAI.objectives = [];
      }
    }
    return zombie;
  }

  Character _getAvailableZombie() {
    for (int i = 0; i < zombies.length; i++) {
      if (zombies[i].active) continue;
      return zombies[i];
    }
    final zombie = Character(
        type: CharacterType.Zombie,
        x: 0,
        y: 0,
        ai: AI(
          mode: NpcMode.Aggressive,
        ),
        health: settings.health.zombie,
        weapon: SlotType.Empty,
        );
    zombies.add(zombie);
    return zombie;
  }

  Character spawnRandomZombieLevel(int level) {
    return spawnRandomZombie(
        damage: level,
        health: zombieHealth[clampInt(
          level,
          0,
          maxZombieLevel,
        )],
        experience: zombieExperience[clampInt(
          level,
          0,
          maxZombieLevel,
        )]);
  }

  Character spawnRandomZombie({
    int health = 10,
    int damage = 1,
    int experience = 1
  }) {
    if (zombieSpawnPoints.isEmpty) throw ZombieSpawnPointsEmptyException();
    final spawnPoint = randomItem(zombieSpawnPoints);
    return spawnZombie(
        x: spawnPoint.x,
        y: spawnPoint.y,
        team: teams.east,
        health: health,
        damage: damage
    );
  }

  int get zombieCount {
    int count = 0;
    for (final zombie in zombies) {
      if (!zombie.alive) continue;
      count++;
    }
    return count;
  }

  void dispatchV2(GameEventType type, Vector2 position, {double angle = 0}){
    dispatch(type, position.x, position.y, angle);
  }

  void dispatch(GameEventType type, double x, double y,
      [double angle = 0]) {
    final event = _getAvailableGameEvent();
    event.type = type;
    event.x = x;
    event.y = y;
    event.angle = angle * radiansToDegrees;
    event.frameDuration = gameEventDuration;
  }

  void updateZombieTargets() {
    for (final zombie in zombies) {
      if (zombie.dead) {
        continue;
      }
      final zombieAI = zombie.ai;
      if (zombieAI == null) continue;
      final zombieAITarget = zombieAI.target;
      if (zombieAITarget != null &&
          (zombieAITarget.dead || !withinChaseRange(zombieAI, zombieAITarget))) {
          zombieAI.target = null;
      }

      num targetDistance = 9999999.0;

      for (final otherZombie in zombies) {
        if (otherZombie.dead) continue;
        if (zombie.team == otherZombie.team) continue;
        if (!withinViewRange(zombieAI, otherZombie)) continue;
        final npcDistance = cheapDistance(zombie, otherZombie);
        if (npcDistance >= targetDistance) continue;
        if (!isVisibleBetween(zombie, otherZombie)) continue;
        setNpcTarget(zombieAI, otherZombie);
        targetDistance = npcDistance;
      }

      for (final player in players) {
        if (player.dead) continue;
        if (sameTeam(player, zombie)) continue;
        if (!withinViewRange(zombieAI, player)) continue;
        final npcDistance = cheapDistance(zombie, player);
        if (npcDistance >= targetDistance) continue;
        if (!isVisibleBetween(zombie, player)) continue;
        setNpcTarget(zombieAI, player);
        targetDistance = npcDistance;
        break;
      }
      final target = zombieAI.target;
      if (target != null){
        if (targetDistance > 100) {
          npcSetPathTo(zombieAI, target.x, target.y);
        }
      }
    }
  }

  bool withinViewRange(AI ai, Vector2 target) {
    return withinRadius(ai.character, target, ai.viewRange);
  }

  bool withinChaseRange(AI ai, Vector2 target) {
    return withinRadius(ai.character, target, ai.chaseRange);
  }

  num cheapDistance(Vector2 a, Vector2 b) {
    return diff(a.y, b.y) + diff(a.x, b.x);
  }

  void updateInteractableNpcTargets() {
    if (zombies.isEmpty) return;
    final initial = getFirstAliveZombieIndex();
    if (initial == _none) return;

    final npcsLength = npcs.length;
    for (var i = 0; i < npcsLength; i++) {
      final ai = npcs[i].ai;
      if (ai == null) continue;
      updateInteractableNpcTarget(ai, initial);
    }
  }

  int getFirstAliveZombieIndex() {
    for (int i = 0; i < zombies.length; i++) {
      if (zombies[i].alive) return i;
    }
    return _none;
  }

  void updateInteractableNpcTarget(AI ai, int j) {
    if (ai.mode == NpcMode.Ignore) return;

    final aiWeaponRange = ai.character.weapon.range;
    var closest = zombies[j];
    var closestDistance = distanceV2(closest, ai.character);
    final zombiesLength = zombies.length;
    for (var i = j + 1; i < zombiesLength; i++) {
      final zombie = zombies[i];
      if (!zombie.alive) continue;
      var distance2 = distanceV2(zombie, ai.character);
      if (distance2 > closestDistance) continue;
      closest = zombie;
      closestDistance = distance2;
    }
    final actualDistance = distanceV2(ai.character, closest);
    if (actualDistance > aiWeaponRange) {
      ai.clearTarget();
      ai.character.state = CharacterState.Idle;
    } else {
      setNpcTarget(ai, closest);
    }
  }

  void setNpcTarget(AI ai, Character value) {
    if (ai.character == value) {
      throw Exception("AI cannot target itself");
    }
    if (ai.character.team == value.team && value.team != 0) {
      throw Exception("Npc target same team");
    }
    if (value.dead) {
      throw Exception("Npc cannot target dead");
    }
    if (!value.active) {
      throw Exception("Npc cannot target deactive");
    }
    if (ai.character.dead) {
      throw Exception("Npc cannot set target because self is dead");
    }
    ai.target = value;
  }

  void removeDisconnectedPlayers() {
    for (var i = 0; i < players.length; i++) {
      final player = players[i];

      if (player.lastUpdateFrame++ < settings.framesUntilPlayerDisconnected)
        continue;

      for (final npc in zombies) {
        npc.ai?.clearTargetIf(player);
      }
      player.active = false;
      players.removeAt(i);
      engine.deregisterPlayer(player);
      i--;

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
    character.active = true;
    character.collidable = true;

    if (character is Player) {
      character.magic = character.maxMagic;
    }

    final spawnPoint = getNextSpawnPoint();
    character.x = spawnPoint.x;
    character.y = spawnPoint.y;
  }

  void npcSetRandomDestination(AI ai, {int radius = 10}) {
    final node = scene.tileNodeAt(ai.x, ai.y);
    if (!node.open) return;
    final minColumn = max(0, node.column - radius);
    final maxColumn = min(scene.columns, node.column + radius);
    final minRow = max(0, node.row - radius);
    final maxRow = min(scene.rows, node.row + radius);
    final randomColumn = randomInt(minColumn, maxColumn);
    final randomRow = randomInt(minRow, maxRow);
    final randomTile = scene.tileNodes[randomRow][randomColumn];
    npcSetPathToTileNode(ai, randomTile);
  }

  void npcSetPathTo(AI ai, double x, double y) {
    npcSetPathToTileNode(ai, scene.tileNodeAt(x, y));
  }

  void npcSetPathToTileNode(AI ai, TileNode node) {
    pathFindDestination = node;
    pathFindAI = ai;
    pathFindSearchID++;
    ai.pathIndex = -1;
    scene.visitNode(scene.tileNodeAt(ai.x, ai.y));
  }

  void _updateGameEvents() {
    for (int i = 0; i < gameEvents.length; i++) {
      if (gameEvents[i].frameDuration <= 0) continue;
      gameEvents[i].frameDuration--;
    }
  }

  void _updateSpawnPointCollisions() {
    for (int i = 0; i < players.length; i++) {
      Player player = players[i];
      for (SpawnPoint spawnPoint in spawnPoints) {
        if (diffOver(player.x, spawnPoint.x, settings.radius.spawnPoint))
          continue;
        if (diffOver(player.y, spawnPoint.y, settings.radius.spawnPoint))
          continue;
        for (SpawnPoint point in spawnPoint.game.spawnPoints) {
          if (point.game != this) continue;
          changeGame(player, spawnPoint.game);
          double xDiff = spawnPoint.x - player.x;
          double yDiff = spawnPoint.y - player.y;
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

  void _updateCharacterStateAttacking(Character character) {
    final stateDuration = character.stateDuration;

    if (character.type == CharacterType.Zombie) {
      if (stateDuration != framePerformStrike) return;
      final attackTarget = character.attackTarget;
      if (attackTarget == null) return;
      applyStrike(character, attackTarget, character.weapon.damage);
      character.attackTarget = null;
      return;
    }

    final weapon = character.slots.weapon;
    final weaponType = weapon.type;

    if (weaponType.isSword) {
      if (stateDuration == 1) {
        dispatchV2(GameEventType.Sword_Woosh, character);
      }
    }

    if (weaponType.isHandgun) {
        if (stateDuration == 1){
          if (weapon.amount <= 0) {
            dispatchV2(GameEventType.Clip_Empty, character);
            return;
          }
          dispatchV2(GameEventType.Handgun_Fired, character, angle: character.angle);
          return;
        }
        if (stateDuration == 2){
          if (weapon.amount <= 0){
            return;
          }
          weapon.amount--;
          spawnProjectile(
              character: character,
              accuracy: 0,
              speed: 12.0,
              range: weaponType.range,
              damage: weaponType.damage,
              type: ProjectileType.Bullet);
          return;
        }
      }

      if (weaponType.isShotgun) {
        if (stateDuration == 1){
          if (weapon.amount <= 0){
            dispatchV2(GameEventType.Ammo_Acquired, character);
            return;
          }
          dispatchV2(GameEventType.Shotgun_Fired, character);
          character.slots.weapon.amount--;
          final totalBullets = 4;
          for (int i = 0; i < totalBullets; i++){
            spawnProjectile(
                character: character,
                accuracy: 0.1,
                speed: 12.0,
                range: weaponType.range,
                damage: weaponType.damage,
                type: ProjectileType.Bullet);
          }
        }
      }

      if (weaponType.isBow){
        if (character.stateDuration == 1){
          dispatchV2(GameEventType.Draw_Bow, character);
        }
      }

      if (character.stateDuration == framePerformStrike) {
        if (weaponType.isBow) {
          dispatchV2(GameEventType.Release_Bow, character);
          spawnArrow(character, damage: weaponType.damage);
          character.attackTarget = character.attackTarget;
          return;
        }
        if (weaponType.isMelee) {
          final attackTarget = character.attackTarget;
          if (attackTarget != null) {
            applyStrike(character, attackTarget, character.weapon.damage);
            return;
          }
          final hit = physics.raycastHit(
              character: character,
              characters: zombies,
              range: weaponType.range);
          if (hit != null) {
            applyStrike(character, hit, character.weapon.damage);
          }
          return;
        }
      }
  }
}


// void applyCratePhysics(Crate crate, List<Character> characters) {
//   for (final character in characters) {
//     if (!character.active) continue;
//     if (diffOver(crate.x, character.x, radius.crate)) continue;
//     if (diffOver(crate.y, character.y, radius.crate)) continue;
//     final dis = approximateDistance(crate, character);
//     if (dis >= radius.crate) continue;
//     final b = radius.crate - dis;
//     final r = radiansBetween(crate.x, crate.y, character.x, character.y);
//     character.x += adj(r, b);
//     character.y += opp(r, b);
//   }
// }

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

  final distance = hypotenuse(player.x - x, player.y - y);

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
      timeInSeconds = scene.startHour! * secondsPerHour;
    }
    if (scene.secondsPerFrames != null) {
      secondsPerFrame = scene.secondsPerFrames!;
    }
  }

  @override
  void update() {
    timeInSeconds = (timeInSeconds + secondsPerFrame) % secondsPerDay;
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
