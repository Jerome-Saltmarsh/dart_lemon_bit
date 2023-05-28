
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() => gamestream.games.isometric.clientState.inventoryReads.value++;
  static void redrawHotKeys() => gamestream.games.isometric.clientState.readsHotKeys.value++;

  static void clearMouseOverDialogType() =>
    gamestream.games.isometric.clientState.hoverDialogType.value = DialogType.None;

  static void clearHoverIndex() =>
    gamestream.games.isometric.clientState.hoverIndex.value = -1;

  static void playSoundWindow() =>
      gamestream.audio.click_sound_8(1);

  static void dragStartSetNone(){
    gamestream.games.isometric.clientState.dragStart.value = -1;
  }

  static void setDragItemIndex(int index) =>
    () => gamestream.games.isometric.clientState.dragStart.value = index;

  static void dropDraggedItem(){
    if (gamestream.games.isometric.clientState.dragStart.value == -1) return;
    gamestream.network.sendClientRequestInventoryDrop(gamestream.games.isometric.clientState.dragStart.value);
  }

  static void messageClear(){
    writeMessage("");
  }

  static void writeMessage(String value){
    gamestream.games.isometric.clientState.messageStatus.value = value;
  }

  static void playAudioError(){
    gamestream.audio.errorSound15();
  }

  static void inventorySwapDragTarget(){
    if (gamestream.games.isometric.clientState.dragStart.value == -1) return;
    if (gamestream.games.isometric.clientState.hoverIndex.value == -1) return;
    gamestream.network.sendClientRequestInventoryMove(
      indexFrom: gamestream.games.isometric.clientState.dragStart.value,
      indexTo: gamestream.games.isometric.clientState.hoverIndex.value,
    );
  }

  static void refreshBakeMapLightSources() {
    gamestream.games.isometric.clientState.nodesLightSourcesTotal = 0;
    for (var i = 0; i < gamestream.games.isometric.nodes.total; i++){
      if (!NodeType.emitsLight(gamestream.games.isometric.nodes.nodeTypes[i])) continue;
      if (gamestream.games.isometric.clientState.nodesLightSourcesTotal >= gamestream.games.isometric.clientState.nodesLightSources.length) {
        gamestream.games.isometric.clientState.nodesLightSources = Uint16List(gamestream.games.isometric.clientState.nodesLightSources.length + 100);
        refreshBakeMapLightSources();
        return;
      }
      gamestream.games.isometric.clientState.nodesLightSources[gamestream.games.isometric.clientState.nodesLightSourcesTotal] = i;
      gamestream.games.isometric.clientState.nodesLightSourcesTotal++;
    }
  }

  static void clearHoverDialogType() {
    gamestream.games.isometric.clientState.hoverDialogType.value = DialogType.None;
  }

  static void showMessage(String message){
    gamestream.games.isometric.clientState.messageStatus.value = "";
    gamestream.games.isometric.clientState.messageStatus.value = message;
  }

  static void spawnConfettiPlayer() {
     for (var i = 0; i < 10; i++){
       gamestream.games.isometric.clientState.spawnParticleConfetti(
         gamestream.games.isometric.player.position.x,
         gamestream.games.isometric.player.position.y,
         gamestream.games.isometric.player.position.z,
       );
     }
  }
}