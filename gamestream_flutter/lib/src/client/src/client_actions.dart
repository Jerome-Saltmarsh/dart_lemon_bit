
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() => ClientState.inventoryReads.value++;
  static void redrawHotKeys() => ClientState.readsHotKeys.value++;

  static void clearMouseOverDialogType() =>
    ClientState.hoverDialogType.value = DialogType.None;

  static void clearHoverIndex() =>
    ClientState.hoverIndex.value = -1;

  static void playSoundWindow() =>
      gamestream.audio.click_sound_8(1);

  static void dragStartSetNone(){
    ClientState.dragStart.value = -1;
  }

  static void setDragItemIndex(int index) =>
    () => ClientState.dragStart.value = index;

  static void dropDraggedItem(){
    if (ClientState.dragStart.value == -1) return;
    gamestream.network.sendClientRequestInventoryDrop(ClientState.dragStart.value);
  }

  static void messageClear(){
    writeMessage("");
  }

  static void writeMessage(String value){
    ClientState.messageStatus.value = value;
  }

  static void playAudioError(){
    gamestream.audio.errorSound15();
  }

  static void inventorySwapDragTarget(){
    if (ClientState.dragStart.value == -1) return;
    if (ClientState.hoverIndex.value == -1) return;
    gamestream.network.sendClientRequestInventoryMove(
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

  static void spawnConfettiPlayer() {
     for (var i = 0; i < 10; i++){
       GameState.spawnParticleConfetti(
         GamePlayer.position.x,
         GamePlayer.position.y,
         GamePlayer.position.z,
       );
     }
  }
}