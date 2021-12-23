
import 'package:bleed_client/classes/Particle.dart';


typedef Particle GetParticle();

class ParticleEmitter {
  double x = 0;
  double y = 0;
  int rate;
  int next = 0;
  Function(Particle particle) emit;

  ParticleEmitter({
    required this.x,
    required this.y,
    required this.rate,
    required this.emit
  });
}

