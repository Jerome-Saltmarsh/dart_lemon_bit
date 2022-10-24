
import 'package:gamestream_flutter/library.dart';

void onPlayerStoreItemsChanged(List<Weapon> values){
   GameState.player.storeVisible.value = values.isNotEmpty;
   if (values.isNotEmpty){
      GameState.player.storeVisible.value = true;
      GameState.actionShowInventory();
   } else {
      GameState.player.storeVisible.value = false;
      GameState.actionInventoryClose();
   }
}
