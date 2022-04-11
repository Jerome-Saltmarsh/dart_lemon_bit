
import 'package:lemon_math/Vector2.dart';

class Collider extends Vector2 {
  double radius;
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  var collidable = true;

  Collider(double x, double y, this.radius) : super(x, y);

  void onCollisionWith(Collider other){ }

  bool withinBounds(double x, double y) {
    return getDistanceXY(x, y) <= radius;
  }
}