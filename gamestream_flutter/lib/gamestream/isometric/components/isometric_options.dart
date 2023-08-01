
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/component_isometric.dart';
import 'package:gamestream_flutter/library.dart';

class IsometricOptions with ComponentIsometric {
  var renderHealthBarEnemies = true;
  var renderHealthBarAllies = true;
  var updateAmbientAlphaAccordingToTimeEnabled = true;
  var sceneSmokeSourcesSmokeDuration = 250;
  var clearErrorTimer = -1;
  var messageStatusDuration = 0;

  final rendersSinceUpdate = Watch(0);
  final messageBoxVisible = Watch(false);
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
    messageBoxVisible.onChanged(onVisibilityChangedMessageBox);
    rendersSinceUpdate.onChanged(_onChangedRendersSinceUpdate);
  }

  bool get playMode => !editMode;

  bool get editMode => edit.value;

  @override
  void onReady() {
    game = Watch<Game>(website, onChanged: _onChangedGame);
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
    action.playAudioError();
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

  void updateClearErrorTimer() {
    if (clearErrorTimer <= 0)
      return;

    clearErrorTimer--;
    if (clearErrorTimer > 0)
      return;

    error.value = null;
  }

  void actionSetModePlay(){
    edit.value = false;
  }

  void actionSetModeEdit(){
    edit.value = true;
  }

  void messageBoxToggle(){
    messageBoxVisible.value = !messageBoxVisible.value;
  }

  void messageBoxShow(){
    messageBoxVisible.value = true;
  }

  void messageBoxHide(){
    messageBoxVisible.value = false;
  }

  void onVisibilityChangedMessageBox(bool visible){
    if (visible) {
      isometric.textFieldMessage.requestFocus();
      return;
    }
    isometric.textFieldMessage.unfocus();
    isometric.textEditingControllerMessage.text = '';
  }

  void onChangedError(String error) {
    messageStatus.value = error;
    if (error.isNotEmpty) {
      messageStatusDuration = 200;
    } else {
      messageStatusDuration = 0;
    }
  }

  void update() {
    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = '';
      }
    }
  }

  void _onChangedRendersSinceUpdate(int value){
    triggerAlarmNoMessageReceivedFromServer.value = value > 200;
  }
}