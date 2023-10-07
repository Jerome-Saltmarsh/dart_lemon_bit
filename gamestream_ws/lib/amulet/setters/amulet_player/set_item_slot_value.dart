import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_item.dart';

void setItemSlotValue(
    ItemSlot itemSlot,
    AmuletItem? amuletItem,
    int cooldown,
) {
  itemSlot.item = amuletItem;
  itemSlot.cooldown = cooldown;
}

