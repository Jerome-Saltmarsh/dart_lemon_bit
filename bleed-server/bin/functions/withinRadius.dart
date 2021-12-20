
import 'package:lemon_math/diff_over.dart';
import 'package:lemon_math/distance_between.dart';

import '../classes/Positioned.dart';
import '../common/classes/Vector2.dart';

bool withinRadius(Positioned positioned, Vector2 position, double radius){
  return withinDistance(positioned, position.x, position.y, radius);
}

bool withinDistance(Positioned positioned, double x, double y, double radius){
  if (diffOver(positioned.x, x, radius)) return false;
  if (diffOver(positioned.y, y, radius)) return false;
  return distanceBetween(positioned.x, positioned.y, x, y) <= radius;
}