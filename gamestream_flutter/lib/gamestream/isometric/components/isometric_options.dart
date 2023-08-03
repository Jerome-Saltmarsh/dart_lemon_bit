
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/network/functions/detect_connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/lemon_ioc/updatable.dart';

class IsometricOptions with IsometricComponent implements Updatable {

  var framesPerLightingUpdate = 60;
  var cursorType = IsometricCursorType.Hand;
  var renderCursorEnable = true;
  var renderHealthBarEnemies = true;
  var renderHealthBarAllies = true;
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
  Future initializeComponent(sharedPreferences) async {
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
        website.error.value = 'unable to join game';
        network.websocket.disconnect();
        break;
      default:
        break;
    }
  }

  void _onChangedGame(Game game) {
    engine.buildUI = game.buildUI;
    engine.onLeftClicked = game.onLeftClicked;
    engine.onRightClicked = game.onRightClicked;
    engine.onKeyPressed = game.onKeyPressed;
    game.onActivated();
  }

  void toggleEditMode() => edit.value = !edit.value;


  void _onChangedEdit(bool value) {
    if (value) {
      camera.target = null;
      editor.cursorSetToPlayer();
      player.message.value = '-press arrow keys to move\n\n-press tab to play';
      player.messageTimer = 300;
    } else {
      action.cameraTargetPlayer();
      editor.deselectGameObject();
      // isometric.ui.mouseOverDialog.setFalse();
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
    GameType.Capture_The_Flag => captureTheFlag,
    // GameType.Moba => findComponent<Moba>(),
    GameType.Amulet => amulet,
    _ => throw Exception('mapGameTypeToGame($gameType)')
  };
}