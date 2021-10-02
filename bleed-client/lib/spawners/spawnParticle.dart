import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/instances/settings.dart';

import '../state.dart';

void spawnParticle({
  ParticleType type,
  double x,
  double y,
  double z = 0,
  double xv = 0,
  double yv = 0,
  double zv = 0,
  double weight = 1,
  int duration = 100,
  double scale = 1,
  double scaleV = 0,
  double rotation = 0,
  double rotationV = 0,
  bounciness = 0.5,
}) {

  for (Particle particle in compiledGame.particles){
    if (particle.active) continue;
    particle.type = type;
    particle.x = x;
    particle.y = y;
    particle.z = z;
    particle.xv = xv;
    particle.yv = yv;
    particle.zv = zv;
    particle.weight = weight;
    particle.duration = duration;
    particle.scale = scale;
    particle.scaleV = scaleV;
    particle.rotation = rotation;
    particle.rotationV = rotationV;
    particle.bounciness = bounciness;
    particle.active = true;
    return;
  }
}
