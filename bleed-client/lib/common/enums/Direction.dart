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

const List<Direction> directions = Direction.values;
const _piQuarter = pi / 4.0;

double convertDirectionToAngle(Direction direction){
  return direction.index * _piQuarter;
}

Direction convertAngleToDirection(double angle) {
  return directions[angle ~/ _piQuarter];
}

int convertAngleToDirectionInt(double angle){
  return angle ~/ _piQuarter;
}

int angleToDirection(double angle){
  return angle ~/ _piQuarter;
}

