
import 'dart:math';

import '../classes.dart';
import '../enums.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import '../utils.dart';
import 'applyForce.dart';

void spawnExplosion(double x, double y){
  dispatch(GameEventType.Explosion, x, y);
  for(Character character in npcs){
    if(objectDistanceFrom(character, x, y) < settingsGrenadeExplosionRadius){
      changeCharacterHealth(character, -settingsGrenadeExplosionDamage);
      double rotation = radiansBetween2(character, x, y);
      double magnitude = 10;
      applyForce(character, rotation + pi, magnitude);
    }
  }
}