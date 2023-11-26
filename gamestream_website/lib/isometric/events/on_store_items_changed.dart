
import 'package:gamestream_flutter/isometric/actions/action_inventory_close.dart';
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/isometric/watches/inventory_visible.dart';

void onPlayerStoreItemsChanged(List<Weapon> values){
   storeVisible.value = values.isNotEmpty;
   if (values.isNotEmpty){
      storeVisible.value = true;
      actionShowInventory();
   } else {
      storeVisible.value = false;
      actionInventoryClose();
   }
}
