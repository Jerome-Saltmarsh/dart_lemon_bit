
import 'package:lemon_math/diff_over.dart';

import '../classes/Positioned.dart';
import '../common/classes/Vector2.dart';

bool withinRadius(Positioned positioned, Vector2 position, double radius){
  if (diffOver(positioned.x, position.x, radius)) return false;
  if (diffOver(positioned.y, position.y, radius)) return false;
  return true;
}