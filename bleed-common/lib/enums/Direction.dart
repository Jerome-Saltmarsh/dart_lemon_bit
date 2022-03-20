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

final directionRightIndex = Direction.Right.index;
const directions = Direction.values;
final directionsLength = directions.length;
const _piQuarter = pi / 4.0;
const _pi2 = pi + pi;

double convertDirectionToAngle(Direction direction){
  return direction.index * _piQuarter;
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

