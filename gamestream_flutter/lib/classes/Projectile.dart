
import 'package:bleed_common/library.dart';
import 'package:lemon_math/library.dart';

class Projectile extends Vector2 {
  var type = TechType.Bow;
  var angle = 0.0;
  var z = 0.0;
  Projectile(): super(0, 0);
}