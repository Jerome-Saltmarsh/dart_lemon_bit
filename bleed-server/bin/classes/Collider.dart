import 'package:lemon_math/library.dart';

import '../common/constants.dart';
import 'components.dart';

class Collider with Position, Radius {
  double z = 0;
  double get left => x - radius;
  double get right => x + radius;
  double get top => y - radius;
  double get bottom => y + radius;
  var collidable = true;

  double get tileRowPercentage => ((x + y) / tileSize) % 1.0;

  Collider({
    required double x,
    required double y,
    required double radius
  }) {
    this.x = x;
    this.y = y;
    this.radius = radius;
  }

  void onCollisionWith(Collider other){ }

  bool withinBounds(Vector2 position) {
    return getDistance(position) <= radius;
  }

  double getOverlap(Collider collider){
    return (radius + collider.radius) - getDistance(collider);
  }
}