
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:gamestream_flutter/library.dart';

class ClientEvents {
  static void onInventoryReadsChanged(int value){
    ClientActions.clearItemTypeHover();
  }

  static void onChangedAttributesWindowVisible(bool value){
    ClientActions.playSoundWindow();
  }

  static void onChangedHotKeys(int value){
    ClientActions.redrawHotKeys();
  }

  static void onChangedRaining(bool raining){
    raining ? GameActions.rainStart() : GameActions.rainStop();
    GameState.refreshLighting();
  }

  static void onDragStarted(int itemIndex){
    ClientState.dragStart.value = itemIndex;
    ClientState.dragEnd.value = -1;
  }

  static void onDragCompleted(){

  }

  static void onItemIndexPrimary(int itemIndex){
     GameNetwork.sendClientRequestInventoryEquip(itemIndex);
  }

  static void onItemIndexSecondary(int itemIndex){
    GameNetwork.sendClientRequestInventoryDrop(itemIndex);
  }

  static void onDragCancelled(Velocity velocity, Offset offset){
    ClientActions.dropDraggedItem();
    ClientState.dragStart.value = -1;
    ClientState.dragEnd.value = -1;
  }

  static void onDragEndItemIndex(DraggableDetails details){

  }

  static void onKeyPressed(LogicalKeyboardKey key){
    if (key == ClientConstants.Key_Toggle_Input_Mode) {
      GameIO.actionToggleInputMode();
      return;
    }
    if (key == ClientConstants.Key_Toggle_Debug_Mode) {
      GameActions.toggleDebugMode();
      return;
    }
    if (key == ClientConstants.Key_Toggle_Window_Attributes) {
      ClientActions.windowTogglePlayerAttributes();
      return;
    }

    if (GameState.playMode) {
      onKeyPressedPlayMode(key);
    } else {

      // if (key == LogicalKeyboardKey.digit5) {
      //   GameEditor.paintTorch();
      //   return;
      // }
      // if (key == LogicalKeyboardKey.digit4) {
      //   GameEditor.paintTree();
      //   return;
      // }
    }
  }

  static void onKeyPressedPlayMode(LogicalKeyboardKey key){
    if (key == ClientConstants.Key_Inventory){
      GameNetwork.sendClientRequestInventoryToggle();
      return;
    }
    if (ClientQuery.keyboardKeyIsHotKey(key)) {
      onKeyPressedPlayModeHotKey(key);
      return;
    }
    if (key == ClientConstants.Key_Message) {
      GameActions.messageBoxShow();
      return;
    }
    if (key == ClientConstants.Key_Auto_Attack) {
      GameActions.attackAuto();
      return;
    }
    if (key == ClientConstants.Key_Zoom) {
      GameActions.toggleZoom();
      return;
    }
  }

  static void onDragAcceptWatchBelt(Watch<int> watchBelt, int index) =>
    ServerActions.inventoryMoveToWatchBelt(index, watchBelt);

  static void onButtonPressedWatchBelt(Watch<int> watchBeltType) =>
    ServerActions.equipWatchBeltType(watchBeltType);

  static void onRightClickedWatchBelt(Watch<int> watchBelt){
    ServerActions.inventoryUnequip(
        ServerQuery.mapWatchBeltTypeToItemType(watchBelt)
    );
  }

  static void onKeyPressedPlayModeHotKey(LogicalKeyboardKey key) {
    if (ClientState.hoverIndex.value >= 0 &&
        ClientState.hoverDialogIsInventory
    ) {
      GameNetwork.sendClientRequestInventoryMove(
          indexFrom: ClientState.hoverIndex.value,
          indexTo: ClientQuery.mapKeyboardKeyToBeltIndex(key),
      );
      return;
    }
    ServerActions.equipWatchBeltType(ClientQuery.mapKeyboardKeyToWatchBeltType(key));
  }
}