
import 'package:gamestream_flutter/library.dart';

class ClientActions {

  static void redrawInventory() => gamestream.isometricEngine.clientState.inventoryReads.value++;
  static void redrawHotKeys() => gamestream.isometricEngine.clientState.readsHotKeys.value++;

  static void clearMouseOverDialogType() =>
    gamestream.isometricEngine.clientState.hoverDialogType.value = DialogType.None;

  static void clearHoverIndex() =>
    gamestream.isometricEngine.clientState.hoverIndex.value = -1;

  static void playSoundWindow() =>
      gamestream.audio.click_sound_8(1);

  static void dragStartSetNone(){
    gamestream.isometricEngine.clientState.dragStart.value = -1;
  }

  static void setDragItemIndex(int index) =>
    () => gamestream.isometricEngine.clientState.dragStart.value = index;

  static void dropDraggedItem(){
    if (gamestream.isometricEngine.clientState.dragStart.value == -1) return;
    gamestream.network.sendClientRequestInventoryDrop(gamestream.isometricEngine.clientState.dragStart.value);
  }

  static void messageClear(){
    writeMessage("");
  }

  static void writeMessage(String value){
    gamestream.isometricEngine.clientState.messageStatus.value = value;
  }

  static void playAudioError(){
    gamestream.audio.errorSound15();
  }

  static void inventorySwapDragTarget(){
    if (gamestream.isometricEngine.clientState.dragStart.value == -1) return;
    if (gamestream.isometricEngine.clientState.hoverIndex.value == -1) return;
    gamestream.network.sendClientRequestInventoryMove(
      indexFrom: gamestream.isometricEngine.clientState.dragStart.value,
      indexTo: gamestream.isometricEngine.clientState.hoverIndex.value,
    );
  }

  static void refreshBakeMapLightSources() {
    gamestream.isometricEngine.clientState.nodesLightSourcesTotal = 0;
    for (var i = 0; i < gamestream.isometricEngine.nodes.total; i++){
      if (!NodeType.emitsLight(gamestream.isometricEngine.nodes.nodeTypes[i])) continue;
      if (gamestream.isometricEngine.clientState.nodesLightSourcesTotal >= gamestream.isometricEngine.clientState.nodesLightSources.length) {
        gamestream.isometricEngine.clientState.nodesLightSources = Uint16List(gamestream.isometricEngine.clientState.nodesLightSources.length + 100);
        refreshBakeMapLightSources();
        return;
      }
      gamestream.isometricEngine.clientState.nodesLightSources[gamestream.isometricEngine.clientState.nodesLightSourcesTotal] = i;
      gamestream.isometricEngine.clientState.nodesLightSourcesTotal++;
    }
  }

  static void clearHoverDialogType() {
    gamestream.isometricEngine.clientState.hoverDialogType.value = DialogType.None;
  }

  static void showMessage(String message){
    gamestream.isometricEngine.clientState.messageStatus.value = "";
    gamestream.isometricEngine.clientState.messageStatus.value = message;
  }

  static void spawnConfettiPlayer() {
     for (var i = 0; i < 10; i++){
       gamestream.isometricEngine.clientState.spawnParticleConfetti(
         gamestream.isometricEngine.player.position.x,
         gamestream.isometricEngine.player.position.y,
         gamestream.isometricEngine.player.position.z,
       );
     }
  }
}