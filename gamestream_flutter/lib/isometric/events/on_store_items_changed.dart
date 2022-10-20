
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/game_library.dart';

void onPlayerStoreItemsChanged(List<Weapon> values){
   storeVisible.value = values.isNotEmpty;
   if (values.isNotEmpty){
      storeVisible.value = true;
      GameState.actionShowInventory();
   } else {
      storeVisible.value = false;
      GameState.actionInventoryClose();
   }
}
