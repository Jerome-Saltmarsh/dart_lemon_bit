import 'package:bleed_client/enums/ParticleType.dart';

class Particle {
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
  double bounceHeightFriction;

  Particle(
    this.type,
    this.x,
    this.y,
    this.z,
    this.xv,
    this.yv,
    this.zv, {
    this.weight,
    this.duration,
    this.rotation = 0,
    this.rotationV = 0,
    this.scale = 1,
    this.scaleV = 0,
    this.bounceHeightFriction = 0.3,
  });
}
