
import 'package:gamestream_flutter/library.dart';

class GameActions {

  static void loadSelectedSceneName(){
    final sceneName = GameEditor.selectedSceneName.value;
    if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
    GameNetwork.sendClientRequestEditorLoadGame(sceneName);
    GameEditor.actionGameDialogClose();
  }

  static void rainStart(){
    final rows = GameNodes.totalRows;
    final columns = GameNodes.totalColumns;
    final zs = GameNodes.totalZ - 1;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        for (var z = zs; z >= 0; z--) {
          final index = GameState.getNodeIndexZRC(z, row, column);
          final type = GameNodes.nodeTypes[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || GameNodes.nodeOrientations[index] == NodeOrientation.Solid) {
              GameState.setNodeType(z + 1, row, column, NodeType.Rain_Landing);
            }
            GameState.setNodeType(z + 2, row, column, NodeType.Rain_Falling);
            break;
          }
          if (
              column == 0 ||
              row == 0 ||
              !GameQueries.gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
              !GameQueries.gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
          ){
            GameState.setNodeType(z, row, column, NodeType.Rain_Falling);
          }
        }
      }
    }
  }

  static void rainStop() {
    for (var i = 0; i < GameNodes.total; i++) {
      if (!NodeType.isRain(GameNodes.nodeTypes[i])) continue;
      GameNodes.nodeTypes[i] = NodeType.Empty;
      GameNodes.nodeOrientations[i] = NodeOrientation.None;
    }
  }

  ///
  static void rainFixBug(){

  }

  static void actionSetModePlay(){
    ClientState.edit.value = false;
  }

  static void actionSetModeEdit(){
    ClientState.edit.value = true;
  }

  static void actionToggleEdit() {
    ClientState.edit.value = !ClientState.edit.value;
  }

  static void messageBoxToggle(){
    GameUI.messageBoxVisible.value = !GameUI.messageBoxVisible.value;
  }

  static void messageBoxShow(){
    GameUI.messageBoxVisible.value = true;
  }

  static void messageBoxHide(){
    GameUI.messageBoxVisible.value = false;
  }

  static void toggleDebugMode(){
    ClientState.debugVisible.value = !ClientState.debugVisible.value;;
  }

  static void setTarget() {
    GameIO.touchscreenCursorAction = CursorAction.Set_Target;
  }

  static void attackAuto() {
    GameIO.touchscreenCursorAction = CursorAction.Stationary_Attack_Auto;
  }

  static void playerStop() {
    GameIO.recenterCursor();
    setTarget();
  }

  static void toggleZoom(){
    GameAudio.weaponSwap2();
    if (Engine.targetZoom != GameConfig.Zoom_Far){
      Engine.targetZoom = GameConfig.Zoom_Far;
    } else {
      Engine.targetZoom = GameConfig.Zoom_Close;
    }
  }
}

