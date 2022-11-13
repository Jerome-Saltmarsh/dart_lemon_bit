
import 'package:gamestream_flutter/library.dart';

/// The data stored in client state belongs to the client and can be safely read and written
class ClientState {
  static final raining = Watch(false, onChanged: ClientEvents.onChangedRaining);
  static final readsHotKeys = Watch(0);
  static final inventoryReads = Watch(0, onChanged: ClientEvents.onInventoryReadsChanged);
  static final hoverItemType = Watch(ItemType.Empty);
  static final hoverIndex = Watch(-1);
  static final hoverDialogType = Watch(DialogType.None);
  static final windowVisibleAttributes = Watch(false, onChanged: ClientEvents.onChangedAttributesWindowVisible);
  static final debugVisible = Watch(false);
  static final torchesIgnited = Watch(true);
  static final touchButtonSide = Watch(TouchButtonSide.Right);
  static final rendersSinceUpdate = Watch(0, onChanged: GameEvents.onChangedRendersSinceUpdate);
  static final particles = <Particle>[];
  static var totalActiveParticles = 0;

  static var srcXRainFalling = 6640.0;
  static var srcXRainLanding = 6739.0;
  static var nextLightning = 0;

  static final hotKey1 = Watch(0, onChanged: ClientEvents.onChangedHotKeys);
  static final hotKey2 = Watch(0, onChanged: ClientEvents.onChangedHotKeys);
  static final hotKey3 = Watch(0, onChanged: ClientEvents.onChangedHotKeys);
  static final hotKey4 = Watch(0, onChanged: ClientEvents.onChangedHotKeys);

  // PROPERTIES
  static bool get hoverDialogIsInventory => hoverDialogType.value == DialogType.Inventory;
  static bool get hoverDialogDialogIsTrade => hoverDialogType.value == DialogType.Trade;
}