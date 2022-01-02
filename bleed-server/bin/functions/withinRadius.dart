
import 'dart:math';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/diff.dart';

bool withinRadius(Vector2 a, Vector2 b, double radius){
  return withinDistance(a, b.x, b.y, radius);
}

bool withinDistance(Vector2 positioned, double x, double y, double radius){
  final xDiff = diff(positioned.x, x);
  if (xDiff > radius) return false;

  final yDiff = diff(positioned.y, y);
  if (yDiff > radius) return false;

  return magnitude(xDiff, yDiff) <= radius;
}

double magnitude(num adjacent, num opposite){
  return sqrt((adjacent * adjacent) + (opposite * opposite));
}