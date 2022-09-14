

import 'package:lemon_math/library.dart';

import '../classes/collider.dart';
import '../common/maths.dart';

void onCollisionBetweenColliders(Collider a, Collider b){
  resolveCollisionPhysics(a, b);
  a.onCollisionWith(b);
  b.onCollisionWith(a);
}

void doNothing(){

}

void resolveCollisionPhysics(Collider a, Collider b) {
  final combinedRadius = a.radius + b.radius;
  final totalDistance = getDistanceXY(a.x, a.y, b.x, b.y);
  final overlap = combinedRadius - totalDistance;
  if (overlap < 0) return;
  var xDiff = a.x - b.x;
  var yDiff = a.y - b.y;

  if (xDiff == 0 && yDiff == 0) {
    if (a.moveOnCollision){
      a.x += 5;
      xDiff += 5;
    }
    if (b.moveOnCollision){
      b.x -= 5;
      xDiff += 5;
    }
  }

  final ratio = 1.0 / getHypotenuse(xDiff, yDiff);
  final xDiffNormalized = xDiff * ratio;
  final yDiffNormalized = yDiff * ratio;
  final halfOverlap = overlap * 0.5;
  final targetX = xDiffNormalized * halfOverlap;
  final targetY = yDiffNormalized * halfOverlap;
  if (a.moveOnCollision){
    a.x += targetX;
    a.y += targetY;
  }
  if (b.moveOnCollision){
    b.x -= targetX;
    b.y -= targetY;
  }
}

