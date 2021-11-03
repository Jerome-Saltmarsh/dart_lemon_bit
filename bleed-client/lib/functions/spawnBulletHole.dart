
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/utils.dart';

import '../state.dart';
import 'spawners/spawnParticle.dart';

void spawnBulletHole(double x, double y){
  compiledGame.bulletHoles[compiledGame.bulletHoleIndex].x = x;
  compiledGame.bulletHoles[compiledGame.bulletHoleIndex].y = y;
  compiledGame.bulletHoleIndex = (compiledGame.bulletHoleIndex + 1) % settings.maxBulletHoles;
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