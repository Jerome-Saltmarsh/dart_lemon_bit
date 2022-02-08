import 'dart:math';

import 'package:lemon_math/abs.dart';
import 'package:lemon_math/angle_between.dart';

import 'classes/Character.dart';
import 'constants.dart';
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
