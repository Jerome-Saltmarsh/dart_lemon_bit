
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
         // assignHotKeyWatchPlayerWeapon(ServerState.hotKey1);
       }
       if (index == "2") {
         // assignHotKeyWatchPlayerWeapon(ClientState.hotKey2);
       }
       if (index == "3") {
         // assignHotKeyWatchPlayerWeapon(ClientState.hotKey3);
       }
       if (index == "4") {
         // assignHotKeyWatchPlayerWeapon(ClientState.hotKey4);
       }
       if (index == "Q") {
         // assignHotKeyWatchPlayerWeapon(ClientState.hotKeyQ);
       }
       if (index == "E") {
         // assignHotKeyWatchPlayerWeapon(ClientState.hotKeyE);
       }
  }

  static void setDragStart(int clientType) =>
    () => ClientState.dragStart.value = clientType;

  static void assignHotKeyWatchPlayerWeapon(Watch<int> hotKeyWatch) =>
    assignHotKeyWatchValue(hotKeyWatch, GamePlayer.weapon.value);

  static void assignHotKeyWatchValue(Watch<int> hotKeyWatch, int value){
    if (hotKeyWatch.value == value) return;

    if (value != ItemType.Empty){
      // for (final hotKey in ClientState.hotKeyWatches) {
      //   if (hotKey.value != value) continue;
      //   hotKey.value = ItemType.Empty;
      // }
    }
    hotKeyWatch.value = value;
  }
}