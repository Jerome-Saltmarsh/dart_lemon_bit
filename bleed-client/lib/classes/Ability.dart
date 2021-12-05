
import 'package:bleed_client/common/AbilityType.dart';
import 'package:lemon_watch/watch.dart';

class Ability {
  Watch<AbilityType> type= Watch(AbilityType.None);
  Watch<int> level = Watch(0);
}