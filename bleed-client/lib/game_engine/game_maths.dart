// constants
import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../maths.dart';

const double degreesToRadions = 0.0174533;
const double radionsToDegrees =  57.29578;
const double _0 = 0;
const double _360 = 360;

double radiansBetween(Vector2 a, Vector2 b) {
  return convertVectorToDegrees(a.x - b.x, b.y - a.y) * degreesToRadions;
}

double convertVectorToDegrees(double x, double y) {
  if (x < _0)
  {
    return _360 - (atan2(x, y) * -radionsToDegrees);
  }
  return atan2(x, y) * radionsToDegrees;
}

double getRadiansBetween(double x1, double y1, double x2, double y2) {
  double x = x1 - x2;
  if (x < _0) {
    return -atan2(x, y1 - y2);
  }
  return pi2 - atan2(x, y1 - y2);
}