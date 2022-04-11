import 'dart:math';

class Direction {
  static const Up = 0;
  static const UpRight = 1;
  static const Right = 2;
  static const DownRight = 3;
  static const Down = 4;
  static const DownLeft = 5;
  static const Left = 6;
  static const UpLeft = 7;
}

int sanitizeDirectionIndex(int index){
  return index >= 0 ? index % 8 : 8 - (index.abs() % 8);
}

int convertAngleToDirection(double angle) {
  const piQuarter = pi * 0.25;
  return clampAngle(angle) ~/ piQuarter;
}

double clampAngle(double angle){
  const pi2 = pi * 2;
  if (angle < 0) {
    angle = pi2 - (-angle % pi2);
  }
  return angle % pi2;
}
