import 'package:gamestream_flutter/isometric/events/on_inventory_visible_changed.dart';
import 'package:lemon_watch/watch.dart';

final inventoryVisible = Watch(false, onChanged: onInventoryVisibleChanged);

void actionShowInventory(){
  inventoryVisible.value = true;
}

