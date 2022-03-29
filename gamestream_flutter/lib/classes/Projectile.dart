
import 'package:lemon_math/Vector2.dart';
import 'package:bleed_common/enums/ProjectileType.dart';

class Projectile extends Vector2 {
  var type = ProjectileType.Arrow;
  var angle = 0.0;
  Projectile(): super(0, 0);
}