import 'dart:math';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';

import 'classes/Character.dart';
import 'classes/Collider.dart';
import 'classes/GameObject.dart';
import 'common/SlotType.dart';
import 'functions.dart';
import 'maths.dart';

final physics = _Physics();

class _Physics {
  I? raycastHit<I extends Collider>({
    required Character character,
    required List<I> colliders,
    required double range,
    double angleRange = pi,
  }) {
    double targetDistance = 0;
    final range = character.weapon.range;
    final radiusTop = character.y - range;
    final radiusBottom = character.y + range;
    final radiusLeft = character.x - range;
    final radiusRight = character.x + range;
    I? target;
    for (var collider in colliders) {
      if (!collider.collidable) continue;
      if (collider.bottom < radiusTop) continue;
      if (collider.top > radiusBottom) return null;
      if (collider.right < radiusLeft) continue;
      if (collider.left > radiusRight) continue;
      final angle = angleBetween(
          character.x, character.y, collider.x, collider.y);
      final angleDiff =
      calculateAngleDifference(angle, character.aimAngle);
      if (angleDiff > angleRange) continue;
      final charDistance = distanceV2(collider, character);
      if (charDistance > range) continue;
      if (target == null || charDistance < targetDistance) {
        target = collider;
        targetDistance = charDistance;
      }
    }
    return target;
  }
}

T? sphereCaste<T extends Collider>({
  required List<T> colliders,
  required double x,
  required double y,
  required double radius,
  required Function(T t) predicate,
}) {
  if (colliders.isEmpty) return null;
  final top = y - radius;
  final bottom = y + radius;
  final left = x - radius;
  final right = x + radius;
  T? closest = null;
  var closestDistance = 9999999.0;

  for (final collider in colliders) {
    if (!collider.collidable) continue;
    if (predicate(collider)) continue;
    if (collider.bottom < top) continue;
    if (collider.top > bottom) break;
    if (collider.right < left) continue;
    if (collider.left > right) continue;
    final colliderDistance = distanceBetween(collider.x, collider.y, x, y);
    if (colliderDistance >= closestDistance) continue;
    closest = collider;
    closestDistance = colliderDistance;
  }
  return closest;
}

T? findClosestVector2<T extends Vector2>({
  required double x,
  required double y,
  required List<T> colliders,
  required Function(T t) predicate,
}) {
  if (colliders.isEmpty) return null;
  T? closest = null;
  var closestDistance = 9999999.0;

  for (final collider in colliders) {
    if (predicate(collider)) continue;
    final colliderDistance = distanceBetween(collider.x, collider.y, x, y);
    if (colliderDistance >= closestDistance) continue;
    closest = collider;
    closestDistance = colliderDistance;
  }
  return closest;
}


void setVelocityTowards(GameObject gameObject, Vector2 target, double speed){
  final angle = radiansV2(gameObject, target);
  gameObject.xv = adj(angle, speed);
  gameObject.yv = opp(angle, speed);
}