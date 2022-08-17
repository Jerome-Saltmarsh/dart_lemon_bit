
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onInventoryVisibleChanged(bool inventoryVisible){
  audioSingleClickSound();
  if (!inventoryVisible && storeVisible.value) {
       sendClientRequestStoreClose();
  }
}