import 'classes.dart';
import 'common.dart';
import 'compiler.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void initUpdateLoop() {
  createJob(fixedUpdate, ms: 1000 ~/ 30);
  createJob(npcWanderJob, seconds: 10);
  // createJob(deleteDeadAndExpiredCharacters, seconds: 6);
  createJob(updateNpcTargets, ms: 500);
}

void updateNpcTargets() {
  for(Npc npc in npcs){
    if (npc.targetSet) continue;
    updateNpcTarget(npc);
  }
}

void updateNpcTarget(Npc npc){
  for (Character player in players) {
    if (player.dead) continue;
    if (distanceBetween(npc, player) > zombieViewRange) continue;
    npc.targetId = player.id;
    return;
  }
}


// void deleteDeadAndExpiredCharacters() {
//   for (int i = 0; i < characters.length; i++) {
//     dynamic character = characters[i];
//     dynamic characterPrivate = getCharacterPrivate(character);
//
//     if (isHuman(characterPrivate) && connectionExpired(character)) {
//       removeCharacter(character);
//       i--;
//       continue;
//     }
//     if (isDead(character)) {
//       if (frame - character[keyFrameOfDeath] > 120) {
//         if (isNpc(characterPrivate)) {
//           removeCharacter(character);
//           i--;
//         } else {
//           setCharacterStateIdle(character);
//           setPosition(character, x: 0, y: 0);
//         }
//       }
//     }
//   }
// }

void updateBullets() {
  for (int i = 0; i < bullets.length; i++) {
    Bullet bullet = bullets[i];
    bullet.x += bullet.xVel;
    bullet.y += bullet.yVel;
    if (bulletDistanceTravelled(bullet) > bulletRange) {
      bullets.removeAt(i);
      i--;
      continue;
    }
    compressBullet(bullet);
  }

  checkBulletCollision(npcs);
  checkBulletCollision(players);
}

void checkBulletCollision(List<Character> list){
  for(int i = 0; i < bullets.length; i++){
    Bullet bullet = bullets[i];
    for (int j = 0; j < list.length; j++) {
      Character characters = list[j];
      if (characters.dead) continue;
      if (characters.id == bullet.ownerId) continue;
      double dis = distanceBetween(list[j], bullet);
      if (dis < characterBulletRadius) {
        bullets.removeAt(i);
        i--;
        characters.health--;
        if (characters.health <= 0) {
          characters.state = CharacterState.Dead;
          characters.frameOfDeath = frame;
        }
        characters.xVel += bullet.xVel * 0.25;
        characters.yVel += bullet.yVel * 0.25;
        break;
      }
    }
  }
}

void updateNpc(Npc npc) {
  if (npc.dead) return;

  if (npc.targetSet) {
    Character? target = npcTarget(npc);
    if (target == null || target.dead) {
      npc.clearTarget();
      npc.idle();
      return;
    }

    characterFaceObject(npc, target);
    double targetDistance = objectDistanceFrom(npc, target.x, target.y);

    if (targetDistance > 20) {
      npc.walk();
    } else {
      setCharacterState(npc, CharacterState.Striking);
      changeCharacterHealth(target, -0.01);
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
  character.x += character.xVel;
  character.y += character.yVel;
  character.xVel *= velocityFriction;
  character.yVel *= velocityFriction;

  switch (character.state) {
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
    case CharacterState.Walking:
      switch (character.direction) {
        case Direction.Up:
          character.y -= character.speed;
          break;
        case Direction.UpRight:
          character.x += character.speed * 0.5;
          character.y -= character.speed * 0.5;
          break;
        case Direction.Right:
          character.x += character.speed;
          break;
        case Direction.DownRight:
          character.x += character.speed * 0.5;
          character.y += character.speed * 0.5;
          break;
        case Direction.Down:
          character.y += character.speed;
          break;
        case Direction.DownLeft:
          character.x -= character.speed * 0.5;
          character.y += character.speed * 0.5;
          break;
        case Direction.Left:
          character.x -= character.speed;
          break;
        case Direction.UpLeft:
          character.x -= character.speed * 0.5;
          character.y -= character.speed * 0.5;
          break;
      }
      break;
  }
}

void updateCharacters() {
  players.forEach(updateCharacter);
  npcs.forEach(updateCharacter);
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
  compileState();

  if (fps < 20) {
    print("Warning FPS Drop: $fps");
  }
}

void updateNpcs() {
  npcs.forEach(updateNpc);
}

void compressBullet(Bullet bullet) {
  bullet.x = round(bullet.x);
  bullet.y = round(bullet.y);
}

int compareCharacters(GameObject a, GameObject b) {
  if (a.x < b.x) {
    return -1;
  }
  return 1;
}

void updateCollisionBetween(List<Character> characters) {
  for (int i = 0; i < characters.length - 1; i++) {
    if (characters[i].dead) continue;
    for (int j = i + 1; j < characters.length; j++) {
      resolveCollision(characters[i], characters[j]);
    }
  }
}

void resolveCollision(Character a, Character b) {
  if (a.dead) return;
  if (b.dead) return;
  double xDiff = a.x - b.x;
  if (abs(xDiff) > characterRadius2) return;
  double yDiff = a.y - b.y;
  if (abs(yDiff) > characterRadius2) return;
  double distance = distanceBetween(a, b);
  if (distance >= characterRadius2) return;
  double overlap = characterRadius2 - distance;
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
  npcs.sort(compareCharacters);
  players.sort(compareCharacters);

  updateCollisionBetween(npcs);
  updateCollisionBetween(players);

  for (int i = 0; i < npcs.length; i++) {
    for (int j = 0; j < players.length; j++) {
      resolveCollision(npcs[i], players[j]);
    }
  }
}
