import 'dart:math';

import 'package:lemon_math/normlize.dart';

const piQuarter = pi / 4.0;

double normalizeX(double x, double y){
  return normalize(x, y) * x;
}

double normalizeY(double x, double y){
  return normalize(x, y) * y;
}

double clampMagnitudeX(double x, double y, double value){
  return normalizeX(x, y) * value;
}

double clampMagnitudeY(double x, double y, double value){
  return normalizeY(x, y) * value;
}
