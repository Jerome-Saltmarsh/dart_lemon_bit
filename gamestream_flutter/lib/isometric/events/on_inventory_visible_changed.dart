
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/library.dart';

void onInventoryVisibleChanged(bool inventoryVisible){
  GameAudio.click_sound_8();
  if (!inventoryVisible && storeVisible.value) {
    GameNetwork.sendClientRequestStoreClose();
  }
}