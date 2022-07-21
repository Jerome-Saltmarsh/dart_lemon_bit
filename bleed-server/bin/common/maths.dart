
import 'dart:math';


double getMagnitudeV3(num x, num y, num z){
  return sqrt((x * x) + (y * y) + (z * z));
}

double getDistanceXY(double x1, double y1, double x2, double y2){
  return sqrt(squareDifference(x1, x2) + squareDifference(y1, y2));
}

double getDistanceV3(double x1, double y1, double z1, double x2, double y2, double z2){
  return sqrt(
      squareDifference(x1, x2)
          +
          squareDifference(y1, y2)
          +
          squareDifference(z1, z2)
  );
}

double squareDifference(double a, double b){
  final diff = (a - b).abs();
  return diff * diff;
}