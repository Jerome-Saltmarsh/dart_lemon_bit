
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onInventoryVisibleChanged(bool inventoryVisible){
  AudioEngine.audioSingleClickSound();
  if (!inventoryVisible && storeVisible.value) {
       sendClientRequestStoreClose();
  }
}