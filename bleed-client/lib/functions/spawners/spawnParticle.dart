import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';

void spawnParticle({
    required ParticleType type,
    required double x,
    required double y,
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
    double airFriction = 0.98
}) {

  Particle particle = getAvailableParticle();
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
  particle.airFriction = airFriction;
}

Particle getAvailableParticle() {
  for (Particle particle in isometric.state.particles) {
    if (particle.active) continue;
    return particle;
  }
  Particle particle = Particle();
  isometric.state.particles.add(particle);
  return particle;
}
