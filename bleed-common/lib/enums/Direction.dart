import 'dart:math';

enum Direction {
  Up,
  UpRight,
  Right,
  DownRight,
  Down,
  DownLeft,
  Left,
  UpLeft,
}

const directionUpIndex = 0;
const directionUpRightIndex = 1;
const directionRightIndex = 2;
const directionDownRightIndex = 3;
const directionDownIndex = 4;
const directionDownLeftIndex = 5;
const directionLeftIndex = 6;
const directionUpLeftIndex = 7;

const directions = Direction.values;
final directionsLength = directions.length;
final directionsMaxIndex = directions.length - 1;
const _piQuarter = pi / 4.0;
const _pi2 = pi + pi;

double convertDirectionToAngle(Direction direction){
  return direction.index * _piQuarter;
}

int sanitizeDirectionIndex(int index){
  return index >= 0 ? index % 8 : (index + 7) % 8;
}

double _fixAngle(double angle){
  if (angle < 0) {
    angle = (_pi2 + angle).abs() % _pi2;
  }
  return angle % _pi2;
}

Direction convertAngleToDirection(double angle) {
  return directions[convertAngleToDirectionInt(angle)];
}

int convertAngleToDirectionInt(double angle){
  return _fixAngle(angle) ~/ _piQuarter;
}

int angleToDirection(double angle){
  return _fixAngle(angle) ~/ _piQuarter;
}

