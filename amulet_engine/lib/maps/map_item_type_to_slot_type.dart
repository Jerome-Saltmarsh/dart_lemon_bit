
import '../packages/common.dart';

SlotType mapItemTypeToSlotType(int itemType) => switch (itemType) {
      ItemType.Weapon => SlotType.Weapon,
      ItemType.Helm => SlotType.Helm,
      ItemType.Armor => SlotType.Armor,
      ItemType.Shoes => SlotType.Shoes,
      _ => throw Exception(
          'amuletPlayer.mapItemTypeToSlotType(itemType: $itemType)')
    };