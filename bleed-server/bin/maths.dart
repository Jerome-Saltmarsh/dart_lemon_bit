import 'dart:math';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/hypotenuse.dart';

import 'constants.dart';

const _0 = 0.0;
const half = 0.5;
const _1 = 1.0;

double distanceV2(Vector2 a, Vector2 b) {
  return distanceBetween(a.x, a.y, b.x, b.y);
}

double distanceV2From(Vector2 a, double x, double y) {
  return distanceBetween(a.x, a.y, x, y);
}

int absInt(int value) {
  if (value < _0) return -value;
  return value;
}

int diffInt(int a, int b){
  return absInt(a - b);
}

double radiansV2(Vector2 a, Vector2 b) {
  return radiansBetween(a.x, a.y, b.x, b.y);
}

double radiansBetween2(Vector2 a, double x, double y) {
  return radiansBetween(a.x, a.y, x, y);
}

double radiansBetween(double x1, double y1, double x2, double y2) {
  return radians(x1 - x2, y1 - y2);
}

double velX(double rotation, double speed) {
  return -cos(rotation + piHalf) * speed;
}

double velY(double rotation, double speed) {
  return -sin(rotation + piHalf) * speed;
}

double radians(double x, double y) {
  if (x < _0) return -atan2(x, y);
  return pi2 - atan2(x, y);
}

double adj(double rotation, num magnitude) {
  return -cos(rotation + piHalf) * magnitude;
}

double opp(double rotation, num magnitude) {
  return -sin(rotation + piHalf) * magnitude;
}

double normalize(double x, double y) {
  return _1 / hypotenuse(x, y);
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
  return ((bX - aX) * (cY - aY) - (bY - aY) * (cX - aX)) > _0;
}
