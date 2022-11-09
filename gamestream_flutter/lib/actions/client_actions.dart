
import 'package:gamestream_flutter/library.dart';

class ClientActions {


  static void redrawInventory() {
    ClientState.inventoryReads.value++;
  }

  static void closeWindowInventoryInformation() {
    ClientState.itemTypeHover.value = ItemType.Empty;
  }
}