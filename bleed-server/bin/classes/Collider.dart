
import 'package:lemon_math/Vector2.dart';

class Collider extends Vector2 {
  double radius;
  Collider(double x, double y, this.radius) : super(x, y);
}