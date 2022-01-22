

import 'package:bleed_client/render/constants/atlas.dart';
import 'package:lemon_math/Vector2.dart';

import 'common/ItemType.dart';

final _Maps maps = _Maps();

class _Maps {
  final Map<ItemType, Vector2> itemAtlas = {
    ItemType.Handgun: atlas.items.handgun,
    ItemType.Shotgun: atlas.items.shotgun,
    ItemType.Armour: atlas.items.armour,
    ItemType.Health: atlas.items.health,
  };
}