
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_math/give_or_take.dart';

import 'spawners/spawnParticle.dart';

void spawnBulletHole(double x, double y){
  game.bulletHoles[game.bulletHoleIndex].x = x;
  game.bulletHoles[game.bulletHoleIndex].y = y;
  game.bulletHoleIndex = (game.bulletHoleIndex + 1) % settings.maxBulletHoles;
  double r = 0.1;
  repeat((){
    spawnParticle(
        type: ParticleType.Smoke,
        x : x,
        y: y,
        z: 0,
        xv: giveOrTake(r),
        yv: giveOrTake(r),
        zv: 0.0075,
        weight: 0.0,
        duration: 120,
        rotation: 0,
        rotationV: 0,
        scale: 0.35,
        scaleV: 0.002
    );
  }, 4, 200);

}