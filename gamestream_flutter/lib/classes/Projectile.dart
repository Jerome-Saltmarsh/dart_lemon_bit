

import 'package:bleed_common/enums/ProjectileType.dart';

class Projectile {
  double x;
  double y;
  ProjectileType type;
  double angle;

  Projectile(this.x, this.y, this.type, this.angle);
}