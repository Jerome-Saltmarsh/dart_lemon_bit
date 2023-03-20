
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
    raining ? GameActions.rainStart() : GameActions.rainStop();
    GameNodes.resetNodeColorsToAmbient();
  }

  static void onDragStarted(int itemIndex){
    // print("onDragStarted()");
    ClientState.dragStart.value = itemIndex;
    ClientState.dragEnd.value = -1;
  }

  static void onDragCompleted(){
    // print("onDragCompleted()");
  }

  static void onDragEnd(DraggableDetails details){
    // print("onDragEnd()");
  }

  static void onItemIndexPrimary(int itemIndex) {
    if (ClientState.hoverDialogDialogIsTrade){
      GameNetwork.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
     GameNetwork.sendClientRequestInventoryEquip(itemIndex);
  }

  static void onItemIndexSecondary(int itemIndex){
    if (ClientState.hoverDialogDialogIsTrade){
      GameNetwork.sendClientRequestInventoryBuy(itemIndex);
      return;
    }
    GamePlayer.interactModeTrading
        ? GameNetwork.sendClientRequestInventorySell(itemIndex)
        : GameNetwork.sendClientRequestInventoryDrop(itemIndex);
  }

  static void onDragAcceptEquippedItemContainer(int? i){
    if (i == null) return;
    GameNetwork.sendClientRequestInventoryEquip(i);
  }

  static void onDragCancelled(Velocity velocity, Offset offset){
    // print("onDragCancelled()");
    if (ClientState.hoverIndex.value == -1){
      ClientActions.dropDraggedItem();
    } else {
      ClientActions.inventorySwapDragTarget();
    }
    ClientState.dragStart.value = -1;
    ClientState.dragEnd.value = -1;
  }

  static void onKeyPressed(int key){

    if (key == ClientConstants.Key_Toggle_Debug_Mode) {
      GameActions.toggleDebugMode();
      return;
    }

    if (key == KeyCode.Tab) {
      GameActions.actionToggleEdit();
      return;
    }

    if (GameState.playMode) {
      onKeyPressedModePlay(key);
    } else {
      onKeyPressedModeEdit(key);
    }
  }

  static void onKeyPressedModeEdit(int key){

    switch (key){
      case ClientConstants.Key_Duplicate:
        GameNetwork.sendGameObjectRequestDuplicate();
        break;
      case KeyCode.F:
        GameEditor.paint();
        break;
      case KeyCode.G:
        if (GameEditor.gameObjectSelected.value) {
          GameNetwork.sendGameObjectRequestMoveToMouse();
        } else {
          GameCamera.cameraSetPositionGrid(GameEditor.row, GameEditor.column, GameEditor.z);
        }
        break;
      case KeyCode.R:
        GameEditor.selectPaintType();
        break;
      case KeyCode.Arrow_Up:
        if (Engine.keyPressedShiftLeft) {
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
        if (Engine.keyPressedShiftLeft) {
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
      GameActions.toggleZoom();
      return;
    }

    if (key == ClientConstants.Key_Suicide) {
      GameNetwork.sendClientRequest(ClientRequest.Suicide);
      return;
    }

    if (key == KeyCode.Enter) {
      GameNetwork.sendClientRequest(ClientRequest.Suicide);
      return;
    }

    if (Engine.isLocalHost){
      if (key == ClientConstants.Key_Settings) {
        GameActions.toggleWindowSettings();
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
        ServerQuery.mapWatchBeltTypeToItemType(watchBelt)
    );
  }

  static void onAcceptDragInventoryIcon(){
     if (ClientState.dragStart.value == -1) return;
     GameNetwork.sendClientRequestInventoryDeposit(ClientState.dragStart.value);
  }

  static void onChangedMessageStatus(String value){
    if (value.isEmpty){
      ClientState.messageStatusDuration = 0;
    } else {
      ClientState.messageStatusDuration = 150;
    }
  }

  static void onChangedAreaTypeVisible(bool value) =>
      ClientState.areaTypeVisibleDuration = value
          ? ClientConstants.Area_Type_Duration
          : 0;

  static void onChangedDebugMode(bool value){
    GameRender.renderDebug = value;
  }

  static void onChangedCredits(int value){
    GameAudio.coins.play();
  }
}