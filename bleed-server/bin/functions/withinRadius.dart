
import 'dart:math';


import '../classes/collider.dart';
import '../classes/player.dart';
import '../classes/position3.dart';
import '../common/maths.dart';

bool withinRadius(Position3 a, Position3 b, num radius){
  return withinDistance(a, b.x, b.y, b.z, radius);
}

bool withinDistance(Position3 positioned, double x, double y, double z, num radius){
  final xDiff = (positioned.x - x).abs();
  if (xDiff > radius) return false;

  final yDiff = (positioned.y - y).abs();
  if (yDiff > radius) return false;

  final zDiff = (positioned.z - z).abs();
  if (zDiff > radius) return false;

  return getMagnitudeV3(xDiff, yDiff, zDiff) <= radius;
}

double magnitude(num adjacent, num opposite){
  return sqrt((adjacent * adjacent) + (opposite * opposite));
}

bool withinAttackRadius(Player player, Collider target){
  return withinRadius(player, target, player.equippedRange + target.radius);
}