import 'package:bleed_common/DynamicObjectType.dart';
import 'package:lemon_math/library.dart';

class DynamicObject extends Vector2 {
  var type = DynamicObjectType.Rock;
  DynamicObject() : super(0, 0);
}