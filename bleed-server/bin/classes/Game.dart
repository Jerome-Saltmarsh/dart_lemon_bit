import 'dart:math';

import '../classes.dart';
import '../compile.dart';
import '../constants.dart';
import '../enums.dart';
import '../enums/GameEventType.dart';
import '../enums/GameType.dart';
import '../enums/Weapons.dart';
import '../extensions/settings-extensions.dart';
import '../functions/applyForce.dart';
import '../instances/settings.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import '../update.dart';
import '../utils.dart';
import 'Block.dart';

class Game {
  static int _id = 0;
  final String id = (_id++).toString();
  final GameType type;
  final List<List<Tile>> tiles;
  final int maxPlayers;
  List<Npc> npcs = [];
  List<Player> players = [];
  List<Bullet> bullets = [];
  List<Grenade> grenades = [];
  List<GameObject> objects = [];
  List<Block> blocks = [];
  List<GameEvent> gameEvents = [];
  String compiled = "";
  StringBuffer buffer = StringBuffer();

  Game(this.type, this.tiles, this.maxPlayers);
}

extension GameFunctions on Game {

  void updateAndCompile() {
    updateCharacters();
    updateCollisions();
    updateBullets();
    updateBullets(); // called twice to fix collision detection
    updateNpcs();
    updateGameEvents();
    updateGrenades();
    compileState(this);
  }

  void sortBlocks(){
    blocks.sort((a, b) => a.leftX < b.leftX ? -1 : 1);
  }

  void updateNpc(Npc npc) {
    if (npc.dead) return;

    // todo this belongs in update character
    if (npc.state == CharacterState.Striking) {
      if (npc.stateDuration-- > 0) return;
      setCharacterStateIdle(npc);
    }

    if (npc.targetSet) {
      if (!npc.target.active) {
        npc.clearTarget();
        npc.idle();
        return;
      }
      characterFaceObject(npc, npc.target);
      if (npcWithinStrikeRange(npc, npc.target)) {
        setCharacterState(npc, CharacterState.Striking);
        changeCharacterHealth(npc.target, -zombieStrikeDamage);
        dispatch(GameEventType.Zombie_Strike, npc.x, npc.y, 0, 0);
      } else {
        npc.walk();
      }
      return;
    }

    if (npc.destinationSet) {
      if (arrivedAtDestination(npc)) {
        npc.clearDestination();
        npc.idle();
      } else {
        faceDestination(npc);
        npc.walk();
      }
      return;
    }
    npc.idle();
  }

  void updateCharacters() {
    removeInactiveNpcs();
    players.forEach(updatePlayer);
    players.forEach(updateCharacter);
    npcs.forEach(updateCharacter);
  }

  void handleBlockCollisions(List<GameObject> gameObjects){
    int minJ = 0;
    for (int i = 0; i < gameObjects.length; i++) {
      GameObject gameObject = gameObjects[i];
      for (int j = 0; j < blocks.length; j++) {
        Block block = blocks[j];
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
          if(gameObject.x > block.x && gameObject.y < block.y){

          }else{
            double xd = gameObject.x - block.leftX;
            double yd = gameObject.y - block.leftY;
            if (xd > yd) {
              gameObject.x -= xd - yd;
              gameObject.y += xd - yd;
            }
            continue;
          }
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

  void updateCollisions() {
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

  void characterFireWeapon(Player character) {
    if (character.dead) return;
    if (character.stateDuration > 0) return;
    faceAimDirection(character);

    double d = 15;
    double x = character.x + adj(character.aimAngle, d);
    double y = character.y + opp(character.aimAngle, d);

    switch (character.weapon) {
      case Weapon.HandGun:
        character.stateDuration = settingsClipEmptyCooldown;
        if (character.handgunAmmunition.rounds <= 0) {
          dispatch(GameEventType.Clip_Empty, x, y, 0, 0);
          return;
        }
        character.handgunAmmunition.rounds--;
        Bullet bullet = spawnBullet(character);
        character.state = CharacterState.Firing;
        character.stateDuration = settingsHandgunCooldown;
        dispatch(GameEventType.Handgun_Fired, x, y, bullet.xv, bullet.yv);
        break;
      case Weapon.Shotgun:
        character.xv += velX(character.aimAngle + pi, 1);
        character.yv += velY(character.aimAngle + pi, 1);
        for (int i = 0; i < settingsShotgunBulletsPerShot; i++) {
          spawnBullet(character);
        }
        Bullet bullet = bullets.last;
        character.state = CharacterState.Firing;
        character.stateDuration = shotgunCoolDown;
        dispatch(GameEventType.Shotgun_Fired, character.x, character.y,
            bullet.xv, bullet.yv);
        break;
      case Weapon.SniperRifle:
        Bullet bullet = spawnBullet(character);
        character.state = CharacterState.Firing;
        character.stateDuration = settingsSniperCooldown;
        ;
        dispatch(GameEventType.SniperRifle_Fired, character.x, character.y,
            bullet.xv, bullet.yv);
        break;
      case Weapon.MachineGun:
        Bullet bullet = spawnBullet(character);
        character.state = CharacterState.Firing;
        character.stateDuration = settings.machineGunCoolDown;
        ;
        dispatch(GameEventType.MachineGun_Fired, character.x, character.y,
            bullet.xv, bullet.yv);
        break;
    }
  }

  void setCharacterState(Character character, CharacterState value) {
    if (character.dead) return;
    if (character.state == value) return;
    if (value != CharacterState.Dead && character.stateDuration > 0) return;

    switch (value) {
      case CharacterState.Running:
        if (character is Player && character.stamina <= minStamina) {
          character.state = CharacterState.Walking;
          return;
        }
        break;
      case CharacterState.Dead:
        character.collidable = false;
        break;
      case CharacterState.ChangingWeapon:
        character.stateDuration = 10;
        break;
      case CharacterState.Aiming:
        character.accuracy = 0;
        break;
      case CharacterState.Firing:
        // TODO Fix hack
        characterFireWeapon(character as Player);
        break;
      case CharacterState.Striking:
        character.stateDuration = 10;
        break;
      case CharacterState.Reloading:
        character.stateDuration = 20;
        break;
    }
    character.state = value;
  }

  void setCharacterStateIdle(Character character) {
    setCharacterState(character, CharacterState.Idle);
  }

  void changeCharacterHealth(Character character, double amount) {
    if (character.dead && amount < 0) return;

    character.health += amount;
    character.health = clamp(character.health, 0, character.maxHealth);
    if (character.health <= 0) {
      setCharacterState(character, CharacterState.Dead);
    }
  }

  Npc findNpcById(int id) {
    return npcs.firstWhere((npc) => npc.id == id, orElse: () {
      throw Exception("could not find npc with id $id");
    });
  }

  void updateBullets() {
    for (int i = 0; i < bullets.length; i++) {
      Bullet bullet = bullets[i];
      bullet.x += bullet.xv;
      bullet.y += bullet.yv;
      if (bulletDistanceTravelled(bullet) > bullet.range) {
        dispatch(GameEventType.Bullet_Hole, bullet.x, bullet.y, 0, 0);
        bullets.removeAt(i);
        i--;
        continue;
      }
    }
    bullets.sort(compareGameObjects);


    int jMin = 0;
    for (int i = 0; i < bullets.length; i++) {
      Bullet bullet = bullets[i];
      for (int j = jMin; j < blocks.length; j++) {
        Block block = blocks[j];
        if (bullet.x > block.rightX) {
          jMin++;
          break;
        }
        if (bullet.x < block.leftX) break;
        if (bullet.y < block.topY) continue;
        if (bullet.y > block.bottomY) continue;

        if (bullet.x < block.topX && bullet.y < block.leftY) {
          double xd = block.topX - bullet.x;
          double yd = bullet.y - block.topY;
          if (yd > xd) {
            bullets.removeAt(i);
            i--;
          }
          continue;
        }

        if (bullet.x < block.bottomX && bullet.y > block.leftY) {
          if(bullet.x > block.x && bullet.y < block.y){

          }else{
            double xd = bullet.x - block.leftX;
            double yd = bullet.y - block.leftY;
            if (xd > yd) {
              bullets.removeAt(i);
              i--;
            }
            continue;
          }
        }
        if (bullet.x > block.topX && bullet.y < block.rightY) {
          double xd = bullet.x - block.topX;
          double yd = bullet.y - block.topY;

          if (yd > xd) {
            bullets.removeAt(i);
            i--;
          }
          continue;
        }

        if (bullet.x > block.bottomX && bullet.y > block.rightY) {
          double xd = block.rightX - bullet.x;
          double yd = bullet.y - block.rightY;
          if (xd > yd) {
            bullets.removeAt(i);
            i--;
          }
          continue;
        }
      }
    }

    checkBulletCollision(npcs);
    checkBulletCollision(players);
  }

  void spawnExplosion(double x, double y) {
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
  }

  void updateGameEvents() {
    for (int i = 0; i < gameEvents.length; i++) {
      if (gameEvents[i].frameDuration-- > 0) continue;
      gameEvents.removeAt(i);
      i--;
    }
  }

  void updateNpcs() {
    npcs.forEach(updateNpc);
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
      player.stamina++;
    } else if (player.idling) {
      player.stamina += 2;
    } else if (player.aiming) {
      player.stamina += 2;
    } else if (player.firing) {
      player.stamina += 1;
    }
    player.stamina = clampInt(player.stamina, 0, player.maxStamina);
  }

  void updateGrenades() {
    for (Grenade grenade in grenades) {
      applyMovement(grenade);
      applyFriction(grenade, settingsGrenadeFriction);
      double gravity = 0.06;
      grenade.zv -= gravity;
      if (grenade.z < 0) {
        grenade.z = 0;
      }
    }
  }

  void checkBulletCollision(List<Character> characters) {
    int s = 0;
    for (int i = 0; i < bullets.length; i++) {
      Bullet bullet = bullets[i];
      for (int j = s; j < characters.length; j++) {
        Character character = characters[j];
        if (!character.active) continue;
        if (character.left > bullet.right) break;
        if (character.dead) continue;
        if (bullet.left > character.right) {
          s++;
          continue;
        }
        if (bullet.top > character.bottom) continue;
        if (bullet.bottom < character.top) continue;

        bullets.removeAt(i);
        i--;
        changeCharacterHealth(character, -bullet.damage);
        character.xv += bullet.xv * bulletImpactVelocityTransfer;
        character.yv += bullet.yv * bulletImpactVelocityTransfer;

        if (character is Player) {
          dispatch(GameEventType.Player_Hit, character.x, character.y,
              bullet.xv, bullet.yv);
          return;
        }

        if (character.alive) {
          dispatch(GameEventType.Zombie_Hit, character.x, character.y,
              bullet.xv, bullet.yv);
        } else {
          if (randomBool()) {
            dispatch(GameEventType.Zombie_Killed, character.x, character.y,
                bullet.xv, bullet.yv);
            delayed(() => character.active = false, ms: randomInt(200, 800));
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

  void removeInactiveNpcs() {
    for (int i = 0; i < npcs.length; i++) {
      if (!npcs[i].active) {
        npcs.removeAt(i);
        i--;
      }
    }
  }

  void clearNpcs() {
    npcs.clear();
  }

  void updateCharacter(Character character) {
    character.x += character.xv;
    character.y += character.yv;
    character.xv *= velocityFriction;
    character.yv *= velocityFriction;

    if (character.y < tilesLeftY) {
      if (-character.x > character.y) {
        character.x = -character.y;
        character.y++;
      } else if (character.x > character.y) {
        character.x = character.y;
        character.y++;
      }
    } else {
      if (character.x > 0) {
        double m = tilesRightX + tilesRightX;
        double d = character.x + character.y;
        if (d > m) {
          character.x = m - character.y;
          character.y--;
        }
      } else {
        double m = tilesRightX + tilesRightX;
        double d = -character.x + character.y;
        if (d > m) {
          character.x = -(m - character.y);
          character.y--;
        }
      }
    }

    switch (character.state) {
      case CharacterState.ChangingWeapon:
        character.stateDuration--;
        if (character.stateDuration <= 0) {
          setCharacterState(character, CharacterState.Aiming);
        }
        break;
      case CharacterState.Aiming:
        if (character.accuracy > 0.05) {
          character.accuracy -= 0.005;
        }
        break;
      case CharacterState.Firing:
        character.stateDuration--;
        if (character.stateDuration <= 0) {
          setCharacterState(character, CharacterState.Aiming);
        }
        break;
      case CharacterState.Reloading:
        character.stateDuration--;
        if (character.stateDuration <= 0) {
          setCharacterState(character, CharacterState.Aiming);
          (character as Player).handgunAmmunition.rounds =
              character.handgunAmmunition.clipSize;
          dispatch(GameEventType.Reloaded, character.x, character.y, 0, 0);
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
  }

  void throwGrenade(double x, double y, double angle, double strength) {
    double speed = settingsGrenadeSpeed * strength;
    Grenade grenade =
        Grenade(x, y, adj(angle, speed), opp(angle, speed), 0.8 * strength);
    grenades.add(grenade);
    delayed(() {
      grenades.remove(grenade);
      spawnExplosion(grenade.x, grenade.y);
    }, ms: settingsGrenadeDuration);
  }

  Bullet spawnBullet(Character character) {
    double d = 5;
    double x = character.x + adj(character.aimAngle, d);
    double y = character.y + opp(character.aimAngle, d);

    Bullet bullet = Bullet(
        x,
        y,
        velX(
            character.aimAngle +
                giveOrTake(getWeaponAccuracy(character.weapon)),
            getWeaponBulletSpeed(character.weapon)),
        velY(
            character.aimAngle +
                giveOrTake(getWeaponAccuracy(character.weapon)),
            getWeaponBulletSpeed(character.weapon)),
        character.id,
        getWeaponRange(character.weapon) +
            giveOrTake(settingsWeaponRangeVariation),
        getWeaponDamage(character.weapon));
    bullets.add(bullet);
    return bullet;
  }

  Npc spawnNpc(double x, double y) {
    Npc npc = Npc(x: x, y: y, health: 3, maxHealth: 3);
    npcs.add(npc);
    npcSetRandomDestination(npc);
    return npc;
  }

  Npc spawnRandomNpc() {
    return spawnNpc(randomBetween(-spawnRadius, spawnRadius),
        randomBetween(-spawnRadius, spawnRadius) + 1000);
  }

  Player spawnPlayer({required String name}) {
    Player player = Player(
        uuid: _generateUUID(),
        x: giveOrTake(50),
        y: 1000 + giveOrTake(50),
        name: name);
    players.add(player);
    return player;
  }

  void dispatch(GameEventType type, double x, double y, double xv, double xy) {
    gameEvents.add(GameEvent(type, x, y, xv, xy));
  }

  void updateNpcTargets() {
    int minP = 0;
    Npc npc;

    for (int i = 0; i < npcs.length; i++) {
      if (npcs[i].targetSet) continue;
      npc = npcs[i];
      for (int p = minP; p < players.length; p++) {
        if (players[p].x < npc.x - zombieViewRange) {
          minP++;
          break;
        }
        if (players[p].x > npc.x + zombieViewRange) {
          break;
        }
        if (abs(players[p].y - npc.y) > zombieViewRange) {
          continue;
        }

        npc.target = players[p];
      }
    }
  }

  void jobNpcWander() {
    for (Npc npc in npcs) {
      if (npc.targetSet) continue;
      if (npc.destinationSet) continue;
      if (randomBool()) return;
      npcSetRandomDestination(npc);
    }
  }

  void jobRemoveDisconnectedPlayers() {
    for (int i = 0; i < players.length; i++) {
      if (players[i].lastEventFrame > settingsPlayerDisconnectFrames) {
        print('Removing disconnected player ${players[i].id}');
        players.removeAt(i);
        i--;
      }
    }
  }
}

String _generateUUID() {
  return uuidGenerator.v4().substring(0, 8);
}
