
import 'dart:math';

import 'package:lemon_math/Vector2.dart';

import '../classes/Collider.dart';
import '../classes/Player.dart';

bool withinRadius(Vector2 a, Vector2 b, num radius){
  return withinDistance(a, b.x, b.y, radius);
}

bool withinDistance(Vector2 positioned, double x, double y, num radius){
  final xDiff = (positioned.x - x).abs();
  if (xDiff > radius) return false;

  final yDiff = (positioned.y - y).abs();
  if (yDiff > radius) return false;

  return magnitude(xDiff, yDiff) <= radius;
}

double magnitude(num adjacent, num opposite){
  return sqrt((adjacent * adjacent) + (opposite * opposite));
}

bool withinAttackRadius(Player player, Collider target){
  return withinRadius(player, target, player.weaponRange + target.radius);
}