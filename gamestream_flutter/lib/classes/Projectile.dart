
import 'package:bleed_common/ProjectileType.dart';
import 'package:lemon_math/library.dart';

class Projectile extends Vector2 {
  var type = ProjectileType.Arrow;
  var angle = 0.0;
  Projectile(): super(0, 0);
}