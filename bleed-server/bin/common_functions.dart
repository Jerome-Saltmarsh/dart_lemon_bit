import 'dart:math';
import 'common.dart';

double eight = pi / 8.0;
double quarter = pi / 4.0;

int convertAngleToDirection(double angle) {
  if (angle < eight) {
    return directionUp;
  }
  if (angle < eight + (quarter * 1)) {
    return directionUpRight;
  }
  if (angle < eight + (quarter * 2)) {
    return directionRight;
  }
  if (angle < eight + (quarter * 3)) {
    return directionDownRight;
  }
  if (angle < eight + (quarter * 4)) {
    return directionDown;
  }
  if (angle < eight + (quarter * 5)) {
    return directionDownLeft;
  }
  if (angle < eight + (quarter * 6)) {
    return directionLeft;
  }
  if (angle < eight + (quarter * 7)) {
    return directionUpLeft;
  }
  return directionUp;
}
