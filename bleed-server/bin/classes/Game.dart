import 'dart:math';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/abs.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/hypotenuse.dart';
import 'package:lemon_math/randomItem.dart';

import '../bleed/zombie_health.dart';
import '../common/AbilityMode.dart';
import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/GameEventType.dart';
import '../common/GameStatus.dart';
import '../common/GameType.dart';
import '../common/ItemType.dart';
import '../common/PlayerEvent.dart';
import '../common/SlotType.dart';
import '../common/Tile.dart';
import '../common/WeaponType.dart';
import '../common/enums/Direction.dart';
import '../common/enums/ObjectType.dart';
import '../common/enums/ProjectileType.dart';
import '../common/enums/Shade.dart';
import '../constants.dart';
import '../constants/no_squad.dart';
import '../engine.dart';
import '../enums.dart';
import '../enums/npc_mode.dart';
import '../functions.dart';
import '../functions/applyForce.dart';
import '../functions/withinRadius.dart';
import '../interfaces/HasSquad.dart';
import '../language.dart';
import '../maths.dart';
import '../physics.dart';
import '../settings.dart';
import '../utilities.dart';
import 'Ability.dart';
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
import 'Weapon.dart';

const _none = -1;

final _Teams teams = _Teams();

class _Teams {
  final west = 0;
  final east = 1;
}

// This should be OpenWorldScene
abstract class Game {
  static int _id = 0;
  final String id = (_id++).toString();
  final Scene scene;

  // late bool started;
  late GameStatus status;
  GameType gameType;

  bool get countingDown => status == GameStatus.Counting_Down;

  bool get inProgress => status == GameStatus.In_Progress;

  bool get finished => status == GameStatus.Finished;

  bool get awaitingPlayers => status == GameStatus.Awaiting_Players;

  void cancelCountDown() {
    status = GameStatus.Awaiting_Players;
    countDownFramesRemaining = 0;
  }

  void onNpcKilled(Character npc, Character src) {}

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
  String compiled = "";
  String compiledTiles = "";
  String compiledEnvironmentObjects = "";
  bool debugMode = false;
  Map<int, StringBuffer> compiledTeamText = {};
  int countDownFramesRemaining = framesPerSecond * 3;

  int getTime();

  void onGameStarted() {}

  void onPlayerDeath(Player player) {}

  void onNpcObjectivesCompleted(Character npc) {}

  void updateNpcBehavior(Character npc) {}

  /// Returning true will cause the item to be removed
  bool onPlayerItemCollision(Player player, Item item) {
    return true;
  }

  void changeGame(Player player, Game to) {
    if (player.game == to) return;

    players.remove(player);

    for (Character zombie in player.game.zombies) {
      final ai = zombie.ai;
      if (ai == null) continue;
      if (ai.target != player) continue;
      ai.target = null;
    }

    to.players.add(player);
    player.game = to;
    player.sceneChanged = true;
  }

  int numberOfPlayersOnTeam(int team) {
    int count = 0;
    for (Player player in players) {
      if (!player.active) continue;
      if (player.team != team) continue;
      count++;
    }
    return count;
  }

  int get numberOfAlivePlayers {
    int playersRemaining = 0;
    for (Player player in players) {
      if (player.alive) playersRemaining++;
    }
    return playersRemaining;
  }

  void update() {}

  void onPlayerDisconnected(Player player) {}

  GameEvent _getAvailableGameEvent() {
    for (GameEvent gameEvent in gameEvents) {
      if (gameEvent.frameDuration <= 0) {
        gameEvent.frameDuration = 2;
        gameEvent.assignNewId();
        return gameEvent;
      }
    }
    GameEvent empty = GameEvent(GameEventType.Credits_Acquired, 0, 0, 0, 0);
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

    for (Vector2 crate in scene.crates) {
      crates.add(Crate(x: crate.x, y: crate.y));
    }

    for (final character in scene.characters) {
      if (character.type == CharacterType.Zombie) {
        zombies.add(Character(
            type: CharacterType.Zombie,
            x: character.x,
            y: character.y,
            health: 100,
            weapons: [
              Weapon(type: WeaponType.Unarmed, damage: 1, capacity: 0)
            ]));
      } else {
        npcs.add(InteractableNpc(
            name: "Bob",
            onInteractedWith: (Player player) {},
            x: character.x,
            y: character.y,
            health: 100,
            weapon: Weapon(
              type: WeaponType.HandGun,
              rounds: 10,
              capacity: 10,
              damage: 5,
            )));
      }
    }

    for (final environmentObject in scene.environment) {
      if (environmentObject.radius > 0) {
        colliders.add(Collider(environmentObject.x, environmentObject.y,
            environmentObject.radius));
      }
    }

    for (int row = 0; row < scene.rows; row++) {
      for (int column = 0; column < scene.columns; column++) {
        switch (scene.tiles[row][column]) {
          case Tile.ZombieSpawn:
            zombieSpawnPoints.add(getTilePosition(row, column));
            break;
          case Tile.RandomItemSpawn:
            break;
          default:
            break;
        }
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
const characterMaxFrames = 99;

extension GameFunctions on Game {
  void spawnRandomOrb(double x, double y) {
    items.add(Item(type: randomItem(orbTypes), x: x, y: y));
  }

  Vector2 getSceneCenter() =>
      getTilePosition(scene.rows ~/ 2, scene.columns ~/ 2);

  int getFirstAliveZombieEnemyIndex(int team) {
    for (int i = 0; i < zombies.length; i++) {
      if (zombies[i].dead) continue;
      if (zombies[i].team == team) continue;
      return i;
    }
    return -1;
  }

  int getFirstAlivePlayerEnemyIndex(int team) {
    for (int i = 0; i < players.length; i++) {
      if (players[i].dead) continue;
      if (players[i].team == team) continue;
      return i;
    }
    return -1;
  }

  Character? getClosestEnemyZombie(
      {required double x,
      required double y,
      required int team,
      required double radius}) {
    double top = y - radius - settings.radius.character;
    double bottom = y + radius + settings.radius.character;
    double left = x - radius - settings.radius.character;
    double right = x + radius + settings.radius.character;

    Character? closest = null;
    double distance = -1;
    for (Character zombie in zombies) {
      if (zombie.y < top) continue;
      if (zombie.y > bottom) break;
      if (zombie.x < left) continue;
      if (zombie.x > right) continue;
      if (zombie.team == team) continue;
      if (zombie.dead) continue;
      if (!zombie.active) continue;

      double zombieDistance = distanceV2From(zombie, x, y);
      if (closest == null || zombieDistance < distance) {
        closest = zombie;
        distance = zombieDistance;
        continue;
      }
    }
    return closest;
  }

  Character? getClosestEnemyPlayer(double x, double y, int team) {
    int i = getFirstAlivePlayerEnemyIndex(team);
    if (i == -1) return null;

    double top = y - settings.radius.cursor - settings.radius.character;
    double bottom = x + settings.radius.cursor + settings.radius.character;

    Character closest = players[i];
    num closestX = diff(x, closest.x);
    num closestY = diff(y, closest.y);
    num close = min(closestX, closestY);
    for (Character player in players) {
      if (player.team == team) continue;
      if (player.dead) continue;
      if (!player.active) continue;
      if (player.y < top) continue;
      if (player.y > bottom) break;
      num closestX2 = diff(x, player.x);
      num closestY2 = diff(y, player.y);
      num closes2 = min(closestX2, closestY2);
      if (closes2 < close) {
        closest = player;
        close = closes2;
      }
    }
    return closest;
  }

  Character? getClosestEnemy(double x, double y, int team) {
    Character? zombie = getClosestEnemyZombie(
        x: x, y: y, team: team, radius: settings.radius.cursor);
    Character? player = getClosestEnemyPlayer(x, y, team);

    if (zombie == null) {
      if (player == null) {
        return null;
      }
      return player;
    }
    if (player == null) {
      return zombie;
    }

    double zombieDistance = distanceV2From(zombie, x, y);
    double playerDistance = distanceV2From(player, x, y);
    return zombieDistance < playerDistance ? zombie : player;
  }

  void updateInProgress() {
    duration++;
    update();
    _updatePlayersAndNpcs();
    _updateCollisions();
    _updateProjectiles();
    _updateProjectiles(); // called twice to fix collision detection
    _updateAI();
    _updateGameEvents();
    _updateSpawnPointCollisions();
    _updateItems();
    _updateCharacterFrames();
    sortGameObjects();
  }

  void updateFrames(List<Character> character) {
    for (final character in character) {
      character.stateFrameCount =
          (character.stateFrameCount + 1) % characterMaxFrames;
    }
  }

  /// calculates if there is a wall between two objects
  bool isVisibleBetween(Vector2 a, Vector2 b) {
    double r = radiansV2(a, b);
    double d = distanceV2(a, b);
    double vX = adj(r, tileSize);
    double vY = opp(r, tileSize);
    int jumps = d ~/ tileSize;
    double x = a.x + vX;
    double y = a.y + vY;
    for (int i = 0; i < jumps; i++) {
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
    if (target.alive) return;
    final targetAI = target.ai;
    if (targetAI != null) {
      target.active = false;
      onNpcKilled(target, src);
    }

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

  void _characterStrike(Character character, Character target){
    if (!targetWithinStrikingRange(character, target)) return;
    characterFaceV2(character, target);
    setCharacterStateStriking(character);
    character.attackTarget = target;
  }

  void _characterRunAt(Character character, Vector2 target){
    characterFaceV2(character, target);
    setCharacterState(character, CharacterState.Running);
  }

  void _updateCharacterAI(Character character) {
    if (character.dead) return;
    if (character.busy) return;
    if (character.inactive) return;
    final ai = character.ai;
    if (ai == null) return;

    if (ai.objectives.isNotEmpty) {
      if (withinRadius(character, ai.objectives.last, 100)) {
        ai.objectives.removeLast();
        if (ai.objectives.isNotEmpty) {
          final next = ai.objectives.last;
          npcSetPathTo(ai, next.x, next.y);
        } else {
          onNpcObjectivesCompleted(character);
        }
      }
    }

    final target = ai.target;
    if (target != null) {
      switch (character.weapon.type) {
        case WeaponType.Unarmed:
          if (targetWithinStrikingRange(character, target)){
            _characterStrike(character, target);
            return;
          }
          final dis = cheapDistance(character, target);
          if (dis < 100) {
            _characterRunAt(character, target);
            return;
          }
          break;
        default:
          if (!targetWithinFiringRange(character, target)) break;
          if (!isVisibleBetween(character, target)) break;

          characterAimAt(character, target.x, target.y);
          setCharacterState(character, CharacterState.Firing);
          return;
      }

      // @on npc update find
      if (ai.mode == NpcMode.Aggressive) {
        if (engine.frame % 30 == 0) {
          ai.path =
              scene.findPath(character.x, character.y, target.x, target.y);
        }
        if (ai.path.length <= 1 &&
            !targetWithinStrikingRange(character, target)) {
          characterFaceV2(character, target);
          setCharacterState(character, CharacterState.Running);
          return;
        }
      }
    }

    if (ai.path.isNotEmpty) {
      if (arrivedAtPath(ai)) {
        ai.path.removeAt(0);
        if (ai.path.isEmpty) {
          character.state = CharacterState.Idle;
          return;
        }
      }
      // @on npc going to path
      characterFace(character, ai.path[0].x, ai.path[0].y);
      character.state = CharacterState.Running;
      return;
    }
    character.state = CharacterState.Idle;
  }

  void _updatePlayersPerSecond() {
    if (duration % framesPerSecond != 0) return;

    for (Player player in players) {
      if (player.dead) continue;
      player.ability1.update();
      player.ability2.update();
      player.ability3.update();
      player.ability4.update();

      if (player.ability1.cooldownRemaining > 0) {
        player.ability1.cooldownRemaining--;
        player.abilitiesDirty = true;
      }
      if (player.ability2.cooldownRemaining > 0) {
        player.ability2.cooldownRemaining--;
        player.abilitiesDirty = true;
      }
      if (player.ability3.cooldownRemaining > 0) {
        player.ability3.cooldownRemaining--;
        player.abilitiesDirty = true;
      }
      if (player.ability4.cooldownRemaining > 0) {
        player.ability4.cooldownRemaining--;
        player.abilitiesDirty = true;
      }
    }
  }

  void _updatePlayersAndNpcs() {
    _updatePlayersPerSecond();

    for (int i = 0; i < players.length; i++) {
      updatePlayer(players[i]);
      updateCharacter(players[i]);
    }

    for (int i = 0; i < zombies.length; i++) {
      updateCharacter(zombies[i]);
    }

    for (int i = 0; i < npcs.length; i++) {
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

    for (Player player in players) {
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        if (item.top > player.bottom) break;
        if (item.bottom < player.top) continue;
        if (item.right < player.left) continue;
        if (item.left > player.right) continue;
        if (onPlayerItemCollision(player, item)) {
          items.removeAt(i);
          i--;
        }
      }
    }
  }

  void sortGameObjects() {
    sortVertically(zombies);
    sortVertically(players);
    sortVertically(npcs);
    sortVertically(items);
    sortVertically(projectiles);
  }

  Player? findPlayerById(int id) {
    for (Player player in players) {
      if (player.id == id) return player;
    }
    return null;
  }

  void _characterAttack(Character character) {
    if (character.dead) return;
    if (character.busy) return;
    faceAimDirection(character);

    if (character is Player) {
      if (character.weapon.type != WeaponType.Unarmed &&
          character.weapon.rounds <= 0) {
        character.stateDuration = settings.coolDown.clipEmpty;
        dispatch(GameEventType.Clip_Empty, character.x, character.y, 0, 0);
        return;
      }
    }

    double d = 15;
    double x = character.x + adj(character.aimAngle, d);
    double y = character.y + opp(character.aimAngle, d) - 5;
    character.state = CharacterState.Firing;
    character.weapon.rounds--;

    switch (character.weapon.type) {
      case WeaponType.HandGun:
        Projectile bullet = spawnBullet(character);
        character.stateDuration = coolDown.handgun;
        dispatch(GameEventType.Handgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case WeaponType.Shotgun:
        character.xv += velX(character.aimAngle + pi, 1);
        character.yv += velY(character.aimAngle + pi, 1);
        for (int i = 0; i < settings.shotgunBulletsPerShot; i++) {
          spawnBullet(character);
        }
        Projectile bullet = projectiles.last;
        character.stateDuration = coolDown.shotgun;
        dispatch(GameEventType.Shotgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case WeaponType.SniperRifle:
        Projectile bullet = spawnBullet(character);
        character.stateDuration = coolDown.sniperRifle;
        dispatch(GameEventType.SniperRifle_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case WeaponType.AssaultRifle:
        Projectile bullet = spawnBullet(character);
        character.stateDuration = coolDown.assaultRifle;
        dispatch(GameEventType.MachineGun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      default:
        break;
    }
  }

  // kill character
  void setCharacterStateDead(Character character) {
    if (character.dead) return;
    character.state = CharacterState.Dead;
    character.collidable = false;
    character.stateFrameCount = duration;
    character.ai?.onDeath();

    if (character is Player) {
      dispatch(GameEventType.Player_Death, character.x, character.y);
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

  void setCharacterStateStriking(Character character){
    setCharacterState(character, CharacterState.Striking);
  }

  void setCharacterState(Character character, CharacterState value) {
    // @on character set state
    if (character.dead) return;
    if (character.state == value) return;
    if (value != CharacterState.Dead && character.busy) return;

    switch (value) {
      case CharacterState.Dead:
        setCharacterStateDead(character);
        return;
      case CharacterState.Changing:
        character.stateDuration = 10;
        break;
      case CharacterState.Firing:
        // @on character firing weapon
        if (character.weapon == WeaponType.Unarmed) {
          setCharacterState(character, CharacterState.Striking);
          return;
        }
        _characterAttack(character);
        break;
      case CharacterState.Striking:
        // @on character striking
        faceAimDirection(character);
        character.stateDuration = settings.duration.strike;
        break;
      case CharacterState.Performing:
        // TODO
        character.stateDuration = settings.duration.strike;
        break;
      default:
        break;
    }
    character.state = value;
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
        dispatch(GameEventType.Bullet_Hole, projectile.x, projectile.y, 0, 0);
        break;
      case ProjectileType.Fireball:
        spawnExplosion(src: projectile.owner, x: projectile.x, y: projectile.y);
        break;
      case ProjectileType.Arrow:
        break;
    }
  }

  void _updateProjectiles() {
    for (int i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      projectile.x += projectile.xv;
      projectile.y += projectile.yv;
      final target = projectile.target;
      if (target != null) {
        setVelocityTowards(projectile, target, projectile.speed);
      } else if (projectileDistanceTravelled(projectile) > projectile.range) {
        deactivateProjectile(projectile);
      }
    }

    for (int i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (projectile.collideWithEnvironment) continue;
      if (scene.bulletCollisionAt(projectile.x, projectile.y)) {
        deactivateProjectile(projectile);
      }
    }

    sortVertically(projectiles);
    checkProjectileCollision(zombies);
    checkProjectileCollision(players);

    for (int i = 0; i < projectiles.length; i++) {
      if (!projectiles[i].active) continue;
      if (!projectiles[i].collideWithEnvironment) continue;
      for (EnvironmentObject environmentObject in scene.environment) {
        if (!environmentObject.collidable) continue;
        if (!overlapping(projectiles[i], environmentObject)) continue;
        deactivateProjectile(projectiles[i]);
        break;
      }
    }
  }

  void breakCrate(Crate crate) {
    // @on break crate
    if (!crate.active) return;
    spawnRandomItem(crate.x, crate.y);
    crate.deactiveDuration = settings.crateDeactiveDuration;
    dispatch(GameEventType.Crate_Breaking, crate.x, crate.y);
  }

  void spawnRandomItem(double x, double y) {
    items.add(Item(type: randomItem(itemTypes), x: x, y: y));
  }

  void spawnFreezeCircle({required double x, required double y}) {
    applyFreezeTo(x: x, y: y, characters: zombies);
    applyFreezeTo(x: x, y: y, characters: players);
    dispatch(GameEventType.FreezeCircle, x, y, 0, 0);
  }

  void applyFreezeTo(
      {required double x,
      required double y,
      required List<Character> characters}) {
    for (Character character in characters) {
      if (!withinDistance(character, x, y, settings.radius.freezeCircle))
        continue;
      freeze(character);
    }
  }

  void freeze(Character character) {
    character.frozen = true;
    character.frozenDuration = settings.duration.frozen;
  }

  void spawnExplosion(
      {required Character src, required double x, required double y}) {
    dispatch(GameEventType.Explosion, x, y, 0, 0);

    for (Character zombie in zombies) {
      if (!withinDistance(zombie, x, y, settings.radius.explosion)) continue;
      double rotation = radiansBetween2(zombie, x, y);
      double magnitude = 10;
      applyForce(zombie, rotation + pi, magnitude);

      if (zombie.dead) continue;
      applyDamage(src, zombie, settings.damage.grenade);
    }

    for (Player player in players) {
      if (objectDistanceFrom(player, x, y) > settings.radius.explosion)
        continue;
      double rotation = radiansBetween2(player, x, y);
      double magnitude = 10;
      applyForce(player, rotation + pi, magnitude);

      if (player.alive) {
        changeCharacterHealth(player, -settings.damage.grenade);
      }
    }
  }

  bool sameTeam(Player a, Player b) {
    if (a == b) return true;
    if (a.team == noSquad) return false;
    if (b.team == noSquad) return false;
    return a.team == b.team;
  }

  void _updateAI() {
    for(final zombie in zombies){
      _updateCharacterAI(zombie);
    }

    // zombies.forEach(_updateCharacterAI);
    npcs.forEach(_updateCharacterAI);
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

    switch (player.state) {
      case CharacterState.Running:
        break;
    }
  }

  void checkProjectileCollision(List<Character> characters) {
    int s = 0;
    for (int i = 0; i < projectiles.length; i++) {
      final projectile = projectiles[i];
      if (!projectile.active) continue;
      final target = projectile.target;
      if (target != null) {
        if (withinRadius(projectile, target, settings.radius.character)){
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
    deactivateProjectile(projectile);
    applyStrike(projectile.owner, character, projectile.damage);
  }

  void applyStrike(Character src, Character target, int damage) {
    if (!enemies(src, target)) return;
    if (target.dead) return;
    applyDamage(src, target, damage);
    final angleBetweenSrcAndTarget = radiansBetween2(src, target.x, target.y);
    final healthPercentage = damage / target.maxHealth;
    applyForce(target, angleBetweenSrcAndTarget, healthPercentage);
    if (target.dead) {
      dispatch(GameEventType.Zombie_Killed, target.x, target.y,
          target.xv, target.yv);
    } else {
      dispatch(
          GameEventType.Zombie_Hit,
          target.x,
          target.y,
          velX(src.aimAngle, settings.knifeHitAcceleration * 2),
          velY(src.aimAngle, settings.knifeHitAcceleration * 2));
    }
  }

  void updateCharacterStatePerforming(Character character) {
    final ability = character.performing;
    if (ability == null) return;
    switch (ability.type) {
      case AbilityType.Explosion:
        final int castFrame = 3;
        if (character.stateDuration == castFrame) {
          spawnExplosion(
              src: character,
              x: character.abilityTarget.x,
              y: character.abilityTarget.y);
          character.performing = null;
        }
        break;
      case AbilityType.Blink:
        if (character.stateDuration == 3) {
          dispatch(GameEventType.Teleported, character.x, character.y);
          character.x = character.abilityTarget.x;
          character.y = character.abilityTarget.y;
          dispatch(GameEventType.Teleported, character.x, character.y);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.FreezeCircle:
        final int castFrame = 3;
        if (character.stateDuration == castFrame) {
          spawnFreezeCircle(
              x: character.abilityTarget.x, y: character.abilityTarget.y);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.Fireball:
        final int castFrame = 3;
        if (character.stateDuration == castFrame) {
          spawnFireball(character);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.Split_Arrow:
        final int castFrame = 3;
        if (character.stateDuration == castFrame) {
          Projectile arrow1 = spawnArrow(character, damage: character.damage);
          double angle = piSixteenth;
          arrow1.target = null;
          setProjectileAngle(arrow1, character.aimAngle - angle);
          Projectile arrow2 = spawnArrow(character, damage: character.damage);
          arrow2.target = null;
          Projectile arrow3 = spawnArrow(character, damage: character.damage);
          arrow3.target = null;
          setProjectileAngle(arrow3, character.aimAngle + angle);
          character.performing = null;
          character.attackTarget = null;
        }
        break;

      case AbilityType.Long_Shot:
        final int castFrame = 3;
        if (character.stateDuration == castFrame) {
          final int damageMultiplier = 3;
          spawnArrow(character, damage: character.damage * damageMultiplier)
              .range = ability.range;
          character.attackTarget = null;
          character.performing = null;
        }
        break;

      case AbilityType.Brutal_Strike:
        final int castFrame = 8;
        if (character.stateDuration == castFrame) {
          character.performing = null;
          const damageMultiplier = 2;
          for (final zombie in zombies) {
            if (distanceV2(zombie, character) < character.attackRange) {
              applyStrike(
                  character, zombie, character.damage * damageMultiplier);
            }
          }
          character.attackTarget = null;
          character.performing = null;
        }
        break;
      case AbilityType.Death_Strike:
        final int castFrame = 8;
        const damageMultiplier = 3;
        if (character.stateDuration == castFrame) {
          Character? attackTarget = character.attackTarget;
          if (attackTarget != null) {
            applyStrike(
                character, attackTarget, character.damage * damageMultiplier);
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

    if (abs(character.xv) > settings.minVelocity) {
      character.x += character.xv;
      character.y += character.yv;
      character.xv *= settings.velocityFriction;
      character.yv *= settings.velocityFriction;
    }

    if (character.frozenDuration > 0) {
      character.frozenDuration--;
      if (character.frozenDuration == 0) {
        character.frozen = false;
      }
    }

    if (character.dead) return;

    if (character.stateDuration > 0) {
      character.stateDuration--;
      if (character.stateDuration == 0) {
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
      case CharacterState.Striking:
        _updateCharacterStateStriking(character);
        break;
    }

    if (character.previousState != character.state) {
      character.previousState = character.state;
      character.stateFrameCount = 0;
    }
  }

  void _updateCharacterStateRunning(Character character) {
    switch (character.direction) {
      case Direction.Up:
        character.y -= character.speed;
        break;
      case Direction.UpRight:
        character.x += velX(piQuarter, character.speed);
        character.y += velY(piQuarter, character.speed);
        break;
      case Direction.Right:
        character.x += character.speed;
        break;
      case Direction.DownRight:
        character.x += velX(piQuarter, character.speed);
        character.y -= velY(piQuarter, character.speed);
        break;
      case Direction.Down:
        character.y += character.speed;
        break;
      case Direction.DownLeft:
        character.x -= velX(piQuarter, character.speed);
        character.y -= velY(piQuarter, character.speed);
        break;
      case Direction.Left:
        character.x -= character.speed;
        break;
      case Direction.UpLeft:
        character.x -= velX(piQuarter, character.speed);
        character.y += velY(piQuarter, character.speed);
        break;
    }
  }

  void updateCharacterTileCollision(Character character) {
    if (!scene.tileWalkableAt(character.left, character.top)) {
      character.x += 3;
      character.y += 3;
    }
    if (!scene.tileWalkableAt(character.right, character.top)) {
      character.x -= 3;
      character.y += 3;
    }
    if (!scene.tileWalkableAt(character.left, character.bottom)) {
      character.x += 3;
      character.y -= 3;
    }
    if (!scene.tileWalkableAt(character.right, character.bottom)) {
      character.x -= 3;
      character.y -= 3;
    }
  }

  void throwGrenade(Player player, double angle, double strength) {
    double speed = settings.grenadeSpeed * strength;
    Grenade grenade =
        Grenade(player, adj(angle, speed), opp(angle, speed), 0.8 * strength);
    grenades.add(grenade);
    delayed(() {
      grenades.remove(grenade);
      spawnExplosion(src: player, x: grenade.x, y: grenade.y);
    }, ms: settings.grenadeDuration);
  }

  Projectile spawnBullet(Character character) {
    return spawnProjectile(
        character: character,
        accuracy: getWeaponAccuracy(character.weapon.type),
        speed: getBulletSpeed(character.weapon.type),
        range: getWeaponRange(character.weapon.type),
        damage: character.weapon.damage,
        type: ProjectileType.Bullet);
  }

  Projectile spawnFireball(Character character) {
    return spawnProjectile(
        character: character,
        accuracy: 0,
        speed: settings.projectileSpeed.fireball,
        damage: 100,
        range: settings.range.firebolt,
        type: ProjectileType.Fireball);
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
    double spawnDistance = character.radius + 20;
    Projectile projectile = getAvailableProjectile();
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
    for (int i = 0; i < projectiles.length; i++) {
      if (projectiles[i].active) continue;
      return projectiles[i];
    }
    Projectile projectile = Projectile();
    projectiles.add(projectile);
    return projectile;
  }

  Character spawnZombie(
    double x,
    double y, {
    required int health,
    required int team,
    required int damage,
    List<Vector2>? objectives,
  }) {
    final zombie = _getAvailableZombie();
    zombie.damage = damage;
    zombie.team = team;
    zombie.active = true;
    zombie.state = CharacterState.Idle;
    zombie.stateDuration = 0;
    zombie.previousState = CharacterState.Idle;
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
        health: settings.health.zombie,
        weapons: [Weapon(
          type: WeaponType.Unarmed,
          damage: 0,
          capacity: 0,
        )]);
    zombie.ai = AI(zombie);
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

  Character spawnRandomZombie(
      {required int health, required int damage, int experience = 1}) {
    if (zombieSpawnPoints.isEmpty) throw ZombieSpawnPointsEmptyException();
    final spawnPoint = randomItem(zombieSpawnPoints);
    return spawnZombie(spawnPoint.x, spawnPoint.y,
        team: teams.east, health: health, damage: damage);
  }

  int get zombieCount {
    int count = 0;
    for (final zombie in zombies) {
      if (!zombie.alive) continue;
      count++;
    }
    return count;
  }

  void dispatch(GameEventType type, double x, double y,
      [double xv = 0, double yv = 0]) {
    GameEvent gameEvent = _getAvailableGameEvent();
    gameEvent.type = type;
    gameEvent.x = x;
    gameEvent.y = y;
    gameEvent.xv = xv;
    gameEvent.yv = yv;
    gameEvent.frameDuration = 2;
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
        if (zombie.team == player.team) continue;
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
    int initial = getFirstAliveZombieIndex();
    if (initial == _none) return;

    for (int i = 0; i < npcs.length; i++) {
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

    Character closest = zombies[j];
    num closestDistance = cheapDistance(closest, ai.character);
    for (int i = j + 1; i < zombies.length; i++) {
      if (!zombies[i].alive) continue;
      num distance2 = cheapDistance(zombies[i], ai.character);
      if (distance2 > closestDistance) continue;
      closest = zombies[i];
      closestDistance = distance2;
    }

    double range = getWeaponRange(ai.character.weapon.type);
    double actualDistance = distanceBetween(ai.character.x, ai.character.y, closest.x, closest.y);
    if (actualDistance > range) {
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
    if (ai.character.team == value.team && value.team != -1) {
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

  void updateNpcObjective(AI ai) {
    npcSetRandomDestination(ai);
  }

  void removeDisconnectedPlayers() {
    for (int i = 0; i < players.length; i++) {
      if (players[i].lastUpdateFrame < settings.framesUntilPlayerDisconnected)
        continue;

      print("removing disconnected player");
      Player player = players[i];
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

    if (character is Player) {
      character.magic = character.maxMagic;
    }

    Vector2 spawnPoint = getNextSpawnPoint();
    character.x = spawnPoint.x;
    character.y = spawnPoint.y;
    character.collidable = true;
  }

  Vector2 getNextSpawnPoint() {
    if (scene.playerSpawnPoints.isEmpty) {
      throw Exception("player spawn points is empty (scene: '${scene.name}')");
    }
    spawnPointIndex = (spawnPointIndex + 1) % scene.playerSpawnPoints.length;
    return scene.playerSpawnPoints[spawnPointIndex];
  }

  void npcSetRandomDestination(AI ai) {
    npcSetPathToTileNode(ai, getRandomOpenTileNode());
  }

  TileNode getRandomOpenTileNode() {
    while (true) {
      TileNode node = randomItem(randomItem(scene.tileNodes));
      if (!node.open) continue;
      return node;
    }
  }

  void npcSetPathTo(AI ai, double x, double y) {
    npcSetPathToTileNode(ai, scene.tileNodeAt(x, y));
  }

  void npcSetPathToTileNode(AI ai, TileNode node) {
    if (ai.path.isNotEmpty){
      final last = ai.path.last;
      final xDiff = diff(node.position.x, last.x);
      if (xDiff < 10){
        final yDiff = diff(node.position.y, last.y);
        if (yDiff < 10){
          return;
        }
      }
    }
    ai.path = scene.findPathNodes(scene.tileNodeAt(ai.character.x, ai.character.y), node);
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
    if (engine.frame % characterFramesChange == 0) {
      updateFrames(players);
      updateFrames(zombies);
      updateFrames(npcs);
    }
  }

  void _updateItems() {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      item.duration--;
      if (item.duration > 0) continue;
      items.removeAt(i);
    }
  }

  void _updateCharacterStateStriking(Character character) {
    if (character.type == CharacterType.Zombie){
        if (character.stateDuration == engine.framePerformStrike){
          final attackTarget = character.attackTarget;
          if (attackTarget != null){
            applyStrike(character, attackTarget, character.damage);
            character.attackTarget = null;
            final speed = 0.2;
            dispatch(GameEventType.Zombie_Strike, attackTarget.x, attackTarget.y,
                velX(character.aimAngle, speed), velY(character.aimAngle, speed));
          }
        }
    }

    if (character is Player) {
      if (character.stateDuration == engine.framePerformStrike) {
        if (character.slots.weapon.isBow) {
          spawnArrow(character, damage: character.slots.weapon.damage);
          character.attackTarget = character.attackTarget;
          return;
        }
        if (character.slots.weapon.isMelee) {
          final attackTarget = character.attackTarget;
          if (attackTarget != null) {
            applyStrike(character, attackTarget, character.damage);
            return;
          }
          final hit = physics.raycastHit(
              character: character,
              characters: zombies,
              range: character.slots.weapon.range);
          if (hit != null) {
            applyStrike(character, hit, character.damage);
          }
          return;
        }
      }
    }

    switch (character.type) {
      case CharacterType.Witch:
        if (character.stateDuration == 3 && character.attackTarget != null) {
          spawnBlueOrb(character);
          character.attackTarget = null;
        }
        break;
      case CharacterType.Archer:
        if (character.stateDuration == 3 && character.attackTarget != null) {
          spawnArrow(character, damage: character.damage);
          character.attackTarget = null;
        }
        break;
      case CharacterType.Swordsman:
        if (character.stateDuration == 6) {
          final attackTarget = character.attackTarget;
          if (attackTarget == null) {}
          if (attackTarget != null) {
            applyStrike(character, attackTarget, character.damage);
          }
        }
        break;
      default:
        break;
    }
  }
}

void applyCratePhysics(Crate crate, List<Character> characters) {
  for (Character character in characters) {
    if (!character.active) continue;
    if (diffOver(crate.x, character.x, radius.crate)) continue;
    if (diffOver(crate.y, character.y, radius.crate)) continue;
    double dis = distanceBetween(crate.x, crate.y, character.x, character.y);
    if (dis >= radius.crate) continue;
    double b = radius.crate - dis;
    double r = radiansBetween(crate.x, crate.y, character.x, character.y);
    character.x += adj(r, b);
    character.y += opp(r, b);
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

void changeWeapon(Player player, int index) {
  if (player.deadOrBusy) return;
  if (index < 0) return;
  if (index == player.equippedIndex) return;
  if (index >= player.weapons.length) return;
  player.equippedIndex = index;
  player.game.setCharacterState(player, CharacterState.Changing);
}

void playerSetAbilityTarget(Player player, double x, double y) {
  Ability? ability = player.ability;
  if (ability == null) return;

  double distance = distanceBetween(player.x, player.y, x, y);

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
  // @on set character type
  player.type = value;
  player.abilitiesDirty = true;
  player.level = 1;
  player.abilityPoints = 1;

  switch (value) {
    case CharacterType.Human:
      player.weapons = [
        Weapon(type: WeaponType.Unarmed, damage: 1, capacity: 0),
        Weapon(type: WeaponType.HandGun, damage: 1, capacity: 21),
        Weapon(type: WeaponType.Shotgun, damage: 1, capacity: 12),
        Weapon(type: WeaponType.SniperRifle, damage: 1, capacity: 8),
        Weapon(type: WeaponType.AssaultRifle, damage: 1, capacity: 100),
      ];
      break;
    case CharacterType.Zombie:
      break;
    case CharacterType.Witch:
      player.attackRange = 170;
      player.maxMagic = 100;
      player.magic = player.maxMagic;
      player.ability1 = Ability(
        type: AbilityType.Explosion,
        level: 0,
        cost: 60,
        range: 200,
        cooldown: 15,
        radius: settings.radius.explosion,
        mode: AbilityMode.Area,
      );
      player.ability2 = Ability(
        type: AbilityType.Blink,
        level: 0,
        cost: 10,
        range: 200,
        cooldown: 10,
        mode: AbilityMode.Directed,
      );
      player.ability3 = Ability(
        type: AbilityType.FreezeCircle,
        level: 0,
        cost: 10,
        range: 200,
        cooldown: 15,
        radius: settings.radius.explosion,
        mode: AbilityMode.Area,
      );
      player.ability4 = Ability(
        type: AbilityType.Fireball,
        level: 0,
        cost: 10,
        range: 200,
        cooldown: 25,
        mode: AbilityMode.Directed,
      );
      break;
    case CharacterType.Swordsman:
      player.attackRange = 50;
      player.maxMagic = 100;
      player.ability1 = Ability(
        type: AbilityType.Brutal_Strike,
        level: 0,
        cost: 10,
        range: player.attackRange,
        cooldown: 15,
        mode: AbilityMode.Targeted,
      );
      player.ability2 = IronShield(player);
      player.ability3 = Ability(
        type: AbilityType.Death_Strike,
        level: 0,
        cost: 10,
        range: player.attackRange,
        cooldown: 15,
        mode: AbilityMode.Activated,
      );
      player.ability4 = Ability(
        type: AbilityType.Explosion,
        level: 0,
        cost: 10,
        range: 200,
        cooldown: 15,
        mode: AbilityMode.Area,
      );
      break;
    case CharacterType.Archer:
      player.attackRange = 210;
      player.damage = 18;
      player.maxMagic = 100;
      player.ability1 = Ability(
        type: AbilityType.Split_Arrow,
        level: 0,
        cost: 40,
        range: 200,
        cooldown: 10,
        mode: AbilityMode.Directed,
      );
      player.ability2 = Dash(player);
      player.ability3 = Ability(
        type: AbilityType.Long_Shot,
        level: 0,
        cost: 40,
        range: 250,
        cooldown: 15,
        mode: AbilityMode.Targeted,
      );
      player.ability4 = Ability(
        type: AbilityType.Fireball,
        level: 0,
        cost: 70,
        range: 200,
        cooldown: 25,
        mode: AbilityMode.Directed,
      );
      break;
  }

  player.magic = player.maxMagic;
  player.health = player.maxHealth;
}

Character? getClosestEnemy({
  required double x,
  required double y,
  required int team,
  required double radius,
  required List<Character> characters,
}) {
  double top = y - radius;
  double bottom = y + radius;
  double left = x - radius;
  double right = x + radius;

  Character? closest = null;
  double distance = -1;
  for (Character character in characters) {
    if (character.y < top) continue;
    if (character.y > bottom) break;
    if (character.x < left) continue;
    if (character.x > right) continue;
    if (character.team == team) continue;
    if (character.dead) continue;
    if (!character.active) continue;

    double characterDistance = distanceV2From(character, x, y);
    if (closest == null || characterDistance < distance) {
      closest = character;
      distance = characterDistance;
      continue;
    }
  }
  return closest;
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
    return Player(game: this, type: CharacterType.Human, y: 500);
  }
}

class ZombieSpawnPointsEmptyException implements Exception {}
