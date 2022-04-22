
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

    switch (type) {
      case CollectableType.Wood:
        target.wood++;
        target.onPlayerEvent(PlayerEvent.Collect_Wood);
        break;
      case CollectableType.Stone:
        target.stone++;
        target.onPlayerEvent(PlayerEvent.Collect_Rock);
        break;
      case CollectableType.Experience:
        target.onPlayerEvent(PlayerEvent.Collect_Experience);
        break;
      case CollectableType.Gold:
        target.gold++;
        target.onPlayerEvent(PlayerEvent.Collect_Gold);
        break;
    }
  }
}