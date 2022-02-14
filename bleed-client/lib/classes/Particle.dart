import 'package:bleed_client/modules/isometric/enums.dart';

class Particle {
  bool active = true;
  double x = 0;
  double y = 0;
  double z = 0;
  double xv = 0;
  double yv = 0;
  double zv = 0;
  double weight = 0;
  int duration = 0;
  double rotation = 0;
  double rotationV = 0;
  double scale = 0;
  double scaleV = 0;
  ParticleType type = ParticleType.None;
  double bounciness = 0;
  double airFriction = 0.98;
  bool foreground = false;
  int hue = 0;
}

