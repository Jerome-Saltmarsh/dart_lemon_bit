import 'dart:math';
import 'keys.dart';

const double degreesToRadions = 0.0174533;
const double radionsToDegrees =  57.29578;
final Random random = Random();

class Vector2 {
  double x;
  double y;
  Vector2(this.x, this.y);
}

double randomBetween(num a, num b){
  return (random.nextDouble() * (b - a)) + a;
}

double giveOrTake(double value){
  return randomBetween(-value, value);
}

double magnitude(double a, double b){
  return sqrt((a * a) + (b * b));
}

double distanceBetween(dynamic a, dynamic b){
  double xDiff = a[x] - b[x];
  double yDiff = a[y] - b[y];
  return magnitude(xDiff, yDiff);
}

double distance(double x1, double y1, double x2, double y2){
  return magnitude(x1 - x2, y1 - y2);
}

double abs(double value){
  if(value < 0) return -value;
  return value;
}

// utility methods
int millisecondsSince(DateTime value){
  return durationSince(value).inMilliseconds;
}

Duration durationSince(DateTime value){
  return DateTime.now().difference(value);
}

Vector2 convertRadionsToVector(num radions){
  num r = radions - (pi * 0.5);
  return Vector2(cos(r), sin(r));
}

double radionsBetweenObject(dynamic a, dynamic b) {
  return radionsBetween(a[x], a[y], b[x], b[y]);
}

double radionsBetween2(dynamic a, double x, double y) {
  return radionsBetween(a[x], a[y], x, y);
}

double convertVectorToDegrees(double x, double y) {
  if (x < 0)
  {
    return 360 - (atan2(x, y) * radionsToDegrees * -1);
  }
  return atan2(x, y) * radionsToDegrees;
}

double radionsBetween(double x1, double y1, double x2, double y2) {
  double x = x1 - x2;
  double y = y1 - y2;
  if (x < 0) {
    return (atan2(x, y) * -1);
  }
  return (pi + pi) - atan2(x, y);
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