

import 'package:bleed_client/common/enums/ProjectileType.dart';

class Projectile {
  double x;
  double y;
  ProjectileType type;
  double angle;

  Projectile(this.x, this.y, this.type, this.angle);
}