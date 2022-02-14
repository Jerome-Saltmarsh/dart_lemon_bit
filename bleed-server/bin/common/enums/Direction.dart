import 'dart:math';

enum Direction {
  // Down,
  // DownRight,
  // Right,
  // UpRight,
  // Up,
  // UpLeft,
  // Left,
  // DownLeft,
  Up,
  UpRight,
  Right,
  DownRight,
  Down,
  DownLeft,
  Left,
  UpLeft,
}

const List<Direction> directions = Direction.values;

// const double pi = math.pi;
const double _piEighth = pi / 8.0;
const double piQuarter = pi / 4.0;

double convertDirectionToAngle(Direction direction){
  return direction.index * piQuarter;
}

Direction convertAngleToDirection(double angle) {
  if (angle < _piEighth) {
    return Direction.Up;
  }
  if (angle < _piEighth + (piQuarter)) {
    return Direction.UpRight;
  }
  if (angle < _piEighth + (piQuarter * 2)) {
    return Direction.Right;
  }
  if (angle < _piEighth + (piQuarter * 3)) {
    return Direction.DownRight;
  }
  if (angle < _piEighth + (piQuarter * 4)) {
    return Direction.Down;
  }
  if (angle < _piEighth + (piQuarter * 5)) {
    return Direction.DownLeft;
  }
  if (angle < _piEighth + (piQuarter * 6)) {
    return Direction.Left;
  }
  if (angle < _piEighth + (piQuarter * 7)) {
    return Direction.UpLeft;
  }
  return Direction.Up;
}

