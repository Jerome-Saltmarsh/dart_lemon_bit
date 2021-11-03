
import 'package:bleed_client/classes/Particle.dart';


typedef Particle GetParticle();

class ParticleEmitter {
  double x = 0;
  double y = 0;
  int rate;
  int next = 0;
  Function(Particle particle) emit;

  ParticleEmitter({this.x, this.y, this.rate, this.emit});
}

