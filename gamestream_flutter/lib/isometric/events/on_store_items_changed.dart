
import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:gamestream_flutter/isometric/ui/watch_inventory_visible.dart';

void onPlayerStoreItemsChanged(List<Weapon> values){
   if (values.isNotEmpty){
      actionShowInventory();
   } else {
      actionHideInventory();
   }
}
