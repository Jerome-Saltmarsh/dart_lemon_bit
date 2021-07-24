import 'common.dart';
import 'common_functions.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void initUpdateLoop() {
  createJob(fixedUpdate, ms: 1000 ~/ 30);
  createJob(spawnZombieJob, seconds: 5);
  createJob(npcWanderJob, seconds: 10);
  // createJob(deleteDeadAndExpiredCharacters, seconds: 6);
  createJob(updateNpcTarget, ms: 500);
}

void updateNpcTarget() {
  List<dynamic> players = charactersPrivate.where(isHuman).toList();
  List<dynamic> npcs = charactersPrivate.where(isNpc).toList();

  for (int i = 0; i < npcs.length; i++) {
    dynamic npc = npcs[i];
    if (!npcTargetSet(npc)) {
      for (dynamic player in players) {
        dynamic npcPublic = getCharacterPublic(npc);
        dynamic playerPublic = getCharacterPublic(player);
        if (distanceBetween(npcPublic, playerPublic) < zombieViewRange) {
          npcSetTarget(npc, player);
        }
      }
    }
  }
}

void deleteDeadAndExpiredCharacters() {
  for (int i = 0; i < characters.length; i++) {
    dynamic character = characters[i];
    dynamic characterPrivate = getCharacterPrivate(character);

    if (isHuman(characterPrivate) && connectionExpired(character)) {
      removeCharacter(character);
      i--;
      continue;
    }
    if (isDead(character)) {
      if (frame - character[keyFrameOfDeath] > 120) {
        if (isNpc(characterPrivate)) {
          removeCharacter(character);
          i--;
        } else {
          setCharacterStateIdle(character);
          setPosition(character, x: 0, y: 0);
        }
      }
    }
  }
}

void updateBullets() {
  for (int i = 0; i < bullets.length; i++) {
    dynamic bullet = bullets[i];
    bullet[keyFrame]++;
    bullet['x'] += bullet[keyVelocityX];
    bullet['y'] += bullet[keyVelocityY];

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
        dynamic characterJPrivate = getCharacterPrivate(characterJ);
        bullets.removeAt(i);
        i--;
        characterJPrivate[keyHealth]--;
        if (characterJPrivate[keyHealth] <= 0) {
          setCharacterStateDead(characterJ);
          characterJ[keyFrameOfDeath] = frame;
        }
        characterJPrivate[keyVelocityX] += bullet[keyVelocityX] * 0.25;
        characterJPrivate[keyVelocityY] += bullet[keyVelocityY] * 0.25;
        break;
      }
    }
  }
}

dynamic getCharacterPrivate(dynamic character) {
  return charactersPrivate
      .firstWhere((characterPrivate) => characterPrivate[keyId] == character[indexId]);
}

dynamic getCharacterPublic(dynamic character) {
  return characters.firstWhere((element) => element[indexId] == character[keyId]);
}

void updateCharacter(dynamic character) {
  // TODO Remove this hack
  // if (character[keyPositionX] == double.nan) {
  //   print("character x is nan");
  //   character[keyPositionX] = 0;
  //   character[keyPositionY] = 0;
  // }

  dynamic characterPrivate = getCharacterPrivate(character);
  if (isNpc(characterPrivate) && isAlive(character)) {
    if (!npcTargetSet(characterPrivate)) {
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
        npcClearTarget(characterPrivate);
      } else {
        double angle = radionsBetweenObject(character, target);
        setCharacterState(character, characterStateWalking);
        setDirection(character, convertAngleToDirection(angle));
      }
    }
  }

  character[indexPosX] += characterPrivate[keyVelocityX];
  character[indexPosY] += characterPrivate[keyVelocityY];
  characterPrivate[keyVelocityX] *= velocityFriction;
  characterPrivate[keyVelocityY] *= velocityFriction;

  switch (getState(character)) {
    case characterStateAiming:
      if (character[keyAccuracy] > 0.05) {
        character[keyAccuracy] -= 0.005;
      }
      break;
    case characterStateFiring:
      characterPrivate[keyShotCoolDown]--;
      if (characterPrivate[keyShotCoolDown] <= 0) {
        setCharacterStateIdle(character);
      }
      break;
    case characterStateIdle:
      break;
    case characterStateWalking:
      double speed = getSpeed(characterPrivate);
      switch (getDirection(character)) {
        case directionUp:
          character[indexPosY] -= speed;
          break;
        case directionUpRight:
          character[indexPosX] += speed * 0.5;
          character[indexPosY] -= speed * 0.5;
          break;
        case directionRight:
          character[indexPosX] += speed;
          break;
        case directionDownRight:
          character[indexPosX] += speed * 0.5;
          character[indexPosY] += speed * 0.5;
          break;
        case directionDown:
          character[indexPosY] += speed;
          break;
        case directionDownLeft:
          character[indexPosX] -= speed * 0.5;
          character[indexPosY] += speed * 0.5;
          break;
        case directionLeft:
          character[indexPosX] -= speed;
          break;
        case directionUpLeft:
          character[indexPosX] -= speed * 0.5;
          character[indexPosY] -= speed * 0.5;
          break;
      }
      break;
  }
}

void removeCharacter(dynamic character) {
  characters.removeWhere((element) => element[keyId] == character[keyId]);
  charactersPrivate
      .removeWhere((element) => element[keyId] == character[keyId]);
}

void updateCharacters() {
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
    roundKey(character, indexPosX);
    roundKey(character, indexPosY);
  }
}

int compareCharacters(dynamic a, dynamic b) {
  if (posX(a) < posX(b)) {
    return -1;
  }
  return 1;
}

void updateCollisions() {
  characters.sort(compareCharacters);
  for (int i = 0; i < characters.length - 1; i++) {
    dynamic characterI = characters[i];
    if (isDead(characterI)) continue;
    for (int j = i + 1; j < characters.length; j++) {
      dynamic characterJ = characters[j];
      if (isDead(characterJ)) continue;
      double xDiff = posX(characterI) - posX(characterJ);
      if (abs(xDiff) > characterRadius2) break;
      double yDiff = posY(characterI) - posY(characterJ);
      if (abs(yDiff) > characterRadius2) continue;
      double distance = distanceBetween(characterI, characterJ);
      if (distance >= characterRadius2) continue;
      double overlap = characterRadius2 - distance;
      double halfOverlap = overlap * 0.5;
      double mag = magnitude(xDiff, yDiff);
      double ratio = 1.0 / mag;
      double xDiffNormalized = xDiff * ratio;
      double yDiffNormalized = yDiff * ratio;
      double targetX = xDiffNormalized * halfOverlap;
      double targetY = yDiffNormalized * halfOverlap;
      characterI[indexPosX] += targetX;
      characterI[indexPosY] += targetY;
      characterJ[indexPosX] -= targetX;
      characterJ[indexPosY] -= targetY;
    }
  }
}
