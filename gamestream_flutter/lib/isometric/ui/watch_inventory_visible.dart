import 'package:lemon_watch/watch.dart';

final watchInventoryVisible = Watch(false);

void actionToggleInventoryVisible() => watchInventoryVisible.value = !watchInventoryVisible.value;

void actionShowInventory(){
  watchInventoryVisible.value = true;
}

void actionHideInventory(){
  watchInventoryVisible.value = false;
}