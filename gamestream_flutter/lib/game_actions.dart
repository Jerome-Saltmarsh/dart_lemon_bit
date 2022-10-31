
import 'package:gamestream_flutter/library.dart';

class GameActions {
  static void setAmbientShadeToHour(){
    GameState.ambientShade.value = Shade.fromHour(GameState.hours.value);
  }

  static void spawnDustCloud(double x, double y, double z) {
    for (var i = 0; i < 3; i++){
      // GameState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: Engine.randomAngle());
    }
  }

  static void loadSelectedSceneName(){
    final sceneName = GameEditor.selectedSceneName.value;
    if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
    GameNetwork.sendClientRequestEditorLoadGame(sceneName);
    GameEditor.actionGameDialogClose();
  }

  static void rainStart(){
    for (var row = 0; row < GameState.nodesTotalRows; row++) {
      for (var column = 0; column < GameState.nodesTotalColumns; column++) {
        for (var z = GameState.nodesTotalZ - 1; z >= 0; z--) {

          final index = GameState.getNodeIndexZRC(z, row, column);
          final type = GameNodes.nodesType[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || GameNodes.nodesOrientation[index] == NodeOrientation.Solid) {
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
    for (var i = 0; i < GameNodes.nodesTotal; i++) {
      if (!NodeType.isRain(GameNodes.nodesType[i])) continue;
      GameNodes.nodesType[i] = NodeType.Empty;
      GameNodes.nodesOrientation[i] = NodeOrientation.None;
    }
  }

  static void actionSetModePlay(){
    GameState.edit.value = false;
  }

  static void actionSetModeEdit(){
    GameState.edit.value = true;
  }

  static void actionToggleEdit() {
    GameState.edit.value = !GameState.edit.value;
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
    GameState.debugVisible.value = !GameState.debugVisible.value;;
  }

  static void runToMouse() {
    GameNetwork.updateBuffer[17] = 1;
  }

  static void performActionPrimary() {
     GameIO.performActionPrimary = true;
  }

  static void playerStop() {
    GameIO.recenterCursor();
    runToMouse();
  }
}

