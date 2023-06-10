
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
}