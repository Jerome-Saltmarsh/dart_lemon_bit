
import 'package:lemon_math/library.dart';
import '../common/library.dart';
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

    if (target is Player) {
      _playerCollect(target as Player);
    }
    else
    if (target is Structure){
      final owner = (target as Structure).owner;
      if (owner != null){
        _playerCollect(owner);
      }
    }
  }

  void _playerCollect(Player player){
    switch (type) {
      case CollectableType.Wood:
        player.wood += amount;
        player.writePlayerEvent(PlayerEvent.Collect_Wood);
        break;
      case CollectableType.Stone:
        player.stone += amount;
        player.writePlayerEvent(PlayerEvent.Collect_Rock);
        break;
      case CollectableType.Experience:
        player.writePlayerEvent(PlayerEvent.Collect_Experience);
        break;
      case CollectableType.Gold:
        player.gold += amount;
        player.writePlayerEvent(PlayerEvent.Collect_Gold);
        break;
    }
  }
}