// constants
import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../maths.dart';

const double degreesToRadions = 0.0174533;
const double radionsToDegrees =  57.29578;


Vector2 convertRadionsToVector(num radions){
  num r = radions - (pi * 0.5);
  return Vector2(cos(r), sin(r));
}

double radionsBetween(Vector2 a, Vector2 b) {
  return convertVectorToDegrees(a.x - b.x, b.y - a.y) * degreesToRadions;
}

double convertVectorToDegrees(double x, double y) {
  if (x < 0)
  {
    return 360 - (atan2(x, y) * radionsToDegrees * -1);
  }
  return atan2(x, y) * radionsToDegrees;
}


double getRadionsBetween(double x1, double y1, double x2, double y2) {
  double x = x1 - x2;
  double y = y1 - y2;
  if (x < 0) {
    return (atan2(x, y) * -1);
  }
  return pi2 - atan2(x, y);
}