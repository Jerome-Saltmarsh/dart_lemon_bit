import 'dart:math';
import 'classes.dart';
import 'constants.dart';

const double goldenRatio = 1.61803398875;
const double goldenRatioInverse = 1.0 / goldenRatio;
const double degreesToRadians = 0.0174533;
const double radiansToDegrees = 57.29578;
final Random random = Random();

double randomBetween(num a, num b) {
  return (random.nextDouble() * (b - a)) + a;
}

bool randomBool() {
  return random.nextDouble() > 0.5;
}

int randomInt(int min, int max) {
  return random.nextInt(max - min) + min;
}

double randomRadion() {
  return random.nextDouble() * pi2;
}

double giveOrTake(double value) {
  return randomBetween(-value, value);
}

double magnitude(double a, double b) {
  return sqrt((a * a) + (b * b));
}

double distanceBetween(GameObject a, GameObject b) {
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;
  return magnitude(xDiff, yDiff);
}

double distance(double x1, double y1, double x2, double y2) {
  return magnitude(x1 - x2, y1 - y2);
}

double abs(double value) {
  if (value < 0) return -value;
  return value;
}

// utility methods
int millisecondsSince(DateTime value) {
  return durationSince(value).inMilliseconds;
}

Duration durationSince(DateTime value) {
  return now().difference(value);
}

DateTime now() => DateTime.now();

double radiansBetweenObject(GameObject a, GameObject b) {
  return radiansBetween(a.x, a.y, b.x, b.y);
}

double radiansBetween2(GameObject a, double x, double y) {
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
  if (x < 0) {
    return (atan2(x, y) * -1);
  }
  return pi2 - atan2(x, y);
}

double adj(double rotation, num magnitude) {
  return -cos(rotation + piHalf) * magnitude;
}

double opp(double rotation, num magnitude) {
  return -sin(rotation + piHalf) * magnitude;
}

double normalize(double x, double y) {
  return 1.0 / magnitude(x, y);
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
  return ((bX - aX) * (cY - aY) - (bY - aY) * (cX - aX)) > 0;
}
