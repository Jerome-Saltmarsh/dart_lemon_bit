
import 'package:gamestream_flutter/classes/local_server.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/mode.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/lemon_websocket_client/websocket_client.dart';
import 'package:gamestream_flutter/types/server_mode.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/cursor_type.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/network/functions/detect_connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/packages/lemon_components.dart';

class IsometricOptions with IsometricComponent implements Updatable {
  var renderNorth = true;
  var renderEast = true;
  var alphaBlend = 128;
  var cameraPlayFollowPlayer = true;
  var cameraEdit = Position();
  var cameraDebug = Position();
  var charactersEffectParticles = false;
  var renderWindVelocity = false;
  var renderCameraTargets = false;
  var renderRunLine = false;
  var renderVisibilityBeams = false;
  var renderHeightMap = false;
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

  final serverMode = Watch(ServerMode.remote);
  final cameraPlay = Position();
  final mode = Watch(Mode.Play);
  final highlightIconInventory = WatchBool(false);
  final timeVisible = WatchBool(true);
  final windowOpenMenu = WatchBool(false);
  final operationStatus = Watch(OperationStatus.None);
  final region = Watch<ConnectionRegion?>(ConnectionRegion.LocalHost);
  final serverFPS = Watch(0);
  final sceneName = Watch<String?>(null);
  final gameRunning = Watch(true);
  final watchTimePassing = Watch(false);
  final rendersSinceUpdate = Watch(0);
  final triggerAlarmNoMessageReceivedFromServer = Watch(false);
  final messageStatus = Watch('');
  final gameError = Watch<GameError?>(null);

  late final Watch<Game> game;
  late final WebsocketClient websocket;

  late final localServer = LocalServer(
    parser: parser,
  );

  IsometricOptions(){
    mode.onChanged(onChangedMode);
    messageStatus.onChanged(_onChangedMessageStatus);
    gameError.onChanged(_onChangedGameError);
    rendersSinceUpdate.onChanged(_onChangedRendersSinceUpdate);
    sceneName.onChanged((t) {print('scene.name = $t');});
  }

  @override
  Future onComponentInit(sharedPreferences) async {
    print('uri-base-host: ${Uri.base.host}');
    print('region-detected: ${detectConnectionRegion()}');
    game = Watch<Game>(website, onChanged: _onChangedGame);
    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
    engine.cursorType.value = CursorType.Basic;
    websocket = WebsocketClient(
      readString: parser.addString,
      readBytes: parser.add,
      onError: onWebsocketNetworkError,
      onDone: onWebsocketNetworkDone,
    );

    websocket.connectionStatus.onChanged(
        events.onChangedNetworkConnectionStatus
    );
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
        websocket.disconnect();
        break;
      case GameError.PlayerNotFound:
        ui.error.value = 'player character could not be found';
        websocket.disconnect();
        break;
      default:
        break;
    }
  }

  void _onChangedGame(Game game) {
    ui.gameUI.value = game.buildUI;
    game.onActivated();
  }

  void toggleEditMode() {
    if (editing){
      setModePlay();
    } else {
      setModeEdit();
    }
  }

  void onChangedMode(int mode) {
    switch (mode){
      case Mode.Play:
        editor.deselectGameObject();
        activateCameraPlay();
        break;
      case Mode.Edit:
        editor.cameraCenterOnNodeSelectedIndex();
        editor.cursorSetToPlayer();
        activateCameraEdit();
        break;
      case Mode.Debug:
        activateCameraDebug();
        break;
    }
  }

  void activateCameraDebug() {
    camera.target = cameraDebug;
  }

  void activateCameraEdit() {
    camera.target = cameraEdit;
  }

  void activateCameraPlay(){
    camera.target = cameraPlay;
  }

  void _onChangedMessageStatus(String value){
    if (value.isEmpty){
      messageStatusDuration = 0;
    } else {
      messageStatusDuration = 150;
    }
  }

  void setModePlay(){
    mode.value = Mode.Play;
  }

  void setModeEdit(){
    mode.value = Mode.Edit;
  }

  void setModeDebug(){
    mode.value = Mode.Debug;
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

    if (cameraPlayFollowPlayer){
      cameraPlay.copy(player.position);
    }

    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = '';
      }
    }

    if (clearErrorTimer > 0) {
      clearErrorTimer--;
      if (clearErrorTimer <= 0)
        gameError.value = null;
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

  void operationDone(){
    operationStatus.value = OperationStatus.None;
  }

  void startOperation(OperationStatus status){
    operationStatus.value = status;
  }

  void toggleRenderCameraTargets() => renderCameraTargets = !renderCameraTargets;

  bool get debugging => mode.value == Mode.Debug;

  bool get editing => mode.value == Mode.Edit;

  bool get playing => mode.value == Mode.Play;

  set debugging(bool value) => mode.value = value ? Mode.Debug : Mode.Play;

  void setCameraPositionToPlayer(){
    final cameraPlay = this.cameraPlay;
    final player = this.player;
    cameraPlay.x = player.x;
    cameraPlay.y = player.y;
    cameraPlay.z = player.z;
  }

  @override
  void onComponentDispose() {
    print('isometricNetwork.onComponentDispose()');
    websocket.disconnect();
  }

  bool get playModeMulti => serverMode.value == ServerMode.remote;

  bool get playModeSingle => serverMode.value == ServerMode.local;

  void onWebsocketNetworkError(Object error, StackTrace stack) {
    if (error.toString().contains('NotAllowedError')){
      return;
    }
    print(error.toString());
    print(stack);
    ui.error.value = error.toString();
  }

  void onWebsocketNetworkDone() {
    scene.clear();
    amulet.onNetworkDone();
  }
}