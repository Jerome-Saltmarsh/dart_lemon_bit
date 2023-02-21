
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() => ClientState.inventoryReads.value++;
  static void redrawHotKeys() => ClientState.readsHotKeys.value++;

  static void clearMouseOverDialogType() =>
    ClientState.hoverDialogType.value = DialogType.None;

  static void clearHoverIndex() =>
    ClientState.hoverIndex.value = -1;

  static void playSoundWindow() =>
      GameAudio.click_sound_8(1);

  static void dragStartSetNone(){
    ClientState.dragStart.value = -1;
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
    for (var i = 0; i < GameNodes.total; i++){
      if (!NodeType.emitsLight(GameNodes.nodeTypes[i])) continue;
      if (ClientState.nodesLightSourcesTotal >= ClientState.nodesLightSources.length) {
        ClientState.nodesLightSources = Uint16List(ClientState.nodesLightSources.length + 100);
        refreshBakeMapLightSources();
        return;
      }
      ClientState.nodesLightSources[ClientState.nodesLightSourcesTotal] = i;
      ClientState.nodesLightSourcesTotal++;
    }
  }

  static void clearHoverDialogType() {
    ClientState.hoverDialogType.value = DialogType.None;
  }

  static void showMessage(String message){
    ClientState.messageStatus.value = "";
    ClientState.messageStatus.value = message;
  }

  static void refreshTotalGrenades(){
    GamePlayer.totalGrenades.value = ServerQuery.countItemTypeQuantityInPlayerPossession(ItemType.Weapon_Thrown_Grenade);
  }
}