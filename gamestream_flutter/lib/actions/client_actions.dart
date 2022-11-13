
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() => ClientState.inventoryReads.value++;
  static void redrawHotKeys() => ClientState.readsHotKeys.value++;

  static void clearMouseOverDialogType() =>
    ClientState.hoverDialogType.value = DialogType.None;

  static void clearItemTypeHover() =>
    ClientState.hoverItemType.value = ItemType.Empty;

  static void windowClosePlayerAttributes() =>
    ClientState.windowVisibleAttributes.value = false;

  static void windowOpenPlayerAttributes() =>
    ClientState.windowVisibleAttributes.value = true;

  static void windowTogglePlayerAttributes() =>
      ClientState.windowVisibleAttributes.value = !ClientState.windowVisibleAttributes.value;

  static void playSoundWindow() =>
      GameAudio.click_sound_8(1);

  static void dragStartSetNone(){
    ClientState.dragStart.value = DragStart.None;
  }

  static void assignEquippedItemToHotKey(String index){
       if (index == "1") {
         ClientState.hotKey1.value = GamePlayer.weapon.value;
       }
       if (index == "2") {
         ClientState.hotKey2.value = GamePlayer.weapon.value;
       }
       if (index == "3") {
         ClientState.hotKey3.value = GamePlayer.weapon.value;
       }
       if (index == "4") {
         ClientState.hotKey4.value = GamePlayer.weapon.value;
       }
       if (index == "Q") {
         ClientState.hotKeyQ.value = GamePlayer.weapon.value;
       }
       if (index == "E") {
         ClientState.hotKeyE.value = GamePlayer.weapon.value;
       }
  }

  static void setDragStart(int clientType) =>
    () => ClientState.dragStart.value = clientType;

  static void removeEquippedWeaponHotKey() {
    if (GamePlayer.weapon.value == ItemType.Empty) return;

    for (final hotKey in ClientState.hotKeyWatches) {
      if (hotKey.value != GamePlayer.weapon.value) continue;
      hotKey.value = ItemType.Empty;
    }
  }
}