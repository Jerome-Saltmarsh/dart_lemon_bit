
import 'package:bleed_common/Projectile_Type.dart';
import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';

class Projectile extends Vector3 {
  var type = 0;
  var angle = 0.0;
  Projectile(): super(0, 0, 0);
}