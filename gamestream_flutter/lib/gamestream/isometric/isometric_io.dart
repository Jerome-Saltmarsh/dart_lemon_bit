
import 'package:gamestream_flutter/library.dart';

class IsometricIO {

  void onKeyPressed(int key){

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

  void onKeyPressedModePlay(int key) {

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

  void onKeyPressedModeEdit(int key){

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
}