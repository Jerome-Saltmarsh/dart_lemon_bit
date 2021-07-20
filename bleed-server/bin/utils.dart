import 'dart:math';

import 'common.dart';
import 'functions/spawn_character.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';

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

void setDirection(dynamic character, int value) {
  character[keyDirection] = value;
}

dynamic npcTarget(dynamic character) {
  return findCharacterById(character[keyNpcTarget]);
}

dynamic findCharacterById(int id) {
  return characters.firstWhere((element) => element[keyCharacterId] == id,
      orElse: () {
    return null;
  });
}

bool npcTargetSet(dynamic character) {
  return character[keyNpcTarget] != null;
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

double getSpeed(dynamic character){
  if(isHuman(character)){
    return characterSpeed;
  }
  return zombieSpeed;
}

dynamic spawnPlayer(double x, double y, String name){
  return spawnCharacter(x, y, name: name, npc: false, health: playerHealth);
}

dynamic spawnZombie(double x, double y){
  return spawnCharacter(y, x, npc: true, health: zombieHealth);
}

double velX(double rotation, double speed){
  return -cos(rotation + (pi * 0.5)) * speed;
}
double velY(double rotation, double speed){
  return -sin(rotation + (pi * 0.5)) * speed;
}

void setVelocity(dynamic target, double rotation, double speed){
  target[keyVelocityX] = velX(rotation, bulletSpeed);
  target[keyVelocityY] = velY(rotation, bulletSpeed);
}
