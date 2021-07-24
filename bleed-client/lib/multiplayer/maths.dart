import 'dart:math';
import 'common.dart';
import 'utils.dart';

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

double distanceBetween(dynamic characterA, dynamic characterB){
  double xDiff = posX(characterA) - posX(characterB);
  double yDiff = posY(characterA) - posY(characterB);
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
  return radionsBetween(posX(a), posY(a), posX(b), posY(b));
}

double radionsBetween2(dynamic a, double x, double y) {
  return radionsBetween(posX(a), posY(a), x, y);
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