import 'common.dart';
import 'common_functions.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void initUpdateLoop() {
  createJob(fixedUpdate, ms: 1000 ~/ 60);
  createJob(spawnZombieJob, seconds: 5);
  createJob(npcWanderJob, seconds: 10);
}

void updateBullets() {
  for (int i = 0; i < bullets.length; i++) {
    dynamic bullet = bullets[i];
    bullet[keyFrame]++;
    bullet[keyPositionX] += bullet[keyVelocityX];
    bullet[keyPositionY] += bullet[keyVelocityY];

    if (bulletDistanceTravelled(bullet) > bulletRange) {
      bullets.removeAt(i);
      i--;
      continue;
    }

    for (int j = 0; j < characters.length; j++) {
      if (bullet[keyId] == characters[j][keyId]) continue;
      if (isDead(characters[j])) continue;
      double dis = distanceBetween(characters[j], bullet);
      if (dis < characterBulletRadius) {
        dynamic characterJ = characters[j];
        bullets.removeAt(i);
        i--;
        characterJ[keyHealth]--;
        if (characterJ[keyHealth] <= 0) {
          characterJ[keyState] = characterStateDead;
          characterJ[keyFrameOfDeath] = frame;
        }

        dynamic characterJPrivate = getCharacterPrivate(characterJ);
        characterJPrivate[keyVelocityX] += bullet[keyVelocityX] * 0.25;
        characterJPrivate[keyVelocityY] += bullet[keyVelocityY] * 0.25;
        break;
      }
    }
  }
}

dynamic getCharacterPrivate(dynamic character){
  return charactersPrivate.firstWhere((element) => element[keyId] == character[keyId]);
}

void updateCharacter(dynamic character) {
  // TODO Remove this hack
  if (character[keyPositionX] == double.nan) {
    print("character x is nan");
    character[keyPositionX] = 0;
    character[keyPositionY] = 0;
  }


  dynamic characterPrivate = getCharacterPrivate(character);

  if (isNpc(character) && isAlive(character)) {
    if (!npcTargetSet(characterPrivate)) {
      for (int j = 0; j < characters.length; j++) {
        if (isNpc(characters[j])) continue;
        dynamic characterJ = characters[j];
        if (distanceBetween(character, characterJ) < zombieViewRange) {
          npcSetTarget(characterPrivate, characterJ);
          break;
        }
      }

      if (npcDestinationSet(characterPrivate)) {
        if (npcArrivedAtDestination(character)) {
          setCharacterStateIdle(character);
          npcClearDestination(characterPrivate);
        } else {
          npcFaceDestination(character, characterPrivate);
          setCharacterStateWalk(character);
        }
      }
    } else {
      dynamic target = npcTarget(characterPrivate);
      if (target == null || isDead(target)) {
        characterPrivate(character);
      } else {
        double angle = radionsBetweenObject(character, target);
        setCharacterState(character, characterStateWalking);
        setDirection(character, convertAngleToDirection(angle));
      }
    }
  }

  character[keyPositionX] += characterPrivate[keyVelocityX];
  character[keyPositionY] += characterPrivate[keyVelocityY];
  characterPrivate[keyVelocityX] *= velocityFriction;
  characterPrivate[keyVelocityY] *= velocityFriction;

  switch (character[keyState]) {
    case characterStateAiming:
      if (character[keyAccuracy] > 0.05) {
        character[keyAccuracy] -= 0.005;
      }
      break;
    case characterStateFiring:
      character[keyShotCoolDown]--;
      if (character[keyShotCoolDown] <= 0) {
        setCharacterStateIdle(character);
      }
      break;
    case characterStateIdle:
      break;
    case characterStateWalking:
      double speed = getSpeed(character);
      switch (character[keyDirection]) {
        case directionUp:
          character[keyPositionY] -= speed;
          break;
        case directionUpRight:
          character[keyPositionX] += speed * 0.5;
          character[keyPositionY] -= speed * 0.5;
          break;
        case directionRight:
          character[keyPositionX] += speed;
          break;
        case directionDownRight:
          character[keyPositionX] += speed * 0.5;
          character[keyPositionY] += speed * 0.5;
          break;
        case directionDown:
          character[keyPositionY] += speed;
          break;
        case directionDownLeft:
          character[keyPositionX] -= speed * 0.5;
          character[keyPositionY] += speed * 0.5;
          break;
        case directionLeft:
          character[keyPositionX] -= speed;
          break;
        case directionUpLeft:
          character[keyPositionX] -= speed * 0.5;
          character[keyPositionY] -= speed * 0.5;
          break;
      }
      break;
  }
}

void removeCharacter(dynamic character){
  characters.removeWhere((element) => element[keyId] == character[keyId]);
  charactersPrivate.removeWhere((element) => element[keyId] == character[keyId]);
}

void updateCharacters() {
  for (int i = 0; i < characters.length; i++) {
    dynamic character = characters[i];

    if (isHuman(character) && connectionExpired(character)) {
      removeCharacter(character);
      i--;
      continue;
    }
    if (isDead(character)) {
      if (frame - character[keyFrameOfDeath] > 120) {
        if (isNpc(character)) {
          removeCharacter(character);
          i--;
        } else {
          character[keyState] = characterStateIdle;
          setPosition(character, x: 0, y: 0);
        }
      }
    }
  }

  characters.forEach(updateCharacter);
}

void fixedUpdate() {
  frame++;
  updateCharacters();
  updateCollisions();
  updateBullets();
  compressData();
}

void compressData() {
  for (dynamic character in characters) {
    roundKey(character, keyPositionX);
    roundKey(character, keyPositionY);
    if (character[keyDestinationX] != null) {
      roundKey(character, keyDestinationX);
      roundKey(character, keyDestinationY);
    }
    // if (character[keyVelocityX] != null) {
    //   roundKey(character, keyVelocityX, decimals: 2);
    //   roundKey(character, keyVelocityY, decimals: 2);
    // }
  }
}

void updateCollisions() {
  for (int i = 0; i < characters.length; i++) {
    dynamic characterI = characters[i];
    if (isDead(characterI)) continue;
    for (int j = i + 1; j < characters.length; j++) {
      dynamic characterJ = characters[j];
      if (isDead(characterJ)) continue;
      double distance = distanceBetween(characterI, characterJ);
      if (distance < characterRadius2) {
        double overlap = characterRadius2 - distance;
        double halfOverlap = overlap * 0.5;
        double xDiff = characterI[keyPositionX] - characterJ[keyPositionX];
        double yDiff = characterI[keyPositionY] - characterJ[keyPositionY];
        double mag = magnitude(xDiff, yDiff);
        double ratio = 1.0 / mag;
        double xDiffNormalized = xDiff * ratio;
        double yDiffNormalized = yDiff * ratio;
        double targetX = xDiffNormalized * halfOverlap;
        double targetY = yDiffNormalized * halfOverlap;
        characterI[keyPositionX] += targetX;
        characterI[keyPositionY] += targetY;
        characterJ[keyPositionX] -= targetX;
        characterJ[keyPositionY] -= targetY;
      }
    }
  }
}

void updateMovement(dynamic character) {
  const double velocityFriction = 0.94;
  character[keyPositionX] += character[keyVelocityX];
  character[keyPositionY] += character[keyVelocityY];
  character[keyVelocityX] *= velocityFriction;
  character[keyVelocityY] *= velocityFriction;

  switch (character[keyState]) {
    case characterStateWalking:
      double speed = getSpeed(character);
      switch (character[keyDirection]) {
        case directionUp:
          character[keyPositionY] -= speed;
          break;
        case directionUpRight:
          character[keyPositionX] += speed * 0.5;
          character[keyPositionY] -= speed * 0.5;
          break;
        case directionRight:
          character[keyPositionX] += speed;
          break;
        case directionDownRight:
          character[keyPositionX] += speed * 0.5;
          character[keyPositionY] += speed * 0.5;
          break;
        case directionDown:
          character[keyPositionY] += speed;
          break;
        case directionDownLeft:
          character[keyPositionX] -= speed * 0.5;
          character[keyPositionY] += speed * 0.5;
          break;
        case directionLeft:
          character[keyPositionX] -= speed;
          break;
        case directionUpLeft:
          character[keyPositionX] -= speed * 0.5;
          character[keyPositionY] -= speed * 0.5;
          break;
      }
      break;
  }
}
