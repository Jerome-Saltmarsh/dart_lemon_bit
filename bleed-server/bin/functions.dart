import 'dart:math';

import 'package:lemon_math/abs.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/hypotenuse.dart';

import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'constants.dart';
import 'engine.dart';
import 'maths.dart';

Character? raycastHit(
    {
    required Character character,
    required List<Character> characters,

      double angleRange = pi,
      required double range,
    }) {
  double targetDistance = 0;
  double radiusTop = character.y - character.attackRange;
  double radiusBottom = character.y + character.attackRange;
  double radiusLeft = character.x - character.attackRange;
  double radiusRight = character.x + character.attackRange;
  Character? target;
  for (Character char in characters) {
    if (char.bottom < radiusTop) continue;
    if (char.top > radiusBottom) return null;
    if (char.right < radiusLeft) continue;
    if (char.left > radiusRight) continue;
    final angle = angleBetween(
        character.x, character.y, char.x, char.y);
    final angleDiff =
    calculateAngleDifference(angle, character.aimAngle);
    if (angleDiff > angleRange) continue;
    final charDistance = distanceV2(char, character);
    if (charDistance > range) continue;
    if (target == null || charDistance < targetDistance) {
      target = char;
      targetDistance = charDistance;
    }
  }
  return target;
}

double calculateAngleDifference(double angleA, double angleB) {
  double diff = abs(angleA - angleB).toDouble();
  if (diff < pi) {
    return diff;
  }
  return pi2 - diff;
}


void updateCollisionBetween(List<GameObject> gameObjects) {
  for (int i = 0; i < gameObjects.length - 1; i++) {
    if (!gameObjects[i].collidable) continue;
    for (int j = i + 1; j < gameObjects.length; j++) {
      if (!gameObjects[j].collidable) continue;
      if (gameObjects[j].top > gameObjects[i].bottom) break;
      if (gameObjects[j].left > gameObjects[i].right) continue;
      if (gameObjects[j].bottom < gameObjects[i].top) continue;
      resolveCollisionA(gameObjects[i], gameObjects[j]);
    }
  }
}

void resolveCollisionA(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if (overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;

  if (xDiff == 0 && yDiff == 0) {
    a.x -= 5;
    b.y += 5;
    xDiff = 10;
  }

  double halfOverlap = overlap * 0.5;
  double mag = hypotenuse(xDiff, yDiff);
  double ratio = 1.0 / mag;
  double xDiffNormalized = xDiff * ratio;
  double yDiffNormalized = yDiff * ratio;
  double targetX = xDiffNormalized * halfOverlap;
  double targetY = yDiffNormalized * halfOverlap;
  a.x += targetX;
  a.y += targetY;
  b.x -= targetX;
  b.y -= targetY;
}

void resolveCollisionB(GameObject a, GameObject b) {
  double overlap = collisionOverlap(a, b);
  if (overlap < 0) return;
  double xDiff = a.x - b.x;
  double yDiff = a.y - b.y;
  double mag = hypotenuse(xDiff, yDiff);
  double ratio = 1.0 / mag;
  double xDiffNormalized = xDiff * ratio;
  double yDiffNormalized = yDiff * ratio;
  double targetX = xDiffNormalized * overlap;
  double targetY = yDiffNormalized * overlap;
  a.x += targetX;
  a.y += targetY;
}

double collisionOverlap(GameObject a, GameObject b) {
  return a.radius + b.radius - distanceV2(a, b);
}

void resolveCollisionBetween(List<GameObject> gameObjectsA,
    List<GameObject> gameObjectsB, CollisionResolver resolve) {
  int minJ = 0;
  for (int i = 0; i < gameObjectsA.length; i++) {
    final a = gameObjectsA[i];
    if (!a.collidable) continue;
    for (int j = minJ; j < gameObjectsB.length; j++) {
      final b = gameObjectsB[j];
      if (!b.collidable) continue;
      if (a.bottom < b.top) {
        minJ++;
        break;
      }
      if (a.top > b.bottom) continue;
      if (a.right < b.left) continue;
      if (a.left > b.right) continue;
      resolve(a, b);
    }
  }
}

typedef void CollisionResolver(GameObject a, GameObject b);

