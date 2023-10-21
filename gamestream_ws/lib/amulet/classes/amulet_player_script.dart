import 'package:gamestream_ws/gamestream/amulet.dart';
import 'package:gamestream_ws/isometric.dart';

import 'amulet_game.dart';
import 'amulet_player.dart';
import 'talk_option.dart';

class AmuletPlayerScript {
  final AmuletPlayer player;
  final actions = <Function()>[];
  var index = 0;
  var running = true;

  AmuletPlayerScript(this.player);

  void update(){

    if (!running){
      return;
    }

    if (index < 0 || index >= actions.length){
      actions.clear();
      index = -1;
      running = false;
      return;
    }

    final action = actions[index];
    if (action.call() != false){
      index++;
    }
  }

  AmuletPlayerScript wait({int seconds = 0}) {
    final frames = seconds * Amulet.Frames_Per_Second;
    final endFrame = player.amuletGame.frame + frames;
    return add(() => player.amuletGame.frame >= endFrame);
  }

  AmuletPlayerScript add(Function() action){
    actions.add(action);
    return this;
  }

  AmuletPlayerScript playerControlsDisabled() => playerControls(false);

  AmuletPlayerScript playerControlsEnabled() => playerControls(true);

  AmuletPlayerScript playerControls(bool enabled) =>
      add(() {
        player.controlsEnabled = enabled;
      });

  AmuletPlayerScript movePlayerToSceneKey(String sceneKey) =>
      movePositionToSceneKey(player, sceneKey);

  AmuletPlayerScript movePositionToSceneKey(
      Position position,
      String sceneKey,
  ) =>
      movePositionToIndex(position, getSceneKey(sceneKey));

  AmuletPlayerScript movePositionToIndex(Position position, int index) => add(() {
    final scene = getScene();
    position.x = scene.getIndexX(index);
    position.y = scene.getIndexY(index);
    position.z = scene.getIndexZ(index);
  });

  AmuletPlayerScript cameraSetTarget(Position? position) =>
      add(() => player.cameraTarget = position);

  AmuletPlayerScript talk(String text, {List<TalkOption>? options}) {
    var initialized = false;
    return add(() {
      if (initialized) {
        return !player.interacting;
      }
      player.talk(text, options: options);
      initialized = true;
      return false;
    });
  }

  AmuletPlayerScript cameraClearTarget() => cameraSetTarget(null);

  int getSceneKey(String sceneKey) =>
      getScene().getKey(sceneKey);

  Scene getScene() => getAmuletGame().scene;

  AmuletGame getAmuletGame() => player.amuletGame;
}

