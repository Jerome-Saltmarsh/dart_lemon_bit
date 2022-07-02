
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/isometric/player_store.dart';

void onInventoryVisibleChanged(bool inventoryVisible){
  if (!inventoryVisible && storeVisible) {
       sendClientRequestStoreClose();
  }
}