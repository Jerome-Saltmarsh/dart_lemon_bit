
import 'package:gamestream_ws/amulet.dart';

import 'set_item_slot_value.dart';

void swapItemSlots(AmuletPlayer player, ItemSlot a, ItemSlot b){
  final aItem = a.amuletItem;
  final aCooldown = a.cooldown;
  final bItem = b.amuletItem;
  final bCooldown = b.cooldown;
  setItemSlotValue(a, bItem, bCooldown);
  setItemSlotValue(b, aItem, aCooldown);
  player.notifyEquipmentDirty();
}

