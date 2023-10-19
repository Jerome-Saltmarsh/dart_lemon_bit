import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages/common/src/game_error.dart';
import 'package:gamestream_ws/packages/common/src/isometric/slot_type.dart';

import 'player_swap_item_slots.dart';

void playerUseInventorySlot(
    AmuletPlayer player,
    SlotType slotType,
    int index,
) {
  if (index < 0)
    return;

  switch (slotType){

    case SlotType.Weapons:
      player.selectWeaponAtIndex(index);
      return;
    case SlotType.Items:
      final items = player.items;
      if (index >= items.length)
        return;

      final inventorySlot = items[index];
      final item = inventorySlot.amuletItem;

      if (item == null) {
        return;
      }

      if (item.isWeapon) {
        final emptyWeaponSlot = player.getEmptyWeaponSlot();
        if (emptyWeaponSlot != null){
          playerSwapItemSlots(player, inventorySlot, emptyWeaponSlot);
          if (player.equippedWeaponIndex == -1){
            player.equippedWeaponIndex = player.weapons.indexOf(emptyWeaponSlot);
          }
        } else {
          player.writeGameError(GameError.Weapon_Rack_Full);
        }
      } else
      if (item.isTreasure) {
        final emptyTreasureSlot = player.getEmptyTreasureSlot();
        if (emptyTreasureSlot != null){
          playerSwapItemSlots(player, inventorySlot, emptyTreasureSlot);
        }
      } else
      if (item.isHelm){
        playerSwapItemSlots(player, inventorySlot, player.equippedHelm);
      } else
      if (item.isLegs){
        playerSwapItemSlots(player, inventorySlot, player.equippedLegs);
      } else
      if (item.isBody){
        playerSwapItemSlots(player, inventorySlot, player.equippedBody);
      } else
      if (item.isShoes){
        playerSwapItemSlots(player, inventorySlot, player.equippedShoe);
      }
      if (item.isHand){
        if (player.equippedHandLeft.amuletItem == null){
          playerSwapItemSlots(player, inventorySlot, player.equippedHandLeft);
        } else {
          playerSwapItemSlots(player, inventorySlot, player.equippedHandRight);
        }
      }

      if (item.isConsumable){
        final consumableType = item.subType;
        player.consumeItem(consumableType);
        player.clearSlot(inventorySlot);
        player.writePlayerEventItemTypeConsumed(consumableType);
        return;
      }
      break;

    default:
      player.swapWithAvailableItemSlot(player.getItemSlot(slotType, index));
      break;
  }
}
