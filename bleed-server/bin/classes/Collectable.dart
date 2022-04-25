
import 'package:lemon_math/Vector2.dart';

import '../common/CollectableType.dart';
import '../common/PlayerEvent.dart';
import 'Player.dart';
import 'Structure.dart';
import 'components.dart';

class Collectable with
    Position,
    Velocity,
    Active,
    Target<Position>,
    Duration,
    Type<int>
{
  void update(){
    if (inactive) return;
    duration++;
    x += xv;
    y += yv;
    applyFriction(0.96);
    moveTowards(target, duration * 0.075);
    if (getDistance(target) > 10) return;
    deactivate();

    if (target is Player) {
      _playerCollect(target as Player);
    }
    else
    if (target is Structure){
      _playerCollect((target as Structure).owner);
    }
  }

  void _playerCollect(Player player){
    switch (type) {
      case CollectableType.Wood:
        player.wood++;
        player.onPlayerEvent(PlayerEvent.Collect_Wood);
        break;
      case CollectableType.Stone:
        player.stone++;
        player.onPlayerEvent(PlayerEvent.Collect_Rock);
        break;
      case CollectableType.Experience:
        player.onPlayerEvent(PlayerEvent.Collect_Experience);
        break;
      case CollectableType.Gold:
        player.gold++;
        player.onPlayerEvent(PlayerEvent.Collect_Gold);
        break;
    }
  }
}