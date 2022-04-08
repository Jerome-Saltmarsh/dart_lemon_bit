import 'dart:math';

const directionUpIndex = 0;
const directionUpRightIndex = 1;
const directionRightIndex = 2;
const directionDownRightIndex = 3;
const directionDownIndex = 4;
const directionDownLeftIndex = 5;
const directionLeftIndex = 6;
const directionUpLeftIndex = 7;

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
