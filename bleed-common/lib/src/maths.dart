
import 'dart:math';

double getMagnitudeV3(num x, num y, num z) =>
    sqrt((x * x) + (y * y) + (z * z));

double getDistanceXY(double x1, double y1, double x2, double y2) =>
  sqrt(getDistanceV2Squared(x1, y1, x2, y2));

double getDistanceV3(double x1, double y1, double z1, double x2, double y2, double z2) =>
    sqrt(getDistanceV3Squared(x1, y1, z1, x2, y2, z2));

double getDistanceV3Squared(double x1, double y1, double z1, double x2, double y2, double z2) =>
    pow(x1 - x2, 2) +
    pow(y1 - y2, 2) +
    pow(z1 - z2, 2).toDouble();

double getDistanceV2Squared(double x1, double y1, double x2, double y2) =>
       pow(x1 - x2, 2) +
       pow(y1 - y2, 2).toDouble();

bool withinDistanceV3(double x1, double y1, double z1, double x2, double y2, double z2, double distance) =>
    (x1 - x2).abs() < distance &&
    (y1 - y2).abs() < distance &&
    (z1 - z2).abs() < distance;