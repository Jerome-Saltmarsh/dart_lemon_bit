
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/opposite.dart';

import '../classes/Vector2.dart';
import 'randomRadian.dart';

Vector2 randomPositionAround(double x, double y, double radius){
  double r = randomRadian();
  return Vector2(x + adjacent(r, radius), y + opposite(r, radius));
}