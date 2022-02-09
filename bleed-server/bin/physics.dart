import 'dart:math';

import 'package:lemon_math/angle_between.dart';

import 'classes/Character.dart';
import 'functions.dart';
import 'maths.dart';

final _Physics physics = _Physics();

class _Physics {
  Character? raycastHit({
    required Character character,
    required List<Character> characters,
    required double range,
    double angleRange = pi,
  }) {
    double targetDistance = 0;
    final radiusTop = character.y - character.attackRange;
    final radiusBottom = character.y + character.attackRange;
    final radiusLeft = character.x - character.attackRange;
    final radiusRight = character.x + character.attackRange;
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
}

