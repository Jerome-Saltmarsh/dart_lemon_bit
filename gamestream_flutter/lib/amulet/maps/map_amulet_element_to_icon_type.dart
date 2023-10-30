import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:gamestream_flutter/packages/common/src/amulet/amulet_element.dart';

IconType mapAmuletElementToIconType(AmuletElement amuletElement) => switch(amuletElement){
    AmuletElement.water => IconType.Element_Water,
    AmuletElement.fire => IconType.Element_Fire,
    AmuletElement.air => IconType.Element_Air,
    AmuletElement.earth => IconType.Element_Earth,
};

