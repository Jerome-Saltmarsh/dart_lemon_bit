import 'dart:math';

import 'package:lemon_math/library.dart';

double distanceV2(Position a, Position b) {
  return getHypotenuse(a.x - b.x, a.y - b.y);
}

double radiansV2(Position a, Position b) {
  return radiansBetween(a.x, a.y, b.x, b.y);
}

double radiansBetween2(Position a, double x, double y) {
  return radiansBetween(a.x, a.y, x, y);
}

double radiansBetween(double x1, double y1, double x2, double y2) {
  return atan2(y2 - y1, x2 - x1);
}

double normalize(double x, double y) {
  return 1.0 / getHypotenuse(x, y);
}

double normalizeX(double x, double y) {
  return normalize(x, y) * x;
}

double normalizeY(double x, double y) {
  return normalize(x, y) * y;
}

double clampMagnitudeX(double x, double y, double value) {
  return normalizeX(x, y) * value;
}

double clampMagnitudeY(double x, double y, double value) {
  return normalizeY(x, y) * value;
}

bool isLeft(double aX, double aY, double bX, double bY, double cX, double cY) {
  return ((bX - aX) * (cY - aY) - (bY - aY) * (cX - aX)) > 0;
}

// double getGridAngle(double x1, double y1, double x2, double y2){
//    final x3 = x1 + y1;
//    final y3 = y1 - x1;
//    final x4 = x2 + y2;
//    final y4 = y2 - x2;
//    final opposite = x3 - x4;
//    final adjacent = y3 - y4;
//    final angle = getAngle(adjacent, opposite);
//    return angle;
// }