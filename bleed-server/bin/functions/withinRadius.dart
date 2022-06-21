
import 'dart:math';

import 'package:lemon_math/library.dart';

import '../classes/collider.dart';
import '../classes/Player.dart';

bool withinRadius(Position a, Position b, num radius){
  return withinDistance(a, b.x, b.y, radius);
}

bool withinDistance(Position positioned, double x, double y, num radius){
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
  return withinRadius(player, target, player.equippedRange + target.radius);
}