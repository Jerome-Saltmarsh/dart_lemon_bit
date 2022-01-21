import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomItem.dart';

import 'classes/Player.dart';
import 'classes/Projectile.dart';
import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'classes/Npc.dart';
import 'classes/Weapon.dart';
import 'common/CollectableType.dart';
import 'common/WeaponType.dart';
import 'common/enums/Direction.dart';
import 'constants.dart';
import 'maths.dart';
import 'settings.dart';

const double tileSize = 48.0;
const double halfTileSize = 24;
const secondsPerMinute = 60;
const minutesPerHour = 60;
const _minusOne = -1;
const _one = 1;

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

// TODO impertinent logic
void setDirection(Character character, Direction direction) {
  if (character.dead) return;
  if (character.busy) return;
  character.direction = direction;
}

bool withinViewRange(Npc npc, GameObject target) {
  return distanceV2(npc, target) < settings.npc.viewRange;
}

bool arrivedAtPath(Npc npc) {
  if (diffOver(npc.x, npc.path[0].x, settings.npc.destinationRadius)) return false;
  if (diffOver(npc.y, npc.path[0].y, settings.npc.destinationRadius)) return false;
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
  setDirection(character, convertAngleToDirection(angle));
}

void characterFaceV2(Character character, Vector2 target) {
  characterFace(character, target.x, target.y);
}

double getShotAngle(Character character) {
  return character.aimAngle + giveOrTake(character.accuracy * 0.5);
}

void faceAimDirection(Character character) {
  setDirection(character, convertAngleToDirection(character.aimAngle));
}

Direction convertAngleToDirection(double angle) {
  if (angle < piEighth) {
    return Direction.Up;
  }
  if (angle < piEighth + (piQuarter)) {
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
  if (diff(source.x, target.x) > settings.range.zombieStrike) return false;
  if (diff(source.y, target.y) > settings.range.zombieStrike) return false;
  return true;
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


CollectableType get randomCollectableType => randomItem(CollectableType.values);

int calculateTime({int minute = 0, int hour = 0}){
  return secondsPerMinute * minutesPerHour * hour + minute;
}

void sortVertically(List<Vector2> vectors){
  _insertionSort(list: vectors, compare: _compareVectorsY);
}

int _compareVectorsY(Vector2 a, Vector2 b) {
  if (a.y < b.y) {
    return _minusOne;
  }
  return _one;
}

void _insertionSort<E>({
  required List<E> list,
  required int Function(E, E) compare,
}) {
  int start = 0;
  int end = list.length;

  for (var pos = start + 1; pos < end; pos++) {
    var min = start;
    var max = pos;
    var element = list[pos];
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      if (compare(element, list[mid]) < 0) {
        max = mid;
      } else {
        min = mid + 1;
      }
    }
    list.setRange(min + 1, pos + 1, list, min);
    list[min] = element;
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