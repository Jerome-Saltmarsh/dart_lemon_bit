
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onInventoryVisibleChanged(bool inventoryVisible){
  GameAudio.audioSingleClickSound();
  if (!inventoryVisible && storeVisible.value) {
       sendClientRequestStoreClose();
  }
}