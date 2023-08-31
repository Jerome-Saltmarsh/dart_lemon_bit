import 'package:gamestream_server/packages.dart';

import 'mmo_player.dart';

void handleInventoryRequest(AmuletPlayer player, List<int> arguments) {
  if (arguments.isEmpty) return;

  if (!isValidIndex(arguments[1], InventoryRequest.values)) {
    return;
  }

  switch (InventoryRequest.values[arguments[1]]) {
    case InventoryRequest.Move:
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

      final srcItem = srcItemObject.item;
      final targetItem = targetItemObject.item;

      if (srcItem == null)
        return;

      if (!targetSlotType.supportsItemType(srcItem.type)) {
        return;
      }

      targetItemObject.item = srcItem;
      srcItemObject.item = targetItem;
      player.notifyEquipmentDirty();
      break;

    case InventoryRequest.Use:
      final slotTypeIndex = arguments[2];
      final srcIndex = arguments[3];
      player.useInventorySlot(SlotType.values[slotTypeIndex], srcIndex);
      break;

    case InventoryRequest.Drop:
      final slotTypeIndex = arguments[2];
      final srcIndex = arguments[3];
      player.inventoryDrop(SlotType.values[slotTypeIndex], srcIndex);
      break;
  }
}
