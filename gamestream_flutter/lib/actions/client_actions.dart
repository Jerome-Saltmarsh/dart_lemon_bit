
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() => ClientState.inventoryReads.value++;

  static void windowCloseInventoryInformation() =>
    ClientState.itemTypeHover.value = ItemType.Empty;

  static void windowClosePlayerAttributes() =>
    ClientState.windowVisibleAttributes.value = false;

  static void windowOpenPlayerAttributes() =>
    ClientState.windowVisibleAttributes.value = true;

  static void windowTogglePlayerAttributes() =>
      ClientState.windowVisibleAttributes.value = !ClientState.windowVisibleAttributes.value;
}