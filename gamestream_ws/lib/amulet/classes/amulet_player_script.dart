import 'package:gamestream_ws/gamestream/amulet.dart';
import 'package:gamestream_ws/isometric.dart';

import 'amulet_game.dart';
import 'amulet_player.dart';
import 'talk_option.dart';

class AmuletPlayerScript {
  final actions = <Function>[];
  final AmuletPlayer player;
  var index = 0;

  AmuletPlayerScript(this.player);

  bool get finished => index >= actions.length;

  void update(){
    final action = actions[index];
    if (action.call() != false){
      index++;
    }
  }

  AmuletPlayerScript wait({int seconds = 0}) {
    final frames = seconds * Amulet.Frames_Per_Second;
    var endFrame = -1;

    return add(() {
      final currentFrame = getAmuletGame().frame;
      if (endFrame == -1){
        log('wait(seconds: $seconds)');
        endFrame = currentFrame + frames;
      }
      return currentFrame >= endFrame;
    });
  }

  AmuletPlayerScript playerControlsDisabled() => playerControls(false);

  AmuletPlayerScript playerControlsEnabled() => playerControls(true);

  AmuletPlayerScript playerControls(bool enabled) =>
      add(() {
        log('playerControls(enabled: $enabled)');
        if (enabled){
          player.cameraTarget = player;
        } else {
          setCharacterStateIdle(player);
          player.clearPath();
          player.setDestinationToCurrentPosition();
        }
        player.controlsEnabled = enabled;
      });

  AmuletPlayerScript movePlayerToSceneKey(String sceneKey) =>
      movePositionToSceneKey(player, sceneKey);

  AmuletPlayerScript movePositionToSceneKey(
      Position position,
      String sceneKey,
  ) =>
      movePositionToIndex(position, getSceneKeyIndex(sceneKey));

  AmuletPlayerScript movePositionToIndex(Position position, int index) => add(() {
    final scene = getScene();
    position.x = scene.getIndexX(index);
    position.y = scene.getIndexY(index);
    position.z = scene.getIndexZ(index);
  });

  AmuletPlayerScript cameraSetTarget(Position? position) =>
      add(() => player.cameraTarget = position);

  AmuletPlayerScript cameraSetTargetSceneKey(String sceneKey) =>
      add(() {
        log('cameraSetTargetSceneKey("$sceneKey")');
        return player.cameraTarget = getSceneKeyPosition(sceneKey);
      });

  AmuletPlayerScript talk(String text, {List<TalkOption>? options}) {
    var initialized = false;
    return add(() {
      if (initialized) {
        return !player.interacting;
      }
      player.talk(text, options: options);
      initialized = true;
      log('talk(text: "$text")');
      return false;
    });
  }

  AmuletPlayerScript cameraClearTarget() => cameraSetTarget(null);

  Position getSceneKeyPosition(String sceneKey){
    final position = Position();
    getScene().movePositionToIndex(
        position, getSceneKeyIndex(sceneKey)
    );
    return position;
  }

  int getSceneKeyIndex(String sceneKey) =>
      getScene().getKey(sceneKey);

  Scene getScene() => getAmuletGame().scene;

  AmuletGame getAmuletGame() => player.amuletGame;

  AmuletPlayerScript setNodeEmptyAtSceneKey(String sceneKey) {
    return setNodeEmptyAtIndex(getSceneKeyIndex(sceneKey));
  }

  AmuletPlayerScript setNodeEmptyAtIndex(int index) =>
      add(() {
        log('setNodeEmptyAtIndex($index)');
        getAmuletGame().setNodeEmpty(index);
      });

  AmuletPlayerScript add(Function() action){
    actions.add(action);
    return this;
  }

  void log(String text){
    print('script.log: $text');
  }
}


