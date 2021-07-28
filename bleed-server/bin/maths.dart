import 'dart:math';
import 'classes.dart';

const double degreesToRadions = 0.0174533;
const double radionsToDegrees =  57.29578;
final Random random = Random();

double randomBetween(num a, num b){
  return (random.nextDouble() * (b - a)) + a;
}

double giveOrTake(double value){
  return randomBetween(-value, value);
}

double magnitude(double a, double b){
  return sqrt((a * a) + (b * b));
}

double distanceBetween(GameObject a, GameObject b){
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;
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

double radionsBetweenObject(GameObject a, GameObject b) {
  return radionsBetween(a.x, a.y, b.x, b.y);
}

double radionsBetween2(GameObject a, double x, double y) {
  return radionsBetween(a.x, a.y, x, y);
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