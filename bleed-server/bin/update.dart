import 'classes.dart';
import 'common.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void initUpdateLoop() {
  createJob(fixedUpdate, ms: 1000 ~/ 30);
  // createJob(spawnZombieJob, seconds: 5);
  createJob(npcWanderJob, seconds: 10);
  // createJob(deleteDeadAndExpiredCharacters, seconds: 6);
  createJob(updateNpcTarget, ms: 500);
}

void updateNpcTarget() {
  for (int i = 0; i < npcs.length; i++) {
    Npc npc = npcs[i];
    if (npc.targetSet) continue;
    for (Character player in players) {
      if (distanceBetween(npc, player) < zombieViewRange) {
        npc.targetId = player.id;
      }
    }
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

    for (int j = 0; j < npcs.length; j++) {
      Npc npc = npcs[j];
      if (npc.dead) continue;
      if (npc.id == bullet.ownerId) continue;
      double dis = distanceBetween(npcs[j], bullet);
      if (dis < characterBulletRadius) {
        bullets.removeAt(i);
        i--;
        npc.health--;
        if (npc.health <= 0) {
          npc.state = CharacterState.Dead;
          npc.frameOfDeath = frame;
        }
        npc.xVel += bullet.xVel * 0.25;
        npc.yVel += bullet.yVel * 0.25;
        break;
      }
    }

    for (int j = 0; j < players.length; j++) {
      Character character = players[j];
      if (character.dead) continue;
      if (character.id == bullet.ownerId) continue;
      double dis = distanceBetween(character, bullet);
      if (dis < characterBulletRadius) {
        bullets.removeAt(i);
        i--;
        character.health--;
        if (character.health <= 0) {
          character.state = CharacterState.Dead;
          character.frameOfDeath = frame;
        }
        character.xVel += bullet.xVel * 0.15;
        character.yVel += bullet.yVel * 0.15;
        break;
      }
    }
  }
}

void updateNpc(Npc npc) {
  if (npc.dead) return;

  if (npc.targetSet) {
    Character target = npcTarget(npc);
    if (isDead(target)) {
      npc.clearTarget();
    } else {
      npc.walk();
      characterFaceObject(npc, target);
    }
  } else {
    if (npc.destinationSet) {
      if (arrivedAtDestination(npc)) {
        npc.idle();
        npc.clearDestination();
      } else {
        faceDestination(npc);
        npc.walk();
      }
    }
  }
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
  for(int i =0 ; i < players.length; i++){
    if(players[i].x.isNaN || players[i].y.isNaN){
      players[i].x = 0;
      players[i].y = 0;
    }
  }
  players.forEach(updateCharacter);
  npcs.forEach(updateCharacter);
}

void detectCorruptData(){
  for(int i =0 ; i < players.length; i++){
    if(players[i].x.isNaN || players[i].y.isNaN){
      print("removing player because invalid position");
    }
  }
}

void fixedUpdate() {
  frame++;
  DateTime now = DateTime.now();
  frameDuration = now.difference(frameTime);
  frameTime = now;
  updateCharacters();
  updateCollisions();
  updateBullets();
  updateNpcs();
  compressData();
  detectCorruptData();
}


void updateNpcs(){
  npcs.forEach(updateNpc);
}

void compressData() {
  players.forEach(compressCharacter);
  npcs.forEach(compressCharacter);
}

void compressCharacter(Character character) {
  character.x = round(character.x);
  character.y = round(character.y);
}

void compressBullet(Bullet bullet){
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
  if (isDead(a)) return;
  if (isDead(b)) return;
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
