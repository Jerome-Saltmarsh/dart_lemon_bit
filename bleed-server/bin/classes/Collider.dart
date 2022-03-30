
import 'package:lemon_math/Vector2.dart';

class Collider extends Vector2 {
  double radius;

  double get bottom => y + radius;
  double get top => y - radius;

  Collider(double x, double y, this.radius) : super(x, y);
}