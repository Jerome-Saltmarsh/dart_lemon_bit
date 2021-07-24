import 'dart:async';
import 'dart:math';

import 'common.dart';
import 'common_functions.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';

double posX(dynamic value){
  return value[keyPositionX];
}

double posY(dynamic value){
  return value[keyPositionY];
}

double bulletDistanceTravelled(dynamic bullet) {
  return distance(bullet[keyPositionX], bullet[keyPositionY], bullet[keyStartX],
      bullet[keyStartY]);
}

List<dynamic> getHumans() {
  return characters.where(isHuman).toList();
}

List<dynamic> getNpcs() {
  return characters.where(isNpc).toList();
}

bool isHuman(dynamic character) {
  return character[keyType] == typeHuman;
}

bool isNpc(dynamic character) {
  return character[keyType] == typeNpc;
}

bool isAlive(dynamic character) {
  return character[keyState] != characterStateDead;
}

bool isFiring(dynamic character){
  return character[keyState] == characterStateFiring;
}

void setCharacterState(dynamic character, int value) {
  character[keyState] = value;
}

void setCharacterStateWalk(dynamic character){
  setCharacterState(character, characterStateWalking);
}

void setCharacterStateIdle(dynamic character){
  setCharacterState(character, characterStateIdle);
}

void setCharacterStateFiring(dynamic character){
  setCharacterState(character, characterStateFiring);
}

void setDirection(dynamic character, int value) {
  character[keyDirection] = value;
}

dynamic npcTarget(dynamic character) {
  return findCharacterById(character[keyNpcTargetId]);
}

void npcClearTarget(character) {
  character[keyNpcTargetId] = null;
}

dynamic findCharacterById(int id) {
  return characters.firstWhere((element) => element[keyId] == id,
      orElse: () {
    return null;
  });
}

bool npcTargetSet(dynamic npc) {
  return npc[keyNpcTargetId] != null;
}

void npcClearDestination(dynamic npc){
  npc[keyDestinationX] = null;
  npc[keyDestinationY] = null;
}

bool npcDestinationSet(dynamic npc){
  return npc[keyDestinationX] != null;
}

void npcSetDestination(dynamic npc, double x, double y){
  npc[keyDestinationX] = x;
  npc[keyDestinationY] = y;
}

void npcSetRandomDestination(dynamic npc){
  npcSetDestination(npc, randomBetween(-100, 100), randomBetween(-100, 100));
}

bool npcArrivedAtDestination(dynamic npc){
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
    character[keyPositionX] = x;
  }
  if (y != null) {
    character[keyPositionY] = y;
  }
}

int getId(dynamic character) {
  return character[keyId];
}

int lastUpdateFrame(dynamic character) {
  return character[keyLastUpdateFrame];
}

bool connectionExpired(dynamic character) {
  return frame - lastUpdateFrame(character) > expiration;
}

bool isDead(dynamic character) {
  return character[keyState] == characterStateDead;
}

bool isAiming(dynamic character) {
  return character[keyState] == characterStateAiming;
}

double getSpeed(dynamic character) {
  if (isHuman(character)) {
    return characterSpeed;
  }
  return zombieSpeed;
}

dynamic spawnPlayer(double x, double y, String name) {
  return spawnCharacter(x, y, name: name, npc: false, health: playerHealth, weapon: weaponHandgun);
}

dynamic spawnZombie(double x, double y) {
  return spawnCharacter(y, x, npc: true, health: zombieHealth, weapon: weaponUnarmed);
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

double npcDistanceFromDestination(dynamic npc){
  return objectDistanceFrom(npc, npc[keyDestinationX], npc[keyDestinationY]);
}

double objectDistanceFrom(dynamic character, double x, double y){
  return distance(character[keyPositionX], character[keyPositionY], character[keyDestinationX], character[keyDestinationY]);
}

void npcFaceDestination(dynamic npc){
  characterFace(npc, npc[keyDestinationX], npc[keyDestinationY]);
}

void characterFace(dynamic character, double x, double y){
  setDirection(character, convertAngleToDirection(radionsBetween2(character, x, y)));
}

void createJob(Function function, {int seconds = 0, int ms = 0}) {
  Timer.periodic(Duration(seconds: seconds, milliseconds: ms), (timer) {
    function();
  });
}

void assignId(dynamic object){
  id++;
  object[keyId] = id;
}

double round(double value, {int decimals = 1}){
  return double.parse(value.toStringAsFixed(decimals));
}

void roundKey(dynamic object, String key, {int decimals = 1}){
  object[key] = round(object[key], decimals: decimals);
}

double getShotAngle(character) {
  double accuracy = character[keyAccuracy];
  double angle = character[keyRotation] + giveOrTake(accuracy * 0.5);
  character[keyAccuracy] = startingAccuracy;
  return angle;
}

void fireWeapon(dynamic character){
  switch (character[keyWeapon]) {
    case weaponHandgun:
      double angle = getShotAngle(character);
      spawnBullet(character[keyPositionX], character[keyPositionY],
          angle, character[keyId]);
      setCharacterStateFiring(character);
      character[keyShotCoolDown] = pistolCoolDown;
      break;
    case weaponShotgun:
      for(int i = 0; i < 5; i++){
        spawnBullet(character[keyPositionX], character[keyPositionY],
            getShotAngle(character), character[keyId]);
      }
      setCharacterStateFiring(character);
      character[keyShotCoolDown] = shotgunCoolDown;
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
  bullet[keyPositionX] = x;
  bullet[keyPositionY] = y;
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
  Map<String, dynamic> character = new Map();
  assignId(character);
  character[keyPositionX] = x;
  character[keyPositionY] = y;
  character[keyWeapon] = weapon;
  character[keyDirection] = directionDown;
  character[keyState] = characterStateIdle;
  character[keyHealth] = health;
  character[keyType] = npc ? typeNpc : typeHuman;
  character[keyId] = character[keyId];

  Map<String, dynamic> characterPrivate = new Map();
  characterPrivate[keyVelocityX] = 0;
  characterPrivate[keyVelocityY] = 0;
  characterPrivate[keyId] = character[keyId];

  if (name != null) {
    character[keyPlayerName] = name;
  }
  if (!npc) {
    character[keyLastUpdateFrame] = frame;
  }
  characters.add(character);
  charactersPrivate.add(characterPrivate);
  return character;
}

void spawnZombieJob() {
  if (getNpcs().length >= maxZombies) return;
  spawnRandomZombie();
}

dynamic spawnRandomZombie() {
  return spawnZombie(randomBetween(-spawnRadius, spawnRadius), randomBetween(-spawnRadius, spawnRadius));
}


