
import 'package:bleed_client/common/AbilityType.dart';

class Ability {
  AbilityType type;
  int level;
  Ability({this.type = AbilityType.None, this.level = 0});
}