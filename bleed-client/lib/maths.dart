import 'dart:math';

import 'package:bleed_client/common/classes/Vector2.dart';

const double degreesToRadian = 0.0174533;
const double radianToDegrees =  57.29578;
const double piHalf = pi / 2.0;
const double piQuarter = pi * 0.25;
const double pi2 = pi + pi;
final Random random = Random();

const double goldenRatio = 1.61803398875;
const double goldenRatioInverse = 1.0 / goldenRatio;
const double goldenRatioInverseB = 1.0 - goldenRatioInverse;

double randomBetween(num a, num b){
  return (random.nextDouble() * (b - a)) + a;
}

double giveOrTake(double value){
  return randomBetween(-value, value);
}

double magnitude(double a, double b){
  return sqrt((a * a) + (b * b));
}

double distance(double x1, double y1, double x2, double y2){
  return magnitude(x1 - x2, y1 - y2);
}

double abs(double value){
  if(value < 0) return -value;
  return value;
}

Vector2 positionTowards(double x1, double y1, double x2, double y2, double distance){
  double rot = radionsBetween(x1, y1, x2, y2);
  return Vector2(x1 + velX(rot, distance), y1 + velY(rot, distance));
}

// utility methods
int millisecondsSince(DateTime value){
  return durationSince(value).inMilliseconds;
}

Duration durationSince(DateTime value){
  return DateTime.now().difference(value);
}

double radionsBetween(double x1, double y1, double x2, double y2) {
  double x = x1 - x2;
  double y = y1 - y2;
  if (x < 0) {
    return (atan2(x, y) * -1);
  }
  return (pi + pi) - atan2(x, y);
}

double toRadian(double x, double y) {
  if (x < 0)
  {
    return pi2 - (atan2(x, y)  * -1);
  }
  return atan2(x, y);
}

double radians(double x, double y) {
  if (x < 0) return -atan2(x, y);
  return pi2 - atan2(x, y);
}

double velX(double rotation, double speed) {
  return -cos(rotation + (pi * 0.5)) * speed;
}

double velY(double rotation, double speed) {
  return -sin(rotation + (pi * 0.5)) * speed;
}


double normalize(double x, double y){
  return 1.0 / magnitude(x, y);
}

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

double adj(double rotation, double magnitude) {
  return -cos(rotation + piHalf) * magnitude;
}

double opp(double rotation, double magnitude) {
  return -sin(rotation + piHalf) * magnitude;
}

double diff(double a, double b){
  return abs(a - b);
}
