
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';

import '../common/classes/Vector2.dart';

bool withinRadius(Vector2 a, Vector2 b, double radius){
  return withinDistance(a, b.x, b.y, radius);
}

bool withinDistance(Vector2 positioned, double x, double y, double radius){
  if (diffOver(positioned.x, x, radius)) return false;
  if (diffOver(positioned.y, y, radius)) return false;
  return distanceBetween(positioned.x, positioned.y, x, y) <= radius;
}