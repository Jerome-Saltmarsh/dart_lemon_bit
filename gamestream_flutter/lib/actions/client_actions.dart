
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() {
    ClientState.inventoryReads.value++;
  }

  static void closeWindowInventoryInformation() {
    GameInventoryUI.itemTypeHover.value = ItemType.Empty;
  }
}