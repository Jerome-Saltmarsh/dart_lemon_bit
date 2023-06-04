import 'dart:math';
import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/maths/get_distance_between_v3.dart';
import 'package:lemon_math/library.dart';

import 'games/isometric/isometric_character.dart';
import 'games/isometric/isometric_collider.dart';
import 'games/isometric/isometric_position.dart';

I? raycastHit<I extends IsometricCollider>({
  required IsometricCharacter character,
  required List<I> colliders,
  required double range,
  double angleRange = pi * 0.5,
}) {
  double targetDistance = 99999999;
  I? target;
  for (var collider in colliders) {
    if (!collider.active) continue;
    if (!collider.hitable) continue;
    if (collider == character) continue;
    final distance =  getDistanceBetweenV3(character, collider);
    if (distance > range) continue;
    final angle = character.getAngle(collider);
    final angleDiff = calculateAngleDifference(angle, character.faceAngle);
    if (angleDiff > angleRange) continue;
    if (distance < targetDistance) {
      target = collider;
      targetDistance = distance;
    }
  }
  return target;
}

List<T> sphereCastAll<T extends Position>({
  required Position position,
  required double radius,
  required List<T> values,
  Predicate<T>? where,
}) {
  if (where != null) {
    return values.where((value) => value.getDistance(position) < radius && where(value)).toList();
  }
  return values.where((value) => value.getDistance(position) < radius).toList();
}

T? sphereCaste<T extends IsometricCollider>({
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
    if (!collider.active) continue;
    if (!collider.hitable) continue;
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

T? findClosestVector3<T extends IsometricPosition>({
  required double x,
  required double y,
  required double z,
  required List<T> positions,
  required bool Function(T t) where,
}) {
  if (positions.isEmpty) return null;
  T? closest = null;
  var closestDistance = 9999999.0;

  for (final position in positions) {
    if (!where(position)) continue;
    final colliderDistance = getDistanceV3(position.x, position.y, position.z, x, y, z);
    if (colliderDistance >= closestDistance) continue;
    closest = position;
    closestDistance = colliderDistance;
  }
  return closest;
}

T? findClosest3<T extends IsometricPosition>({
  required double x,
  required double y,
  required double z,
  required List<T> positions,
}) {
  if (positions.isEmpty) return null;
  T? closest = null;
  var closestDistance = 9999999.0;

  for (final position in positions) {
    final colliderDistance = getDistanceV3(position.x, position.y, position.z, x, y, z);
    if (colliderDistance >= closestDistance) continue;
    closest = position;
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

