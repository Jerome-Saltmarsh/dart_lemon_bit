
import '../packages/src.dart';
import 'amulet.dart';
import 'amulet_game.dart';
import 'amulet_player.dart';
import 'talk_option.dart';

class AmuletPlayerScript {
  final actions = <Function>[];
  final AmuletPlayer player;
  var index = 0;

  AmuletPlayerScript(this.player);

  bool get finished => index >= actions.length;

  Amulet get amulet => player.amulet;

  AmuletGame get amuletGame => player.amuletGame;

  void update(){
    final action = actions[index];
    if (action.call() != false){
      index++;
    }
  }

  AmuletPlayerScript wait({int seconds = 0}) {
    final frames = seconds * Frames_Per_Second;
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

  AmuletPlayerScript clearHighlightedItem() =>
      add(() => player.writeClearHighlightedAmuletItem());

  AmuletPlayerScript highlightAmuletItem(AmuletItem amuletItem) =>
      add(() => player.writeHighlightAmuletItems(amuletItem));

  AmuletPlayerScript controlsEnabled() => controls(true);

  AmuletPlayerScript controls(bool enabled) =>
      add(() {
        // log('controls(enabled: $enabled)');
        if (enabled){
          player.clearCameraTarget();
        } else {
          player.setCharacterStateIdle();
          player.clearPath();
          player.setDestinationToCurrentPosition();
        }
        player.setControlsEnabled(enabled);
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
        a.facePosition(b);
        b.facePosition(a);
      });

  AmuletPlayerScript puzzleSolved() =>
      playerEvent(PlayerEvent.Puzzle_Solved);

  AmuletPlayerScript playerEvent(int playerEvent) =>
      add(() => player.writePlayerEvent(playerEvent));

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

  AmuletPlayerScript talk(Collider speaker, String text, {List<TalkOption>? options}) {
    var initialized = false;
    return add(() {
      if (initialized) {
        return !player.interacting;
      }

      player.talk(speaker, text, options: options);
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

  AmuletPlayerScript setNodeEmptyAtSceneKey(String sceneKey) =>
      setNodeEmptyAtIndex(getSceneKeyIndex(sceneKey));

  AmuletPlayerScript playAudioType(AudioType audioType) =>
      add(() => player.playAudioType(audioType));

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

  AmuletPlayerScript gameEventPosition(int gameEvent, Position position) =>
      add(() => getAmuletGame().dispatchGameEventPosition(gameEvent, position));

  AmuletPlayerScript gameEventSceneKey(int gameEvent, String sceneKey) =>
      gameEventIndex(gameEvent, getScene().getKey(sceneKey));

  AmuletPlayerScript gameEventIndex(int gameEvent, int index) {
    final scene = getScene();
    return gameEventXYZ(
        gameEvent,
        scene.getIndexX(index),
        scene.getIndexY(index),
        scene.getIndexZ(index),
    );
  }

  AmuletPlayerScript gameEventXYZ(int gameEvent, double x, double y, double z) =>
      add(() => player.amuletGame.dispatchGameEvent(gameEvent, x, y, z));

  AmuletPlayerScript deactivate(Collider collider) =>
      add(() {
        log('deactivate($collider)');
        getAmuletGame().deactivate(collider);
      });

  AmuletPlayerScript changeGame(AmuletGame game, {String? sceneKey}) =>
      add(() => amulet.playerChangeGame(
          player: player,
          target: game,
          sceneKey: sceneKey,
      ));

  AmuletPlayerScript flag(String flagName) =>
      add(() {
        log('flag($flagName)');
        player.flagged(flagName);
      });

  AmuletPlayerScript end() {
    controlsEnabled();
    cameraClearTarget();
    return this;
  }

  AmuletPlayerScript snapCameraToPlayer() =>
      add(() => player.writePlayerEvent(PlayerEvent.Player_Moved));

  AmuletPlayerScript zoom(double value) => add(() => player.writeZoom(value));

  AmuletPlayerScript add(Function() action){
    actions.add(action);
    return this;
  }

  void log(String text){
    print('script.log: $text');
  }
}


