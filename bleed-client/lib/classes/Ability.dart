
import 'package:bleed_client/common/AbilityType.dart';
import 'package:lemon_watch/watch.dart';

class Ability {
  Watch<AbilityType> type = Watch(AbilityType.None);
  Watch<int> level = Watch(0);
  Watch<int> cooldownRemaining = Watch(0);
  Watch<int> cooldown = Watch(0);
  Watch<int> magicCost = Watch(0);
  Watch<bool> canAfford = Watch(false);

  Ability(){
    level.onChanged((int value) {
      print("${type.value} level changed to $value");
    });
  }
}