import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages/common/src/game_error.dart';
import 'package:gamestream_ws/packages/common/src/isometric/slot_type.dart';

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

          player.swapAmuletItemSlots(inventorySlot, emptyWeaponSlot);
          // playerSwapItemSlots(player, inventorySlot, emptyWeaponSlot);
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
          player.swapAmuletItemSlots(inventorySlot, emptyTreasureSlot);
        }
      } else
      if (item.isHelm){
        player.swapAmuletItemSlots(inventorySlot, player.equippedHelm);
      } else
      if (item.isLegs){
        player.swapAmuletItemSlots(inventorySlot, player.equippedLegs);
      } else
      if (item.isBody){
        player.swapAmuletItemSlots(inventorySlot, player.equippedBody);
      } else
      if (item.isShoes){
        player.swapAmuletItemSlots(inventorySlot, player.equippedShoe);
      }
      if (item.isHand){
        if (player.equippedHandLeft.amuletItem == null){
          player.swapAmuletItemSlots(inventorySlot, player.equippedHandLeft);
        } else {
          player.swapAmuletItemSlots(inventorySlot, player.equippedHandRight);
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
