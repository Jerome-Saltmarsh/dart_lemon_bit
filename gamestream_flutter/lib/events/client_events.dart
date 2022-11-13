
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

  static void onDragCompleted(){

  }

  static void onDragCancelled(Velocity velocity, Offset offset){

  }

  static void onDragEnd(DraggableDetails details){

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
      if (key == ClientConstants.Key_Inventory){
        GameNetwork.sendClientRequestInventoryToggle();
        return;
      }
      if (ClientQuery.keyboardKeyIsHotKey(key)) {
        onKeyPressedHotKey(key);
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

  static void onKeyPressedHotKey(LogicalKeyboardKey key) {
    final hotKeyWatch = ClientQuery.getKeyboardKeyHotKeyWatch(key);
    if (ClientState.hoverIndex.value >= 0 &&
        ClientState.hoverDialogIsInventory) {
      hotKeyWatch.value = ClientQuery.getHoverItemType();
      return;
    }
    if (hotKeyWatch.value == ItemType.Empty) {
      ClientActions.removeEquippedWeaponHotKey();
      hotKeyWatch.value = GamePlayer.weapon.value;
      return;
    }
    ServerActions.equipItemType(hotKeyWatch.value);
  }
}