
import 'dart:math';

import 'package:gamestream_ws/packages.dart';

import 'character.dart';
import 'collider.dart';
import 'position.dart';

class Physics {
  static const Gravity = 0.98;
  static const Friction = 0.75;
  static const Bounce_Friction = 0.65;
  static const Friction_Air = 0.9995;
  static const Min_Velocity = 0.005;
  static const Projectile_Radius = 10.0;
  static const Projectile_Z_Velocity = 0.05;
  static const Max_Velocity = 7.0;
  static const Max_Fall_Velocity = 10.0;
  static const Max_Throw_Velocity = 15.0;
  static const Max_Throw_Velocity_Z = 10;
  static const Max_Throw_Distance = 400.0;
  static const Max_Vertical_Collision_Displacement = 15.0;


  static I? raycastHit<I extends Collider>({
    required Character character,
    required List<I> colliders,
    required double range,
    double angleRange = pi * 0.5,
  }) {
    double targetDistance = 99999999;
    I? target;
    for (var collider in colliders) {
      if (!collider.active) continue;
      if (!collider.hitbox) continue;
      if (collider == character) continue;
      final distance =  character.getDistance(collider);
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

  static T? sphereCaste<T extends Collider>({
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
      if (!collider.hitbox) continue;
      if (predicate != null && predicate(collider)) continue;
      if (collider.boundsBottom < top) continue;
      if (collider.boundsTop > bottom) break;
      if (collider.boundsRight < left) continue;
      if (collider.boundsLeft > right) continue;
      final colliderDistance = distanceBetween(collider.x, collider.y, x, y);
      if (colliderDistance >= closestDistance) continue;
      closest = collider;
      closestDistance = colliderDistance;
    }
    return closest;
  }

  static T? findClosestVector3<T extends Position>({
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
      final colliderDistance = getDistanceXYZ(position.x, position.y, position.z, x, y, z);
      if (colliderDistance >= closestDistance) continue;
      closest = position;
      closestDistance = colliderDistance;
    }
    return closest;
  }

  static T? findClosest3<T extends Position>({
    required double x,
    required double y,
    required double z,
    required List<T> positions,
  }) {
    if (positions.isEmpty) return null;
    T? closest = null;
    var closestDistance = 9999999.0;

    for (final position in positions) {
      final colliderDistance = getDistanceXYZ(position.x, position.y, position.z, x, y, z);
      if (colliderDistance >= closestDistance) continue;
      closest = position;
      closestDistance = colliderDistance;
    }
    return closest;
  }

  static num calculateAngleDifference(double angleA, double angleB) {
    final diff = (angleA - angleB).abs();
    if (diff < pi) {
      return diff;
    }
    return pi2 - diff;
  }
}