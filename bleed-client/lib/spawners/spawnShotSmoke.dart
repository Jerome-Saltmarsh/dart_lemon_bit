
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';

import '../state.dart';

void spawnShotSmoke(double x, double y, double xv, double yv){

  for(int i = 0; i < 4; i++){
    double speed = 0.5 + giveOrTake(0.2);
    double cx = clampMagnitudeX(xv, yv, speed) + giveOrTake(0.3);
    double cy = clampMagnitudeY(xv, yv, speed)+ giveOrTake(0.3);

    compiledGame.particles.add(Particle(
        ParticleType.Smoke,
        x,
        y,
        0.3,
        cx,
        cy,
        0.0075,
        weight: 0.0,
        duration: 120,
        rotation: 0,
        rotationV: 0,
        scale: 0.35 + giveOrTake(0.15),
        scaleV: 0.001 + giveOrTake(0.0005)
    ));
  }

}