import 'classes.dart';
import 'classes/Collision.dart';
import 'common.dart';
import 'compile.dart';
import 'constants.dart';
import 'enums.dart';
import 'enums/GameEventType.dart';
import 'jobs.dart';
import 'language.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void initUpdateLoop() {
  periodic(fixedUpdate, ms: 1000 ~/ 30);
  periodic(jobNpcWander, seconds: 3);
  periodic(jobRemoveDisconnectedPlayers, seconds: 5);
  periodic(updateNpcTargets, ms: 500);
}

void fixedUpdate() {
  frame++;
  DateTime now = DateTime.now();
  frameDuration = now.difference(frameTime);
  if (frameDuration.inMilliseconds > 0) {
    fps = 1000 ~/ frameDuration.inMilliseconds;
  }
  frameTime = now;

  updateCharacters();
  updateCollisions();
  updateBullets();
  updateBullets(); // called twice to fix collision detection
  updateNpcs();
  updateGameEvents();
  updateGrenades();
  compileState();
}

void sortGameObjects() {
  npcs.sort(compareGameObjects);
  players.sort(compareGameObjects);
  bullets.sort(compareGameObjects);
}

void updateNpcTargets() {
  int minP = 0;
  Npc npc;
  for(int i = 0; i < npcs.length; i++){
    if(npcs[i].targetSet) continue;
    npc = npcs[i];
    for(int p = minP; p < players.length; p++){
      if (players[p].x < npc.x - zombieViewRange){
        minP++;
        break;
      }
      if (players[p].x > npc.x + zombieViewRange){
        break;
      }
      if(abs(players[p].y - npc.y) > zombieViewRange){
        continue;
      }

      npc.target = players[p];
    }
  }
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
  checkBulletCollision(npcs);
  checkBulletCollision(players);
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
      character.xv += bullet.xv * 0.25;
      character.yv += bullet.yv * 0.25;

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

void updateNpc(Npc npc) {
  if (npc.dead) return;

  // todo this belongs in update character
  if (npc.state == CharacterState.Striking) {
    if (npc.shotCoolDown-- > 0) return;
    setCharacterStateIdle(npc);
  }

  if (npc.targetSet) {
    if (!npc.target.active) {
      npc.clearTarget();
      npc.idle();
      return;
    }
    characterFaceObject(npc, npc.target);
    double targetDistance = objectDistanceFrom(npc, npc.target.x, npc.target.y);

    if (targetDistance > settingsZombieStrikeRange) {
      npc.walk();
    } else {
      setCharacterState(npc, CharacterState.Striking);
      changeCharacterHealth(npc.target, -zombieStrikeDamage);
      dispatch(GameEventType.Zombie_Strike, npc.x, npc.y, 0, 0);
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

void updateCharacter(Character character) {
  character.x += character.xv;
  character.y += character.yv;
  character.xv *= velocityFriction;
  character.yv *= velocityFriction;

  switch (character.state) {
    case CharacterState.ChangingWeapon:
      character.shotCoolDown--;
      if (character.shotCoolDown <= 0) {
        setCharacterState(character, CharacterState.Aiming);
      }
      break;
    case CharacterState.Aiming:
      if (character.accuracy > 0.05) {
        character.accuracy -= 0.005;
      }
      break;
    case CharacterState.Firing:
      character.shotCoolDown--;
      if (character.shotCoolDown <= 0) {
        setCharacterState(character, CharacterState.Aiming);
      }
      break;
    case CharacterState.Reloading:
      character.shotCoolDown--;
      if (character.shotCoolDown <= 0) {
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

void updateCharacters() {
  for (int i = 0; i < npcs.length; i++) {
    if (!npcs[i].active) {
      npcs.removeAt(i);
      i--;
    }
  }

  players.forEach(updateCharacter);
  npcs.forEach(updateCharacter);

  for (Player player in players) {
    if (frame - player.lastEventFrame > 5 && player.walking) {
      setCharacterStateIdle(player);
    }
  }
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

int compareGameObjects(GameObject a, GameObject b) {
  if (a.x < b.x) {
    return -1;
  }
  return 1;
}

void updateCollisionBetween(List<GameObject> gameObjects) {
  for (int i = 0; i < gameObjects.length - 1; i++) {
    if (!gameObjects[i].collidable) continue;
    for (int j = i + 1; j < gameObjects.length; j++) {
      if (!gameObjects[j].collidable) continue;
      if (gameObjects[j].left > gameObjects[i].right) break;
      if (gameObjects[j].top > gameObjects[i].bottom) continue;
      if (gameObjects[j].bottom < gameObjects[i].top) continue;
      resolveCollision(gameObjects[i], gameObjects[j]);
    }
  }
}

double collisionOverlap(GameObject a, GameObject b){
  return a.radius + b.radius - distanceBetween(a, b);
}

void resolveCollision(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if(overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;
  double halfOverlap = overlap * 0.5;
  double mag = magnitude(xDiff, yDiff);
  double ratio = 1.0 / mag;
  double xDiffNormalized = xDiff * ratio;
  double yDiffNormalized = yDiff * ratio;
  double targetX = xDiffNormalized * halfOverlap;
  double targetY = yDiffNormalized * halfOverlap;
  a.x += targetX;
  a.y += targetY;
  b.x -= targetX;
  b.y -= targetY;
}

void updateCollisions() {
  npcs.sort(compareGameObjects);
  players.sort(compareGameObjects);
  updateCollisionBetween(npcs);
  updateCollisionBetween(players);
  resolveCollisionBetween(npcs, players);
}

void resolveCollisionBetween(List<GameObject> gameObjectsA, List<GameObject> gameObjectsB) {
  int minJ = 0;
  for (int i = 0; i < gameObjectsA.length; i++) {
    if (!gameObjectsA[i].collidable) continue;
    for (int j = minJ; j < gameObjectsB.length; j++) {
      if (!gameObjectsB[minJ].collidable) {
        minJ++;
        break;
      }
      if (gameObjectsB[j].left > gameObjectsA[i].right) break;
      if (gameObjectsB[j].right < gameObjectsA[i].left) {
        minJ++;
        continue;
      }
      if (gameObjectsA[i].top > gameObjectsB[j].bottom) continue;
      if (gameObjectsA[i].bottom < gameObjectsB[j].top) continue;
      resolveCollision(gameObjectsA[i], gameObjectsB[j]);
    }
  }
}
