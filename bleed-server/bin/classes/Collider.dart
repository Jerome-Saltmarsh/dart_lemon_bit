
import 'package:lemon_math/Vector2.dart';

class Collider extends Vector2 {
  double radius;
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;

  Collider(double x, double y, this.radius) : super(x, y);
}