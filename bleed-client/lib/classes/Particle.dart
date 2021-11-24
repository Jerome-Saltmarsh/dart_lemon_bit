import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/render/enums/Hue.dart';

class Particle {
  bool active = false;
  double x;
  double y;
  double z;
  double xv;
  double yv;
  double zv;
  double weight;
  int duration;
  double rotation;
  double rotationV;
  double scale;
  double scaleV;
  ParticleType type;
  double bounciness;
  double airFriction = 0.98;
  bool foreground = false;
  Hue hue = Hue.White;
}

