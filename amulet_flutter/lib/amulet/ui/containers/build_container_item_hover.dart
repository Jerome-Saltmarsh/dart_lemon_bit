
import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/gamestream/ui.dart';


Widget buildContainerAmuletItemHover({
  required Amulet amulet,
}) => buildWatchNullable(
      amulet.aimTargetItemTypeCurrent, (item) {
        return amulet.amuletUI.buildContainerCompareItems(item, null);
      });

