
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
  
  static void onKeyPressed(LogicalKeyboardKey key){
    if (key == LogicalKeyboardKey.keyX) {
      GameIO.actionToggleInputMode();
      return;
    }
    if (key == LogicalKeyboardKey.keyP) {
      GameActions.toggleDebugMode();
      return;
    }
    if (key == LogicalKeyboardKey.keyB) {
      ClientActions.windowTogglePlayerAttributes();
      return;
    }

    if (GameState.playMode) {
      if (key == LogicalKeyboardKey.keyR){
        GameNetwork.sendClientRequestInventoryToggle();
        return;
      }

      if (key == LogicalKeyboardKey.digit1) {
        if (ClientState.hoverIndex.value >= 0 && ClientState.hoverDialogIsInventory){
          ClientState.hotKey1.value = ServerState.inventory[ClientState.hoverIndex.value];
        } else {
          if (ClientState.hotKey1.value == ItemType.Empty) {
            ClientState.hotKey1.value = GamePlayer.weapon.value;
            return;
          }
          ServerActions.equipItemType(ClientState.hotKey1.value);
        }
        return;
      }
      if (key == LogicalKeyboardKey.digit2) {
        if (ClientState.hoverIndex.value >= 0 && ClientState.hoverDialogIsInventory){
          ClientState.hotKey2.value = ServerState.inventory[ClientState.hoverIndex.value];
        } else {
          if (ClientState.hotKey2.value == ItemType.Empty) {
            ClientState.hotKey2.value = GamePlayer.weapon.value;
            return;
          }
          ServerActions.equipItemType(ClientState.hotKey2.value);
        }
        return;
      }
      if (key == LogicalKeyboardKey.digit3) {
        if (ClientState.hoverIndex.value >= 0 && ClientState.hoverDialogIsInventory){
          ClientState.hotKey3.value = ServerState.inventory[ClientState.hoverIndex.value];
        } else {
          if (ClientState.hotKey3.value == ItemType.Empty) {
            ClientState.hotKey3.value = GamePlayer.weapon.value;
            return;
          }
          ServerActions.equipItemType(ClientState.hotKey3.value);
        }
        return;
      }
      if (key == LogicalKeyboardKey.digit4) {
        if (ClientState.hoverIndex.value >= 0 && ClientState.hoverDialogIsInventory){
          ClientState.hotKey4.value = ServerState.inventory[ClientState.hoverIndex.value];
        } else {
          if (ClientState.hotKey4.value == ItemType.Empty) {
            ClientState.hotKey4.value = GamePlayer.weapon.value;
            return;
          }
          ServerActions.equipItemType(ClientState.hotKey4.value);
        }
        return;
      }

      if (key == LogicalKeyboardKey.keyQ) {
        if (ClientState.hoverIndex.value >= 0 && ClientState.hoverDialogIsInventory){
          ClientState.hotKeyQ.value = ServerState.inventory[ClientState.hoverIndex.value];
        } else {
          if (ClientState.hotKeyQ.value == ItemType.Empty) {
            ClientState.hotKeyQ.value = GamePlayer.weapon.value;
            return;
          }
          ServerActions.equipItemType(ClientState.hotKeyQ.value);
        }
        return;
      }
      if (key == LogicalKeyboardKey.keyE) {
        if (ClientState.hoverIndex.value >= 0 && ClientState.hoverDialogIsInventory){
          ClientState.hotKeyE.value = ServerState.inventory[ClientState.hoverIndex.value];
        } else {
          if (ClientState.hotKeyE.value == ItemType.Empty) {
            ClientState.hotKeyE.value = GamePlayer.weapon.value;
            return;
          }
          ServerActions.equipItemType(ClientState.hotKeyE.value);
        }
        return;
      }
      if (key == LogicalKeyboardKey.enter) {
        GameActions.messageBoxShow();
      }
      if (key == LogicalKeyboardKey.space) {
        GameActions.attackAuto();
      }
      if (key == LogicalKeyboardKey.keyF) {
        GameActions.toggleZoom();
      }
    } else {

      if (key == LogicalKeyboardKey.digit5) {
        GameEditor.paintTorch();
        return;
      }
      if (key == LogicalKeyboardKey.digit4) {
        GameEditor.paintTree();
        return;
      }
    }
  }
}