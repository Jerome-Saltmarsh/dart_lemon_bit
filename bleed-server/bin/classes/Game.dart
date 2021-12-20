import 'dart:math';

import 'package:lemon_math/abs.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/diff_under.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/hypotenuse.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/randomItem.dart';

import '../bleed/zombie_health.dart';
import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/CollectableType.dart';
import '../common/GameEventType.dart';
import '../common/ItemType.dart';
import '../common/PlayerEvent.dart';
import '../common/Tile.dart';
import '../common/WeaponType.dart';
import '../common/classes/Vector2.dart';
import '../common/enums/Direction.dart';
import '../common/enums/ObjectType.dart';
import '../common/enums/ProjectileType.dart';
import '../common/enums/Shade.dart';
import '../compile.dart';
import '../constants.dart';
import '../constants/no_squad.dart';
import '../enums.dart';
import '../enums/npc_mode.dart';
import '../exceptions/ZombieSpawnPointsEmptyException.dart';
import '../functions/applyForce.dart';
import '../functions/insertionSort.dart';
import '../functions/withinRadius.dart';
import '../games/world.dart';
import '../global.dart';
import '../interfaces/HasSquad.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import '../update.dart';
import '../utils.dart';
import '../utils/game_utils.dart';
import 'Ability.dart';
import 'Character.dart';
import 'Collectable.dart';
import 'Collider.dart';
import 'Crate.dart';
import 'EnvironmentObject.dart';
import 'GameEvent.dart';
import 'GameObject.dart';
import 'Grenade.dart';
import 'InteractableNpc.dart';
import 'Item.dart';
import 'Npc.dart';
import 'Player.dart';
import 'Projectile.dart';
import 'Scene.dart';
import 'SpawnPoint.dart';
import 'TileNode.dart';
import 'Weapon.dart';

const _none = -1;

enum Teams {
  Good,
  Bad,
}

// This should be OpenWorldScene
abstract class Game {
  static int _id = 0;
  final String id = (_id++).toString();
  final Scene scene;

  late bool started;

  /// Used to constrain the brightness of a level
  /// For example a cave which is very dark even during day time
  /// or a dark forest
  Shade shadeMax = Shade.Bright;
  int duration = 0;
  List<Npc> zombies = [];
  List<InteractableNpc> npcs = [];
  List<SpawnPoint> spawnPoints = [];
  List<Player> players = [];
  List<Projectile> projectiles = [];
  List<Grenade> grenades = [];
  List<GameEvent> gameEvents = [];
  List<Crate> crates = [];

  final List<Collider> colliders = [];
  final List<Collectable> collectables = [];
  final List<Vector2> playerSpawnPoints = [];
  final List<Item> items = [];
  int spawnPointIndex = 0;
  final List<Vector2> zombieSpawnPoints = [];
  String compiled = "";
  String compiledTiles = "";
  String compiledEnvironmentObjects = "";
  bool compilePaths = false;

  void onGameStarted() {}

  void updateNpcBehavior(Npc npc) {}

  void changeGame(Player player, Game to) {
    if (player.game == to) return;

    players.remove(player);

    for (Npc zombie in player.game.zombies) {
      if (zombie.target == player) {
        zombie.clearTarget();
      }
    }

    to.players.add(player);
    player.game = to;
    player.sceneChanged = true;
  }

  int numberOfPlayersInSquad(int squad) {
    int count = 0;
    for (Player player in players) {
      if (!player.active) continue;
      if (player.team != squad) continue;
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

  void update();

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

  Game(this.scene, {this.shadeMax = Shade.Bright, this.started = true}) {
    this.crates.clear();
    global.onGameCreated(this);

    for (Vector2 crate in scene.crates) {
      crates.add(Crate(x: crate.x, y: crate.y));
    }

    for (EnvironmentObject environmentObject in scene.environment) {
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
          case Tile.PlayerSpawn:
            playerSpawnPoints.add(getTilePosition(row, column));
            break;
          case Tile.RandomItemSpawn:
            Vector2 tilePosition = getTilePosition(row, column);
            collectables.add(Collectable(
                tilePosition.x, tilePosition.y, randomCollectableType));
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
  void updateAndCompile() {
    // @on update game
    duration++;
    update();
    _updatePlayersAndNpcs();
    _updateCollisions();
    _updateProjectiles();
    _updateProjectiles(); // called twice to fix collision detection
    _updateNpcs();
    // _updateGrenades();
    // _updateCollectables();
    _updateGameEvents();
    // _updateCrates();
    _updateSpawnPointCollisions();

    if (frame % characterFramesChange == 0) {
      updateFrames(players);
      updateFrames(zombies);
      updateFrames(npcs);
    }
    compileGame(this);
  }

  void updateFrames(List<Character> character) {
    for (Character character in character) {
      character.stateFrameCount =
          (character.stateFrameCount + 1) % characterMaxFrames;
    }
  }

  void _updateCollectables() {
    // @on update collectables
    for (Player player in players) {
      for (int i = 0; i < collectables.length; i++) {
        if (!collectables[i].active) continue;

        if (abs(player.x - collectables[i].x) > settings.itemCollectRadius)
          continue;
        if (abs(player.y - collectables[i].y) > settings.itemCollectRadius)
          continue;

        switch (collectables[i].type) {
          case CollectableType.Handgun_Ammo:
            dispatch(GameEventType.Item_Acquired, collectables[i].x,
                collectables[i].y, 0, 0);
            break;
          default:
            break;
        }
        collectables[i].active = false;
        // TODO expensive call
        delayed(() {
          activateCollectable(collectables[i]);
        }, seconds: settings.itemReactivationInSeconds);
      }
    }
  }

  /// calculates if there is a wall between two objects
  bool isVisibleBetween(Vector2 a, Vector2 b) {
    double r = radiansBetweenObject(a, b);
    double d = distanceBetweenObjects(a, b);
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

  void activateCollectable(Collectable collectable) {
    collectable.active = true;
    collectable.setType(randomCollectableType);
  }

  void applyDamage(Character src, Character target, int amount) {
    if (target.dead) return;
    if (target.invincible) return;
    changeCharacterHealth(target, -amount);
    if (target.alive) return;
    if (target is Npc) {
      target.active = false;
    }
    if (src is Player) {
      if (target is Npc) {
        playerGainExperience(src, target.experience);
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

  void updateNpc(Npc npc) {
    // @on update npc
    if (npc.dead) return;
    if (npc.busy) return;
    if (npc.inactive) return;

    if (npc.objectiveSet) {
      if (withinRadius(npc, npc.objective, settings.radius.character)) {
        npc.objectives.removeLast();
        if (npc.objectiveSet) {
          npcSetPathTo(npc, npc.objective.x, npc.objective.y);
        }
      }
    }

    if (npc.targetSet) {
      switch (npc.weapon.type) {
        case WeaponType.Unarmed:
          if (!targetWithinStrikingRange(npc, npc.target)) break;

          // @on npc target within striking range
          characterFaceObject(npc, npc.target);
          setCharacterState(npc, CharacterState.Striking);
          applyDamage(npc, npc.target, settings.damage.zombieStrike);
          double speed = 0.1;
          double rotation = radiansBetweenObject(npc, npc.target);
          dispatch(GameEventType.Zombie_Strike, npc.target.x, npc.target.y,
              velX(rotation, speed), velY(rotation, speed));
          return;
        default:
          if (!targetWithinFiringRange(npc, npc.target)) break;
          if (!isVisibleBetween(npc, npc.target)) break;

          characterAimAt(npc, npc.target.x, npc.target.y);
          setCharacterState(npc, CharacterState.Firing);
          return;
      }

      // @on npc update find
      if (npc.mode == NpcMode.Aggressive) {
        if (frame % 30 == 0) {
          npc.path = scene.findPath(npc.x, npc.y, npc.target.x, npc.target.y);
        }
        if (npc.path.length <= 1 &&
            !targetWithinStrikingRange(npc, npc.target)) {
          characterFaceObject(npc, npc.target);
          setCharacterState(npc, CharacterState.Walking);
          return;
        }
      }
    }

    if (npc.path.isNotEmpty) {
      if (arrivedAtPath(npc)) {
        // @on npc arrived at path
        npc.path.removeAt(0);
        if (npc.path.isEmpty) {
          npc.state = CharacterState.Idle;
          return;
        }
      }
      // @on npc going to path
      characterFace(npc, npc.path[0].x, npc.path[0].y);
      npc.state = CharacterState.Walking;
      return;
    }
    npc.state = CharacterState.Idle;
  }

  void _updatePlayersPerSecond() {
    if (duration % framesPerSecond != 0) return;

    for (Player player in players) {
      if (player.dead) continue;
      player.magic += player.magicRegen;
      player.health += player.healthRegen;

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

    for (Character character in players) {
      for (Collider collider in colliders) {
        double combinedRadius = character.radius + collider.radius;
        if (diffOver(character.x, collider.x, combinedRadius)) continue;
        if (diffOver(character.y, collider.y, combinedRadius)) continue;
        double _distance = distanceBetweenObjects(character, collider);
        if (_distance > combinedRadius) continue;
        double overlap = combinedRadius - _distance;
        double r = radiansBetweenObject(character, collider);
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
  }

  void sortGameObjects() {
    insertionSort(list: zombies, compare: compareGameObjectsY);
    insertionSort(list: players, compare: compareGameObjectsY);
    insertionSort(list: npcs, compare: compareGameObjectsY);
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
      case WeaponType.SlowingCircle:
        casteSlowingCircle(character, x, y);
        character.stateDuration = coolDown.fireball;
        break;
      case WeaponType.Firebolt:
        Projectile bullet = spawnFireball(character);
        character.stateDuration = coolDown.fireball;
        dispatch(GameEventType.Handgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case WeaponType.Bow:
        Projectile bow = spawnArrow(character, damage: 5);
        character.stateDuration = coolDown.bow;
        dispatch(GameEventType.Arrow_Fired, x, y, bow.xv, bow.yv);
        break;
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

  void onPlayerDeath(Player player) {
    dispatch(GameEventType.Player_Death, player.x, player.y);
    for (Npc npc in zombies) {
      if (npc.target != player) continue;
      npc.clearTarget();
    }
  }

  void setCharacterStateDead(Character character) {
    if (character.dead) return;
    character.state = CharacterState.Dead;
    character.collidable = false;
    character.stateFrameCount = duration;
    if (character is Player) {
      onPlayerDeath(character);
    } else if (character is Npc) {
      character.clearTarget();
    }

    for (Projectile projectile in projectiles) {
      if (projectile.target != character) continue;
      projectile.target = null;
    }

    for (Player player in players) {
      if (player.attackTarget != character) continue;
      player.attackTarget = null;
    }
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
      case CharacterState.ChangingWeapon:
        character.stateDuration = 10;
        break;
      case CharacterState.Aiming:
        character.accuracy = 0;
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
        characterAimAt(
            character, character.abilityTarget.x, character.abilityTarget.y);
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
    // @on update bullet
    for (int i = 0; i < projectiles.length; i++) {
      if (!projectiles[i].active) continue;
      Projectile projectile = projectiles[i];
      projectile.x += projectile.xv;
      projectile.y += projectile.yv;

      Character? target = projectile.target;
      if (target != null) {
        final double rot = radiansBetweenObject(projectile, target);
        projectile.xv = adj(rot, projectile.speed);
        projectile.yv = opp(rot, projectile.speed);
        if (distanceBetween(projectile.x, projectile.y, target.x, target.y) <
            settings.radius.character) {
          handleProjectileHit(projectile, target);
        }
      } else if (projectileDistanceTravelled(projectile) > projectile.range) {
        deactivateProjectile(projectile);
      }
    }

    for (int i = 0; i < projectiles.length; i++) {
      if (!projectiles[i].collideWithEnvironment) continue;
      if (scene.bulletCollisionAt(projectiles[i].x, projectiles[i].y)) {
        deactivateProjectile(projectiles[i]);
      }
    }

    insertionSort(list: projectiles, compare: compareGameObjectsY);
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

      if (zombie.dead) {
        double forceX = clampMagnitudeX(zombie.x - x, zombie.y - y, magnitude);
        double forceY = clampMagnitudeY(zombie.x - x, zombie.y - y, magnitude);
        dispatch(GameEventType.Zombie_killed_Explosion, zombie.x, zombie.y,
            forceX, forceY);
      }
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

  void _updateNpcs() {
    for (Npc npc in zombies) {
      updateNpc(npc);
    }

    for (InteractableNpc interactableNpc in npcs) {
      updateNpc(interactableNpc);
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

    switch (player.state) {
      case CharacterState.Walking:
        if (player.lastUpdateFrame > 5) {
          setCharacterStateIdle(player);
        }
        break;
      case CharacterState.Striking:
        // @on player striking
        // @on character striking
        if (player.type != CharacterType.Human) return;

        if (player.stateDuration == 10) {
          dispatch(GameEventType.Knife_Strike, player.x, player.y);
        }

        if (player.stateDuration == 8) {
          double frontX =
              player.x + velX(player.aimAngle, settings.range.knife);
          double frontY =
              player.y + velY(player.aimAngle, settings.range.knife);

          for (Npc npc in zombies) {
            // @on zombie struck by player
            if (!npc.alive) continue;
            if (!npc.active) continue;
            if (diffOver(npc.x, frontX, radius.character)) continue;
            if (diffOver(npc.y, frontY, radius.character)) continue;
            npc.xv += velX(player.aimAngle, settings.knifeHitAcceleration);
            npc.yv += velY(player.aimAngle, settings.knifeHitAcceleration);
            applyDamage(player, npc, settings.damage.knife);
            double a = angleBetween(player.x, player.y, npc.x, npc.y);
            applyForce(npc, a, 5);

            if (npc.dead) {
              dispatch(GameEventType.Zombie_killed_Explosion, npc.x, npc.y,
                  npc.xv, npc.yv);
            } else {
              dispatch(
                  GameEventType.Zombie_Hit,
                  npc.x,
                  npc.y,
                  velX(player.aimAngle, settings.knifeHitAcceleration * 2),
                  velY(player.aimAngle, settings.knifeHitAcceleration * 2));
            }
            return;
          }
        }
    }
    player.currentTile = scene.tileAt(player.x, player.y);
  }

  void _updateGrenades() {
    for (Grenade grenade in grenades) {
      applyMovement(grenade);
      applyFriction(grenade, settings.grenadeFriction);
      grenade.zv -= settings.grenadeGravity;

      if (grenade.z < 0) {
        grenade.z = 0;
        grenade.zv = -grenade.zv * 0.5;
      }
    }
  }

  void checkProjectileCollision(List<Character> characters) {
    int s = 0;
    for (int i = 0; i < projectiles.length; i++) {
      Projectile projectile = projectiles[i];
      if (!projectile.active) continue;
      if (projectile.target != null) {
        continue;
      }
      for (int j = s; j < characters.length; j++) {
        Character character = characters[j];
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
    character.xv += projectile.xv * settings.bulletImpactVelocityTransfer;
    character.yv += projectile.yv * settings.bulletImpactVelocityTransfer;

    if (enemies(projectile, character)) {
      // @on zombie hit by bullet
      applyDamage(projectile.owner, character, projectile.damage);

      if (character is Player) {
        dispatch(GameEventType.Player_Hit, character.x, character.y,
            projectile.xv, projectile.yv);
        return;
      }
    }

    if (character.alive) {
      dispatch(GameEventType.Zombie_Hit, character.x, character.y,
          projectile.xv, projectile.yv);
    } else {
      // @on zombie killed by player
      if (projectile.owner is Npc) {
        // on zombie killed by npc
        (projectile.owner as Npc).clearTarget();
      }
      if (character is Npc) {
        character.clearTarget();
      }
      // items.add(Item(type: ItemType.Handgun, x: character.x, y: character.y));
      character.active = false;
      dispatch(GameEventType.Zombie_killed_Explosion, character.x, character.y,
          projectile.xv, projectile.yv);
    }
  }

  void applyStrike(Character src, Character target, int damage) {
    if (target.dead) return;
    applyDamage(src, target, damage);
    double a = radiansBetween2(src, target.x, target.y);

    /// calculate force by dividing damage by target's max health
    applyForce(target, a, 5);
    if (target is Npc == false) return;

    if (target.dead) {
      dispatch(GameEventType.Zombie_killed_Explosion, target.x, target.y,
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

  double calculateAngleDifference(double angleA, double angleB) {
    double diff = abs(angleA - angleB).toDouble();
    if (diff < pi) {
      return diff;
    }
    return pi2 - diff;
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

    // if (npc.state == CharacterState.Striking) {
    //   if (npc.stateDuration-- > 0) return;
    //   setCharacterStateIdle(npc);
    // }

    if (character.stateDuration > 0) {
      character.stateDuration--;
      if (character.stateDuration == 0) {
        setCharacterState(character, CharacterState.Idle);
      }
    }

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

    switch (character.state) {
      case CharacterState.Aiming:
        if (character.accuracy > 0.05) {
          character.accuracy -= 0.005;
        }
        break;
      case CharacterState.Walking:
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
        break;
      case CharacterState.Performing:
        Ability? ability = character.performing;

        if (ability == null) {
          return;
        }

        switch (ability.type) {
          // @on performing
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
              Projectile arrow1 =
                  spawnArrow(character, damage: character.damage);
              double angle = piSixteenth;
              arrow1.target = null;
              setProjectilAngle(arrow1, character.aimAngle - angle);
              Projectile arrow2 =
                  spawnArrow(character, damage: character.damage);
              arrow2.target = null;
              Projectile arrow3 =
                  spawnArrow(character, damage: character.damage);
              arrow3.target = null;
              setProjectilAngle(arrow3, character.aimAngle + angle);
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
              for (Npc zombie in zombies) {
                if (distanceBetweenObjects(zombie, character) <
                    character.attackRange) {
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
                applyStrike(character, attackTarget,
                    character.damage * damageMultiplier);
              }
              character.attackTarget = null;
              character.performing = null;
            }
            break;
          default:
            break;
        }
        break;
      case CharacterState.Striking:
        switch (character.type) {
          case CharacterType.Witch:
            if (character.stateDuration == 3 &&
                character.attackTarget != null) {
              spawnBlueOrb(character);
              character.attackTarget = null;
            }
            break;
          case CharacterType.Archer:
            if (character.stateDuration == 3 &&
                character.attackTarget != null) {
              spawnArrow(character, damage: character.damage);
              character.attackTarget = null;
            }
            break;
          case CharacterType.Swordsman:
            if (character.stateDuration == 6) {
              Character? attackTarget = character.attackTarget;

              // otherwise do a raycast hit
              if (attackTarget == null) {
                Character? target = null;
                double targetDistance = 0;
                double radiusTop = character.y - character.attackRange;
                double radiusBottom = character.y + character.attackRange;
                double radiusLeft = character.x - character.attackRange;
                double radiusRight = character.x + character.attackRange;
                for (Npc zombie in zombies) {
                  if (zombie.bottom < radiusTop) continue;
                  if (zombie.top > radiusBottom) break;
                  if (zombie.right < radiusLeft) continue;
                  if (zombie.left > radiusRight) continue;
                  double angle = angleBetween(
                      character.x, character.y, zombie.x, zombie.y);
                  double angleDiff =
                      calculateAngleDifference(angle, character.aimAngle);
                  if (angleDiff > pi) continue;
                  double zombieDistance =
                      distanceBetweenObjects(zombie, character);
                  if (zombieDistance > character.attackRange) continue;
                  if (target == null || zombieDistance < targetDistance) {
                    target = zombie;
                    targetDistance = zombieDistance;
                  }
                }
                attackTarget = target;
              }

              if (attackTarget != null) {
                applyStrike(character, attackTarget, character.damage);
              }
            }
            break;
          default:
            break;
        }
        break;
      case CharacterState.Running:
        double runRatio = character.speed * (1.0 + goldenRatioInverse);
        switch (character.direction) {
          case Direction.Up:
            character.y -= runRatio;
            break;
          case Direction.UpRight:
            character.x += velX(piQuarter, runRatio);
            character.y += velY(piQuarter, runRatio);
            break;
          case Direction.Right:
            character.x += runRatio;
            break;
          case Direction.DownRight:
            character.x += velX(piQuarter, runRatio);
            character.y -= velY(piQuarter, runRatio);
            break;
          case Direction.Down:
            character.y += runRatio;
            break;
          case Direction.DownLeft:
            character.x -= velX(piQuarter, runRatio);
            character.y -= velY(piQuarter, runRatio);
            break;
          case Direction.Left:
            character.x -= runRatio;
            break;
          case Direction.UpLeft:
            character.x -= velX(piQuarter, runRatio);
            character.y += velY(piQuarter, runRatio);
            break;
        }
        break;
    }

    if (character.previousState != character.state) {
      character.previousState = character.state;
      character.stateFrameCount = 0;
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
    projectile.direction = convertAngleToDirection(character.aimAngle);
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

  Npc spawnZombie(double x, double y, {
        required int health,
        required int experience,
        required int team,
        List<Vector2>? objectives,
      }) {
    Npc zombie = _getAvailableZombie();
    zombie.team = team;
    zombie.active = true;
    zombie.experience = experience;
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

    if (objectives != null){
      zombie.objectives = objectives;
    }else{
      zombie.objectives = [];
    }

    return zombie;
  }

  Npc _getAvailableZombie() {
    for (int i = 0; i < zombies.length; i++) {
      if (zombies[i].active) continue;
      return zombies[i];
    }
    final Npc npc = Npc(
        type: CharacterType.Zombie,
        x: 0,
        y: 0,
        health: settings.health.zombie,
        weapon: Weapon(
          type: WeaponType.Unarmed,
          damage: 0,
          capacity: 0,
        ));
    zombies.add(npc);
    return npc;
  }

  Npc spawnRandomZombieLevel(int level) {
    return spawnRandomZombie(
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

  Npc spawnRandomZombie({int health = 25, required int experience}) {
    if (zombieSpawnPoints.isEmpty) throw ZombieSpawnPointsEmptyException();
    Vector2 spawnPoint = randomItem(zombieSpawnPoints);
    return spawnZombie(
        spawnPoint.x,
        spawnPoint.y,
        team: Teams.Bad.index,
        health: health,
        experience: experience
    );
  }

  int get zombieCount {
    int count = 0;
    for (Npc npc in zombies) {
      if (!npc.alive) continue;
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
    Npc zombie;
    for (int i = 0; i < zombies.length; i++) {
      zombie = zombies[i];
      if (zombie.targetSet) {
        // @on update npc with target
        // TODO check if there is a closer enemy
        if (withinChaseRange(zombie, zombie.target)) continue;
        zombie.clearTarget();
      }

      for (Npc npc in zombies){
        if (npc.dead) continue;
        if (zombie.team == npc.team) continue;
        if (!withinViewRange(zombie, npc)) continue;
        if (!isVisibleBetween(zombie, npc)) continue;
        setNpcTarget(zombie, npc);
      }

      for (Player player in players) {
        if (player.dead) continue;
        if (zombie.team == player.team) continue;
        if (!withinViewRange(zombie, player)) continue;
        if (!isVisibleBetween(zombie, player)) continue;
        setNpcTarget(zombie, player);
        break;
      }
    }
  }

  bool withinViewRange(Npc npc, Vector2 target){
    return withinRadius(npc, target, settings.npc.viewRange);
  }

  bool withinChaseRange(Npc npc, Vector2 target){
    return withinRadius(npc, target, settings.npc.chaseRange);
  }

  num cheapDistance(Vector2 a, Vector2 b) {
    return diff(a.y, b.y) + diff(a.x, b.x);
  }

  void updateInteractableNpcTargets() {
    if (zombies.isEmpty) return;
    int initial = getFirstAliveZombieIndex();
    if (initial == _none) return;

    for (int i = 0; i < npcs.length; i++) {
      updateInteractableNpcTarget(npcs[i], initial);
    }
  }

  int getFirstAliveZombieIndex() {
    for (int i = 0; i < zombies.length; i++) {
      if (zombies[i].alive) return i;
    }
    return _none;
  }

  void updateInteractableNpcTarget(Npc npc, int j) {
    if (npc.mode == NpcMode.Ignore) return;

    Character closest = zombies[j];
    num closestDistance = cheapDistance(closest, npc);
    for (int i = j + 1; i < zombies.length; i++) {
      if (!zombies[i].alive) continue;
      num distance2 = cheapDistance(zombies[i], npc);
      if (distance2 > closestDistance) continue;
      closest = zombies[i];
      closestDistance = distance2;
    }

    double range = getWeaponRange(npc.weapon.type);
    double actualDistance = distanceBetween(npc.x, npc.y, closest.x, closest.y);
    if (actualDistance > range) {
      npc.clearTarget();
      npc.state = CharacterState.Idle;
    } else {
      setNpcTarget(npc, closest);
    }
  }

  void setNpcTarget(Npc npc, Character value) {
    if (npc == value) {
      throw Exception("Npc cannot target itself");
    }
    if (npc.team == value.team){
      throw Exception("Npc target same team");
    }
    npc.target = value;
  }

  void updateNpcObjective(Npc npc) {
    npcSetRandomDestination(npc);
  }

  void removeDisconnectedPlayers() {
    for (int i = 0; i < players.length; i++) {
      if (players[i].lastUpdateFrame < settings.playerDisconnectFrames)
        continue;

      print("removing disconnected player");
      Player player = players[i];
      for (Npc npc in zombies) {
        if (npc.target != player) continue;
        npc.clearTarget();
      }
      player.active = false;
      players.removeAt(i);
      playerMap.remove(player.uuid);
      i--;
      onPlayerDisconnected(player);
    }
  }

  void revive(Character character) {
    character.state = CharacterState.Idle;
    character.health = character.maxHealth;

    if (character is Player) {
      character.magic = character.maxMagic;
    }

    if (playerSpawnPoints.isEmpty) {
      character.x = giveOrTake(settings.playerStartRadius);
      character.y = tilesLeftY + giveOrTake(settings.playerStartRadius);
    } else {
      Vector2 spawnPoint = getNextSpawnPoint();
      character.x = spawnPoint.x;
      character.y = spawnPoint.y;
    }

    character.collidable = true;
  }

  Vector2 randomPlayerSpawnPoint() {
    return playerSpawnPoints[randomInt(0, playerSpawnPoints.length)];
  }

  Vector2 getNextSpawnPoint() {
    spawnPointIndex = (spawnPointIndex + 1) % playerSpawnPoints.length;
    return playerSpawnPoints[spawnPointIndex];
  }

  void npcSetRandomDestination(Npc npc) {
    npcSetPathToTileNode(npc, getRandomOpenTileNode());
  }

  TileNode getRandomOpenTileNode() {
    while (true) {
      TileNode node = randomItem(randomItem(scene.tileNodes));
      if (!node.open) continue;
      return node;
    }
  }

  void npcSetPathTo(Npc npc, double x, double y) {
    npcSetPathToTileNode(npc, scene.tileNodeAt(x, y));
  }

  void npcSetPathToTileNode(Npc npc, TileNode node) {
    npc.path = scene.findPathNodes(scene.tileNodeAt(npc.x, npc.y), node);
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

  void _updateCrates() {
    for (Crate crate in crates) {
      if (crate.active) continue;
      crate.deactiveDuration--;
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
  if (player.busy) return;
  if (player.dead) return;
  if (index < 0) return;
  if (index >= player.weapons.length) return;
  player.equippedIndex = index;
  player.game.setCharacterState(player, CharacterState.ChangingWeapon);
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
      // TODO: Handle this case.
      break;
    case CharacterType.Zombie:
      // TODO: Handle this case.
      break;
    case CharacterType.Witch:
      player.attackRange = 170;
      player.maxMagic = 100;
      player.magic = player.maxMagic;
      player.ability1 = Ability(
        type: AbilityType.Explosion,
        level: 0,
        magicCost: 60,
        range: 200,
        cooldown: 15,
        radius: settings.radius.explosion,
      );
      player.ability2 = Ability(
          type: AbilityType.Blink,
          level: 0,
          magicCost: 10,
          range: 200,
          cooldown: 10);
      player.ability3 = Ability(
        type: AbilityType.FreezeCircle,
        level: 0,
        magicCost: 10,
        range: 200,
        cooldown: 15,
        radius: settings.radius.explosion,
      );
      player.ability4 = Ability(
          type: AbilityType.Fireball,
          level: 0,
          magicCost: 10,
          range: 200,
          cooldown: 25);
      break;
    case CharacterType.Swordsman:
      player.attackRange = 50;
      player.maxMagic = 100;
      player.ability1 = Ability(
          type: AbilityType.Brutal_Strike,
          level: 0,
          magicCost: 10,
          range: player.attackRange,
          cooldown: 15);
      player.ability2 = IronShield(player);
      player.ability3 = Ability(
          type: AbilityType.Death_Strike,
          level: 0,
          magicCost: 10,
          range: player.attackRange,
          cooldown: 15);
      player.ability4 = Ability(
          type: AbilityType.Explosion,
          level: 0,
          magicCost: 10,
          range: 200,
          cooldown: 15);
      break;
    case CharacterType.Archer:
      player.attackRange = 210;
      player.damage = 2;
      player.maxMagic = 100;
      player.ability1 = Ability(
          type: AbilityType.Split_Arrow,
          level: 0,
          magicCost: 40,
          range: 200,
          cooldown: 10);
      player.ability2 = Dash(player);
      player.ability3 = Ability(
          type: AbilityType.Long_Shot,
          level: 0,
          magicCost: 40,
          range: 250,
          cooldown: 15);
      player.ability4 = Ability(
          type: AbilityType.Fireball,
          level: 0,
          magicCost: 70,
          range: 200,
          cooldown: 25);
      break;
    case CharacterType.Musketeer:
      // TODO: Handle this case.
      break;
  }

  player.magic = player.maxMagic;
  player.health = player.maxHealth;
}
