import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/give_or_take.dart';

import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'common/SlotType.dart';
import 'functions/withinRadius.dart';
import 'maths.dart';

const double tileSize = 48.0;
const double halfTileSize = 24;
const secondsPerMinute = 60;
const minutesPerHour = 60;

double tilesLeftY = 0;

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
  if (character.deadOrBusy) return;
  character.angle = value;
}

bool withinViewRange(AI ai, GameObject target) {
  return distanceV2(ai.character, target) < ai.viewRange;
}

void setVelocity(GameObject gameObject, double rotation, double speed) {
  gameObject.xv = velX(rotation, speed);
  gameObject.yv = velY(rotation, speed);
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

bool targetWithinAttackRange(Character character, GameObject target){
  return withinRadius(character, target, character.weapon.range);
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

void snapToGrid(Vector2 value){
  value.x = (value.x - value.x % tileSize) + halfTileSize;
  value.y = value.y - value.y % tileSize;
}

void sortVertically(List<Vector2> items) {
  var start = 0;
  var end = items.length;
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
