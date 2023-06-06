
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

class ClientEvents {
  static void onInventoryReadsChanged(int value){
    ClientActions.clearHoverIndex();
  }

  static void onChangedAttributesWindowVisible(bool value){
    ClientActions.playSoundWindow();
  }

  static void onChangedHotKeys(int value){
    ClientActions.redrawHotKeys();
  }

  static void onChangedRaining(bool raining){
    raining ? gamestream.isometric.actions.rainStart() : gamestream.isometric.actions.rainStop();
    gamestream.isometric.nodes.resetNodeColorsToAmbient();
  }

  static void onDragStarted(int itemIndex){
    // print("onDragStarted()");
    gamestream.isometric.clientState.dragStart.value = itemIndex;
    gamestream.isometric.clientState.dragEnd.value = -1;
  }

  static void onDragCompleted(){
    // print("onDragCompleted()");
  }

  static void onDragEnd(DraggableDetails details){
    // print("onDragEnd()");
  }

  static void onItemIndexPrimary(int itemIndex) {
    if (gamestream.isometric.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.network.sendClientRequestInventoryEquip(itemIndex);
  }

  static void onItemIndexSecondary(int itemIndex){
    if (gamestream.isometric.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.isometric.player.interactModeTrading
        ? gamestream.network.sendClientRequestInventorySell(itemIndex)
        : gamestream.network.sendClientRequestInventoryDrop(itemIndex);
  }

  static void onDragAcceptEquippedItemContainer(int? i){
    if (i == null) return;
    gamestream.network.sendClientRequestInventoryEquip(i);
  }

  static void onDragCancelled(Velocity velocity, Offset offset){
    // print("onDragCancelled()");
    if (gamestream.isometric.clientState.hoverIndex.value == -1){
      ClientActions.dropDraggedItem();
    } else {
      ClientActions.inventorySwapDragTarget();
    }
    gamestream.isometric.clientState.dragStart.value = -1;
    gamestream.isometric.clientState.dragEnd.value = -1;
  }

  static void onKeyPressed(int key){

    if (key == ClientConstants.Key_Toggle_Debug_Mode) {
      gamestream.isometric.actions.toggleDebugMode();
      return;
    }

    if (key == KeyCode.Tab) {
      gamestream.isometric.actions.actionToggleEdit();
      return;
    }

    if (key == KeyCode.Escape) {
      gamestream.isometric.clientState.window_visible_menu.toggle();
    }

    if (gamestream.isometric.clientState.playMode) {
      onKeyPressedModePlay(key);
    } else {
      onKeyPressedModeEdit(key);
    }
  }

  static void onKeyPressedModeEdit(int key){

    switch (key){
      case ClientConstants.Key_Duplicate:
        gamestream.network.sendGameObjectRequestDuplicate();
        break;
      case KeyCode.F:
        gamestream.isometric.editor.paint();
        break;
      case KeyCode.G:
        if (gamestream.isometric.editor.gameObjectSelected.value) {
          gamestream.network.sendGameObjectRequestMoveToMouse();
        } else {
          gamestream.isometric.camera.cameraSetPositionGrid(gamestream.isometric.editor.row, gamestream.isometric.editor.column, gamestream.isometric.editor.z);
        }
        break;
      case KeyCode.R:
        gamestream.isometric.editor.selectPaintType();
        break;
      case KeyCode.Arrow_Up:
        if (engine.keyPressedShiftLeft) {
          if (gamestream.isometric.editor.gameObjectSelected.value){
            gamestream.isometric.editor.translate(x: 0, y: 0, z: 1);
            return;
          }
          gamestream.isometric.editor.cursorZIncrease();
          return;
        }
        if (gamestream.isometric.editor.gameObjectSelected.value) {
          gamestream.isometric.editor.translate(x: -1, y: -1, z: 0);
          return;
        }
        gamestream.isometric.editor.cursorRowDecrease();
        return;
      case KeyCode.Arrow_Right:
        if (gamestream.isometric.editor.gameObjectSelected.value){
          return gamestream.isometric.editor.translate(x: 1, y: -1, z: 0);
        }
        gamestream.isometric.editor.cursorColumnDecrease();
        break;
      case KeyCode.Arrow_Down:
        if (engine.keyPressedShiftLeft) {
          if (gamestream.isometric.editor.gameObjectSelected.value){
            return gamestream.isometric.editor.translate(x: 0, y: 0, z: -1);
          }
          gamestream.isometric.editor.cursorZDecrease();
        } else {
          if (gamestream.isometric.editor.gameObjectSelected.value){
            return gamestream.isometric.editor.translate(x: 1, y: 1, z: 0);
          }
          gamestream.isometric.editor.cursorRowIncrease();
        }
        break;
      case KeyCode.Arrow_Left:
        if (gamestream.isometric.editor.gameObjectSelected.value){
          return gamestream.isometric.editor.translate(x: -1, y: 1, z: 0);
        }
        gamestream.isometric.editor.cursorColumnIncrease();
        break;
    }
  }

  static void onKeyPressedModePlay(int key) {

    if (key == ClientConstants.Key_Zoom) {
      gamestream.isometric.actions.toggleZoom();
      return;
    }

    if (key == ClientConstants.Key_Suicide) {
      gamestream.network.sendClientRequest(ClientRequest.Suicide);
      return;
    }

    if (key == KeyCode.Enter) {
      gamestream.network.sendClientRequest(ClientRequest.Suicide);
      return;
    }

    if (engine.isLocalHost){
      if (key == ClientConstants.Key_Settings) {
        gamestream.isometric.actions.toggleWindowSettings();
        return;
      }
    }
  }

  static void onDragAcceptWatchBelt(Watch<int> watchBelt, int index) =>
    ServerActions.inventoryMoveToWatchBelt(index, watchBelt);

  static void onButtonPressedWatchBelt(Watch<int> watchBeltType) =>
    ServerActions.equipWatchBeltType(watchBeltType);

  static void onRightClickedWatchBelt(Watch<int> watchBelt){
    ServerActions.inventoryUnequip(
        gamestream.isometric.serverState.mapWatchBeltTypeToItemType(watchBelt)
    );
  }

  static void onAcceptDragInventoryIcon(){
     if (gamestream.isometric.clientState.dragStart.value == -1) return;
     gamestream.network.sendClientRequestInventoryDeposit(gamestream.isometric.clientState.dragStart.value);
  }

  static void onChangedMessageStatus(String value){
    if (value.isEmpty){
      gamestream.isometric.clientState.messageStatusDuration = 0;
    } else {
      gamestream.isometric.clientState.messageStatusDuration = 150;
    }
  }

  static void onChangedAreaTypeVisible(bool value) =>
      gamestream.isometric.clientState.areaTypeVisibleDuration = value
          ? ClientConstants.Area_Type_Duration
          : 0;

  static void onChangedDebugMode(bool value){
    gamestream.isometric.renderer.renderDebug = value;
  }

  static void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }
}