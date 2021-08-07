
import 'dart:math';

import '../classes.dart';
import '../enums/GameEventType.dart';
import '../language.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';
import '../utils.dart';
import 'applyForce.dart';

void spawnExplosion(double x, double y){
  dispatch(GameEventType.Explosion, x, y, 0, 0);
  for(Character character in npcs){
    if(objectDistanceFrom(character, x, y) > settingsGrenadeExplosionRadius) continue;
    double rotation = radiansBetween2(character, x, y);
    double magnitude = 10;
    applyForce(character, rotation + pi, magnitude);

    if(character.alive){
      changeCharacterHealth(character, -settingsGrenadeExplosionDamage);

      if(!character.alive){

        double forceX = clampMagnitudeX(character.x - x, character.y - y, magnitude);
        double forceY = clampMagnitudeY(character.x - x, character.y - y, magnitude);

        if (randomBool()) {
          dispatch(GameEventType.Zombie_Killed, character.x, character.y, forceX, forceY);
          characterFace(character, x, y);
          delayed(() => character.active = false, ms: randomInt(1000, 2000));
        } else {
          character.active = false;
          dispatch(GameEventType.Zombie_killed_Explosion, character.x, character.y, forceX, forceY);
        }
      }
    }
  }
}