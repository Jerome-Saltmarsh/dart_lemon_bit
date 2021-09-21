import 'dart:math';

import '../classes.dart';
import '../common/GameState.dart';
import '../common/Tile.dart';
import '../compile.dart';
import '../constants.dart';
import '../enums.dart';
import '../common/CollectableType.dart';
import '../common/GameEventType.dart';
import '../common/GameType.dart';
import '../common/Weapons.dart';
import '../functions/applyForce.dart';
import '../functions/generateUUID.dart';
import '../instances/scenes.dart';
import '../instances/settings.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import '../update.dart';
import '../utils.dart';
import '../utils/game_utils.dart';
import '../utils/player_utils.dart';
import 'Block.dart';
import 'Collectable.dart';
import 'Inventory.dart';
import 'Player.dart';
import 'Scene.dart';
import 'TileNode.dart';
import 'Vector2.dart';

class Fortress extends Game {
  int nextWave = 100;
  int wave = 0;
  int lives = 10;

  Map<TileNode, List<Vector2>> nodeToFortress = Map();

  Fortress({required int maxPlayers})
      : super(GameType.Fortress, scenes.fortress, maxPlayers);

  void update() {
    if (lives <= 0) return;

    for (int i = 0; i < npcs.length; i++) {
      Npc npc = npcs[i];
      if (npc.path.isEmpty) {
        npcSetPathTo(npc, scene.fortressPosition.x, scene.fortressPosition.y);
        continue;
      }

      if (diff(npc.x, scene.fortressPosition.x) > 50) continue;
      if (diff(npc.y, scene.fortressPosition.y) > 50) continue;
      npcs.removeAt(i);
      i--;
      lives--;
      if (lives <= 0) {
        return;
      }
    }

    if (nextWave > 0) {
      nextWave--;
    } else {
      wave++;
      nextWave = 200;

      for (int row = 0; row < scene.rows; row++) {
        for (int column = 0; column < scene.columns; column++) {
          if (scene.tiles[row][column] == Tile.ZombieSpawn) {
            double x = getTilePositionX(row, column);
            double y = getTilePositionY(row, column);
            for (int i = 0; i < wave; i++) {
              spawnNpc(x + giveOrTake(5), y + giveOrTake(5));
            }
          }
        }
      }
    }
  }

  @override
  bool gameOver() {
    return lives <= 0;
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO auto respawn in 20 seconds
  }

  @override
  Player doSpawnPlayer() {
    Vector2 spawnPoint = getNextSpawnPoint();
    Player player = Player(
      x: spawnPoint.x + giveOrTake(3),
      y: spawnPoint.y + giveOrTake(2),
      inventory: Inventory(3, 3, [
        InventoryItem(0, 0, InventoryItemType.Handgun),
        InventoryItem(0, 1, InventoryItemType.HealthPack),
        InventoryItem(1, 0, InventoryItemType.HandgunClip),
        InventoryItem(2, 2, InventoryItemType.HandgunClip),
        InventoryItem(1, 1, InventoryItemType.ShotgunClip),
      ]),
      grenades: 2,
      meds: 2,
      clips: Clips(handgun: 2),
      rounds: Rounds(handgun: settings.clipSize.handgun),
    );

    return player;
  }
}

class DeathMatch extends Game {
  final int squadSize;

  int get numberOfSquads => maxPlayers ~/ squadSize;

  int get nextSquadNumber {
    if (squadSize <= 1) return -1;

    for (int squad = 0; squad < numberOfSquads; squad++) {
      if (numberOfPlayersOnSquad(squad) < squadSize) return squad;
    }

    throw Exception("this code should never run");
  }

  DeathMatch({required maxPlayers, required this.squadSize})
      : super(GameType.DeathMatch, scenes.town, maxPlayers);

  @override
  void update() {}

  @override
  bool gameOver() {
    return false;
  }

  @override
  void onPlayerDisconnected(Player player) {
    _updateGameState(player);
  }

  @override
  void onPlayerKilled(Player player) {
    _updateGameState(player);
  }

  void _updateGameState(Player player) {
    player.gameState = GameState.Lost;

    if (squadSize == 1) {
      if (numberOfAlivePlayers == 1) {
        for (Player player in players) {
          if (player.alive) player.gameState = GameState.Won;
        }
      }
      return;
    }

    int squad = -1;
    for (Player player in players) {
      if (!player.alive) continue;
      squad = player.squad;
      break;
    }

    for (Player player in players) {
      if (!player.alive) continue;
      if (player.squad == squad) continue;
      return;
    }

    for (Player player in players) {
      if (!player.alive) continue;
      player.gameState = GameState.Won;
    }
  }

  int numberOfPlayersOnSquad(int squad) {
    int count = 0;
    for (Player player in players) {
      if (player.squad != squad) continue;
      count++;
    }
    return count;
  }

  Vector2 getSquadSpawnPoint(int squad) {
    if (squad == -1) return getNextSpawnPoint();
    return playerSpawnPoints[squad % playerSpawnPoints.length];
  }

  @override
  Player doSpawnPlayer() {
    int squad = nextSquadNumber;
    Vector2 spawnPoint = getSquadSpawnPoint(squad);

    Player player = Player(
        x: spawnPoint.x + giveOrTake(3),
        y: spawnPoint.y + giveOrTake(2),
        inventory: Inventory(3, 3, [
          InventoryItem(0, 0, InventoryItemType.Handgun),
          InventoryItem(0, 1, InventoryItemType.HealthPack),
          InventoryItem(1, 0, InventoryItemType.HandgunClip),
          InventoryItem(2, 2, InventoryItemType.HandgunClip),
          InventoryItem(1, 1, InventoryItemType.ShotgunClip),
        ]),
        grenades: 2,
        meds: 2,
        clips: Clips(handgun: 2),
        rounds: Rounds(handgun: settings.clipSize.handgun),
        squad: squad);

    return player;
  }
}

class GameCasual extends Game {
  int totalSquads = 4;

  final int spawnGrenades = 1;
  final int spawnMeds = 1;

  GameCasual(Scene scene, int maxPlayers)
      : super(GameType.Casual, scene, maxPlayers);

  @override
  bool gameOver() {
    return false;
  }

  @override
  void update() {
    if (duration % 50 == 0 && zombieCount < 100) {
      Npc npc = spawnRandomNpc();
      npcSetRandomDestination(npc);
    }
  }

  @override
  void onPlayerKilled(Player player) {
    player.points = 0;
    player.clips = spawnClip();
    player.rounds = spawnRounds();
    player.meds = spawnMeds;
    player.grenades = spawnGrenades;
    player.squad = getNextSquad();
  }

  Clips spawnClip() {
    return Clips(handgun: 3, shotgun: 3, sniperRifle: 2, assaultRifle: 2);
  }

  Rounds spawnRounds(){
    return Rounds(
      handgun: settings.clipSize.handgun,
      shotgun: settings.clipSize.shotgun,
      sniperRifle: settings.clipSize.sniperRifle,
      assaultRifle: settings.clipSize.assaultRifle,
    );
  }

  int getNextSquad(){
    int playersInSquad0 = numberOfPlayersInSquad(0);
    int playersInSquad1 = numberOfPlayersInSquad(1);
    int playersInSquad2 = numberOfPlayersInSquad(2);
    int playersInSquad3 = numberOfPlayersInSquad(3);

    int squad = 0;
    int minSquad = playersInSquad0;

    if (playersInSquad1 < minSquad) {
      minSquad = playersInSquad1;
      squad = 1;
    }
    if (playersInSquad2 < minSquad) {
      minSquad = playersInSquad2;
      squad = 2;
    }
    if (playersInSquad3 < minSquad) {
      minSquad = playersInSquad3;
      squad = 3;
    }

    return squad;
  }

  @override
  Player doSpawnPlayer() {
    // @on spawn player casual
    Vector2 spawnPoint = getNextSpawnPoint();
    Player player = Player(
      x: spawnPoint.x + giveOrTake(3),
      y: spawnPoint.y + giveOrTake(2),
      inventory: Inventory(3, 3, [
        InventoryItem(1, 1, InventoryItemType.ShotgunClip),
      ]),
      grenades: spawnGrenades,
      meds: spawnMeds,
      clips: spawnClip(),
      rounds: spawnRounds(),
    );

    player.squad = getNextSquad();
    player.acquiredHandgun = true;
    player.acquiredShotgun = false;
    player.acquiredSniperRifle = false;
    player.acquiredAssaultRifle = false;
    return player;
  }
}

abstract class Game {
  static int _id = 0;
  final String id = (_id++).toString();
  final String uuid = generateUUID();
  final GameType type;
  final int maxPlayers;
  final Scene scene;
  int duration = 0;
  List<Npc> npcs = [];
  List<Player> players = [];
  List<Bullet> bullets = [];
  List<Grenade> grenades = [];
  List<GameEvent> gameEvents = [];
  final List<Collectable> collectables = [];
  final List<Vector2> playerSpawnPoints = [];
  int spawnPointIndex = 0;
  final List<Vector2> zombieSpawnPoints = [];
  String compiled = "";
  String compiledTiles = "";
  bool compilePaths = false;

  // TODO doesn't belong here
  StringBuffer buffer = StringBuffer();

  Player doSpawnPlayer();

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

  void onPlayerDisconnected(Player player) {}

  bool gameOver();

  Game(this.type, this.scene, this.maxPlayers) {
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
        }
      }
    }
  }
}

extension GameFunctions on Game {
  void updateAndCompile() {
    if (!gameOver()) {
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
    }
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
        }
        collectables[i].active = false;
        // TODO expensive call
        delayed(() {
          activateCollectable(collectables[i]);
        }, seconds: settings.itemReactivationInSeconds);
      }
    }
  }

  void activateCollectable(Collectable collectable) {
    collectable.active = true;
    collectable.setType(randomCollectableType);
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
      if (npcWithinStrikeRange(npc, npc.target)) {
        // @on npc target within striking range
        characterFaceObject(npc, npc.target);
        setCharacterState(npc, CharacterState.Striking);
        changeCharacterHealth(npc.target, -zombieStrikeDamage);

        double speed = 0.1;
        double rotation = radiansBetweenObject(npc, npc.target);
        dispatch(GameEventType.Zombie_Strike, npc.target.x, npc.target.y, velX(rotation, speed), velY(rotation, speed));
        return;
      }

      // @on npc update find
      if (frame % 30 == 0) {
        npc.path = scene.findPath(npc.x, npc.y, npc.target.x, npc.target.y);
      }

      if (npc.path.length <= 1 && !npcWithinStrikeRange(npc, npc.target)) {
        characterFaceObject(npc, npc.target);
        setCharacterState(npc, CharacterState.Walking);
        return;
      }
    }

    if (npc.path.isNotEmpty) {
      if (arrivedAtPath(npc)) {
        // @on npc arrived at path
        npc.path.removeAt(0);
        npc.state = CharacterState.Idle;
        return;
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

    for (int i = 0; i < npcs.length; i++) {
      updateCharacter(npcs[i]);
    }
  }

  void handleBlockCollisions(List<GameObject> gameObjects) {
    for (int i = 0; i < gameObjects.length; i++) {
      GameObject gameObject = gameObjects[i];
      for (int j = 0; j < scene.blocks.length; j++) {
        Block block = scene.blocks[j];
        if (block.rightX < gameObject.left) continue;
        if (gameObject.right < block.leftX) break;
        if (gameObject.y < block.topY) continue;
        if (gameObject.y > block.bottomY) continue;

        if (gameObject.x < block.topX && gameObject.y < block.leftY) {
          double xd = block.topX - gameObject.x;
          double yd = gameObject.y - block.topY;
          if (yd > xd) {
            gameObject.x = block.topX - yd;
            gameObject.y--;
          }
          continue;
        }

        if (gameObject.x < block.bottomX && gameObject.y > block.leftY) {
          double xd = gameObject.x - block.leftX;
          double yd = gameObject.y - block.leftY;
          if (xd > yd) {
            gameObject.x -= xd - yd;
            gameObject.y += xd - yd;
          }
          continue;
        }
        if (gameObject.x > block.topX && gameObject.y < block.rightY) {
          double xd = gameObject.x - block.topX;
          double yd = gameObject.y - block.topY;

          if (yd > xd) {
            gameObject.x += yd - xd;
            gameObject.y -= yd - xd;
          }
          continue;
        }

        if (gameObject.x > block.bottomX && gameObject.y > block.rightY) {
          double xd = block.rightX - gameObject.x;
          double yd = gameObject.y - block.rightY;
          if (xd > yd) {
            gameObject.x += xd - yd;
            gameObject.y += xd - yd;
          }
          continue;
        }
      }
    }
  }

  void _updateCollisions() {
    npcs.sort(compareGameObjects);
    players.sort(compareGameObjects);
    updateCollisionBetween(npcs);
    updateCollisionBetween(players);
    resolveCollisionBetween(npcs, players);

    handleBlockCollisions(players);
    handleBlockCollisions(npcs);
  }

  Player? findPlayerById(int id) {
    for (Player player in players) {
      if (player.id == id) return player;
    }
    return null;
  }

  void _characterFireWeapon(Player player) {
    if (player.dead) return;
    if (player.stateDuration > 0) return;
    faceAimDirection(player);

    if (equippedWeaponRounds(player) <= 0) {
      // @on character insufficient bullets to fire
      player.stateDuration = settingsClipEmptyCooldown;
      dispatch(GameEventType.Clip_Empty, player.x, player.y, 0, 0);
      return;
    }

    double d = 15;
    double x = player.x + adj(player.aimAngle, d);
    double y = player.y + opp(player.aimAngle, d) - 5;

    switch (player.weapon) {
      case Weapon.HandGun:
        // @on character fire handgun
        player.rounds.handgun--;
        Bullet bullet = spawnBullet(player);
        player.state = CharacterState.Firing;
        player.stateDuration = settingsHandgunCooldown;
        dispatch(GameEventType.Handgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.Shotgun:
        // @on character fire shotgun
        player.rounds.shotgun--;
        player.xv += velX(player.aimAngle + pi, 1);
        player.yv += velY(player.aimAngle + pi, 1);
        for (int i = 0; i < settingsShotgunBulletsPerShot; i++) {
          spawnBullet(player);
        }
        Bullet bullet = bullets.last;
        player.state = CharacterState.Firing;
        player.stateDuration = shotgunCoolDown;
        dispatch(GameEventType.Shotgun_Fired, x, y, bullet.xv,
            bullet.yv);
        break;
      case Weapon.SniperRifle:
        // @on character fire sniper rifle
        player.rounds.sniperRifle--;
        Bullet bullet = spawnBullet(player);
        player.state = CharacterState.Firing;
        player.stateDuration = settingsSniperCooldown;
        dispatch(GameEventType.SniperRifle_Fired, x, y, bullet.xv,
            bullet.yv);
        break;
      case Weapon.AssaultRifle:
        // @on character fire assault rifle
        player.rounds.assaultRifle--;
        Bullet bullet = spawnBullet(player);
        player.state = CharacterState.Firing;
        player.stateDuration = settings.machineGunCoolDown;
        dispatch(GameEventType.MachineGun_Fired, x, y, bullet.xv,
            bullet.yv);
        break;
    }
  }

  void setCharacterState(Character character, CharacterState value) {
    // @on character set state
    if (character.dead) return;
    if (character.state == value) return;
    if (value != CharacterState.Dead && character.stateDuration > 0) return;

    switch (value) {
      case CharacterState.Running:
        // @on character running
        if (character is Player && character.stamina <= minStamina) {
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

          for (Npc npc in npcs) {
            if (npc.target != character) continue;
            // @on npc target player killed
            npc.clearTarget();
          }
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
        // TODO Fix hack
        _characterFireWeapon(character as Player);
        break;
      case CharacterState.Striking:
        // @on character striking
        character.stateDuration = 10;
        break;
      case CharacterState.Reloading:
        // @on reload weapon
        Player player = character as Player;

        switch (character.weapon) {
          case Weapon.HandGun:
            // @on reload handgun
            if (player.rounds.handgun >= settings.clipSize.handgun) return;
            if (player.clips.handgun <= 0) return;
            player.rounds.handgun = settings.clipSize.handgun;
            player.clips.handgun--;
            player.stateDuration = settings.reloadDuration.handgun;
            break;
          case Weapon.Shotgun:
            // @on reload shotgun
            if (player.rounds.shotgun >= settings.clipSize.shotgun) return;
            if (player.clips.shotgun <= 0) return;
            player.rounds.shotgun = settings.clipSize.shotgun;
            player.clips.shotgun--;
            player.stateDuration = settings.reloadDuration.shotgun;
            break;
          case Weapon.SniperRifle:
            // @on reload sniper rifle
            if (player.rounds.sniperRifle >= settings.clipSize.sniperRifle) return;
            if (player.clips.sniperRifle <= 0) return;
            player.rounds.sniperRifle = settings.clipSize.sniperRifle;
            player.clips.sniperRifle--;
            player.stateDuration = settings.reloadDuration.sniperRifle;
            break;
          case Weapon.AssaultRifle:
            // @on reload assault rifle
            if (player.rounds.assaultRifle >= settings.clipSize.assaultRifle)
              return;
            if (player.clips.assaultRifle <= 0) return;
            player.rounds.assaultRifle = settings.clipSize.assaultRifle;
            player.clips.assaultRifle--;
            player.stateDuration = settings.reloadDuration.assaultRifle;
            break;
        }
        break;
    }
    character.state = value;
  }

  void setCharacterStateIdle(Character character) {
    setCharacterState(character, CharacterState.Idle);
  }

  void changeCharacterHealth(Character character, double amount) {
    // @on change character health
    if (character.dead) return;

    character.health += amount;
    character.health = clamp(character.health, 0, character.maxHealth);
    if (character.health <= 0) {
      setCharacterState(character, CharacterState.Dead);
    }
  }

  void _updateBullets() {
    // @on update bullet
    for (int i = 0; i < bullets.length; i++) {
      if (!bullets[i].active) continue;
      Bullet bullet = bullets[i];
      bullet.x += bullet.xv;
      bullet.y += bullet.yv;
      if (bulletDistanceTravelled(bullet) > bullet.range) {
        dispatch(GameEventType.Bullet_Hole, bullet.x, bullet.y, 0, 0);
        bullet.active = false;
      }
    }

    for (int i = 0; i < bullets.length; i++) {
      if (scene.tileBoundaryAt(bullets[i].x, bullets[i].y)) {
        bullets[i].active = false;
      }
    }

    bullets.sort(compareGameObjects);
    // _checkBulletBlockCollision();
    checkBulletCollision(npcs);
    checkBulletCollision(players);
  }

  void spawnExplosion(Grenade grenade) {
    double x = grenade.x;
    double y = grenade.y;

    dispatch(GameEventType.Explosion, x, y, 0, 0);
    for (Character character in npcs) {
      if (objectDistanceFrom(character, x, y) > settingsGrenadeExplosionRadius)
        continue;
      double rotation = radiansBetween2(character, x, y);
      double magnitude = 10;
      applyForce(character, rotation + pi, magnitude);

      if (character.alive) {
        changeCharacterHealth(character, -settingsGrenadeExplosionDamage);

        if (!character.alive) {
          // @on npc killed by grenade
          grenade.owner.points += settings.pointsEarned.zombieKilled;

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
      if (objectDistanceFrom(player, x, y) > settingsGrenadeExplosionRadius)
        continue;
      double rotation = radiansBetween2(player, x, y);
      double magnitude = 10;
      applyForce(player, rotation + pi, magnitude);

      if (player.alive) {
        changeCharacterHealth(player, -settingsGrenadeExplosionDamage);
        if (!player.alive) {
          // @on player killed by grenade
          if (!sameTeam(player, grenade.owner)) {
            grenade.owner.points += settings.pointsEarned.playerKilled;
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
    for (Npc npc in npcs) {
      updateNpc(npc);
    }
  }

  void updatePlayer(Player player) {
    if (player.lastEventFrame++ > 5 && player.walking) {
      setCharacterStateIdle(player);
    }

    if (player.running) {
      player.stamina -= 3;
      if (player.stamina <= 0) {
        setCharacterState(player, CharacterState.Walking);
      }
    } else if (player.walking) {
      player.stamina += settings.staminaRefreshRate;
    } else if (player.idling) {
      player.stamina += settings.staminaRefreshRate;
    } else if (player.aiming) {
      player.stamina += settings.staminaRefreshRate;
    } else if (player.firing) {
      player.stamina += settings.staminaRefreshRate;
    }
    player.stamina = clampInt(player.stamina, 0, player.maxStamina);
    player.currentTile = scene.tileAt(player.x, player.y);
  }

  void _updateGrenades() {
    for (Grenade grenade in grenades) {
      applyMovement(grenade);
      applyFriction(grenade, settingsGrenadeFriction);
      grenade.zv -= settings.grenadeGravity;
      if (grenade.z < 0) {
        grenade.z = 0;
      }
    }
  }

  void checkBulletCollision(List<Character> characters) {
    int s = 0;
    for (int i = 0; i < bullets.length; i++) {
      if (!bullets[i].active) continue;
      Bullet bullet = bullets[i];
      for (int j = s; j < characters.length; j++) {
        Character character = characters[j];
        if (!character.active) continue;
        if (character.dead) continue;
        if (character.left > bullet.right) break;
        if (bullet.left > character.right) {
          s++;
          continue;
        }
        if (bullet.top > character.bottom) continue;
        if (bullet.bottom < character.top) continue;

        bullet.active = false;

        character.xv += bullet.xv * bulletImpactVelocityTransfer;
        character.yv += bullet.yv * bulletImpactVelocityTransfer;

        if (bullet.squad == noSquad || bullet.squad != character.squad) {
          changeCharacterHealth(character, -bullet.damage);

          if (character is Player) {
            if (character.dead) {
              if (bullet.owner is Player) {
                // @on player killed by player
                Player owner = bullet.owner as Player;
                owner.points += 10;
                owner.credits += 10;
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
            owner.score.zombiesKilled++;
            owner.points += 5;
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
    npcs.clear();
  }

  void updateCharacter(Character character) {
    if (!character.active) return;

    // TODO magic value
    if (abs(character.xv) > 0.005) {
      character.x += character.xv;
      character.y += character.yv;
      character.xv *= velocityFriction;
      character.yv *= velocityFriction;
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

    while (scene.tileBoundaryAt(character.left, character.top)) {
      character.x++;
      character.y++;
    }
    while (scene.tileBoundaryAt(character.right, character.top)) {
      character.x--;
      character.y++;
    }
    while (scene.tileBoundaryAt(character.left, character.bottom)) {
      character.x++;
      character.y--;
    }
    while (scene.tileBoundaryAt(character.right, character.bottom)) {
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
    double speed = settingsGrenadeSpeed * strength;
    Grenade grenade =
        Grenade(player, adj(angle, speed), opp(angle, speed), 0.8 * strength);
    grenades.add(grenade);
    delayed(() {
      grenades.remove(grenade);
      spawnExplosion(grenade);
    }, ms: settingsGrenadeDuration);
  }

  Bullet spawnBullet(Character character) {
    double d = 5;
    double x = character.x + adj(character.aimAngle, d);
    double y = character.y + opp(character.aimAngle, d);

    double weaponAccuracy = getWeaponAccuracy(character.weapon);
    double bulletSpeed = getWeaponBulletSpeed(character.weapon);

    double xv =
        velX(character.aimAngle + giveOrTake(weaponAccuracy), bulletSpeed);

    double yv =
        velY(character.aimAngle + giveOrTake(weaponAccuracy), bulletSpeed);

    double range = getWeaponRange(character.weapon) +
        giveOrTake(settingsWeaponRangeVariation);

    double damage = getWeaponDamage(character.weapon);

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
      return bullet;
    }

    Bullet bullet = Bullet(x, y, xv, yv, character, range, damage);
    bullets.add(bullet);
    return bullet;
  }

  Npc spawnNpc(double x, double y) {
    for (int i = 0; i < npcs.length; i++) {
      if (npcs[i].active) continue;
      Npc npc = npcs[i];
      npc.active = true;
      npc.state = CharacterState.Idle;
      npc.previousState = CharacterState.Idle;
      npc.health = 3;
      npc.x = x;
      npc.y = y;
      return npc;
    }

    Npc npc = Npc(x: x, y: y, health: zombieHealth, maxHealth: zombieHealth);
    npcs.add(npc);
    return npc;
  }

  Npc spawnRandomNpc() {
    if (zombieSpawnPoints.isEmpty)
      throw Exception(
          "spawnRandomNpc() Error -No zombie spawn points available");
    Vector2 spawnPoint = randomValue(zombieSpawnPoints);
    return spawnNpc(spawnPoint.x + giveOrTake(5), spawnPoint.y + giveOrTake(5));
  }

  int get zombieCount {
    int count = 0;
    for (Npc npc in npcs) {
      if (!npc.alive) continue;
      count++;
    }
    return count;
  }

  Player spawnPlayer() {
    Player player = doSpawnPlayer();
    players.add(player);
    return player;
  }

  void dispatch(GameEventType type, double x, double y, double xv, double xy) {
    gameEvents.add(GameEvent(type, x, y, xv, xy));
  }

  void updateNpcTargets() {
    Npc npc;
    for (int i = 0; i < npcs.length; i++) {
      npc = npcs[i];
      if (npc.targetSet) {
        // @on update npc with target
        if (diff(npc.x, npc.target.x) < zombieChaseRange) continue;
        if (diff(npc.y, npc.target.y) < zombieChaseRange) continue;
        npc.clearTarget();
        npc.state = CharacterState.Idle;
        return;
      }

      for (int p = 0; p < players.length; p++) {
        if (!players[p].alive) continue;
        if (diff(players[p].x, npc.x) > zombieViewRange) continue;
        if (diff(players[p].y, npc.y) > zombieViewRange) continue;
        npc.target = players[p];
        break;
      }
    }
  }

  void jobNpcWander() {
    for (Npc npc in npcs) {
      if (npc.inactive) continue;
      if (npc.busy) continue;
      if (npc.dead) continue;
      if (npc.targetSet) continue;
      if (npc.path.isNotEmpty) continue;
      if (chance(0.25)) return;
      // @on npc set random destination
      npcSetRandomDestination(npc);
    }
  }

  void jobRemoveDisconnectedPlayers() {
    for (int i = 0; i < players.length; i++) {
      if (players[i].lastEventFrame > settingsPlayerDisconnectFrames) {
        Player player = players[i];
        for (Npc npc in npcs) {
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
  }

  void revive(Character character) {
    print('revive(${character.id})');
    character.state = CharacterState.Idle;
    character.health = character.maxHealth;

    for (Npc npc in npcs) {
      if (npc.target == character) {
        npc.clearTarget();
      }
    }

    if (playerSpawnPoints.isEmpty) {
      character.x = giveOrTake(settingsPlayerStartRadius);
      character.y = tilesLeftY + giveOrTake(settingsPlayerStartRadius);
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
      TileNode node = scene.tileNodes[randomInt(0, scene.rows)]
          [randomInt(0, scene.columns)];
      if (node.open) {
        return node;
      }
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
}
