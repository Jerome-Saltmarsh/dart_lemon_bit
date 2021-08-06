import 'dart:math';

import 'classes.dart';
import 'common.dart';
import 'constants.dart';
import 'enums.dart';
import 'events.dart';
import 'language.dart';
import 'maths.dart';
import 'settings.dart';
import 'spawn.dart';
import 'state.dart';

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
    case CharacterState.Striking:
      character.shotCoolDown = 10;
      break;
  }
  character.state = value;
}

void setCharacterStateIdle(Character character){
  setCharacterState(character, CharacterState.Idle);
}

void changeCharacterHealth(Character character, double amount) {
  if (character.dead && amount < 0) return;

  character.health += amount;
  character.health = clamp(character.health, 0, character.maxHealth);
  if (character.health <= 0) {
    setCharacterState(character, CharacterState.Dead);
    onDeath.add(character);
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

Player? findPlayerById(int id) {
  for (Player player in players) {
    if (player.id == id) return player;
  }
  return null;
}

void npcSetRandomDestination(Npc npc) {
  npc.xDes = npc.x + giveOrTake(settingsNpcRoamRange);
  npc.yDes = npc.y + giveOrTake(settingsNpcRoamRange);
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
      character, convertAngleToDirection(radiansBetween2(character, x, y)));
}

void characterFaceObject(Character character, GameObject target) {
  characterFace(character, target.x, target.y);
}

double getShotAngle(Character character) {
  return character.aimAngle + giveOrTake(character.accuracy * 0.5);
}

void faceAimDirection(Character character) {
  setDirection(character, convertAngleToDirection(character.aimAngle));
}

void fireWeapon(Character character) {
  if (character.dead) return;
  if (character.shotCoolDown > 0) return;
  faceAimDirection(character);
  switch (character.weapon) {
    case Weapon.HandGun:
      spawnBullet(character);
      spawnShell(character.x, character.y, character.aimAngle + (pi + giveOrTake(piHalf)));
      character.state = CharacterState.Firing;
      character.shotCoolDown = pistolCoolDown;
      gameEvents.add(GameEvent(character.x, character.y, GameEventType.Handgun_Fired));
      break;
    case Weapon.Shotgun:
      character.xVel += velX(character.aimAngle + pi, 1);
      character.yVel += velY(character.aimAngle + pi, 1);

      for (int i = 0; i < settingsShotgunBulletsPerShot; i++) {
        spawnBullet(character);
      }
      delayed((){
        spawnShell(character.x, character.y, character.aimAngle + (pi + giveOrTake(piHalf)));
      }, ms: 500);
      character.state = CharacterState.Firing;
      character.shotCoolDown = shotgunCoolDown;
      gameEvents.add(GameEvent(character.x, character.y, GameEventType.Shotgun_Fired));
      break;
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

void revive(Character character) {
  print('revive(${character.id})');
  character.state = CharacterState.Idle;
  character.health = character.maxHealth;
  character.x = giveOrTake(settingsPlayerStartRadius);
  character.y = giveOrTake(settingsPlayerStartRadius);
}

void generateTiles() {
  tiles.clear();
  for (int x = 0; x < tilesX; x++) {
    List<Tile> column = [];
    tiles.add(column);
    for (int y = 0; y < tilesY; y++) {
      column.add(Tile.Concrete);
    }
  }
  tiles[4][4] = Tile.Grass;
  tiles[4][5] = Tile.Grass;
}

double getWeaponRange(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return settingsWeaponRangeHandgun;
    case Weapon.Shotgun:
      return settingsWeaponRangeShotgun;
    default:
      throw Exception("no range found for $weapon");
  }
}

double getWeaponAccuracy(Weapon weapon){
  switch (weapon){
    case Weapon.HandGun:
      return settingsWeaponAccuracyHandgun;
    case Weapon.Shotgun:
      return settingsWeaponAccuracyShotgun;
    default:
      throw Exception("no range found for $weapon");
  }
}

void dispatch(GameEventType type, double x, double y){
  print('dispatch($type)');
  gameEvents.add(GameEvent(x, y, type));
}

void applyMovement(PhysicsGameObject physicsGameObject){
  physicsGameObject.x += physicsGameObject.xVel;
  physicsGameObject.y += physicsGameObject.yVel;
}

void applyFriction(PhysicsGameObject physicsGameObject, double value){
  physicsGameObject.xVel *= value;
  physicsGameObject.yVel *= value;
}