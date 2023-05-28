
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
    raining ? gamestream.games.isometric.actions.rainStart() : gamestream.games.isometric.actions.rainStop();
    gamestream.games.isometric.nodes.resetNodeColorsToAmbient();
  }

  static void onDragStarted(int itemIndex){
    // print("onDragStarted()");
    gamestream.games.isometric.clientState.dragStart.value = itemIndex;
    gamestream.games.isometric.clientState.dragEnd.value = -1;
  }

  static void onDragCompleted(){
    // print("onDragCompleted()");
  }

  static void onDragEnd(DraggableDetails details){
    // print("onDragEnd()");
  }

  static void onItemIndexPrimary(int itemIndex) {
    if (gamestream.games.isometric.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    gamestream.network.sendClientRequestInventoryEquip(itemIndex);
  }

  static void onItemIndexSecondary(int itemIndex){
    if (gamestream.games.isometric.clientState.hoverDialogDialogIsTrade){
      gamestream.network.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    GamePlayer.interactModeTrading
        ? gamestream.network.sendClientRequestInventorySell(itemIndex)
        : gamestream.network.sendClientRequestInventoryDrop(itemIndex);
  }

  static void onDragAcceptEquippedItemContainer(int? i){
    if (i == null) return;
    gamestream.network.sendClientRequestInventoryEquip(i);
  }

  static void onDragCancelled(Velocity velocity, Offset offset){
    // print("onDragCancelled()");
    if (gamestream.games.isometric.clientState.hoverIndex.value == -1){
      ClientActions.dropDraggedItem();
    } else {
      ClientActions.inventorySwapDragTarget();
    }
    gamestream.games.isometric.clientState.dragStart.value = -1;
    gamestream.games.isometric.clientState.dragEnd.value = -1;
  }

  static void onKeyPressed(int key){

    if (key == ClientConstants.Key_Toggle_Debug_Mode) {
      gamestream.games.isometric.actions.toggleDebugMode();
      return;
    }

    if (key == KeyCode.Tab) {
      gamestream.games.isometric.actions.actionToggleEdit();
      return;
    }

    if (key == KeyCode.Escape) {
      gamestream.games.isometric.clientState.window_visible_menu.toggle();
    }

    if (gamestream.games.isometric.clientState.playMode) {
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
        GameEditor.paint();
        break;
      case KeyCode.G:
        if (GameEditor.gameObjectSelected.value) {
          gamestream.network.sendGameObjectRequestMoveToMouse();
        } else {
          gamestream.games.isometric.camera.cameraSetPositionGrid(GameEditor.row, GameEditor.column, GameEditor.z);
        }
        break;
      case KeyCode.R:
        GameEditor.selectPaintType();
        break;
      case KeyCode.Arrow_Up:
        if (engine.keyPressedShiftLeft) {
          if (GameEditor.gameObjectSelected.value){
            GameEditor.translate(x: 0, y: 0, z: 1);
            return;
          }
          GameEditor.cursorZIncrease();
          return;
        }
        if (GameEditor.gameObjectSelected.value) {
          GameEditor.translate(x: -1, y: -1, z: 0);
          return;
        }
        GameEditor.cursorRowDecrease();
        return;
      case KeyCode.Arrow_Right:
        if (GameEditor.gameObjectSelected.value){
          return GameEditor.translate(x: 1, y: -1, z: 0);
        }
        GameEditor.cursorColumnDecrease();
        break;
      case KeyCode.Arrow_Down:
        if (engine.keyPressedShiftLeft) {
          if (GameEditor.gameObjectSelected.value){
            return GameEditor.translate(x: 0, y: 0, z: -1);
          }
          GameEditor.cursorZDecrease();
        } else {
          if (GameEditor.gameObjectSelected.value){
            return GameEditor.translate(x: 1, y: 1, z: 0);
          }
          GameEditor.cursorRowIncrease();
        }
        break;
      case KeyCode.Arrow_Left:
        if (GameEditor.gameObjectSelected.value){
          return GameEditor.translate(x: -1, y: 1, z: 0);
        }
        GameEditor.cursorColumnIncrease();
        break;
    }
  }

  static void onKeyPressedModePlay(int key) {

    if (key == ClientConstants.Key_Zoom) {
      gamestream.games.isometric.actions.toggleZoom();
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
        gamestream.games.isometric.actions.toggleWindowSettings();
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
        gamestream.games.isometric.serverState.mapWatchBeltTypeToItemType(watchBelt)
    );
  }

  static void onAcceptDragInventoryIcon(){
     if (gamestream.games.isometric.clientState.dragStart.value == -1) return;
     gamestream.network.sendClientRequestInventoryDeposit(gamestream.games.isometric.clientState.dragStart.value);
  }

  static void onChangedMessageStatus(String value){
    if (value.isEmpty){
      gamestream.games.isometric.clientState.messageStatusDuration = 0;
    } else {
      gamestream.games.isometric.clientState.messageStatusDuration = 150;
    }
  }

  static void onChangedAreaTypeVisible(bool value) =>
      gamestream.games.isometric.clientState.areaTypeVisibleDuration = value
          ? ClientConstants.Area_Type_Duration
          : 0;

  static void onChangedDebugMode(bool value){
    gamestream.games.isometric.renderer.renderDebug = value;
  }

  static void onChangedCredits(int value){
    gamestream.audio.coins.play();
  }
}