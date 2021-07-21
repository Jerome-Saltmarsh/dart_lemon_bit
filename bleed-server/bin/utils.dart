import 'dart:async';
import 'dart:math';

import 'common.dart';
import 'common_functions.dart';
import 'functions/spawn_character.dart';
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

void setCharacterState(dynamic character, int value) {
  character[keyState] = value;
}

void setCharacterStateWalk(dynamic character){
  setCharacterState(character, characterStateWalking);
}

void setCharacterStateIdle(dynamic character){
  setCharacterState(character, characterStateIdle);
}

void setDirection(dynamic character, int value) {
  character[keyDirection] = value;
}

dynamic npcTarget(dynamic character) {
  return findCharacterById(character[keyNpcTarget]);
}

void npcClearTarget(character) {
  character[keyNpcTarget] = null;
}

dynamic findCharacterById(int id) {
  return characters.firstWhere((element) => element[keyCharacterId] == id,
      orElse: () {
    return null;
  });
}

bool npcTargetSet(dynamic npc) {
  return npc[keyNpcTarget] != null;
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
    npc[keyNpcTarget] = value;
  } else {
    npc[keyNpcTarget] = value[keyCharacterId];
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
  return character[keyCharacterId];
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
  return spawnCharacter(x, y, name: name, npc: false, health: playerHealth);
}

dynamic spawnZombie(double x, double y) {
  return spawnCharacter(y, x, npc: true, health: zombieHealth);
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


