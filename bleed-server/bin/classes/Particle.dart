import '../classes.dart';
import '../enums.dart';

class Particle extends PhysicsGameObject {
  int lifeTime;
  double rotation;
  double rotationSpeed;
  double friction;
  double height;
  double heightVelocity;
  ParticleType type;

  Particle(double x, double y, double xVel, double yVel, this.lifeTime,
      this.rotation, this.friction, this.type, this.rotationSpeed,
      {this.height = 0, this.heightVelocity = 0})
      : super(x, y, xVel, yVel);
}
