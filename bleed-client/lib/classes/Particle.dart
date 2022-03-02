import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/opposite.dart';

class Particle {
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
  ParticleType type = ParticleType.Zombie_Head;
  double bounciness = 0;
  double airFriction = 0.98;
  bool foreground = false;
  int hue = 0;
  bool hasShadow = false;
  double size = 0;

  Particle? next;

  bool get active => duration > 0;

  void setAngle({required double value, required double speed}){
    xv = adjacent(value, speed);
    yv = opposite(value, speed);
  }
}

