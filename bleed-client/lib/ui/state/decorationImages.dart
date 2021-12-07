import 'package:bleed_client/common/AbilityType.dart';
import 'package:flutter/painting.dart';

Map<AbilityType, DecorationImage> mapAbilityTypeToDecorationImage = {
  AbilityType.Fireball: _load("fireball"),
  AbilityType.FreezeCircle: _load("freeze"),
  AbilityType.Blink: _load("flash"),
  AbilityType.Explosion: _load("explode"),
};

DecorationImage _load(String name) {
  return DecorationImage(
    image: AssetImage('images/spell-icon-$name.png'),
  );
}
