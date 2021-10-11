import 'dart:math';

import '../classes.dart';
import '../common/GameState.dart';
import '../common/ItemType.dart';
import '../common/Tile.dart';
import '../common/classes/Vector2.dart';
import '../common/constants.dart';
import '../common/functions/diffOver.dart';
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
import 'Crate.dart';
import 'Inventory.dart';
import 'Item.dart';
import 'Player.dart';
import 'Scene.dart';
import 'TileNode.dart';

class Fortress extends Game {
  int nextWave = 100;
  int wave = 0;
  int lives = 10;

  Map<TileNode, List<Vector2>> nodeToFortress = Map();

  Fortress({required int maxPlayers})
      : super(GameType.Fortress, scenes.fortress, maxPlayers);

  void update() {
    if (lives <= 0) return;

    for (int i = 0; i < zombies.length; i++) {
      Npc npc = zombies[i];
      if (npc.path.isEmpty) {
        npcSetPathTo(npc, scene.fortressPosition.x, scene.fortressPosition.y);
        continue;
      }

      if (diff(npc.x, scene.fortressPosition.x) > 50) continue;
      if (diff(npc.y, scene.fortressPosition.y) > 50) continue;
      zombies.removeAt(i);
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
      rounds: Rounds(handgun: constants.maxRounds.handgun),
    );

    return player;
  }
}

class DeathMatch extends Game {
  final int squadSize;
  bool teamsEnabled = false;

  int get numberOfSquads => maxPlayers ~/ squadSize;

  int get nextSquadNumber {
    if( !teamsEnabled) return -1;
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
        rounds: Rounds(handgun: constants.maxRounds.handgun),
        squad: squad);

    return player;
  }
}

class GameCasual extends Game {
  int totalSquads = 4;
  final int spawnGrenades = 1;
  final int spawnMeds = 1;

  GameCasual(Scene scene, int maxPlayers)
      : super(GameType.Casual, scene, maxPlayers) {
    spawnRandomNpcs(10);
  }

  void spawnRandomNpcs(int amount) {
    for (int i = 0; i < amount; i++) {
      spawnRandomNpc();
    }
  }

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
    resetPlayer(player);
  }

  @override
  void onNpcKilled(Npc npc) {
    // @on npc killed
    // items.add(Item(type: ItemType.Health, x: npc.x, y: npc.y));
    if (chance(settings.chanceOfDropItem)) {
      spawnRandomItem(npc.x, npc.y);
      return;
    }
  }

  @override
  void onNpcSpawned(Npc npc) {
    if (chance(0.05)) {
      npc.pointMultiplier = 5;
    } else {
      npc.pointMultiplier = 1;
    }
  }

  Clips spawnClip() {
    return Clips(handgun: 3, shotgun: 3, sniperRifle: 2, assaultRifle: 2);
  }

  Rounds spawnRounds() {
    return Rounds(
      handgun: constants.maxRounds.handgun ~/ 2,
      shotgun: 0,
      sniperRifle: 0,
      assaultRifle: 0,
    );
  }

  int getNextSquad() {
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

    resetPlayer(player);
    return player;
  }

  @override
  void onPlayerRevived(Player player) {
    resetPlayer(player);
  }

  void resetPlayer(Player player) {
    player.resetPoints();
    player.meds = spawnMeds;
    player.grenades = spawnGrenades;
    player.clips = spawnClip();
    player.rounds = spawnRounds();
    player.squad = getNextSquad();
    player.weapon = Weapon.HandGun;
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
  List<Npc> zombies = [];
  List<InteractableNpc> npcs = [];
  List<Player> players = [];
  List<Bullet> bullets = [];
  List<Grenade> grenades = [];
  List<GameEvent> gameEvents = [];
  List<Crate> crates = [];
  final List<Collectable> collectables = [];
  final List<Vector2> playerSpawnPoints = [];
  final List<Item> items = [];
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

  void onNpcKilled(Npc npc) {}

  void onPlayerDisconnected(Player player) {}

  void onPlayerRevived(Player player) {}

  void onNpcSpawned(Npc npc) {}

  bool gameOver();

  Game(this.type, this.scene, this.maxPlayers) {
    this.crates.clear();
    for (Vector2 crate in scene.crates) {
      crates.add(Crate(x: crate.x, y: crate.y));
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
        }
      }
    }
  }
}

extension GameFunctions on Game {
  void updateAndCompile() {
    // @on update game
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
      _updateItems();
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
        changeCharacterHealth(npc.target, -settings.damage.zombieStrike);

        double speed = 0.1;
        double rotation = radiansBetweenObject(npc, npc.target);
        dispatch(GameEventType.Zombie_Strike, npc.target.x, npc.target.y,
            velX(rotation, speed), velY(rotation, speed));
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

    for (int i = 0; i < zombies.length; i++) {
      updateCharacter(zombies[i]);
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
    zombies.sort(compareGameObjects);
    players.sort(compareGameObjects);
    updateCollisionBetween(zombies);
    updateCollisionBetween(players);
    resolveCollisionBetween(zombies, players);
    // handleBlockCollisions(players);
    // handleBlockCollisions(zombies);
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
      player.stateDuration = settings.coolDown.clipEmpty;
      dispatch(GameEventType.Clip_Empty, player.x, player.y, 0, 0);
      return;
    }

    double d = 15;
    double x = player.x + adj(player.aimAngle, d);
    double y = player.y + opp(player.aimAngle, d) - 5;
    player.state = CharacterState.Firing;

    switch (player.weapon) {
      case Weapon.HandGun:
        // @on character fire handgun
        player.rounds.handgun--;
        Bullet bullet = spawnBullet(player);
        player.stateDuration = coolDown.handgun;
        dispatch(GameEventType.Handgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.Shotgun:
        // @on character fire shotgun
        player.rounds.shotgun--;
        player.xv += velX(player.aimAngle + pi, 1);
        player.yv += velY(player.aimAngle + pi, 1);
        for (int i = 0; i < settings.shotgunBulletsPerShot; i++) {
          spawnBullet(player);
        }
        Bullet bullet = bullets.last;
        player.stateDuration = coolDown.shotgun;
        dispatch(GameEventType.Shotgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.SniperRifle:
        // @on character fire sniper rifle
        player.rounds.sniperRifle--;
        Bullet bullet = spawnBullet(player);
        player.stateDuration = coolDown.sniperRifle;
        dispatch(GameEventType.SniperRifle_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.AssaultRifle:
        // @on character fire assault rifle
        player.rounds.assaultRifle--;
        Bullet bullet = spawnBullet(player);
        player.stateDuration = coolDown.assaultRifle;
        dispatch(GameEventType.MachineGun_Fired, x, y, bullet.xv, bullet.yv);
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
        // TODO Fix hack
        _characterFireWeapon(character as Player);
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
        }
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

    for (Crate crate in crates) {
      if (crate.active) continue;
      crate.deactiveDuration--;
    }

    bullets.sort(compareGameObjects);
    checkBulletCollision(zombies);
    checkBulletCollision(players);

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
    items.add(Item(type: randomValue(itemTypes), x: x, y: y));
  }

  void spawnExplosion(Grenade grenade) {
    double x = grenade.x;
    double y = grenade.y;

    dispatch(GameEventType.Explosion, x, y, 0, 0);


    for (Crate crate in crates) {
      if (!crate.active) continue;
      if (diffOver(grenade.x, crate.x, settings.grenadeExplosionRadius)) continue;
      if (diffOver(grenade.y, crate.y, settings.grenadeExplosionRadius)) continue;
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
  }

  void updatePlayer(Player player) {
    player.lastUpdateFrame++;

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
            changeCharacterHealth(npc, -settings.damage.knife);
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

        if (bullet.weapon != Weapon.SniperRifle){
          bullet.active = false;
        }

        character.xv += bullet.xv * settings.bulletImpactVelocityTransfer;
        character.yv += bullet.yv * settings.bulletImpactVelocityTransfer;

        if (enemies(bullet, character)) {
          // @on zombie hit by bullet
          changeCharacterHealth(character, -bullet.damage);

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
            owner.score.zombiesKilled++;
            if (character is Npc) {
              owner.earnPoints(
                  constants.points.zombieKilled * character.pointMultiplier);
            }
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

    // TODO magic value
    if (abs(character.xv) > 0.005) {
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

  Npc spawnNpc(double x, double y) {
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

    Npc npc = Npc(x: x, y: y, health: settings.health.zombie);
    zombies.add(npc);
    onNpcSpawned(npc);
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
    for (Npc npc in zombies) {
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

  // TODO Optimize
  void dispatch(GameEventType type, double x, double y, [double xv = 0, double xy = 0]) {
    gameEvents.add(GameEvent(type, x, y, xv, xy));
  }

  void updateNpcTargets() {
    Npc npc;
    for (int i = 0; i < zombies.length; i++) {
      npc = zombies[i];
      if (npc.targetSet) {
        // @on update npc with target
        if (diff(npc.x, npc.target.x) < settings.zombieChaseRange) continue;
        if (diff(npc.y, npc.target.y) < settings.zombieChaseRange) continue;
        npc.clearTarget();
        npc.state = CharacterState.Idle;
        return;
      }

      for (int p = 0; p < players.length; p++) {
        if (!players[p].alive) continue;
        if (diff(players[p].x, npc.x) > settings.npc.viewRange) continue;
        if (diff(players[p].y, npc.y) > settings.npc.viewRange) continue;
        npc.target = players[p];
        break;
      }
    }
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
      TileNode node = randomValue(randomValue(scene.tileNodes));
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
              if (player.rounds.handgun >= constants.maxRounds.handgun) continue;
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
              if (player.rounds.shotgun >= constants.maxRounds.shotgun) continue;
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
              if (player.rounds.assaultRifle >= constants.maxRounds.assaultRifle)
                continue;
              player.rounds.assaultRifle = clampInt(
                  player.rounds.assaultRifle + constants.maxRounds.assaultRifle ~/ 5,
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
}

void applyCratePhysics(Crate crate, List<Character> characters) {
  for (Character character in characters) {
    if (!character.active) continue;
    if (diffOver(crate.x, character.x, radius.crate)) continue;
    if (diffOver(crate.y, character.y, radius.crate)) continue;
    double dis = distance(crate.x, crate.y, character.x, character.y);
    if (dis >= radius.crate) continue;
    double b = radius.crate - dis;
    double r = radiansBetween(crate.x, crate.y, character.x, character.y);
    character.x += adj(r, b);
    character.y += opp(r, b);
  }
}
