import 'package:amulet_common/src.dart';
import 'package:flutter/material.dart';

Color mapItemQualityToColor(ItemQuality itemQuality) {
  switch (itemQuality) {
    case ItemQuality.Common:
      return Colors.white;
    case ItemQuality.Unique:
      return Colors.blue;
    case ItemQuality.Rare:
      return Colors.yellow;
  }
}
