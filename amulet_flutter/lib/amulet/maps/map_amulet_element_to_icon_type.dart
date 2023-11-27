import 'package:amulet_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:amulet_flutter/packages/common/src/amulet/amulet_element.dart';

IconType mapAmuletElementToIconType(AmuletElement amuletElement) =>
    switch (amuletElement) {
      AmuletElement.water => IconType.Element_Water,
      AmuletElement.fire => IconType.Element_Fire,
      AmuletElement.electricity => IconType.Element_Electricity,
    };
