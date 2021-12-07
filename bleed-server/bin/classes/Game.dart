import 'dart:math';

import 'package:lemon_math/abs.dart';
import 'package:lemon_math/angle.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/hypotenuse.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/randomItem.dart';

import '../bleed/zombie_health.dart';
import '../common/AbilityType.dart';
import '../common/CharacterState.dart';
import '../common/CharacterType.dart';
import '../common/ItemType.dart';
import '../common/Tile.dart';
import '../common/enums/Direction.dart';
import '../common/enums/ObjectType.dart';
import '../common/enums/ProjectileType.dart';
import '../common/enums/Shade.dart';
import '../constants/no_squad.dart';
import '../enums/npc_mode.dart';
import '../functions/insertionSort.dart';
import '../functions/withinRadius.dart';
import '../interfaces/HasSquad.dart';
import 'Ability.dart';
import 'Projectile.dart';
import 'Character.dart';
import 'Collider.dart';
import 'EnvironmentObject.dart';
import '../common/classes/Vector2.dart';
import '../compile.dart';
import '../constants.dart';
import '../enums.dart';
import '../common/CollectableType.dart';
import '../common/GameEventType.dart';
import '../common/WeaponType.dart';
import '../exceptions/ZombieSpawnPointsEmptyException.dart';
import '../functions/applyForce.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import '../update.dart';
import '../utils.dart';
import '../utils/game_utils.dart';
import 'Collectable.dart';
import 'Crate.dart';
import 'GameEvent.dart';
import 'GameObject.dart';
import 'Grenade.dart';
import 'InteractableObject.dart';
import 'Inventory.dart';
import 'Item.dart';
import 'Npc.dart';
import 'Player.dart';
import 'Positioned.dart';
import 'Scene.dart';
import 'SpawnPoint.dart';
import 'TileNode.dart';
import 'InteractableNpc.dart';
import 'Weapon.dart';

const _none = -1;
const _framesPerMagicRegen = 30;

abstract class Game {
  static int _id = 0;
  final String id = (_id++).toString();
  final int maxPlayers;
  final Scene scene;

  /// Used to constrain the brightness of a level
  /// For example a cave which is very dark even during day time
  /// or a dark forest
  Shade shadeMax = Shade.Bright;
  int duration = 0;
  List<Npc> zombies = [];
  List<InteractableNpc> npcs = [];
  List<InteractableObject> interactableObjects = [];
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

  // TODO doesn't belong here
  StringBuffer buffer = StringBuffer();

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
      if (player.squad != squad) continue;
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

  void onNpcKilled(Npc npc) {}

  void onKilledBy(Character target, Character by);

  void onPlayerDisconnected(Player player) {}

  void onPlayerRevived(Player player) {}

  void onNpcSpawned(Npc npc) {}

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

  Game(this.scene, {this.maxPlayers = 64, this.shadeMax = Shade.Bright}) {
    this.crates.clear();

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
    _updateGrenades();
    _updateCollectables();
    _updateGameEvents();
    _updateCrates();
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
            if (!player.inventory.acquire(InventoryItemType.HandgunClip)) {
              continue;
            }
            dispatch(GameEventType.Item_Acquired, collectables[i].x,
                collectables[i].y, 0, 0);
            break;

          case CollectableType.Grenade:
            if (player.grenades >= settings.maxGrenades) continue;
            player.grenades++;
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
  bool isVisibleBetween(Positioned a, Positioned b) {
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
    changeCharacterHealth(target, -amount);
    if (target.alive) return;
    if (target is Npc) {
      target.active = false;
    }
    if (src is Player) {
      if (target is Npc) {
        if (src.level < maxPlayerLevel) {
          src.experience += target.experience;
          while (src.experience >= levelExperience[src.level]) {
            // on player level increased
            src.experience -= levelExperience[src.level];
            src.level++;
            src.skillPoints++;
          }
        }
      }
    }
    onKilledBy(target, src);
  }

  void updateNpc(Npc npc) {
    // @on update npc
    if (npc.dead) return;
    if (npc.busy) return;
    if (npc.inactive) return;

    // todo this belongs in update character
    if (npc.state == CharacterState.Striking) {
      if (npc.stateDuration-- > 0) return;
      setCharacterStateIdle(npc);
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

  void _updatePlayersAndNpcs() {
    if (duration % fps == 0) {
      for (Player player in players) {
        player.magic += player.magicRegen;
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
        Projectile bow = spawnArrow(character);
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

  void setCharacterState(Character character, CharacterState value) {
    // @on character set state
    if (character.dead) return;
    if (character.state == value) return;
    if (value != CharacterState.Dead && character.busy) return;

    switch (value) {
      case CharacterState.Dead:
        // @on character death
        character.collidable = false;
        character.stateFrameCount = duration;
        character.state = value;
        if (character is Player) {
          onPlayerDeath(character);
        } else if (character is Npc) {
          character.clearTarget();
          onNpcKilled(character);
        }
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
        character.stateDuration = settings.duration.knifeStrike;
        break;
      case CharacterState.Performing:
        characterAimAt(
            character, character.abilityTarget.x, character.abilityTarget.y);
        character.stateDuration = settings.duration.knifeStrike;
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
    // @on change character health
    if (character.dead) return;

    character.health += amount;
    if (character.health == 0) {
      setCharacterState(character, CharacterState.Dead);
    }
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

      Positioned? target = projectile.target;
      if (target != null) {
        final double rot = radiansBetweenObject(projectile, target);
        projectile.xv = adj(rot, projectile.speed);
        projectile.yv = opp(rot, projectile.speed);
      } else if (projectileDistanceTravelled(projectile) > projectile.range) {
        deactivateProjectile(projectile);
      }
    }

    for (int i = 0; i < projectiles.length; i++) {
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

    // for (int i = 0; i < crates.length; i++) {
    //   if (!crates[i].active) continue;
    //   Crate crate = crates[i];
    //   applyCratePhysics(crate, players);
    //   applyCratePhysics(crate, zombies);
    //
    //   for (int j = 0; j < projectiles.length; j++) {
    //     if (!projectiles[j].active) continue;
    //     if (diffOver(crate.x, projectiles[j].x, radius.crate)) continue;
    //     if (diffOver(crate.y, projectiles[j].y, radius.crate)) continue;
    //     // @on crate struck by bullet
    //     breakCrate(crate);
    //     projectiles[j].active = false;
    //     break;
    //   }
    // }
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
    if (a.squad == noSquad) return false;
    if (b.squad == noSquad) return false;
    return a.squad == b.squad;
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

          for (Crate crate in crates) {
            if (!crate.active) continue;
            if (diffOver(crate.x, frontX, radius.crate)) continue;
            if (diffOver(crate.y, frontY, radius.crate)) continue;
            breakCrate(crate);
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
      for (int j = s; j < characters.length; j++) {
        Character character = characters[j];
        if (!character.active) continue;
        if (character.dead) continue;
        if (character.left > projectile.right) continue;
        if (projectile.left > character.right) continue;
        if (projectile.top > character.bottom) continue;
        if (projectile.bottom < character.top) continue;

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
          dispatch(GameEventType.Zombie_killed_Explosion, character.x,
              character.y, projectile.xv, projectile.yv);
        }
        break;
      }
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

    while (!scene.tileWalkableAt(character.left, character.top)) {
      character.x++;
      character.y++;
    }
    while (!scene.tileWalkableAt(character.right, character.top)) {
      character.x--;
      character.y++;
    }
    while (!scene.tileWalkableAt(character.left, character.bottom)) {
      character.x++;
      character.y--;
    }
    while (!scene.tileWalkableAt(character.right, character.bottom)) {
      character.x--;
      character.y--;
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
            }
            break;
          case AbilityType.FreezeCircle:
            final int castFrame = 3;
            if (character.stateDuration == castFrame) {
              spawnFreezeCircle(
                  x: character.abilityTarget.x, y: character.abilityTarget.y);
              character.performing = null;
            }
            break;
          case AbilityType.Fireball:
            final int castFrame = 3;
            if (character.stateDuration == castFrame) {
              spawnFireball(character);
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
            if (character.stateDuration == 3) {
              spawnBlueOrb(character);
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
    return spawnProjectile(
        character: character,
        accuracy: 0,
        speed: settings.projectileSpeed.fireball,
        damage: 100,
        range: settings.range.firebolt,
        target: character.attackTarget,
        type: ProjectileType.Blue_Orb);
  }

  void casteSlowingCircle(Character character, double x, double y) {}

  Projectile spawnArrow(Character character) {
    return spawnProjectile(
        character: character,
        accuracy: 0,
        speed: settings.projectileSpeed.arrow,
        damage: 100,
        range: settings.range.arrow,
        type: ProjectileType.Arrow);
  }

  Projectile spawnProjectile({
    required Character character,
    required double accuracy,
    required double speed,
    required double range,
    required int damage,
    required ProjectileType type,
    Positioned? target,
  }) {
    double spawnDistance = character.radius + 20;
    Projectile projectile = getAvailableProjectile();
    projectile.target = target;
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

  Npc spawnZombie(double x, double y,
      {required int health, required int experience}) {
    Npc zombie = _getAvailableZombie();
    zombie.active = true;
    zombie.experience = experience;
    zombie.state = CharacterState.Idle;
    zombie.stateDuration = 0;
    zombie.previousState = CharacterState.Idle;
    zombie.maxHealth = health;
    zombie.health = health;
    zombie.x = x;
    zombie.y = y;
    zombie.yv = 0;
    zombie.xv = 0;
    onNpcSpawned(zombie);
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
    return spawnZombie(spawnPoint.x + giveOrTake(radius.zombieSpawnVariation),
        spawnPoint.y + giveOrTake(radius.zombieSpawnVariation),
        health: health, experience: experience);
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
        if (diff(zombie.x, zombie.target.x) < settings.zombieChaseRange)
          continue;
        if (diff(zombie.y, zombie.target.y) < settings.zombieChaseRange)
          continue;
        zombie.clearTarget();
        zombie.state = CharacterState.Idle;
      }

      for (int p = 0; p < players.length; p++) {
        Player player = players[p];
        if (!player.alive) continue;
        if (diff(player.x, zombie.x) > settings.npc.viewRange) continue;
        if (diff(player.y, zombie.y) > settings.npc.viewRange) continue;
        if (!isVisibleBetween(zombie, player)) continue;
        zombie.target = player;
        break;
      }
    }
  }

  Character? findClosestCharacter(List<Character> list, double x, double y) {
    int j = 0;
    while (true) {
      if (list[j].alive) break;
      j++;
      if (j >= list.length) {
        return null;
      }
    }

    Character closest = list[j];
    num distance = diff(closest.y, y) + diff(closest.x, x);
    for (int i = j + 1; i < list.length; i++) {
      num distance2 = diff(closest.y, y) + diff(closest.x, x);
      if (distance2 > distance) continue;
      closest = list[i];
      distance = distance2;
    }
    return closest;
  }

  num cheapDistance(Positioned a, Positioned b) {
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
    npc.target = value;
  }

  void jobNpcWander() {
    for (Npc npc in zombies) {
      if (npc.inactive) continue;
      if (npc.busy) continue;
      if (npc.dead) continue;
      if (npc.targetSet) continue;
      if (npc.path.isNotEmpty) continue;
      npcSetRandomDestination(npc);
    }
  }

  void jobRemoveDisconnectedPlayers() {
    for (int i = 0; i < players.length; i++) {
      if (players[i].lastUpdateFrame < settings.playerDisconnectFrames)
        continue;
      Player player = players[i];
      for (Npc npc in zombies) {
        if (npc.target == player) {
          npc.clearTarget();
        }
      }
      player.active = false;
      players.removeAt(i);
      i--;

      onPlayerDisconnected(player);
    }
  }

  void revive(Character character) {
    character.state = CharacterState.Idle;
    character.health = character.maxHealth;

    if (playerSpawnPoints.isEmpty) {
      character.x = giveOrTake(settings.playerStartRadius);
      character.y = tilesLeftY + giveOrTake(settings.playerStartRadius);
    } else {
      Vector2 spawnPoint = getNextSpawnPoint();
      character.x = spawnPoint.x;
      character.y = spawnPoint.y;
    }

    onPlayerRevived(character as Player);
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
    // @on npc set random destination
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

  // void _updateItems() {
  //   for (int i = 0; i < items.length; i++) {
  //     Item item = items[i];
  //
  //     // TODO Optimize
  //     if (item.duration-- <= 0) {
  //       items.removeAt(i);
  //       i--;
  //       continue;
  //     }
  //     for (Player player in players) {
  //       if (diffOver(item.x, player.x, radius.item)) continue;
  //       if (diffOver(item.y, player.y, radius.item)) continue;
  //       if (player.dead) continue;
  //
  //       // @on item collectable
  //
  //       switch (item.type) {
  //         case ItemType.Handgun:
  //           dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
  //           break;
  //         case ItemType.Shotgun:
  //           dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
  //           break;
  //         case ItemType.SniperRifle:
  //           // @on sniper rifle acquired
  //           if (player.acquiredSniperRifle) {
  //             if (player.rounds.sniperRifle >= constants.maxRounds.sniperRifle)
  //               continue;
  //             player.rounds.sniperRifle = clampInt(
  //                 player.rounds.sniperRifle + settings.pickup.sniperRifle,
  //                 0,
  //                 constants.maxRounds.sniperRifle);
  //             dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
  //             break;
  //           }
  //           player.rounds.sniperRifle = settings.pickup.sniperRifle;
  //           // player.weapon = WeaponType.SniperRifle;
  //           break;
  //         case ItemType.Assault_Rifle:
  //           // @on assault rifle acquired
  //           if (player.acquiredAssaultRifle) {
  //             if (player.rounds.assaultRifle >=
  //                 constants.maxRounds.assaultRifle) continue;
  //             player.rounds.assaultRifle = clampInt(
  //                 player.rounds.assaultRifle +
  //                     constants.maxRounds.assaultRifle ~/ 5,
  //                 0,
  //                 constants.maxRounds.assaultRifle);
  //             dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
  //             break;
  //           }
  //           player.rounds.assaultRifle = settings.pickup.assaultRifle;
  //           // player.weapon = WeaponType.AssaultRifle;
  //           break;
  //         case ItemType.Credits:
  //           player.earnPoints(settings.collectCreditAmount);
  //           dispatch(GameEventType.Credits_Acquired, item.x, item.y);
  //           break;
  //         case ItemType.Health:
  //           if (player.health >= player.maxHealth) continue;
  //           player.health = player.maxHealth;
  //           dispatch(GameEventType.Health_Acquired, item.x, item.y);
  //           break;
  //         case ItemType.Grenade:
  //           if (player.grenades >= settings.maxGrenades) continue;
  //           player.grenades++;
  //           dispatch(GameEventType.Item_Acquired, item.x, item.y);
  //           break;
  //       }
  //
  //       items.removeAt(i);
  //       i--;
  //     }
  //   }
  // }

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

  switch (value) {
    case CharacterType.Human:
      // TODO: Handle this case.
      break;
    case CharacterType.Zombie:
      // TODO: Handle this case.
      break;
    case CharacterType.Witch:
      player.attackRange = 200;
      player.ability1 = Ability(
          type: AbilityType.Explosion,
          level: 0,
          magicCost: 10,
          range: 200,
          cooldown: 15);
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
          cooldown: 15);
      player.ability4 = Ability(
          type: AbilityType.Fireball,
          level: 0,
          magicCost: 10,
          range: 200,
          cooldown: 25);
      player.maxMagic = 100;
      player.magic = 100;
      break;
    case CharacterType.Knight:
      // TODO: Handle this case.
      break;
    case CharacterType.Archer:
      // TODO: Handle this case.
      break;
    case CharacterType.Musketeer:
      // TODO: Handle this case.
      break;
  }
}
