
import 'package:gamestream_flutter/library.dart';

class IsometricIO {

  var Key_Inventory          = KeyCode.I;
  var Key_Zoom               = KeyCode.F;
  var Key_Suicide            = KeyCode.Backspace;
  var Key_Settings           = KeyCode.Digit_0;
  var Key_Duplicate          = KeyCode.V;
  var Key_Auto_Attack        = KeyCode.Space;
  var Key_Message            = KeyCode.Enter;
  var Key_Toggle_Debug_Mode  = KeyCode.P;
  var Key_Toggle_Map         = KeyCode.M;
  var Mouse_Translation_Sensitivity = 0.1;

  void addListeners(){
    engine.onLeftClicked = onMouseClickedLeft;
  }

  void onKeyPressed(int key){

    if (key == Key_Toggle_Debug_Mode) {
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

    if (key == Key_Zoom) {
      gamestream.isometric.actions.toggleZoom();
      return;
    }

    if (key == Key_Suicide) {
      gamestream.network.sendClientRequest(ClientRequest.Suicide);
      return;
    }

    if (key == KeyCode.Enter) {
      gamestream.network.sendClientRequest(ClientRequest.Suicide);
      return;
    }

    if (engine.isLocalHost){
      if (key == Key_Settings) {
        gamestream.isometric.actions.toggleWindowSettings();
        return;
      }
    }
  }

  void onKeyPressedModeEdit(int key){

    switch (key){
      case KeyCode.V:
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

  void onMouseClickedLeft() {
    if (gamestream.isometric.clientState.edit.value) {
      onMouseClickedEditMode();
    }
  }

  void onMouseClickedEditMode(){
    final isometric = gamestream.isometric;
    switch (isometric.editor.editTab.value) {
      case EditTab.File:
        isometric.editor.setTabGrid();
        isometric.editor.selectMouseBlock();
        break;
      case EditTab.Grid:
        isometric.editor.selectMouseBlock();
        isometric.editor.actionRecenterCamera();
        break;
      case EditTab.Objects:
        isometric.editor.selectMouseGameObject();
        break;
    }
  }

}