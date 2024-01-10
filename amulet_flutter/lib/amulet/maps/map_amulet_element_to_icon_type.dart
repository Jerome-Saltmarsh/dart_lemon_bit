export 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/ui/enums/icon_type.dart';

import 'map_amulet_element_to_icon_type.dart';

IconType mapAmuletElementToIconType(AmuletElement amuletElement) =>
    switch (amuletElement) {
      AmuletElement.water => IconType.Element_Water,
      AmuletElement.fire => IconType.Element_Fire,
      AmuletElement.air => IconType.Element_Air,
      AmuletElement.stone => IconType.Element_Stone,
    };
