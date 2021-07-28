import 'dart:async';
import 'dart:math';

import 'classes.dart';
import 'common.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';

double bulletDistanceTravelled(dynamic bullet) {
  return distance(bullet['x'], bullet['y'], bullet[keyStartX],
      bullet[keyStartY]);
}

void setCharacterState(Character character, CharacterState value) {
  if (character.state == value) return;

  switch (value) {
    case CharacterState.Aiming:
      character.accuracy = 0;
      break;
  }
  character.state = value;
}

void setDirection(Character character, Direction value){
  character.direction = value;
}

bool withinViewRange(Npc npc, GameObject target){
  return distanceBetween(npc, target) < zombieViewRange;
}

Character npcTarget(Npc npc) {
  return findPlayerById(npc.targetId);
}

void npcClearTarget(Npc npc) {
  npc.targetId = -1;
}

Npc findNpcById(int id){
  return npcs.firstWhere((npc) => npc.id == id, orElse: () {
    throw Exception("could not find npc with id $id");
  });
}

Character findPlayerById(int id){
  return players.firstWhere((player) => player.id == id, orElse: () {
    throw PlayerNotFoundException();
  });
}

class PlayerNotFoundException implements Exception {

}

void npcClearDestination(dynamic npc) {
  npc[keyDestinationX] = null;
  npc[keyDestinationY] = null;
}

bool npcDestinationSet(dynamic npc) {
  return npc[keyDestinationX] != null;
}

void npcSetDestination(dynamic npc, double x, double y) {
  npc[keyDestinationX] = x;
  npc[keyDestinationY] = y;
}

void npcSetRandomDestination(dynamic npc) {
  npcSetDestination(npc, randomBetween(-100, 100), randomBetween(-100, 100));
}

bool arrivedAtDestination(Npc npc) {
  return distanceFromDestination(npc) <= destinationArrivedDistance;
}

void npcSetTarget(dynamic npc, dynamic value) {
  if (value is int) {
    npc[keyNpcTargetId] = value;
  } else {
    npc[keyNpcTargetId] = value[keyId];
  }
}

void setPosition(dynamic character, {double? x, double? y}) {
  if (x != null) {
    character[indexPosX] = x;
  }
  if (y != null) {
    character[indexPosY] = y;
  }
}

int getId(dynamic character) {
  return  character[indexId];
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
  setDirection(character, convertAngleToDirection(radionsBetween2(character, x, y)));
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

void roundKey(dynamic object, int key, {int decimals = 1}) {
  object[key] = round(object[key], decimals: decimals);
}

double getShotAngle(Character character) {
  return character.aimAngle + giveOrTake(character.accuracy * 0.5);
}

void fireWeapon(Character character) {
  switch (character.weapon) {
    case Weapon.HandGun:
      characterSpawnBullet(character);
      character.fire();
      character.shotCoolDown = pistolCoolDown;
      break;
    case Weapon.Shotgun:
      for (int i = 0; i < 5; i++) {
        characterSpawnBullet(character);
      }
      character.fire();
      character.shotCoolDown = shotgunCoolDown;
      break;
  }
}

void npcWanderJob() {
  for (Npc npc in npcs) {
    if (npc.targetSet) continue;
    if (npcDestinationSet(npc)) continue;
    npcSetRandomDestination(npc);
  }
}

void spawnBullet(double x, double y, double angle, int characterId) {
  Bullet bullet = Bullet(x, y, velX(angle, bulletSpeed), velY(angle, bulletSpeed), characterId);
  bullet.xStart = x;
  bullet.yStart = y;
  setVelocity(bullet, angle, bulletSpeed);
  bullets.add(bullet);
}

void characterSpawnBullet(Character character){
  spawnBullet(character.x, character.y, getShotAngle(character), character.id);
}

Npc spawnNpc(double x, double y) {
  Npc npc = Npc(x, y);
  npcs.add(npc);
  return npc;
}

Npc spawnRandomNpc() {
  return spawnNpc(randomBetween(-spawnRadius, spawnRadius),
      randomBetween(-spawnRadius, spawnRadius));
}

Character spawnPlayer(String name){
  Character player = Character(0.01, 0.02, Weapon.HandGun, 5, playerSpeed, name);
  players.add(player);
  return player;
}

const double eight = pi / 8.0;
const double quarter = pi / 4.0;

Direction convertAngleToDirection(double angle) {
  if (angle < eight) {
    return Direction.Up;
  }
  if (angle < eight + (quarter * 1)) {
    return Direction.UpRight;
  }
  if (angle < eight + (quarter * 2)) {
    return Direction.Right;
  }
  if (angle < eight + (quarter * 3)) {
    return Direction.DownRight;
  }
  if (angle < eight + (quarter * 4)) {
    return Direction.Down;
  }
  if (angle < eight + (quarter * 5)) {
    return Direction.DownLeft;
  }
  if (angle < eight + (quarter * 6)) {
    return Direction.Left;
  }
  if (angle < eight + (quarter * 7)) {
    return Direction.UpLeft;
  }
  return Direction.Up;
}