
import 'package:gamestream_flutter/library.dart';

class ClientState {
  static final inventoryReads = Watch(0, onChanged: ClientEvents.onInventoryReadsChanged);
  static final hoverItemType = Watch(ItemType.Empty);
  static final hoverIndex = Watch(-1);
  static final hoverDialogType = Watch(DialogType.None);
  static final windowVisibleAttributes = Watch(false, onChanged: ClientEvents.onChangedAttributesWindowVisible);

  static final hotKey1 = Watch(0);
  static final hotKey2 = Watch(0);
  static final hotKey3 = Watch(0);
  static final hotKey4 = Watch(0);

  // PROPERTIES
  static bool get hoverDialogIsInventory => hoverDialogType.value == DialogType.Inventory;
  static bool get hoverDialogDialogIsTrade => hoverDialogType.value == DialogType.Trade;
}