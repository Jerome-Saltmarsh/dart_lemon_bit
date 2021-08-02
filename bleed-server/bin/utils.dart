import 'dart:async';

import 'classes.dart';
import 'common.dart';
import 'constants.dart';
import 'maths.dart';
import 'settings.dart';
import 'spawn.dart';
import 'state.dart';
import 'update.dart';

double bulletDistanceTravelled(Bullet bullet) {
  return distance(bullet.x, bullet.y, bullet.xStart, bullet.yStart);
}

void setCharacterState(Character character, CharacterState value) {
  if (character.dead) return;
  if (character.state == value) return;
  if (character.shotCoolDown > 0) return;

  switch (value) {
    case CharacterState.Aiming:
      character.accuracy = 0;
      break;
    case CharacterState.Firing:
      fireWeapon(character);
      break;
  }
  character.state = value;
}

void changeCharacterHealth(Character character, double amount) {
  character.health += amount;
  character.health = clamp(character.health, 0, character.maxHealth);
  if (character.health <= 0) {
    setCharacterState(character, CharacterState.Dead);
  }
}

double clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

void setDirection(Character character, Direction value) {
  if (value == Direction.None) return;
  if (character.firing) return;
  if (character.dead) return;
  character.direction = value;
}

bool withinViewRange(Npc npc, GameObject target) {
  return distanceBetween(npc, target) < zombieViewRange;
}

Character? npcTarget(Npc npc) {
  return findPlayerById(npc.targetId);
}

void npcClearTarget(Npc npc) {
  npc.targetId = -1;
}

Npc findNpcById(int id) {
  return npcs.firstWhere((npc) => npc.id == id, orElse: () {
    throw Exception("could not find npc with id $id");
  });
}

Character? findPlayerById(int id) {
  for (Character character in players) {
    if (character.id == id) return character;
  }
  return null;
}

void npcSetRandomDestination(Npc npc) {
  npc.xDes = randomBetween(-100, 100);
  npc.yDes = randomBetween(-100, 100);
}

bool arrivedAtDestination(Npc npc) {
  return distanceFromDestination(npc) <= destinationArrivedDistance;
}

int lastUpdateFrame(dynamic character) {
  return character[keyLastUpdateFrame];
}

bool connectionExpired(dynamic character) {
  return frame - lastUpdateFrame(character) > expiration;
}

bool isDead(Character character) {
  return character.state == characterStateDead;
}

bool isAiming(Character character) {
  return character.state == characterStateAiming;
}

void setVelocity(PhysicsGameObject target, double rotation, double speed) {
  target.xVel = velX(rotation, bulletSpeed);
  target.yVel = velY(rotation, bulletSpeed);
}

double distanceFromDestination(Npc npc) {
  return objectDistanceFrom(npc, npc.xDes, npc.yDes);
}

double objectDistanceFrom(GameObject gameObject, double x, double y) {
  return distance(gameObject.x, gameObject.y, x, y);
}

void faceDestination(Npc npc) {
  characterFace(npc, npc.xDes, npc.yDes);
}

void characterFace(Character character, double x, double y) {
  setDirection(
      character, convertAngleToDirection(radionsBetween2(character, x, y)));
}

void characterFaceObject(Character character, GameObject target) {
  characterFace(character, target.x, target.y);
}

void createJob(Function function, {int seconds = 0, int ms = 0}) {
  Timer.periodic(Duration(seconds: seconds, milliseconds: ms), (timer) {
    function();
  });
}

double round(double value, {int decimals = 1}) {
  return double.parse(value.toStringAsFixed(decimals));
}

double getShotAngle(Character character) {
  return character.aimAngle + giveOrTake(character.accuracy * 0.5);
}

void faceAimDirection(Character character) {
  setDirection(character, convertAngleToDirection(character.aimAngle));
}

void fireWeapon(Character character) {
  // if (!character.aiming) return;
  if (character.dead) return;
  if (character.shotCoolDown > 0) return;
  faceAimDirection(character);
  switch (character.weapon) {
    case Weapon.HandGun:
      spawnBullet(character);
      character.fire();
      character.shotCoolDown = pistolCoolDown;
      break;
    case Weapon.Shotgun:
      for (int i = 0; i < 5; i++) {
        spawnBullet(character);
      }
      character.fire();
      character.shotCoolDown = shotgunCoolDown;
      break;
  }
}

void npcWanderJob() {
  for (Npc npc in npcs) {
    if (npc.targetSet) continue;
    if (npc.destinationSet) continue;
    npcSetRandomDestination(npc);
  }
}

void clearNpcs() {
  npcs.clear();
}

Direction convertAngleToDirection(double angle) {
  if (angle < piEighth) {
    return Direction.Up;
  }
  if (angle < piEighth + (piQuarter * 1)) {
    return Direction.UpRight;
  }
  if (angle < piEighth + (piQuarter * 2)) {
    return Direction.Right;
  }
  if (angle < piEighth + (piQuarter * 3)) {
    return Direction.DownRight;
  }
  if (angle < piEighth + (piQuarter * 4)) {
    return Direction.Down;
  }
  if (angle < piEighth + (piQuarter * 5)) {
    return Direction.DownLeft;
  }
  if (angle < piEighth + (piQuarter * 6)) {
    return Direction.Left;
  }
  if (angle < piEighth + (piQuarter * 7)) {
    return Direction.UpLeft;
  }
  return Direction.Up;
}
