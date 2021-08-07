
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';

import '../state.dart';

void spawnShotSmoke(double x, double y, double xv, double yv){
  double speed = 0.5;
  double cx = clampMagnitudeX(xv, yv, speed);
  double cy = clampMagnitudeY(xv, yv, speed);

  particles.add(Particle(
      ParticleType.Smoke,
      x,
      y,
      0.3,
      cx,
      cy,
      0.015,
      weight: 0.0,
      duration: 120,
      rotation: 0,
      rotationV: 0,
      scale: 0.35,
      scaleV: 0.001
  ));
}