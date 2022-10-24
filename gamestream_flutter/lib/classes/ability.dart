
import 'package:bleed_common/AbilityType.dart';
import 'package:lemon_watch/watch.dart';

class Ability {
  final int index;
  Watch<AbilityType> type = Watch(AbilityType.None);
  Watch<int> level = Watch(0);
  Watch<int> cooldownRemaining = Watch(0);
  Watch<int> cooldown = Watch(0);
  Watch<int> magicCost = Watch(0);
  Watch<bool> canAfford = Watch(false);
  Watch<bool> selected = Watch(false);

  Ability(this.index);
}