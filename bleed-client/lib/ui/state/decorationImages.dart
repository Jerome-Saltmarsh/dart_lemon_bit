import 'package:bleed_client/common/AbilityType.dart';
import 'package:flutter/painting.dart';

Map<AbilityType, DecorationImage> mapAbilityTypeToDecorationImage = {
  AbilityType.Fireball: spellIcon("fireball"),
  AbilityType.FreezeCircle: spellIcon("freeze"),
  AbilityType.Blink: spellIcon("flash"),
  AbilityType.Explosion: spellIcon("explode"),
  AbilityType.Dash: spellIcon("dash"),
  AbilityType.Split_Arrow: spellIcon("split-arrows"),
  AbilityType.Long_Shot: spellIcon("long-shot"),
  AbilityType.Iron_Shield: spellIcon("iron-shield"),
  AbilityType.Brutal_Strike: spellIcon("brutal-strike"),
  AbilityType.Death_Strike: spellIcon("death-strike"),
};

final _Icons icons = _Icons();

class _Icons {
  DecorationImage settings = _png('icon settings');
  DecorationImage fullscreen = _png('icon fullscreen');
  DecorationImage google = _png('icons/google_logo');
}

DecorationImage spellIcon(String name) {
  return _png('spell-icon-$name');
}

DecorationImage _png(String name) {
  return DecorationImage(
    image: AssetImage('images/$name.png'),
  );
}

DecorationImage loadDecorationImage(String name) {
  return DecorationImage(
    image: AssetImage(name),
  );
}
