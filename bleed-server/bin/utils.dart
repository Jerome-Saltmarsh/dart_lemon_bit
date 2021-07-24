import 'dart:async';
import 'dart:math';

import 'common.dart';
import 'common_functions.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'update.dart';

double posX(dynamic value) {
  return value[indexPosX];
}

double posY(dynamic value) {
  return value[indexPosY];
}

double bulletDistanceTravelled(dynamic bullet) {
  return distance(bullet['x'], bullet['y'], bullet[keyStartX],
      bullet[keyStartY]);
}

List<dynamic> getHumans() {
  return characters.where(isHuman).toList();
}

List<dynamic> getNpcs() {
  return charactersPrivate.where(isNpc).toList();
}

bool isHuman(dynamic character) {
  return character[keyType] == typeHuman;
}

bool isNpc(dynamic character) {
  return character[keyType] == typeNpc;
}

bool isAlive(dynamic character) {
  return getState(character) != characterStateDead;
}

bool isFiring(dynamic character) {
  return getState(character) == characterStateFiring;
}

int getState(dynamic character){
  return character[indexState];
}

int getDirection(dynamic character){
  return character[indexDirection];
}

void setCharacterState(dynamic character, int value) {
  if (getState(character) == value) return;

  switch (value) {
    case characterStateAiming:
      character[keyAccuracy] = startingAccuracy;
      break;
  }

  character[indexState] = value;
}

void setDirection(dynamic character, int value){
  character[indexDirection] = value;
}

void setCharacterStateWalk(dynamic character) {
  setCharacterState(character, characterStateWalking);
}

void setCharacterStateAim(dynamic character) {
  setCharacterState(character, characterStateAiming);
}

void setCharacterStateIdle(dynamic character) {
  setCharacterState(character, characterStateIdle);
}

void setCharacterStateDead(dynamic character) {
  setCharacterState(character, characterStateDead);
}

void setCharacterStateFiring(dynamic character) {
  setCharacterState(character, characterStateFiring);
}

dynamic npcTarget(dynamic character) {
  return findCharacterById(character[keyNpcTargetId]);
}

void npcClearTarget(character) {
  character[keyNpcTargetId] = null;
}

dynamic findCharacterById(int id) {
  return characters.firstWhere((element) => element[indexId] == id, orElse: () {
    return null;
  });
}

bool npcTargetSet(dynamic npc) {
  return npc[keyNpcTargetId] != null;
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

bool npcArrivedAtDestination(dynamic npc) {
  return npcDistanceFromDestination(npc) <= destinationArrivedDistance;
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

bool isDead(dynamic character) {
  return getState(character) == characterStateDead;
}

bool isAiming(dynamic character) {
  return getState(character) == characterStateAiming;
}

double getSpeed(dynamic character) {
  if (isHuman(character)) {
    return characterSpeed;
  }
  return zombieSpeed;
}

dynamic spawnPlayer(double x, double y, String name) {
  return spawnCharacter(x, y,
      name: name, npc: false, health: playerHealth, weapon: weaponHandgun);
}

dynamic spawnZombie(double x, double y) {
  return spawnCharacter(y, x,
      npc: true, health: zombieHealth, weapon: weaponUnarmed);
}

double velX(double rotation, double speed) {
  return -cos(rotation + (pi * 0.5)) * speed;
}

double velY(double rotation, double speed) {
  return -sin(rotation + (pi * 0.5)) * speed;
}

void setVelocity(dynamic target, double rotation, double speed) {
  target[keyVelocityX] = velX(rotation, bulletSpeed);
  target[keyVelocityY] = velY(rotation, bulletSpeed);
}

double npcDistanceFromDestination(dynamic npc) {
  dynamic npcPrivate = getCharacterPrivate(npc);
  return objectDistanceFrom(
      npc, npcPrivate[keyDestinationX], npcPrivate[keyDestinationY]);
}

double objectDistanceFrom(dynamic character, double x, double y) {
  return distance(posY(character), posY(character), x, y);
}

void npcFaceDestination(dynamic npc, dynamic npcPrivate) {
  characterFace(npc, npcPrivate[keyDestinationX], npcPrivate[keyDestinationY]);
}

void characterFace(dynamic character, double x, double y) {
  setDirection(
      character, convertAngleToDirection(radionsBetween2(character, x, y)));
}

void createJob(Function function, {int seconds = 0, int ms = 0}) {
  Timer.periodic(Duration(seconds: seconds, milliseconds: ms), (timer) {
    function();
  });
}

void assignId(dynamic object) {
  id++;
  object[keyId] = id;
}

double round(double value, {int decimals = 1}) {
  return double.parse(value.toStringAsFixed(decimals));
}

void roundKey(dynamic object, int key, {int decimals = 1}) {
  object[key] = round(object[key], decimals: decimals);
}

double getShotAngle(character) {
  double accuracy = character[keyAccuracy];
  double angle = character[keyRotation] + giveOrTake(accuracy * 0.5);
  character[keyAccuracy] = startingAccuracy;
  return angle;
}

void fireWeapon(dynamic character) {
  dynamic characterPrivate = getCharacterPrivate(character);

  switch (character[keyWeapon]) {
    case weaponHandgun:
      double angle = getShotAngle(character);
      spawnBullet(posX(character), posY(character), angle,
          character[keyId]);
      setCharacterStateFiring(character);
      characterPrivate[keyShotCoolDown] = pistolCoolDown;
      break;
    case weaponShotgun:
      for (int i = 0; i < 5; i++) {
        spawnBullet(posX(character), posY(character),
            getShotAngle(character), character[keyId]);
      }
      setCharacterStateFiring(character);
      characterPrivate[keyShotCoolDown] = shotgunCoolDown;
      break;
  }
}

void npcWanderJob() {
  for (dynamic npc in getNpcs()) {
    if (npcTargetSet(npc)) continue;
    if (npcDestinationSet(npc)) continue;
    npcSetRandomDestination(npc);
  }
}

void spawnBullet(double x, double y, double angle, int characterId) {
  Map<String, dynamic> bullet = Map();
  bullet['x'] = x;
  bullet['y'] = y;
  bullet[keyStartX] = x;
  bullet[keyStartY] = y;
  assignId(bullet);
  setVelocity(bullet, angle, bulletSpeed);
  bullet[keyRotation] = angle;
  bullet[keyFrame] = 0;
  bullet[keyId] = characterId;
  bullets.add(bullet);
}

dynamic spawnCharacter(double x, double y,
    {required bool npc,
    required int health,
    required int weapon,
    String? name}) {
  if (x == double.nan) {
    throw Exception("x is nan");
  }
  dynamic character = [
    id++,
    characterStateIdle,
    directionUp,
    x,
    y,
    weapon,
    if(name != null)
      name,
    if(name != null)
      frame, // last update frame
  ];

  Map<String, dynamic> characterPrivate = new Map();
  characterPrivate[keyType] = npc ? typeNpc : typeHuman;
  characterPrivate[keyHealth] = health;
  characterPrivate[keyVelocityX] = 0;
  characterPrivate[keyVelocityY] = 0;
  characterPrivate[keyId] = getId(character);

  characters.add(character);
  charactersPrivate.add(characterPrivate);
  return character;
}

void spawnZombieJob() {
  if (getNpcs().length >= maxZombies) return;
  spawnRandomZombie();
}

dynamic spawnRandomZombie() {
  return spawnZombie(randomBetween(-spawnRadius, spawnRadius),
      randomBetween(-spawnRadius, spawnRadius));
}
