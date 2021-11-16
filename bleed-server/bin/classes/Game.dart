import 'dart:math';

import 'package:lemon_math/abs.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomBool.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/randomItem.dart';

import '../common/ItemType.dart';
import '../common/Tile.dart';
import '../common/enums/Direction.dart';
import '../common/enums/EnvironmentObjectType.dart';
import '../constants/no_squad.dart';
import '../enums/npc_mode.dart';
import '../functions/insertionSort.dart';
import '../interfaces/HasSquad.dart';
import 'Bullet.dart';
import 'Character.dart';
import 'Collider.dart';
import 'EnvironmentObject.dart';
import '../common/classes/Vector2.dart';
import '../common/constants.dart';
import '../compile.dart';
import '../constants.dart';
import '../enums.dart';
import '../common/CollectableType.dart';
import '../common/GameEventType.dart';
import '../common/Weapons.dart';
import '../exceptions/ZombieSpawnPointsEmptyException.dart';
import '../functions/applyForce.dart';
import '../functions/generateUUID.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import '../update.dart';
import '../utils.dart';
import '../utils/game_utils.dart';
import '../utils/player_utils.dart';
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
import 'TileNode.dart';
import 'InteractableNpc.dart';

const _none = -1;

const List<SpawnPoint> noSpawnPoints = [];

class SpawnPoint extends Positioned {
  final Game game;

  SpawnPoint({
    required this.game,
    required double x,
    required double y,
  }) : super(x, y);
}

abstract class Game {
  static int _id = 0;
  final String id = (_id++).toString();
  final String uuid = generateUUID();
  final int maxPlayers;
  final Scene scene;
  int duration = 0;
  List<Npc> zombies = [];
  List<InteractableNpc> npcs = [];
  List<InteractableObject> interactableObjects = [];
  List<SpawnPoint> spawnPoints = [];
  List<Player> players = [];
  List<Bullet> bullets = [];
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
    // Vector2 spawnPosition = to.getSpawnPositionFrom(player.game);
    player.game = to;
    // player.x = spawnPosition.x;
    // player.y = spawnPosition.y;
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

  void onPlayerKilled(Player player);

  void onNpcKilled(Npc npc) {}

  void onKilledBy(Character target, Character by);

  void onPlayerDisconnected(Player player) {}

  void onPlayerRevived(Player player) {}

  void onNpcSpawned(Npc npc) {}

  Game(this.scene, this.maxPlayers) {
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

extension GameFunctions on Game {
  void updateAndCompile() {
    // @on update game
    duration++;
    update();
    _updatePlayersAndNpcs();
    _updateCollisions();
    _updateBullets();
    _updateBullets(); // called twice to fix collision detection
    _updateNpcs();
    _updateGrenades();
    _updateCollectables();
    _updateGameEvents();
    _updateItems();
    _updateCrates();
    _updateSpawnPointCollisions();

    compileGame(this);
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
          case CollectableType.Health:
            if (player.meds >= settings.maxMeds) continue;
            player.meds++;
            dispatch(GameEventType.Item_Acquired, collectables[i].x,
                collectables[i].y, 0, 0);
            break;
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
      switch (npc.weapon) {
        case Weapon.Unarmed:
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

  void _characterFireWeapon(Character character) {
    if (character.dead) return;
    if (character.stateDuration > 0) return;
    faceAimDirection(character);

    if (character is Player) {
      if (equippedWeaponRounds(character) <= 0) {
        // @on character insufficient bullets to fire
        character.stateDuration = settings.coolDown.clipEmpty;
        dispatch(GameEventType.Clip_Empty, character.x, character.y, 0, 0);
        return;
      }
    }

    double d = 15;
    double x = character.x + adj(character.aimAngle, d);
    double y = character.y + opp(character.aimAngle, d) - 5;
    character.state = CharacterState.Firing;
    switch (character.weapon) {
      case Weapon.HandGun:
        // @on character fire handgun
        if (character is Player) {
          character.rounds.handgun--;
        }
        Bullet bullet = spawnBullet(character);
        character.stateDuration = coolDown.handgun;
        dispatch(GameEventType.Handgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.Shotgun:
        // @on character fire shotgun
        if (character is Player) {
          character.rounds.shotgun--;
        }
        character.xv += velX(character.aimAngle + pi, 1);
        character.yv += velY(character.aimAngle + pi, 1);
        for (int i = 0; i < settings.shotgunBulletsPerShot; i++) {
          spawnBullet(character);
        }
        Bullet bullet = bullets.last;
        character.stateDuration = coolDown.shotgun;
        dispatch(GameEventType.Shotgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.SniperRifle:
        // @on character fire sniper rifle
        if (character is Player) {
          character.rounds.sniperRifle--;
        }
        Bullet bullet = spawnBullet(character);
        character.stateDuration = coolDown.sniperRifle;
        dispatch(GameEventType.SniperRifle_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.AssaultRifle:
        // @on character fire assault rifle
        if (character is Player) {
          character.rounds.assaultRifle--;
        }
        Bullet bullet = spawnBullet(character);
        character.stateDuration = coolDown.assaultRifle;
        dispatch(GameEventType.MachineGun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      default:
        break;
    }
  }

  void setCharacterState(Character character, CharacterState value) {
    // @on character set state
    if (character.dead) return;
    if (character.state == value) return;
    if (value != CharacterState.Dead && character.busy) return;

    switch (value) {
      case CharacterState.Running:
        // @on character running
        if (character is Player && character.stamina <= settings.minStamina) {
          character.state = CharacterState.Walking;
          return;
        }
        break;
      case CharacterState.Dead:
        // @on character death
        character.collidable = false;
        character.stateFrameCount = duration;
        character.state = value;
        if (character is Player) {
          // @on player killed
          character.score.deaths++;
          onPlayerKilled(character);

          for (Npc npc in zombies) {
            if (npc.target != character) continue;
            // @on npc target player killed
            npc.clearTarget();
          }
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
        if (character.weapon == Weapon.Unarmed) {
          setCharacterState(character, CharacterState.Striking);
          return;
        }
        _characterFireWeapon(character);
        break;
      case CharacterState.Striking:
        // @on character striking
        character.stateDuration = settings.duration.knifeStrike;
        break;
      case CharacterState.Reloading:
        // @on reload weapon
        Player player = character as Player;

        switch (character.weapon) {
          case Weapon.HandGun:
            // @on reload handgun
            if (player.rounds.handgun >= constants.maxRounds.handgun) return;
            if (player.clips.handgun <= 0) return;
            player.rounds.handgun = constants.maxRounds.handgun;
            player.clips.handgun--;
            player.stateDuration = settings.reloadDuration.handgun;
            break;
          case Weapon.Shotgun:
            // @on reload shotgun
            if (player.rounds.shotgun >= constants.maxRounds.shotgun) return;
            if (player.clips.shotgun <= 0) return;
            player.rounds.shotgun = constants.maxRounds.shotgun;
            player.clips.shotgun--;
            player.stateDuration = settings.reloadDuration.shotgun;
            break;
          case Weapon.SniperRifle:
            // @on reload sniper rifle
            if (player.rounds.sniperRifle >= constants.maxRounds.sniperRifle)
              return;
            if (player.clips.sniperRifle <= 0) return;
            player.rounds.sniperRifle = constants.maxRounds.sniperRifle;
            player.clips.sniperRifle--;
            player.stateDuration = settings.reloadDuration.sniperRifle;
            break;
          case Weapon.AssaultRifle:
            // @on reload assault rifle
            if (player.rounds.assaultRifle >= constants.maxRounds.assaultRifle)
              return;
            if (player.clips.assaultRifle <= 0) return;
            player.rounds.assaultRifle = constants.maxRounds.assaultRifle;
            player.clips.assaultRifle--;
            player.stateDuration = settings.reloadDuration.assaultRifle;
            break;
          default:
            break;
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

  void _updateBullets() {
    // @on update bullet
    for (int i = 0; i < bullets.length; i++) {
      if (!bullets[i].active) continue;
      Bullet bullet = bullets[i];
      bullet.x += bullet.xv;
      bullet.y += bullet.yv;
      if (bulletDistanceTravelled(bullet) > bullet.range) {
        if (!scene.waterAt(bullet.x, bullet.y)) {
          dispatch(GameEventType.Bullet_Hole, bullet.x, bullet.y, 0, 0);
        }

        bullet.active = false;
      }
    }

    for (int i = 0; i < bullets.length; i++) {
      if (scene.bulletCollisionAt(bullets[i].x, bullets[i].y)) {
        bullets[i].active = false;
      }
    }

    insertionSort(list: bullets, compare: compareGameObjectsY);
    checkBulletCollision(zombies);
    checkBulletCollision(players);

    for (int i = 0; i < bullets.length; i++) {
      if (!bullets[i].active) continue;
      for (EnvironmentObject environmentObject in scene.environment) {
        if (!environmentObject.collidable) continue;
        if (!overlapping(bullets[i], environmentObject)) continue;
        bullets[i].active = false;
        break;
      }
    }

    for (int i = 0; i < crates.length; i++) {
      if (!crates[i].active) continue;
      Crate crate = crates[i];
      applyCratePhysics(crate, players);
      applyCratePhysics(crate, zombies);

      for (int j = 0; j < bullets.length; j++) {
        if (!bullets[j].active) continue;
        if (diffOver(crate.x, bullets[j].x, radius.crate)) continue;
        if (diffOver(crate.y, bullets[j].y, radius.crate)) continue;
        // @on crate struck by bullet
        breakCrate(crate);
        bullets[j].active = false;
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

  void spawnExplosion(Grenade grenade) {
    double x = grenade.x;
    double y = grenade.y;

    dispatch(GameEventType.Explosion, x, y, 0, 0);

    for (Crate crate in crates) {
      if (!crate.active) continue;
      if (diffOver(grenade.x, crate.x, settings.grenadeExplosionRadius))
        continue;
      if (diffOver(grenade.y, crate.y, settings.grenadeExplosionRadius))
        continue;
      breakCrate(crate);
    }

    for (Character character in zombies) {
      if (objectDistanceFrom(character, x, y) > settings.grenadeExplosionRadius)
        continue;
      double rotation = radiansBetween2(character, x, y);
      double magnitude = 10;
      applyForce(character, rotation + pi, magnitude);

      if (character.alive) {
        changeCharacterHealth(character, -settings.damage.grenade);

        if (!character.alive) {
          // @on npc killed by grenade
          grenade.owner.earnPoints(settings.pointsEarned.zombieKilled);

          double forceX =
              clampMagnitudeX(character.x - x, character.y - y, magnitude);
          double forceY =
              clampMagnitudeY(character.x - x, character.y - y, magnitude);

          if (randomBool()) {
            dispatch(GameEventType.Zombie_Killed, character.x, character.y,
                forceX, forceY);
            characterFace(character, x, y);
            delayed(() => character.active = false, ms: randomInt(1000, 2000));
          } else {
            character.active = false;
            dispatch(GameEventType.Zombie_killed_Explosion, character.x,
                character.y, forceX, forceY);
          }
        }
      }
    }

    for (Player player in players) {
      if (objectDistanceFrom(player, x, y) > settings.grenadeExplosionRadius)
        continue;
      double rotation = radiansBetween2(player, x, y);
      double magnitude = 10;
      applyForce(player, rotation + pi, magnitude);

      if (player.alive) {
        changeCharacterHealth(player, -settings.damage.grenade);
        if (!player.alive) {
          // @on player killed by grenade
          if (!sameTeam(player, grenade.owner)) {
            grenade.owner.earnPoints(settings.pointsEarned.playerKilled);
          }
        }
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
      case CharacterState.Running:
        // player.stamina -= 3;
        if (player.stamina <= 0) {
          setCharacterState(player, CharacterState.Walking);
        }
        break;
      case CharacterState.Walking:
        player.stamina += settings.staminaRefreshRate;
        if (player.lastUpdateFrame > 5) {
          setCharacterStateIdle(player);
        }
        break;
      case CharacterState.Idle:
        player.stamina += settings.staminaRefreshRate;
        break;
      case CharacterState.Aiming:
        player.stamina += settings.staminaRefreshRate;
        break;
      case CharacterState.Firing:
        player.stamina += settings.staminaRefreshRate;
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
            dispatch(
                GameEventType.Zombie_Hit,
                npc.x,
                npc.y,
                velX(player.aimAngle, settings.knifeHitAcceleration * 2),
                velY(player.aimAngle, settings.knifeHitAcceleration * 2));
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
    player.stamina = clampInt(player.stamina, 0, player.maxStamina);
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

  void checkBulletCollision(List<Character> characters) {
    int s = 0;
    for (int i = 0; i < bullets.length; i++) {
      Bullet bullet = bullets[i];
      if (!bullet.active) continue;
      for (int j = s; j < characters.length; j++) {
        Character character = characters[j];
        if (!character.active) continue;
        if (character.dead) continue;
        if (character.left > bullet.right) continue;
        if (bullet.left > character.right) continue;
        if (bullet.top > character.bottom) continue;
        if (bullet.bottom < character.top) continue;

        if (bullet.weapon != Weapon.SniperRifle) {
          bullet.active = false;
        }

        character.xv += bullet.xv * settings.bulletImpactVelocityTransfer;
        character.yv += bullet.yv * settings.bulletImpactVelocityTransfer;

        if (enemies(bullet, character)) {
          // @on zombie hit by bullet
          applyDamage(bullet.owner, character, bullet.damage);

          if (character is Player) {
            if (character.dead) {
              if (bullet.owner is Player) {
                // @on player killed by player
                Player owner = bullet.owner as Player;
                owner.earnPoints(settings.pointsEarned.playerKilled);
                owner.score.playersKilled++;
              }
            }

            dispatch(GameEventType.Player_Hit, character.x, character.y,
                bullet.xv, bullet.yv);
            return;
          }
        }

        if (character.alive) {
          dispatch(GameEventType.Zombie_Hit, character.x, character.y,
              bullet.xv, bullet.yv);
        } else {
          // @on zombie killed by player
          if (bullet.owner is Player) {
            Player owner = bullet.owner as Player;
            // call interface instead
            owner.score.zombiesKilled++;
            if (character is Npc) {
              owner.earnPoints(
                  constants.points.zombieKilled * character.pointMultiplier);
            }
          } else if (bullet.owner is Npc) {
            // on zombie killed by npc
            (bullet.owner as Npc).clearTarget();
          }

          if (randomBool()) {
            dispatch(GameEventType.Zombie_Killed, character.x, character.y,
                bullet.xv, bullet.yv);
            delayed(() => character.active = false, ms: 2000);
          } else {
            character.active = false;
            dispatch(GameEventType.Zombie_killed_Explosion, character.x,
                character.y, bullet.xv, bullet.yv);
          }
        }
        break;
      }
    }
  }

  void clearNpcs() {
    zombies.clear();
  }

  void updateCharacter(Character character) {
    if (!character.active) return;

    if (abs(character.xv) > settings.minVelocity) {
      character.x += character.xv;
      character.y += character.yv;
      character.xv *= settings.velocityFriction;
      character.yv *= settings.velocityFriction;
    }

    if (character.dead) return;

    if (character.stateDuration > 0) {
      character.stateDuration--;

      if (character.stateDuration == 0) {
        switch (character.state) {
          case CharacterState.Reloading:
            dispatch(GameEventType.Reloaded, character.x, character.y, 0, 0);
            break;
        }
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
      case CharacterState.Striking:
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
    } else {
      character.stateFrameCount++;
      character.stateFrameCount %=
          100; // prevents the frame count digits getting over 2
    }
  }

  void throwGrenade(Player player, double angle, double strength) {
    double speed = settings.grenadeSpeed * strength;
    Grenade grenade =
        Grenade(player, adj(angle, speed), opp(angle, speed), 0.8 * strength);
    grenades.add(grenade);
    delayed(() {
      grenades.remove(grenade);
      spawnExplosion(grenade);
    }, ms: settings.grenadeDuration);
  }

  Bullet spawnBullet(Character character) {
    double d = 5;
    double x = character.x + adj(character.aimAngle, d);
    double y = character.y + opp(character.aimAngle, d);

    double weaponAccuracy = getWeaponAccuracy(character.weapon);
    double bulletSpeed = getBulletSpeed(character.weapon);

    double xv =
        velX(character.aimAngle + giveOrTake(weaponAccuracy), bulletSpeed);

    double yv =
        velY(character.aimAngle + giveOrTake(weaponAccuracy), bulletSpeed);

    double range = getWeaponRange(character.weapon) +
        giveOrTake(settings.weaponRangeVariation);

    int damage = getWeaponDamage(character.weapon);

    for (int i = 0; i < bullets.length; i++) {
      if (bullets[i].active) continue;
      Bullet bullet = bullets[i];
      bullet.active = true;
      bullet.xStart = x;
      bullet.yStart = y;
      bullet.x = x;
      bullet.y = y;
      bullet.xv = xv;
      bullet.yv = yv;
      bullet.owner = character;
      bullet.range = range;
      bullet.damage = damage;
      bullet.weapon = character.weapon;
      return bullet;
    }

    Bullet bullet = Bullet(x, y, xv, yv, character, range, damage);
    bullets.add(bullet);
    return bullet;
  }

  Npc spawnZombie(double x, double y) {
    for (int i = 0; i < zombies.length; i++) {
      if (zombies[i].active) continue;
      Npc npc = zombies[i];
      npc.active = true;
      npc.state = CharacterState.Idle;
      npc.previousState = CharacterState.Idle;
      npc.health = settings.health.zombie;
      npc.x = x;
      npc.y = y;
      npc.yv = 0;
      npc.xv = 0;
      onNpcSpawned(npc);
      return npc;
    }

    Npc npc =
        Npc(x: x, y: y, health: settings.health.zombie, weapon: Weapon.Unarmed);
    zombies.add(npc);
    onNpcSpawned(npc);
    return npc;
  }

  Npc spawnRandomZombie() {
    if (zombieSpawnPoints.isEmpty) throw ZombieSpawnPointsEmptyException();
    Vector2 spawnPoint = randomItem(zombieSpawnPoints);
    return spawnZombie(spawnPoint.x + giveOrTake(radius.zombieSpawnVariation),
        spawnPoint.y + giveOrTake(radius.zombieSpawnVariation));
  }

  int get zombieCount {
    int count = 0;
    for (Npc npc in zombies) {
      if (!npc.alive) continue;
      count++;
    }
    return count;
  }

  // TODO Optimize
  void dispatch(GameEventType type, double x, double y,
      [double xv = 0, double xy = 0]) {
    gameEvents.add(GameEvent(type, x, y, xv, xy));
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

    double range = getWeaponRange(npc.weapon);
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
    // TODO Expensive operation
    for (int i = 0; i < gameEvents.length; i++) {
      if (gameEvents[i].frameDuration-- < 0) {
        gameEvents.removeAt(i);
        i--;
      }
    }
  }

  void _updateItems() {
    for (int i = 0; i < items.length; i++) {
      Item item = items[i];

      // TODO Optimize
      if (item.duration-- <= 0) {
        items.removeAt(i);
        i--;
        continue;
      }
      for (Player player in players) {
        if (diffOver(item.x, player.x, radius.item)) continue;
        if (diffOver(item.y, player.y, radius.item)) continue;
        if (player.dead) continue;

        // @on item collectable

        switch (item.type) {
          case ItemType.Handgun:
            // @on handgun acquired
            if (player.acquiredHandgun) {
              if (player.rounds.handgun >= constants.maxRounds.handgun)
                continue;
              player.rounds.handgun = min(
                  player.rounds.handgun + settings.pickup.handgun,
                  constants.maxRounds.handgun);
              dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
              break;
            }
            player.clips.handgun = settings.maxClips.handgun;
            player.rounds.handgun = settings.pickup.handgun;
            player.weapon = Weapon.HandGun;
            break;
          case ItemType.Shotgun:
            // @on shotgun acquired
            if (player.acquiredShotgun) {
              if (player.rounds.shotgun >= constants.maxRounds.shotgun)
                continue;
              player.rounds.shotgun = clampInt(
                  player.rounds.shotgun + settings.pickup.shotgun,
                  0,
                  constants.maxRounds.shotgun);
              dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
              break;
            }
            player.rounds.shotgun = settings.pickup.shotgun;
            player.weapon = Weapon.Shotgun;
            break;
          case ItemType.SniperRifle:
            // @on sniper rifle acquired
            if (player.acquiredSniperRifle) {
              if (player.rounds.sniperRifle >= constants.maxRounds.sniperRifle)
                continue;
              player.rounds.sniperRifle = clampInt(
                  player.rounds.sniperRifle + settings.pickup.sniperRifle,
                  0,
                  constants.maxRounds.sniperRifle);
              dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
              break;
            }
            player.rounds.sniperRifle = settings.pickup.sniperRifle;
            player.weapon = Weapon.SniperRifle;
            break;
          case ItemType.Assault_Rifle:
            // @on assault rifle acquired
            if (player.acquiredAssaultRifle) {
              if (player.rounds.assaultRifle >=
                  constants.maxRounds.assaultRifle) continue;
              player.rounds.assaultRifle = clampInt(
                  player.rounds.assaultRifle +
                      constants.maxRounds.assaultRifle ~/ 5,
                  0,
                  constants.maxRounds.assaultRifle);
              dispatch(GameEventType.Ammo_Acquired, item.x, item.y);
              break;
            }
            player.rounds.assaultRifle = settings.pickup.assaultRifle;
            player.weapon = Weapon.AssaultRifle;
            break;
          case ItemType.Credits:
            player.earnPoints(settings.collectCreditAmount);
            dispatch(GameEventType.Credits_Acquired, item.x, item.y);
            break;
          case ItemType.Health:
            if (player.health >= player.maxHealth) continue;
            player.health = player.maxHealth;
            dispatch(GameEventType.Health_Acquired, item.x, item.y);
            break;
          case ItemType.Grenade:
            if (player.grenades >= settings.maxGrenades) continue;
            player.grenades++;
            dispatch(GameEventType.Item_Acquired, item.x, item.y);
            break;
        }

        items.removeAt(i);
        i--;
      }
    }
  }

  void _updateSpawnPointCollisions() {
    for (int i = 0; i < players.length; i++) {
      Player player = players[i];
      for (SpawnPoint spawnPoint in spawnPoints){
        if (diffOver(player.x, spawnPoint.x, settings.radius.spawnPoint)) continue;
        if (diffOver(player.y, spawnPoint.y, settings.radius.spawnPoint)) continue;
        for(SpawnPoint point in spawnPoint.game.spawnPoints){
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
    if (environmentObject.type == EnvironmentObjectType.House02) {}
    ;
  }
}
