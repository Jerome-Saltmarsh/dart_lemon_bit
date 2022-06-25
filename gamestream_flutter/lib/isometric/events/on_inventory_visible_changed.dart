
import 'package:gamestream_flutter/client_request_sender.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';

void onInventoryVisibleChanged(bool inventoryVisible){
  if (!inventoryVisible && storeVisible) {
       sendClientRequestStoreClose();
  }
}