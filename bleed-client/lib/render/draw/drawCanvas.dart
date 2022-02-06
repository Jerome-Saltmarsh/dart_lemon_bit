
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';


double getDistanceBetweenMouseAndPlayer(){
  return distanceBetween(mouseWorldX, mouseWorldY, modules.game.state.player.x, modules.game.state.player.y);
}

final Map<ItemType, Vector2> itemAtlas = {
  ItemType.Handgun: atlas.items.handgun,
  ItemType.Shotgun: atlas.items.shotgun,
  ItemType.Armour: atlas.items.armour,
  ItemType.Health: atlas.items.health,
  ItemType.Orb_Emerald: atlas.items.emerald,
  ItemType.Orb_Ruby: atlas.items.orbRed,
  ItemType.Orb_Topaz: atlas.items.orbTopaz,
};
