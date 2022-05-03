import 'dart:math';

import 'package:lemon_math/library.dart';

import 'classes/Character.dart';
import 'classes/Collider.dart';

final physics = _Physics();

class _Physics {
  I? raycastHit<I extends Collider>({
    required Character character,
    required List<I> colliders,
    required double range,
    double angleRange = pi * 0.5,
  }) {
    double targetDistance = 99999999;
    I? target;
    for (var collider in colliders) {
      if (!collider.collidable) continue;
      final distance = character.getDistance(collider);
      if (distance > range) continue;
      final angle = character.getAngle(collider);
      final angleDiff = calculateAngleDifference(angle, character.angle);
      if (angleDiff > angleRange) continue;
      if (distance < targetDistance) {
        target = collider;
        targetDistance = distance;
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
  Function(T t)? predicate,
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
    if (predicate != null && predicate(collider)) continue;
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

T? findClosestVector2<T extends Position>({
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

num calculateAngleDifference(double angleA, double angleB) {
  final diff = (angleA - angleB).abs();
  if (diff < pi) {
    return diff;
  }
  return pi2 - diff;
}