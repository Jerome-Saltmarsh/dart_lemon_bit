
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() => ClientState.inventoryReads.value++;
  static void redrawHotKeys() => ClientState.readsHotKeys.value++;

  static void clearMouseOverDialogType() =>
    ClientState.hoverDialogType.value = DialogType.None;

  static void clearHoverIndex() =>
    ClientState.hoverIndex.value = -1;

  static void windowClosePlayerAttributes() =>
    ClientState.windowVisibleAttributes.value = false;

  static void windowOpenPlayerAttributes() =>
    ClientState.windowVisibleAttributes.value = true;

  static void windowTogglePlayerAttributes() =>
      ClientState.windowVisibleAttributes.value = !ClientState.windowVisibleAttributes.value;

  static void playSoundWindow() =>
      GameAudio.click_sound_8(1);

  static void dragStartSetNone(){
    ClientState.dragStart.value = -1;
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

  static void setDragItemIndex(int index) =>
    () => ClientState.dragStart.value = index;

  static void dropDraggedItem(){
    if (ClientState.dragStart.value == -1) return;
    GameNetwork.sendClientRequestInventoryDrop(ClientState.dragStart.value);
  }

  static void messageClear(){
    writeMessage("");
  }

  static void writeMessage(String value){
    ClientState.messageStatus.value = value;
  }

  static void playAudioError(){
    GameAudio.errorSound15();
  }

  static void inventorySwapDragTarget(){
    if (ClientState.dragStart.value == -1) return;
    if (ClientState.hoverIndex.value == -1) return;
    GameNetwork.sendClientRequestInventoryMove(
      indexFrom: ClientState.dragStart.value,
      indexTo: ClientState.hoverIndex.value,
    );
  }

  static void refreshBakeMapLightSources() {
    ClientState.nodesLightSourcesTotal = 0;
    for (var i = 0; i < GameNodes.nodesTotal; i++){
      if (!NodeType.emitsLight(GameNodes.nodesType[i])) continue;
      ClientState.nodesLightSources[ClientState.nodesLightSourcesTotal] = i;
      ClientState.nodesLightSourcesTotal++;

      if (ClientState.nodesLightSourcesTotal >= ClientState.nodesLightSources.length) {
        ClientState.nodesLightSources = Uint16List(ClientState.nodesLightSources.length + 500);
        print("refreshBakeMapLightSources overflow");
        refreshBakeMapLightSources();
        return;
      }
    }
  }
}