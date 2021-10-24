import 'dart:math';

import '../constants/pi2.dart';


double getRadiansBetween(double x1, double y1, double x2, double y2) {
  double x = x1 - x2;
  if (x < 0) {
    return -atan2(x, y1 - y2);
  }
  return pi2 - atan2(x, y1 - y2);
}