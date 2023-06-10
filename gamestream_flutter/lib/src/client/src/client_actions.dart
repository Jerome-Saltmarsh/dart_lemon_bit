
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void playSoundWindow() =>
      gamestream.audio.click_sound_8(1);

  static void dragStartSetNone(){
    gamestream.isometric.clientState.dragStart.value = -1;
  }

  static void setDragItemIndex(int index) =>
    () => gamestream.isometric.clientState.dragStart.value = index;

  static void dropDraggedItem(){
    if (gamestream.isometric.clientState.dragStart.value == -1) return;
    gamestream.network.sendClientRequestInventoryDrop(gamestream.isometric.clientState.dragStart.value);
  }

  static void messageClear(){
    writeMessage("");
  }

  static void writeMessage(String value){
    gamestream.isometric.clientState.messageStatus.value = value;
  }

  static void playAudioError(){
    gamestream.audio.errorSound15();
  }

  static void inventorySwapDragTarget(){
    if (gamestream.isometric.clientState.dragStart.value == -1) return;
    if (gamestream.isometric.clientState.hoverIndex.value == -1) return;
    gamestream.network.sendClientRequestInventoryMove(
      indexFrom: gamestream.isometric.clientState.dragStart.value,
      indexTo: gamestream.isometric.clientState.hoverIndex.value,
    );
  }

  static void refreshBakeMapLightSources() {
    gamestream.isometric.clientState.nodesLightSourcesTotal = 0;
    for (var i = 0; i < gamestream.isometric.nodes.total; i++){
      if (!NodeType.emitsLight(gamestream.isometric.nodes.nodeTypes[i])) continue;
      if (gamestream.isometric.clientState.nodesLightSourcesTotal >= gamestream.isometric.clientState.nodesLightSources.length) {
        gamestream.isometric.clientState.nodesLightSources = Uint16List(gamestream.isometric.clientState.nodesLightSources.length + 100);
        refreshBakeMapLightSources();
        return;
      }
      gamestream.isometric.clientState.nodesLightSources[gamestream.isometric.clientState.nodesLightSourcesTotal] = i;
      gamestream.isometric.clientState.nodesLightSourcesTotal++;
    }
  }

  static void clearHoverDialogType() {
    gamestream.isometric.clientState.hoverDialogType.value = DialogType.None;
  }

  static void showMessage(String message){
    gamestream.isometric.clientState.messageStatus.value = "";
    gamestream.isometric.clientState.messageStatus.value = message;
  }

  static void spawnConfettiPlayer() {
     for (var i = 0; i < 10; i++){
       gamestream.isometric.clientState.spawnParticleConfetti(
         gamestream.isometric.player.position.x,
         gamestream.isometric.player.position.y,
         gamestream.isometric.player.position.z,
       );
     }
  }
}