import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages/common/src/amulet/amulet_item.dart';

void setItemSlotValue(
    AmuletItemSlot itemSlot,
    AmuletItem? amuletItem,
    int cooldown,
) {
  itemSlot.amuletItem = amuletItem;
  itemSlot.cooldown = cooldown;
}

