
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
          final type = GameState.nodesType[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || GameState.nodesOrientation[index] == NodeOrientation.Solid) {
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
    for (var i = 0; i < GameState.nodesTotal; i++) {
      if (!NodeType.isRain(GameState.nodesType[i])) continue;
      GameState.nodesType[i] = NodeType.Empty;
      GameState.nodesOrientation[i] = NodeOrientation.None;
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

  static void cameraSetPositionGrid(int row, int column, int z){
    cameraSetPosition(row * tileSize, column * tileSize, z * tileHeight);
  }

  static void cameraSetPosition(double x, double y, double z){
    final renderX = (x - y) * 0.5;
    final renderY = ((y + x) * 0.5) - z;
    Engine.cameraCenter(renderX, renderY);
  }
}