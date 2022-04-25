
import 'package:lemon_math/Vector2.dart';

class Collider with Position {
  double radius;
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  var collidable = true;

  Collider({
    required double x,
    required double y,
    required this.radius
  }) {
    this.x = x;
    this.y = y;
  }

  void onCollisionWith(Collider other){ }

  bool withinBounds(Vector2 position) {
    return getDistance(position) <= radius;
  }
}