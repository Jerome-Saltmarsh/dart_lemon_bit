import 'dart:math';

import 'package:lemon_math/library.dart';

import 'classes/Collider.dart';
import 'maths.dart';

num calculateAngleDifference(double angleA, double angleB) {
  final diff = (angleA - angleB).abs();
  if (diff < pi) {
    return diff;
  }
  return pi2 - diff;
}

void updateCollisionBetween(List<Collider> gameObjects) {
  final numberOfGameObjects = gameObjects.length;
  final numberOfGameObjectsMinusOne = numberOfGameObjects - 1;
  for (var i = 0; i < numberOfGameObjectsMinusOne; i++) {
    final gameObjectI = gameObjects[i];
    if (!gameObjectI.collidable) continue;
    final gameObjectIBottom = gameObjectI.bottom;
    for (var j = i + 1; j < numberOfGameObjects; j++) {
      final gameObjectJ = gameObjects[j];
      if (!gameObjectJ.collidable) continue;
      if (gameObjectJ.top > gameObjectIBottom) break;
      if (gameObjectJ.left > gameObjectI.right) continue;
      if (gameObjectJ.bottom < gameObjectI.top) continue;
      resolveCollisionA(gameObjectI, gameObjectJ);
    }
  }
}

void resolveCollisionA(Collider a, Collider b) {
  final overlap = collisionOverlap(a, b);
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
  a.x += targetX;
  a.y += targetY;
  b.x -= targetX;
  b.y -= targetY;
}

void resolveCollisionB(Collider a, Collider b) {
  final overlap = collisionOverlap(a, b);
  if (overlap <= 0) return;
  final xDiff = a.x - b.x;
  final yDiff = a.y - b.y;
  final mag = getHypotenuse(xDiff, yDiff);
  final ratio = 1.0 / mag;
  final xDiffNormalized = xDiff * ratio;
  final yDiffNormalized = yDiff * ratio;
  final targetX = xDiffNormalized * overlap;
  final targetY = yDiffNormalized * overlap;
  a.x += targetX;
  a.y += targetY;
}

double collisionOverlap(Collider a, Collider b) {
  return a.radius + b.radius - distanceV2(a, b);
}

void resolveCollisionBetween(
    List<Collider> gameObjectsA,
    List<Collider> gameObjectsB,
    CollisionResolver resolve
    ) {
  final aLength = gameObjectsA.length;
  final bLength = gameObjectsB.length;
  for (var i = 0; i < aLength; i++) {
    final a = gameObjectsA[i];
    if (!a.collidable) continue;
    for (var j = 0; j < bLength; j++) {
      final b = gameObjectsB[j];
      if (!b.collidable) continue;
      if (a.bottom < b.top) continue;
      if (a.top > b.bottom) continue;
      if (a.right < b.left) continue;
      if (a.left > b.right) continue;
      resolve(a, b);
    }
  }
}

typedef void CollisionResolver(Collider a, Collider b);



