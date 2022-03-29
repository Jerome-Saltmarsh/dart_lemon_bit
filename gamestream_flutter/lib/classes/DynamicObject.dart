import 'package:bleed_common/DynamicObjectType.dart';
import 'package:lemon_math/Vector2.dart';

class DynamicObject extends Vector2 {
  var type = DynamicObjectType.Rock;
  var health = 1.0;
  DynamicObject() : super(0, 0);
}