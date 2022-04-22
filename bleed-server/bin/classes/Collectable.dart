
import 'package:lemon_math/Vector2.dart';

import '../common/CollectableType.dart';
import '../common/PlayerEvent.dart';
import 'Player.dart';
import 'components.dart';

class Collectable extends Vector2 with Velocity, Active, Target<Player>, Duration {
  var type = 0;
  Collectable() : super(0, 0);

  void update(){
    if (inactive) return;
    duration++;
    x += xv;
    y += yv;
    applyFriction(0.96);
    moveTowards(target, duration * 0.075);
    if (getDistance(target) > 10) return;
    deactivate();
    target.onPlayerEvent(PlayerEvent.Collect_Wood);
    switch(type){
      case CollectableType.Wood:
        target.wood++;
        break;
      case CollectableType.Stone:
        target.stone++;
        break;
    }
  }
}