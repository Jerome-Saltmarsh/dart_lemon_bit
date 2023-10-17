import 'package:gamestream_ws/packages.dart';

import 'amulet_player.dart';
import 'functions/player_use_inventory_slot.dart';

void handleInventoryRequest(AmuletPlayer player, List<int> arguments) {
  if (arguments.isEmpty) return;

  if (!isValidIndex(arguments[1], NetworkRequestInventory.values)) {
    return;
  }

  switch (NetworkRequestInventory.values[arguments[1]]) {
    case NetworkRequestInventory.Move:
      final srcSlotTypeIndex = arguments[2];
      final srcIndex = arguments[3];
      final targetSlotTypeIndex = arguments[4];
      final targetIndex = arguments[5];

      const slotTypes = SlotType.values;

      if (!isValidIndex(srcSlotTypeIndex, slotTypes) ||
          !isValidIndex(targetSlotTypeIndex, slotTypes)) return;

      final srcSlotType = slotTypes[srcSlotTypeIndex];
      final targetSlotType = slotTypes[targetSlotTypeIndex];


      final srcItemObject =
          player.getItemObjectAtSlotType(srcSlotType, srcIndex);
      final targetItemObject =
          player.getItemObjectAtSlotType(targetSlotType, targetIndex);


      final srcItem = srcItemObject.amuletItem;
      final targetItem = targetItemObject.amuletItem;

      if (srcItem == null) {
        return;
      }

      if (targetItem != null && !srcSlotType.supportsItemType(targetItem.type)){
        return;
      }

      if (!targetSlotType.supportsItemType(srcItem.type)) {
        return;
      }

      targetItemObject.amuletItem = srcItem;
      srcItemObject.amuletItem = targetItem;
      player.notifyEquipmentDirty();
      break;

    case NetworkRequestInventory.Use:
      final slotTypeIndex = arguments[2];
      final srcIndex = arguments[3];
      playerUseInventorySlot(player, SlotType.values[slotTypeIndex], srcIndex);
      break;

    case NetworkRequestInventory.Drop:
      final slotTypeIndex = arguments[2];
      final srcIndex = arguments[3];
      player.inventoryDropSlotType(SlotType.values[slotTypeIndex], srcIndex);
      break;
  }
}
