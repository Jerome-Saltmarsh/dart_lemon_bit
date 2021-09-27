
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/utils.dart';

import '../state.dart';

void spawnBulletHole(double x, double y){
  compiledGame.bulletHoles[compiledGame.bulletHoleIndex].x = x;
  compiledGame.bulletHoles[compiledGame.bulletHoleIndex].y = y;
  compiledGame.bulletHoleIndex = (compiledGame.bulletHoleIndex + 1) % settings.maxBulletHoles;
  double r = 0.1;
  repeat((){
    compiledGame.particles.add(Particle(
        ParticleType.Smoke,
        x,
        y,
        0,
        giveOrTake(r),
        giveOrTake(r),
        0.0075,
        weight: 0.0,
        duration: 120,
        rotation: 0,
        rotationV: 0,
        scale: 0.35,
        scaleV: 0.002
    ));
  }, 4, 200);

}