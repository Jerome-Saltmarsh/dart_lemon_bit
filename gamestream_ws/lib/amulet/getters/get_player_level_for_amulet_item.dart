import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_item.dart';

int getLevelForAmuletItem(AmuletPlayer player, AmuletItem amuletItem) =>
    amuletItem.getLevel(
      fire: player.elementFire,
      water: player.elementWater,
      wind: player.elementWind,
      earth: player.elementEarth,
      electricity: player.elementElectricity,
    );
