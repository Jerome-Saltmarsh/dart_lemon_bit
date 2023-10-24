import 'package:gamestream_ws/gamestream/amulet.dart';
import 'package:gamestream_ws/isometric.dart';
import 'package:gamestream_ws/packages/common/src/player_event.dart';

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

  AmuletPlayerScript controlsDisabled() => controls(false);

  AmuletPlayerScript controlsEnabled() => controls(true);

  AmuletPlayerScript controls(bool enabled) =>
      add(() {
        log('controls(enabled: $enabled)');
        if (enabled){
          player.clearCameraTarget();
        } else {
          setCharacterStateIdle(player);
          player.clearPath();
          player.setDestinationToCurrentPosition();
        }
        player.controlsEnabled = enabled;
      });

  AmuletPlayerScript spawnPoint(String? value) =>
      add(() {
        log('spawnPoint($value)');
        player.spawnPoint = value;
      });

  AmuletPlayerScript movePlayerToSceneKey(String sceneKey) =>
      movePositionToSceneKey(player, sceneKey);

  AmuletPlayerScript movePositionToSceneKey(
      Position position,
      String sceneKey,
  ) =>
      movePositionToIndex(position, getSceneKeyIndex(sceneKey));

  AmuletPlayerScript faceEachOther(
      Character a,
      Character b,
  ) =>
      add(() {
        a.face(b);
        b.face(a);
      });

  AmuletPlayerScript movePositionToIndex(Position position, int index) => add(() {
    final scene = getScene();
    position.x = scene.getIndexX(index);
    position.y = scene.getIndexY(index);
    position.z = scene.getIndexZ(index);
  });

  AmuletPlayerScript cameraSetTargetSceneKey(String sceneKey) =>
      add(() {
        log('cameraSetTargetSceneKey("$sceneKey")');
        return player.cameraTarget = getSceneKeyPosition(sceneKey);
      });

  AmuletPlayerScript cameraSetTarget(Position? position) =>
      add(() => player.cameraTarget = position);

  AmuletPlayerScript talk(String text, {List<TalkOption>? options, Position? target}) {
    var initialized = false;
    return add(() {
      if (initialized) {
        return !player.interacting;
      }
      if (target != null){
        player.cameraTarget = target;
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

  AmuletPlayerScript activate(Collider collider) =>
      add(() {
        log('activate($collider)');
        getAmuletGame().activate(collider);
      });

  AmuletPlayerScript deactivate(Collider collider) =>
      add(() {
        log('deactivate($collider)');
        getAmuletGame().deactivate(collider);
      });

  AmuletPlayerScript flag(String flagName) =>
      add(() {
        log('flag($flagName)');
        player.readOnce(flagName);
      });

  AmuletPlayerScript end() {
    controlsEnabled();
    cameraClearTarget();
    return this;
  }

  AmuletPlayerScript snapCameraToPlayer() =>
      add(() => player.writePlayerEvent(PlayerEvent.Player_Moved));

  AmuletPlayerScript objective(String? objective) =>
      add(() {
        log('objective($objective)');
        return player.objective = objective;
      });

  AmuletPlayerScript dataSet(String name, dynamic value) =>
      add(() => player.data[name] = value);

  AmuletPlayerScript dataRemove(String name) =>
      add(() => player.data.remove(name));

  AmuletPlayerScript completeObjective() =>
      add(player.completeCurrentObjective);

  AmuletPlayerScript zoom(double value) => add(() => player.writeZoom(value));

  AmuletPlayerScript add(Function() action){
    actions.add(action);
    return this;
  }

  void log(String text){
    print('script.log: $text');
  }

}


