import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/give_or_take.dart';

import 'classes/Character.dart';
import 'common/utilities.dart';

const tileSize = 48.0;
const halfTileSize = 24.0;

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

double getShotAngle(Character character) {
  return character.angle + giveOrTake(character.accuracy * 0.5);
}

void faceAimDirection(Character character) {
  setAngle(character, character.angle);
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
  const secondsPerMinute = 60;
  const minutesPerHour = 60;
  return secondsPerMinute * minutesPerHour * hour + minute;
}

void snapToGrid(Vector2 value){
  value.x = snapX(value.x, value.y);
  value.y = snapY(value.x, value.y);
}

// double snapX(double x){
//   return  (x - x % tileSize) + halfTileSize;
// }
//
// double snapY(double y){
//   return y - y % tileSize;
// }

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
