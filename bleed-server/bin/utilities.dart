import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/give_or_take.dart';

import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'classes/Player.dart';
import 'classes/Projectile.dart';
import 'common/WeaponType.dart';
import 'functions/withinRadius.dart';
import 'maths.dart';
import 'settings.dart';

const double tileSize = 48.0;
const double halfTileSize = 24;
const secondsPerMinute = 60;
const minutesPerHour = 60;

double tilesLeftY = 0;

double projectileDistanceTravelled(Projectile bullet) {
  return distanceBetween(bullet.x, bullet.y, bullet.xStart, bullet.yStart);
}

double clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

int clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

// TODO floating logic
void setAngle(Character character, double value) {
  if (character.dead) return;
  if (character.busy) return;
  character.angle = value;
}

bool withinViewRange(AI ai, GameObject target) {
  return distanceV2(ai.character, target) < ai.viewRange;
}

bool arrivedAtPath(AI npc) {
  if (diffOver(npc.character.x, npc.destX, settings.npc.destinationRadius)) return false;
  if (diffOver(npc.character.y, npc.destY, settings.npc.destinationRadius)) return false;
  return true;
}

void setVelocity(GameObject gameObject, double rotation, double speed) {
  gameObject.xv = velX(rotation, speed);
  gameObject.yv = velY(rotation, speed);
}

double objectDistanceFrom(GameObject gameObject, double x, double y) {
  return distanceBetween(gameObject.x, gameObject.y, x, y);
}

void characterFace(Character character, double x, double y) {
  characterFaceAngle(character, radiansBetween2(character, x, y));
}

void characterAimAt(Character character, double x, double y){
  characterFaceAngle(character, radiansBetween2(character, x, y));
}

void characterFaceAngle(Character character, double angle){
  character.aimAngle = angle;
  setAngle(character, angle);
}

void characterFaceV2(Character character, Vector2 target) {
  characterFace(character, target.x, target.y);
}

double getShotAngle(Character character) {
  return character.aimAngle + giveOrTake(character.accuracy * 0.5);
}

void faceAimDirection(Character character) {
  setAngle(character, character.aimAngle);
}

void applyMovement(GameObject gameObject) {
  gameObject.x += gameObject.xv;
  gameObject.y += gameObject.yv;
  gameObject.z += gameObject.zv;
}

void applyFriction(GameObject gameObject, double value) {
  gameObject.xv *= value;
  gameObject.yv *= value;
}

bool targetWithinStrikingRange(GameObject source, GameObject target) {
  return withinRadius(source, target, settings.range.zombieStrike);
}

bool targetWithinFiringRange(Character character, GameObject target){
  double range = getWeaponRange(character.weapon.type);
  if (diffOver(character.x, target.x, range)) return false;
  if (diffOver(character.y, target.y, range)) return false;
  return true;
}

Vector2 getTilePosition(int row, int column) {
  return Vector2(
      perspectiveProjectX(row * halfTileSize, column * halfTileSize),
      perspectiveProjectY(row * halfTileSize, column * halfTileSize) +
          halfTileSize);
}

double getTilePositionX(int row, int column){
  return perspectiveProjectX(row * halfTileSize, column * halfTileSize);
}

double getTilePositionY(int row, int column){
  return perspectiveProjectY(row * halfTileSize, column * halfTileSize) +
      halfTileSize;
}

double perspectiveProjectX(double x, double y) {
  return -y + x;
}

double perspectiveProjectY(double x, double y) {
  return x + y;
}

int calculateTime({int minute = 0, int hour = 0}){
  return secondsPerMinute * minutesPerHour * hour + minute;
}

void sortVertically(List<Vector2> items) {
  int start = 0;
  int end = items.length;
  for (var pos = start + 1; pos < end; pos++) {
    var min = start;
    var max = pos;
    var element = items[pos];
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      if (element.y < items[mid].y) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    items.setRange(min + 1, pos + 1, items, min);
    items[min] = element;
  }
}

/// returns -1 if the player does not have the weapon
int getIndexOfWeaponType(Player player, WeaponType type){
  for(int i = 0; i < player.weapons.length; i++){
      if (player.weapons[i].type == type){
        return i;
      }
  }
  return -1;
}