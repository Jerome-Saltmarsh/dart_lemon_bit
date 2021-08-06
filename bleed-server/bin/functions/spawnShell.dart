import '../classes/Particle.dart';
import '../enums.dart';
import '../maths.dart';
import '../settings.dart';
import '../state.dart';

void spawnShell(double x, double y, double rotation) {
  particles.add(Particle(
      x,
      y,
      velX(rotation, settingsParticleShellSpeed),
      velY(rotation, settingsParticleShellSpeed),
      50,
      0,
      0.7,
      ParticleType.Shell,
      0.1,
      height: 0.8,
      heightVelocity: 0.1));
}