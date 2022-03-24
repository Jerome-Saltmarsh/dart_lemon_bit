import 'dart:math';

import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/angle_between.dart';

import 'classes/Character.dart';
import 'classes/GameObject.dart';
import 'common/SlotType.dart';
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
    final range = character.weapon.range;
    final radiusTop = character.y - range;
    final radiusBottom = character.y + range;
    final radiusLeft = character.x - range;
    final radiusRight = character.x + range;
    Character? target;
    for (var char in characters) {
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

void setVelocityTowards(GameObject gameObject, Vector2 target, double speed){
  final angle = radiansV2(gameObject, target);
  gameObject.xv = adj(angle, speed);
  gameObject.yv = opp(angle, speed);
}