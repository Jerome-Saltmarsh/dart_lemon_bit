import 'package:lemon_math/library.dart';

import 'classes/Character.dart';
import 'common/utilities.dart';

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

// Vector2 getTilePosition(int row, int column) {
//   return Vector2(
//       perspectiveProjectX(row * halfTileSize, column * halfTileSize),
//       perspectiveProjectY(row * halfTileSize, column * halfTileSize) +
//           halfTileSize);
// }
//
// double getTilePositionX(int row, int column){
//   return perspectiveProjectX(row * halfTileSize, column * halfTileSize);
// }

// void assign(Position position, int row, int column){
//   position.x = getTilePositionX(row, column);
//   position.y = getTilePositionY(row, column);
// }

// double getTilePositionY(int row, int column){
//   return perspectiveProjectY(row * halfTileSize, column * halfTileSize) +
//       halfTileSize;
// }

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


