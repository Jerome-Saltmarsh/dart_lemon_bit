
import 'package:lemon_math/library.dart';
import 'components.dart';

class Collectable with
    Position,
    Velocity,
    Active,
    Target<Position>,
    Duration,
    Type<int>
{
  var amount = 0;

  void update(){
    if (inactive) return;
    duration++;
    x += xv;
    y += yv;
    applyFriction(0.96);
    moveTowards(target, duration * 0.075);
    if (getDistance(target) > 10) return;
    deactivate();
  }
}