
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:lemon_engine/engine.dart';

class GameActions {
  static void setAmbientShadeToHour(){
    GameState.ambientShade.value = Shade.fromHour(GameState.hours.value);
  }

  static void spawnDustCloud(double x, double y, double z) {
    for (var i = 0; i < 3; i++){
      GameState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: Engine.randomAngle());
    }
  }

  static void loadSelectedSceneName(){
    final sceneName = GameEditor.selectedSceneName.value;
    if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
    GameNetwork.sendClientRequestEditorLoadGame(sceneName);
    actionGameDialogClose();
  }
}