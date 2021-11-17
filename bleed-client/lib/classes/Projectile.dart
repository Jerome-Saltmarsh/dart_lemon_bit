

import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';

class Projectile {
  double x;
  double y;
  ProjectileType type;
  Direction direction;

  Projectile(this.x, this.y, this.type, this.direction);
}