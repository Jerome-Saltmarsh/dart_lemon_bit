
import 'package:lemon_math/Vector2.dart';

import 'Player.dart';
import 'components.dart';

class Collectable extends Vector2 with Velocity, Active, Target<Player>, Duration {
  Collectable() : super(0, 0);
}