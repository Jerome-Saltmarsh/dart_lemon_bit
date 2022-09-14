

import 'package:lemon_math/library.dart';

import '../classes/collider.dart';
import '../maths/get_distance_between_v3.dart';

void onCollisionBetweenColliders(Collider a, Collider b){
  resolveCollisionPhysics(a, b);
  a.onCollisionWith(b);
  b.onCollisionWith(a);
}

void resolveCollisionPhysics(Collider a, Collider b) {
  final combinedRadius = a.radius + b.radius;
  final totalDistance = getDistanceBetweenV3(a, b);
  final overlap = combinedRadius - totalDistance;
  if (overlap < 0) return;
  var xDiff = a.x - b.x;
  var yDiff = a.y - b.y;

  if (xDiff == 0 && yDiff == 0) {
    a.x -= 5;
    b.y += 5;
    xDiff = 10;
  }

  final halfOverlap = overlap * 0.5;
  final mag = getHypotenuse(xDiff, yDiff);
  final ratio = 1.0 / mag;
  final xDiffNormalized = xDiff * ratio;
  final yDiffNormalized = yDiff * ratio;
  final targetX = xDiffNormalized * halfOverlap;
  final targetY = yDiffNormalized * halfOverlap;
  if (a.movable){
    a.x += targetX;
    a.y += targetY;
  }
  if (b.movable){
    b.x -= targetX;
    b.y -= targetY;
  }
}

