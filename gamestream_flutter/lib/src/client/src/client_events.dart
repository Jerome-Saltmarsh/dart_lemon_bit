
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
    raining ? gamestream.isometricEngine.actions.rainStart() : gamestream.isometricEngine.actions.rainStop();
    gamestream.isometricEngine.nodes.resetNodeColorsToAmbient();
  }

  static void onDragStarted(int itemIndex){
    // print("onDragStarted()");
    gamestream.isometricEngine.clientState.dragStart.value = itemIndex;
    gamestream.isometricEngine.clientState.dragEnd.value = -1;
  }

  static void onDragCompleted(){
    // print("onDragCompleted()");
  }

  static void onDragEnd(DraggableDetails details){
    // print("onDragEnd()");
  }

  static void onItemIndexPrimary(int itemIndex) {
    if (gamestream.isometricEngine.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.network.sendClientRequestInventoryEquip(itemIndex);
  }

  static void onItemIndexSecondary(int itemIndex){
    if (gamestream.isometricEngine.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.isometricEngine.player.interactModeTrading
        ? gamestream.network.sendClientRequestInventorySell(itemIndex)
        : gamestream.network.sendClientRequestInventoryDrop(itemIndex);
  }

  static void onDragAcceptEquippedItemContainer(int? i){
    if (i == null) return;
    gamestream.network.sendClientRequestInventoryEquip(i);
  }

  static void onDragCancelled(Velocity velocity, Offset offset){
    // print("onDragCancelled()");
    if (gamestream.isometricEngine.clientState.hoverIndex.value == -1){
      ClientActions.dropDraggedItem();
    } else {
      ClientActions.inventorySwapDragTarget();
    }
    gamestream.isometricEngine.clientState.dragStart.value = -1;
    gamestream.isometricEngine.clientState.dragEnd.value = -1;
  }

  static void onKeyPressed(int key){

    if (key == ClientConstants.Key_Toggle_Debug_Mode) {
      gamestream.isometricEngine.actions.toggleDebugMode();
      return;
    }

    if (key == KeyCode.Tab) {
      gamestream.isometricEngine.actions.actionToggleEdit();
      return;
    }

    if (key == KeyCode.Escape) {
      gamestream.isometricEngine.clientState.window_visible_menu.toggle();
    }

    if (gamestream.isometricEngine.clientState.playMode) {
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
        gamestream.isometricEngine.editor.paint();
        break;
      case KeyCode.G:
        if (gamestream.isometricEngine.editor.gameObjectSelected.value) {
          gamestream.network.sendGameObjectRequestMoveToMouse();
        } else {
          gamestream.isometricEngine.camera.cameraSetPositionGrid(gamestream.isometricEngine.editor.row, gamestream.isometricEngine.editor.column, gamestream.isometricEngine.editor.z);
        }
        break;
      case KeyCode.R:
        gamestream.isometricEngine.editor.selectPaintType();
        break;
      case KeyCode.Arrow_Up:
        if (engine.keyPressedShiftLeft) {
          if (gamestream.isometricEngine.editor.gameObjectSelected.value){
            gamestream.isometricEngine.editor.translate(x: 0, y: 0, z: 1);
            return;
          }
          gamestream.isometricEngine.editor.cursorZIncrease();
          return;
        }
        if (gamestream.isometricEngine.editor.gameObjectSelected.value) {
          gamestream.isometricEngine.editor.translate(x: -1, y: -1, z: 0);
          return;
        }
        gamestream.isometricEngine.editor.cursorRowDecrease();
        return;
      case KeyCode.Arrow_Right:
        if (gamestream.isometricEngine.editor.gameObjectSelected.value){
          return gamestream.isometricEngine.editor.translate(x: 1, y: -1, z: 0);
        }
        gamestream.isometricEngine.editor.cursorColumnDecrease();
        break;
      case KeyCode.Arrow_Down:
        if (engine.keyPressedShiftLeft) {
          if (gamestream.isometricEngine.editor.gameObjectSelected.value){
            return gamestream.isometricEngine.editor.translate(x: 0, y: 0, z: -1);
          }
          gamestream.isometricEngine.editor.cursorZDecrease();
        } else {
          if (gamestream.isometricEngine.editor.gameObjectSelected.value){
            return gamestream.isometricEngine.editor.translate(x: 1, y: 1, z: 0);
          }
          gamestream.isometricEngine.editor.cursorRowIncrease();
        }
        break;
      case KeyCode.Arrow_Left:
        if (gamestream.isometricEngine.editor.gameObjectSelected.value){
          return gamestream.isometricEngine.editor.translate(x: -1, y: 1, z: 0);
        }
        gamestream.isometricEngine.editor.cursorColumnIncrease();
        break;
    }
  }

  static void onKeyPressedModePlay(int key) {

    if (key == ClientConstants.Key_Zoom) {
      gamestream.isometricEngine.actions.toggleZoom();
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
        gamestream.isometricEngine.actions.toggleWindowSettings();
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
        gamestream.isometricEngine.serverState.mapWatchBeltTypeToItemType(watchBelt)
    );
  }

  static void onAcceptDragInventoryIcon(){
     if (gamestream.isometricEngine.clientState.dragStart.value == -1) return;
     gamestream.network.sendClientRequestInventoryDeposit(gamestream.isometricEngine.clientState.dragStart.value);
  }

  static void onChangedMessageStatus(String value){
    if (value.isEmpty){
      gamestream.isometricEngine.clientState.messageStatusDuration = 0;
    } else {
      gamestream.isometricEngine.clientState.messageStatusDuration = 150;
    }
  }

  static void onChangedAreaTypeVisible(bool value) =>
      gamestream.isometricEngine.clientState.areaTypeVisibleDuration = value
          ? ClientConstants.Area_Type_Duration
          : 0;

  static void onChangedDebugMode(bool value){
    gamestream.isometricEngine.renderer.renderDebug = value;
  }

  static void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }
}