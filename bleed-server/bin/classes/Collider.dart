
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/distance_between.dart';

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
    return distanceBetween(this.x, this.y, x, y) <= radius;
  }
}