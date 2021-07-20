// constants
import 'dart:math';

import 'package:vector_math/vector_math.dart';

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