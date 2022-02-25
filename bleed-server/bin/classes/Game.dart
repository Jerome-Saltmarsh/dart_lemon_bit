import 'dart:math';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/abs.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/hypotenuse.dart';
import 'package:lemon_math/randomInt.dart';
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
import '../common/configuration.dart';
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
import '../interfaces/HasSquad.dart';
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

final teams = _Teams();

typedef void OnKilled(Game game, Character src, Character by, int damage);

class _Teams {
  final west = 0;
  final east = 1;
}

class _GameEvents {
  List<OnKilled> onKilled = [];
}

// constants
const castFrame = 3;
const tileCollisionResolve = 3;
const framePerformStrike = 3;

// This should be OpenWorldScene
abstract class Game {
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
            ai: AI(),
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
    items.add(Item(type: randomItem(orbItemTypes), x: x, y: y));
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

  Character? getClosestEnemyZombie({
      required double x,
      required double y,
      required int team,
      required double radius
  }) {
    final top = y - radius - settings.radius.character;
    final bottom = y + radius + settings.radius.character;
    final left = x - radius - settings.radius.character;
    final right = x + radius + settings.radius.character;
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
      final zombieDistance = distanceV2From(zombie, x, y);
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
    final zombie = getClosestEnemyZombie(
        x: x, y: y, team: team, radius: settings.radius.cursor);
    final player = getClosestEnemyPlayer(x, y, team);

    if (zombie == null) {
      if (player == null) {
        return null;
      }
      return player;
    }
    if (player == null) {
      return zombie;
    }

    final zombieDistance = distanceV2From(zombie, x, y);
    final playerDistance = distanceV2From(player, x, y);
    return zombieDistance < playerDistance ? zombie : player;
  }

  void updateInProgress() {
    duration++;
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
    if (target.alive) {
      setCharacterState(target, CharacterState.Hurt);
      return;
    }
    // @on target killed
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

  void _characterStrike(Character character, Character target){
    if (!targetWithinStrikingRange(character, target)) return;
    characterFaceV2(character, target);
    // todo set performing to strike action
    setCharacterStatePerforming(character);
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
          npcSetPathTo(ai, target.x, target.y);
        }
      }
    }

    if (ai.pathIndex >= 0) {
      if (arrivedAtPath(ai)) {
        ai.pathIndex--;
        if (ai.pathIndex < 0) {
          character.state = CharacterState.Idle;
          return;
        }
      }
      // @on npc going to path
      characterFace(character, ai.destX, ai.destY);
      character.state = CharacterState.Running;
      return;
    }
    character.state = CharacterState.Idle;
  }

  void _updatePlayersAndNpcs() {

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
        dispatch(GameEventType.Clip_Empty, character.x, character.y);
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
        dispatch(GameEventType.Handgun_Fired, x, y);
        break;
      case WeaponType.Shotgun:
        character.xv += velX(character.aimAngle + pi, 1);
        character.yv += velY(character.aimAngle + pi, 1);
        for (int i = 0; i < settings.shotgunBulletsPerShot; i++) {
          spawnBullet(character);
        }
        Projectile bullet = projectiles.last;
        character.stateDuration = coolDown.shotgun;
        dispatch(GameEventType.Shotgun_Fired, x, y);
        break;
      case WeaponType.SniperRifle:
        Projectile bullet = spawnBullet(character);
        character.stateDuration = coolDown.sniperRifle;
        dispatch(GameEventType.SniperRifle_Fired, x, y);
        break;
      case WeaponType.AssaultRifle:
        Projectile bullet = spawnBullet(character);
        character.stateDuration = coolDown.assaultRifle;
        dispatch(GameEventType.MachineGun_Fired, x, y);
        break;
      default:
        break;
    }
  }

  void setCharacterStateRunning(Character character) {
    setCharacterState(character, CharacterState.Running);
  }

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

  void setCharacterStatePerforming(Character character){
    character.performing = character.ability;
    character.ability = null;
    setCharacterState(character, CharacterState.Performing);
  }

  void setCharacterState(Character character, CharacterState value) {
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
      case CharacterState.Hurt:
        character.stateDuration = 10;
        break;
      case CharacterState.Firing:
        _characterAttack(character);
        break;
      case CharacterState.Performing:
        character.stateDuration = settings.duration.strike;
        if (character is Player){
          final ability = character.performing;
          if (ability == null) break;
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
      if (objectDistanceFrom(player, x, y) > settings.radius.explosion)
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
        // set performing to strike
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
    dispatch(GameEventType.Arrow_Hit, character.x, character.y);
  }

  void applyStrike(Character src, Character target, int damage) {
    if (!enemies(src, target)) return;
    if (target.dead) return;
    applyDamage(src, target, damage);
    final angleBetweenSrcAndTarget = radiansV2(src, target);
    final healthPercentage = damage / target.maxHealth;
    characterFaceV2(target, src);
    applyForce(target, angleBetweenSrcAndTarget, healthPercentage * 1.5);

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
      _updateCharacterStateStriking(character);
      return;
    }
    switch (ability.type) {
      case AbilityType.Explosion:
        if (character.stateDuration == castFrame) {
          spawnExplosion(
              src: character,
              x: character.abilityTarget.x,
              y: character.abilityTarget.y);
          character.performing = null;
        }
        break;
      case AbilityType.Blink:
        if (character.stateDuration == castFrame) {
          dispatch(GameEventType.Teleported, character.x, character.y);
          character.x = character.abilityTarget.x;
          character.y = character.abilityTarget.y;
          dispatch(GameEventType.Teleported, character.x, character.y);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.Fireball:
        if (character.stateDuration == castFrame) {
          spawnFireball(character);
          character.performing = null;
          character.attackTarget = null;
        }
        break;
      case AbilityType.Split_Arrow:
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
    }

    if (character.previousState != character.state) {
      character.previousState = character.state;
      character.stateFrameCount = 0;
    }
  }

  void _updateCharacterStateRunning(Character character) {
    final speed = character.speed;
    character.x += adj(character.angle, speed);
    character.y += opp(character.angle, speed);
  }

  void updateCharacterTileCollision(Character character) {
    if (!scene.tileWalkableAt(character.left, character.top)) {
      character.x += tileCollisionResolve;
      character.y += tileCollisionResolve;
    }
    if (!scene.tileWalkableAt(character.right, character.top)) {
      character.x -= tileCollisionResolve;
      character.y += tileCollisionResolve;
    }
    if (!scene.tileWalkableAt(character.left, character.bottom)) {
      character.x += tileCollisionResolve;
      character.y -= tileCollisionResolve;
    }
    if (!scene.tileWalkableAt(character.right, character.bottom)) {
      character.x -= tileCollisionResolve;
      character.y -= tileCollisionResolve;
    }
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
        ai: AI(
          mode: NpcMode.Aggressive,
        ),
        health: settings.health.zombie,
        weapons: [Weapon(
          type: WeaponType.Unarmed,
          damage: 0,
          capacity: 0,
        )]);
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
    required int health,
    required int damage,
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

  void dispatchV2(GameEventType type, Vector2 position){
    dispatch(type, position.x, position.y);
  }

  void dispatch(GameEventType type, double x, double y,
      [double angle = 0]) {
    final event = _getAvailableGameEvent();
    event.type = type;
    event.x = x;
    event.y = y;
    event.angle = angle;
    event.frameDuration = 2;
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
    character.active = true;
    character.collidable = true;

    if (character is Player) {
      character.magic = character.maxMagic;
    }

    final spawnPoint = getNextSpawnPoint();
    if (spawnPoint != null){
      character.x = spawnPoint.x;
      character.y = spawnPoint.y;
    }
  }

  Vector2? getNextSpawnPoint() {
    if (scene.playerSpawnPoints.isEmpty) {
      throw Exception("player spawn points is empty (scene: '${scene.name}')");
    }
    spawnPointIndex = (spawnPointIndex + 1) % scene.playerSpawnPoints.length;
    return scene.playerSpawnPoints[spawnPointIndex];
  }

  void npcSetRandomDestination(AI ai, {int radius = 10}) {
    final node = scene.tileNodeAt(ai.x, ai.y);
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
    pathFindPrevious = null;
    pathFindSearchID++;
    ai.pathIndex = -1;
    scene.visitNode(node: scene.tileNodeAt(ai.x, ai.y));
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
        if (character.stateDuration != framePerformStrike){
          final attackTarget = character.attackTarget;
          if (attackTarget != null){
            applyStrike(character, attackTarget, character.damage);
            character.attackTarget = null;
          }
        }
    }

    if (character is Player) {

      if (character.stateDuration == 1){
        if (character.slots.weapon.isSword){
          dispatch(GameEventType.Sword_Woosh, character.x, character.y);
        }
      }

      if (character.stateDuration == framePerformStrike) {
        if (character.slots.weapon.isBow) {
          dispatch(GameEventType.Release_Bow, character.x, character.y);
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
  final ability = player.ability;
  if (ability == null) return;

  final distance = distanceBetween(player.x, player.y, x, y);

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
        type: AbilityType.Ice_Ring,
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
