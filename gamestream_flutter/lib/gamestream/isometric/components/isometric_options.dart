
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/editor/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/network/functions/detect_connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/packages/lemon_components.dart';

class IsometricOptions with IsometricComponent implements Updatable {

  var emitLightsUsingRecursion = false;
  var renderRunLine = false;
  var renderVisibilityBeams = false;
  var renderHeightMap = false;
  var renderRainFallingTwice = true;
  var renderCharacterAnimationFrame = false;
  var characterRenderScale = 0.35;
  var characterShadowColor = Colors.black38;
  var framesPerLightingUpdate = 60;
  var cursorType = IsometricCursorType.Hand;
  var renderCursorEnable = true;
  var renderHealthBarEnemies = false;
  var renderHealthBarAllies = false;
  var updateAmbientAlphaAccordingToTimeEnabled = true;
  var sceneSmokeSourcesSmokeDuration = 250;
  var clearErrorTimer = -1;
  var messageStatusDuration = 0;
  var renderResponse = true;

  final windowOpenMenu = WatchBool(false);
  final operationStatus = Watch(OperationStatus.None);
  final region = Watch<ConnectionRegion?>(ConnectionRegion.LocalHost);
  final serverFPS = Watch(0);
  final sceneName = Watch<String?>(null);
  final gameRunning = Watch(true);
  final watchTimePassing = Watch(false);
  final rendersSinceUpdate = Watch(0);
  final triggerAlarmNoMessageReceivedFromServer = Watch(false);
  final gameType = Watch(GameType.Website);
  final edit = Watch(false);
  final messageStatus = Watch('');
  final error = Watch<GameError?>(null);

  late final Watch<Game> game;


  IsometricOptions(){
    gameType.onChanged(_onChangedGameType);
    edit.onChanged(_onChangedEdit);
    messageStatus.onChanged(_onChangedMessageStatus);
    error.onChanged(_onChangedGameError);
    rendersSinceUpdate.onChanged(_onChangedRendersSinceUpdate);
  }

  bool get playMode => !editMode;

  bool get editMode => edit.value;

  @override
  Future onComponentInit(sharedPreferences) async {
    print('uri-base-host: ${Uri.base.host}');
    print('region-detected: ${detectConnectionRegion()}');
    game = Watch<Game>(website, onChanged: _onChangedGame);
    engine.onMouseEnterCanvas = onMouseEnterCanvas;
    engine.onMouseExitCanvas = onMouseExitCanvas;
    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
    engine.cursorType.value = CursorType.Basic;
  }

  void onMouseEnterCanvas(){
    renderCursorEnable = true;
  }

  void onMouseExitCanvas(){
    renderCursorEnable = false;
  }

  void toggleRenderHealthBarEnemies() {
    renderHealthBarEnemies = !renderHealthBarEnemies;
  }

  void toggleRenderHealthbarAllies(){
    renderHealthBarAllies = !renderHealthBarAllies;
  }

  void _onChangedGameType(GameType value) {
    print('onChangedGameType(${value.name})');
    io.reset();
    action.startGameByType(value);
  }

  void _onChangedGameError(GameError? gameError){
    print('_onChangedGameError($gameError)');
    if (gameError == null)
      return;

    game.value.onGameError(gameError);

    clearErrorTimer = 300;
    audio.playAudioError();
    switch (gameError) {
      case GameError.Unable_To_Join_Game:
        ui.error.value = 'unable to join game';
        network.websocket.disconnect();
        break;
      case GameError.PlayerNotFound:
        ui.error.value = 'player character could not be found';
        network.websocket.disconnect();
        break;
      default:
        break;
    }
  }

  void _onChangedGame(Game game) {
    ui.gameUI.value = game.buildUI;
    engine.onLeftClicked = game.onLeftClicked;
    engine.onRightClicked = game.onRightClicked;
    engine.onKeyPressed = game.onKeyPressed;
    game.onActivated();
  }

  void toggleEditMode() => edit.value = !edit.value;

  void _onChangedEdit(bool value) {
    if (value) {
      io.enabledMouseClick = editor.editTab.value != EditorTab.Marks;
      camera.target = null;
      editor.cursorSetToPlayer();
      player.message.value = '-press arrow keys to move\n\n-press tab to play';
      player.messageTimer = 300;
    } else {
      io.enabledMouseClick = true;
      action.cameraTargetPlayer();
      editor.deselectGameObject();
      if (scene.sceneEditable.value){
        player.message.value = 'press tab to edit';
      }
    }
  }

  void _onChangedMessageStatus(String value){
    if (value.isEmpty){
      messageStatusDuration = 0;
    } else {
      messageStatusDuration = 150;
    }
  }

  void actionSetModePlay(){
    edit.value = false;
  }

  void actionSetModeEdit(){
    edit.value = true;
  }

  void onChangedError(String error) {
    messageStatus.value = error;
    if (error.isNotEmpty) {
      messageStatusDuration = 200;
    } else {
      messageStatusDuration = 0;
    }
  }

  void onComponentUpdate() {

    game.value.update();

    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = '';
      }
    }

    if (clearErrorTimer > 0) {
      clearErrorTimer--;
      if (clearErrorTimer <= 0)
        error.value = null;
    }
  }

  void _onChangedRendersSinceUpdate(int value){
    triggerAlarmNoMessageReceivedFromServer.value = value > 200;
  }

  Game mapGameTypeToGame(GameType gameType) => switch (gameType) {
    GameType.Website => website,
    GameType.Amulet => amulet,
    _ => throw Exception('mapGameTypeToGame($gameType)')
  };

  void toggleRenderCharacterAnimationFrame() =>
      renderCharacterAnimationFrame = !renderCharacterAnimationFrame;

  void toggleRenderRainTwice() =>
      renderRainFallingTwice = !renderRainFallingTwice;

  void operationDone(){
    operationStatus.value = OperationStatus.None;
  }

  void startOperation(OperationStatus status){
    operationStatus.value = status;
  }

}