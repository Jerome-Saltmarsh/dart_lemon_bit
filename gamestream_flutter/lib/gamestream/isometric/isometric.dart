
import 'dart:async';
import 'dart:math';
import 'dart:ui' as dartUI;

import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/functions/convert_seconds_to_ambient_alpha.dart';
import 'package:gamestream_flutter/functions/validate_atlas.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_network.dart';
import 'package:gamestream_flutter/gamestream/audio/audio_single.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/games.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/lemon_websocket_client/connection_status.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/loading_page.dart';
import 'package:golden_ratio/constants.dart';

import '../network/functions/detect_connection_region.dart';
import 'atlases/atlas_nodes.dart';
import 'classes/src.dart';
import 'components/isometric_options.dart';
import 'components/isometric_render.dart';
import 'components/src.dart';
import 'enums/cursor_type.dart';
import 'ui/game_isometric_minimap.dart';
import 'ui/isometric_constants.dart';


class Isometric {

  Isometric() {
    print('Isometric()');
    scene = IsometricScene(this);
    network = IsometricNetwork(this);
    particles = IsometricParticles(this);
    audio = GameAudio(this);
    editor = IsometricEditor(this);
    debug = IsometricDebug(this);
    minimap = IsometricMinimap(this);
    camera = IsometricCamera(this);
    mouse = IsometricMouse(this);
    player = IsometricPlayer(this);
    ui = IsometricUI(this);
    games = Games(this);
    render = IsometricRender(this);

    games.website.errorMessageEnabled.value = true;
    error.onChanged((GameError? error) {
      if (error == null) return;
      game.value.onGameError(error);
    });


    validateAtlases();
  }

  late final Games games;
  late final IsometricNetwork network;
  late final GameAudio audio;
  late final IsometricScene scene;
  late final IsometricParticles particles;
  late final IsometricDebug debug;
  late final IsometricEditor editor;
  late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricPlayer player;
  late final IsometricUI ui;

  var framesPerSmokeEmission = 10;

  var updateAmbientAlphaAccordingToTimeEnabled = true;

  var totalAmbientOffscreen = 0;

  var totalAmbientOnscreen = 0;

  var renderResponse = true;

  var renderCursorEnable = true;

  var clearErrorTimer = -1;

  var nextEmissionSmoke = 0;

  var cursorType = IsometricCursorType.Hand;

  var srcXRainFalling = 6640.0;

  var srcXRainLanding = 6739.0;

  var messageStatusDuration = 0;

  var areaTypeVisibleDuration = 0;

  var nextLightingUpdate = 0;

  var interpolationPadding = 0.0;

  var nodesRaycast = 0;

  var windLine = 0;

  final lighting = Lighting();

  final colors = IsometricColors();

  final imagesLoadedCompleted = Completer();

  final textEditingControllerMessage = TextEditingController();

  final textFieldMessage = FocusNode();

  final panelTypeKey = <int, GlobalKey>{};

  final playerTextStyle = TextStyle(color: Colors.white);

  final timeVisible = Watch(true);

  final windowOpenMenu = WatchBool(false);

  final operationStatus = Watch(OperationStatus.None);

  final region = Watch<ConnectionRegion?>(ConnectionRegion.LocalHost);

  final serverFPS = Watch(0);

  final images = Images();

  final options = IsometricOptions();

  final triggerAlarmNoMessageReceivedFromServer = Watch(false);

  final imagesLoaded = Future.value(false);

  final sceneEditable = Watch(false);

  final sceneName = Watch<String?>(null);

  final gameRunning = Watch(true);

  final weatherBreeze = Watch(false);

  final minutes = Watch(0);

  final lightningType = Watch(LightningType.Off);

  final watchTimePassing = Watch(false);

  final sceneUnderground = Watch(false);

  final animation = IsometricAnimation();

  late final Map<int, dartUI.Image> mapGameObjectTypeToImage;

  late final messageBoxVisible = Watch(false, clamp: (bool value) {
    return value;
  }, onChanged: ui.onVisibilityChangedMessageBox);

  late final edit = Watch(false, onChanged:  onChangedEdit);

  late final messageStatus = Watch('', onChanged: onChangedMessageStatus);

  late final raining = Watch(false, onChanged: onChangedRaining);

  late final areaTypeVisible = Watch(false, onChanged: onChangedAreaTypeVisible);

  late final gameTimeEnabled = Watch(false, onChanged: onChangedGameTimeEnabled);

  late final lightningFlashing = Watch(false, onChanged: onChangedLightningFlashing);

  late final rainType = Watch(RainType.None, onChanged:  onChangedRain);

  late final seconds = Watch(0, onChanged:  onChangedSeconds);

  late final hours = Watch(0, onChanged:  onChangedHour);

  late final windTypeAmbient = Watch(WindType.Calm, onChanged:  onChangedWindType);

  late final error = Watch<GameError?>(null, onChanged: _onChangedGameError);

  late final account = Watch<Account?>(null, onChanged: onChangedAccount);

  late final gameType = Watch(GameType.Website, onChanged: onChangedGameType);

  late final game = Watch<Game>(games.website, onChanged: _onChangedGame);

  late final io = GameIO(this);

  late final rendersSinceUpdate = Watch(0, onChanged: onChangedRendersSinceUpdate);

  late final Engine engine;

  late final IsometricCompositor compositor;

  late final IsometricRender render;

  bool get playMode => !editMode;

  bool get editMode => edit.value;

  bool get lightningOn =>  lightningType.value != LightningType.Off;

  double get windLineRenderX {
    var windLineColumn = 0;
    var windLineRow = 0;
    if (windLine < scene.totalRows){
      windLineColumn = 0;
      windLineRow =  scene.totalRows - windLine - 1;
    } else {
      windLineRow = 0;
      windLineColumn = windLine - scene.totalRows + 1;
    }
    return (windLineRow - windLineColumn) * Node_Size_Half;
  }

  void drawCanvas(Canvas canvas, Size size) {
    if (gameType.value == GameType.Website)
      return;

    totalAmbientOffscreen = 0;
    totalAmbientOnscreen = 0;

    camera.update();
    particles.update();
    scene.update();
    compositor.render3D();
    renderEditMode();
    renderMouseTargetName();
    debug.render();
    game.value.drawCanvas(canvas, size);
    rendersSinceUpdate.value++;

    engine.renderSprite(
        image: images.template_spinning,
        srcX: (256.0 * animation.frame8),
        srcY: 0,
        srcWidth: 256,
        srcHeight: 256,
        dstX: spinningPosition.renderX,
        dstY: spinningPosition.renderY,
        scale: 0.4,
    );
  }

  final spinningPosition = Position(x: 1500, y: 1500, z: 25);

  void update(){

    if (!network.websocket.connected)
      return;

    if (!gameRunning.value) {
      io.writeByte(ClientRequest.Update);
      io.applyKeyboardInputToUpdateBuffer(this);
      io.sendUpdateBuffer();
      return;
    }

    updateClearErrorTimer();
    game.value.update();

    audio.update();
    particles.update();
    animation.update();
    player.update();
    lighting.update();

    scene.updateProjectiles();
    scene.updateGameObjects();
    readPlayerInputEdit();

    io.applyKeyboardInputToUpdateBuffer(this);
    io.sendUpdateBuffer();

    updateParticleEmitters();

    interpolationPadding = ((scene.interpolationLength + 1) * Node_Size) / engine.zoom;
    if (areaTypeVisible.value) {
      if (areaTypeVisibleDuration-- <= 0) {
        areaTypeVisible.value = false;
      }
    }

    if (messageStatusDuration > 0) {
      messageStatusDuration--;
      if (messageStatusDuration <= 0) {
        messageStatus.value = '';
      }
    }

    if (nextLightingUpdate-- <= 0){
      nextLightingUpdate = IsometricConstants.Frames_Per_Lighting_Update;
      updateAmbientAlphaAccordingToTime();
    }
  }

  void readPlayerInputEdit() {
    if (!edit.value)
      return;

    if (engine.keyPressedSpace) {
      engine.panCamera();
    }
    if (engine.keyPressed(KeyCode.Delete)) {
      editor.delete();
    }
    if (io.getInputDirectionKeyboard() != IsometricDirection.None) {
      actionSetModePlay();
    }
    return;
  }

  void onPlayerInitialized(){
    player.position.x = 0;
    player.position.y = 0;
    player.position.z = 0;
    player.previousPosition.x = 0;
    player.previousPosition.y = 0;
    player.previousPosition.z = 0;
    player.indexZ = 0;
    player.indexRow = 0;
    player.indexColumn = 0;
    scene.characters.clear();
    scene.projectiles.clear();
    scene.gameObjects.clear();
    scene.totalProjectiles = 0;
    scene.totalCharacters = 0;
  }

  void projectShadow(Position v3){
    if (!scene.inBoundsPosition(v3)) return;

    final z = getProjectionZ(v3);
    if (z < 0) return;
    particles.spawnParticle(
      type: ParticleType.Shadow,
      x: v3.x,
      y: v3.y,
      z: z,
      angle: 0,
      speed: 0,
      duration: 2,
    );
  }

  double getProjectionZ(Position vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;

    while (true) {
      if (z < 0) return -1;
      final nodeIndex =  scene.getIndexXYZ(x, y, z);
      final nodeOrientation =  scene.nodeOrientations[nodeIndex];

      if (const <int> [
        NodeOrientation.None,
        NodeOrientation.Radial,
        NodeOrientation.Half_South,
        NodeOrientation.Half_North,
        NodeOrientation.Half_East,
        NodeOrientation.Half_West,
      ].contains(nodeOrientation)) {
        z -= IsometricConstants.Node_Height;
        continue;
      }
      if (z > Node_Height){
        return z + (z % Node_Height);
      } else {
        return Node_Height;
      }
    }
  }

  void clean() {
    scene.colorStackIndex = -1;
    scene.ambientStackIndex = -1;
  }

  void onChangedLightningFlashing(bool lightningFlashing){
    if (lightningFlashing) {
      audio.thunder(1.0);
    } else {
      updateAmbientAlphaAccordingToTime();
    }
  }

  void onChangedGameTimeEnabled(bool value){
    timeVisible.value = value;
  }

  void clear() {
     player.position.x = -1;
     player.position.y = -1;
     player.gameDialog.value = null;
     player.npcTalkOptions.value = [];
     scene.totalProjectiles = 0;
     particles.particles.clear();
    engine.zoom = 1;
  }

  int get bodyPartDuration =>  randomInt(120, 200);

  void updateParticleEmitters(){
    if (nextEmissionSmoke-- > 0)
      return;

    nextEmissionSmoke = framesPerSmokeEmission;

    for (var i = 0; i < scene.smokeSourcesTotal; i++){
      final index = scene.smokeSources[i];
      particles.emitSmoke(
          x: scene.getIndexPositionX(index),
          y: scene.getIndexPositionY(index),
          z: scene.getIndexPositionZ(index),
          duration: 250,
      );
    }

    for (final gameObject in scene.gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ObjectType.Barrel_Flaming) continue;
      particles.emitSmoke(
          x: gameObject.x + giveOrTake(5),
          y: gameObject.y + giveOrTake(5),
          z: gameObject.z + 35,
      );
    }
  }

  // PROPERTIES
  int get currentTimeInSeconds => (hours.value * Duration.secondsPerHour) + ( minutes.value * 60);

  void updateAmbientAlphaAccordingToTime(){
    if (!updateAmbientAlphaAccordingToTimeEnabled)
      return;

    scene.ambientAlpha = convertSecondsToAmbientAlpha(currentTimeInSeconds);

    if (rainType.value == RainType.Light){
      scene.ambientAlpha += lighting.rainAmbienceLight;
    }
    if ( rainType.value == RainType.Heavy){
      scene.ambientAlpha += lighting.rainAmbientHeavy;
    }
  }

  void refreshRain(){
    switch ( rainType.value) {
      case RainType.None:
        break;
      case RainType.Light:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Light_X;
        if ( windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = AtlasNode.Node_Rain_Falling_Light_X;
        } else {
          srcXRainFalling = 1851;
        }
        break;
      case RainType.Heavy:
        srcXRainLanding = AtlasNode.Node_Rain_Landing_Heavy_X;
        if ( windTypeAmbient.value == WindType.Calm){
          srcXRainFalling = 1900;
        } else {
          srcXRainFalling = 1606;
        }
        break;
    }
  }

  void showMessage(String message){
    messageStatus.value = '';
    messageStatus.value = message;
  }

  void spawnConfettiPlayer() {
    for (var i = 0; i < 10; i++){
      particles.spawnParticleConfetti(
        player.position.x,
        player.position.y,
         player.position.z,
      );
    }
  }

  void playSoundWindow() =>
      audio.click_sound_8(1);

  void messageClear(){
    writeMessage('');
  }

  void writeMessage(String value){
     messageStatus.value = value;
  }

  void playAudioError(){
    audio.errorSound15();
  }

  void onChangedAttributesWindowVisible(bool value){
     playSoundWindow();
  }

  void onChangedRaining(bool raining){
    raining ?  scene.rainStart() :  scene.rainStop();
    scene.resetNodeColorsToAmbient();
  }

  void onChangedMessageStatus(String value){
    if (value.isEmpty){
       messageStatusDuration = 0;
    } else {
       messageStatusDuration = 150;
    }
  }

  void onChangedAreaTypeVisible(bool value) =>
       areaTypeVisibleDuration = value
          ? 150
          : 0;

  void onChangedCredits(int value){
    audio.coins.play();
  }

  Particle spawnParticleFire({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0
  }) =>
      particles.spawnParticle(
        type: ParticleType.Fire,
        x: x,
        y: y,
        z: z,
        zv: 1,
        angle: 0,
        rotation: 0,
        speed: 0,
        scaleV: 0.01,
        weight: -1,
        duration: duration,
        scale: scale,
      )
        ..emitsLight = true
        ..emissionColor = scene.ambientColor
        ..deactiveOnNodeCollision = false
        ..emissionIntensity = 0.5
  ;

  void spawnParticleLightEmissionAmbient({
    required double x,
    required double y,
    required double z,
  }) =>
      particles.spawnParticle(
        type: ParticleType.Light_Emission,
        x: x,
        y: y,
        z: z,
        angle: 0,
        speed: 0,
        weight: 0,
        duration: 35,
        animation: true,
      )
        ..flash = true
        ..emissionColor = scene.ambientColor
        ..emissionIntensity = 0.0
  ;

  // @override
  void onError(Object error, StackTrace stack) {
    if (error.toString().contains('NotAllowedError')){
      // https://developer.chrome.com/blog/autoplay/
      // This error appears when the game attempts to fullscreen
      // without the user having interacted first
      // TODO dispatch event on fullscreen failed
      onErrorFullscreenAuto();
      return;
    }
    print(error.toString());
    print(stack);
    games.website.error.value = error.toString();
  }

  // @override
  void onChangedNetworkConnectionStatus(ConnectionStatus connection) {
    print('isometric.onChangedNetworkConnectionStatus($connection)');
    network.responseReader.bufferSize.value = 0;

    switch (connection) {
      case ConnectionStatus.Connected:
        engine.cursorType.value = CursorType.None;
        engine.zoomOnScroll = true;
        engine.zoom = 1.0;
        engine.targetZoom = 1.0;
        audio.enabledSound.value = true;
        if (!engine.isLocalHost) {
          engine.fullScreenEnter();
        }
        break;

      case ConnectionStatus.Done:
        engine.cameraX = 0;
        engine.cameraY = 0;
        engine.zoom = 1.0;
        engine.drawCanvasAfterUpdate = true;
        engine.cursorType.value = CursorType.Basic;
        engine.fullScreenExit();
        player.active.value = false;
        clear();
        clean();
        scene.gameObjects.clear();
        sceneEditable.value = false;
        gameType.value = GameType.Website;
        audio.enabledSound.value = false;
        break;
      case ConnectionStatus.Failed_To_Connect:
        games.website.error.value = 'Failed to connect';
        break;
      case ConnectionStatus.Invalid_Connection:
        games.website.error.value = 'Invalid Connection';
        break;
      case ConnectionStatus.Error:
        games.website.error.value = 'Connection Error';
        break;
      default:
        break;
    }

  }

  void onChangedGameType(GameType value) {
    print('onChangedGameType(${value.name})');
    io.reset();
    startGameByType(value);
  }

  void startGameByType(GameType gameType){
    game.value = games.mapGameTypeToGame(gameType);
  }

  void onScreenSizeChanged(
      double previousWidth,
      double previousHeight,
      double newWidth,
      double newHeight,
      ) => detectInputMode();

  void onDeviceTypeChanged(int deviceType){
    detectInputMode();
  }

  void startGameType(GameType gameType){
    network.connectToGame(gameType);
  }

  /// EVENT HANDLER (DO NOT CALL)
  void _onChangedGame(Game game) {
    engine.buildUI = game.buildUI;
    engine.onLeftClicked = game.onLeftClicked;
    engine.onRightClicked = game.onRightClicked;
    engine.onKeyPressed = game.onKeyPressed;
    game.onActivated();
  }

  void _onChangedGameError(GameError? gameError){
    print('_onChangedGameError($gameError)');
    if (gameError == null)
      return;

    clearErrorTimer = 300;
    playAudioError();
    switch (gameError) {
      case GameError.Unable_To_Join_Game:
        games.website.error.value = 'unable to join game';
        network.websocket.disconnect();
        break;
      default:
        break;
    }
  }

  void onChangedAccount(Account? account) {
    // if (account == null) return;
    // final flag = 'subscription_status_${account.userId}';
    // if (storage.contains(flag)){
    //   final storedSubscriptionStatusString = storage.get<String>(flag);
    //   final storedSubscriptionStatus = parseSubscriptionStatus(storedSubscriptionStatusString);
    // }
  }

  void updateClearErrorTimer() {
    if (clearErrorTimer <= 0)
      return;

    clearErrorTimer--;
    if (clearErrorTimer > 0)
      return;

    error.value = null;
  }

  void doRenderForeground(Canvas canvas, Size size){
    if (!network.websocket.connected)
      return;
    renderCursor(canvas);
    renderPlayerAimTargetNameText();

    if (io.inputModeTouch) {
      io.touchController.render(canvas);
    }

    game.value.renderForeground(canvas, size);
  }

  Future init(sharedPreferences) async {
    print('isometric.init()');
    images.load(this);
    await imagesLoadedCompleted.future;
  }

  void onMouseEnterCanvas(){
    renderCursorEnable = true;
  }

  void onMouseExitCanvas(){
    renderCursorEnable = false;
  }

  var initialized = false;

  Widget build(BuildContext context) {
    print('isometric.build()');

    if (initialized){
      print('isometric.build already initialized - skipping');
      return engine;
    }

    initialized = true;

    print('uri-base-host: ${Uri.base.host}');
    print('region-detected: ${detectConnectionRegion()}');

    engine = Engine(
      init: init,
      update: update,
      render: drawCanvas,
      onDrawForeground: doRenderForeground,
      title: 'AMULET',
      themeData: ThemeData(fontFamily: 'VT323-Regular'),
      backgroundColor: IsometricColors.black,
      onError: onError,
      buildUI: games.website.buildUI,
      buildLoadingScreen: () => LoadingPage(),
    );

    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
    engine.drawCanvasAfterUpdate = true;
    engine.cursorType.value = CursorType.Basic;
    engine.deviceType.onChanged(onDeviceTypeChanged);
    engine.onScreenSizeChanged = onScreenSizeChanged;
    engine.onMouseEnterCanvas = onMouseEnterCanvas;
    engine.onMouseExitCanvas = onMouseExitCanvas;
    onEngineBuilt();
    return engine;
  }

  void onEngineBuilt(){
    print('isometric.onEngineBuilt()');
    compositor = IsometricCompositor(this);
    scene.engine = engine;
    engine.drawCanvasAfterUpdate = false;
    renderResponse = true;
  }

  void onReadRespondFinished() {
    engine.onDrawCanvas = drawCanvas;

    if (renderResponse){
      engine.redrawCanvas();
    }
  }

  void detectInputMode() =>
      io.inputMode.value = engine.deviceIsComputer
          ? InputMode.Keyboard
          : InputMode.Touch;

  void playAudioSingleV3({
    required AudioSingle audioSingle,
    required Position position,
    double maxDistance = 600}) => playAudioXYZ(
        audioSingle,
        position.x,
        position.y,
        position.z,
        maxDistance: maxDistance,
    );

  void playAudioXYZ(
    AudioSingle audioSingle,
    double x,
    double y,
    double z,{
      double maxDistance = 600,
    }){
    if (!audio.enabledSound.value) return;
    // TODO calculate distance from camera

    final distanceFromPlayer = getDistanceXYZ(x, y, z, player.x, player.y, player.z);;
    final distanceVolume = GameAudio.convertDistanceToVolume(
      distanceFromPlayer,
      maxDistance: maxDistance,
    );
    audioSingle.play(volume: distanceVolume);
    // play(volume: distanceVolume);
  }

  void refreshGameObjectEmissionColor(GameObject gameObject){
    // TODO
    // gameObject.emissionColor = hsvToColor(
    //   hue: interpolate(ambientHue, gameObject.emissionHue, gameObject.emissionIntensity).toInt(),
    //   saturation: interpolate(ambientSaturation, gameObject.emissionSat, gameObject.emissionIntensity).toInt(),
    //   value: interpolate(ambientValue, gameObject.emissionVal, gameObject.emissionIntensity).toInt(),
    //   opacity: interpolate(ambientAlpha, gameObject.emissionAlp, gameObject.emissionIntensity).toInt(),
    // );
  }

  bool isOnscreen(Position position) {
    const Pad_Distance = 75.0;
    final rx = position.renderX;

    if (rx < engine.Screen_Left - Pad_Distance || rx > engine.Screen_Right + Pad_Distance)
      return false;

    final ry = position.renderY;
    return ry > engine.Screen_Top - Pad_Distance && ry < engine.Screen_Bottom + Pad_Distance;
  }

  Color get color => engine.paint.color;

  set color(Color color) => engine.paint.color = color;

  void renderShadow(double x, double y, double z, {double scale = 1}) =>
      engine.renderSprite(
        image: images.atlas_gameobjects,
        dstX: (x - y) * 0.5,
        dstY: ((y + x) * 0.5) - z,
        srcX: 0,
        srcY: 32,
        srcWidth: 8,
        srcHeight: 8,
        scale: min(scale, 1),
      );

  bool isPerceptiblePosition(Position position) {
    if (!player.playerInsideIsland)
      return true;

    if (scene.outOfBoundsPosition(position))
      return false;

    final index = scene.getIndexPosition(position);
    final indexRow = scene.getIndexRow(index);
    final indexColumn = scene.getIndexRow(index);
    final i = indexRow * scene.totalColumns + indexColumn;
    // TODO REFACTOR
    if (!compositor.rendererNodes.island[i])
      return true;
    final indexZ = scene.getIndexZ(index);
    if (indexZ > player.indexZ + 2)
      return false;

    // TODO REFACTOR
    return compositor.rendererNodes.visible3D[index];
  }

  void renderCircleAroundPlayer({required double radius}) =>
      render.circleOutlineAtPosition(
        position: player.position,
        radius: radius,
      );

  void setColorWhite(){
    engine.setPaintColorWhite();
  }

  void spawnPurpleFireExplosion(double x, double y, double z, {int amount = 5}){

    playAudioXYZ(audio.magical_impact_16,x, y, z);

    for (var i = 0; i < amount; i++) {
      particles.spawnParticleFirePurple(
        x: x + giveOrTake(5),
        y: y + giveOrTake(5),
        z: z, speed: 1,
        angle: randomAngle(),
      );
    }
  }

  void renderEditMode() {
    if (playMode) return;
    if (editor.gameObjectSelected.value){
      engine.renderCircleOutline(
        sides: 24,
        radius: 30,
        x: editor.gameObject.value!.renderX,
        y: editor.gameObject.value!.renderY,
        color: Colors.white,
      );
      render.circleOutlineAtPosition(position: editor.gameObject.value!, radius: 50);
      return;
    }

    render.editWireFrames();
    renderMouseWireFrame();
  }

  double getVolumeTargetWind() {
    final windLineDistance = (engine.screenCenterRenderX - windLineRenderX).abs();
    final windLineDistanceVolume = GameAudio.convertDistanceToVolume(windLineDistance, maxDistance: 300);
    var target = 0.0;
    if (windLineRenderX - 250 <= engine.screenCenterRenderX) {
      target += windLineDistanceVolume;
    }
    final index = windTypeAmbient.value;
    if (index <= WindType.Calm) {
      if (hours.value < 6) return target;
      if (hours.value < 18) return target + 0.1;
      return target;
    }
    if (index <= WindType.Gentle) return target + 0.5;
    return 1.0;
  }

  void renderMouseWireFrame() {
    io.mouseRaycast(render.wireFrameBlue);
  }

  void renderPlayerAimTargetNameText(){
    if (player.aimTargetCategory == TargetCategory.Nothing)
      return;
    if (player.aimTargetName.isEmpty)
      return;
    const style = TextStyle(color: Colors.white, fontSize: 18);
    engine.renderText(
      player.aimTargetName,
      engine.worldToScreenX(player.aimTargetPosition.renderX),
      engine.worldToScreenY(player.aimTargetPosition.renderY),
      style: style,
    );
  }

  void canvasRenderCursorCrossHair(Canvas canvas, double range){
    const srcX = 0;
    const srcY = 192;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() - range,
        anchorY: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() + range,
        anchorY: 0.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() - range,
        dstY: io.getCursorScreenY(),
        anchorX: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY(),
        anchorX: 0.0
    );
  }

  void canvasRenderCursorCrossHairRed(Canvas canvas, double range){
    const srcX = 0;
    const srcY = 384;
    const offset = 0;
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() - range - offset,
        anchorY: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 29,
        srcY: srcY + 0,
        srcWidth: 6,
        srcHeight: 22,
        dstX: io.getCursorScreenX(),
        dstY: io.getCursorScreenY() + range - offset,
        anchorY: 0.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() - range,
        dstY: io.getCursorScreenY() - offset,
        anchorX: 1.0
    );
    engine.renderExternalCanvas(
        canvas: canvas,
        image: images.atlas_icons,
        srcX: srcX + 0,
        srcY: srcY + 29,
        srcWidth: 22,
        srcHeight: 6,
        dstX: io.getCursorScreenX() + range,
        dstY: io.getCursorScreenY() - offset,
        anchorX: 0.0
    );
  }

  void canvasRenderCursorHand(Canvas canvas){
    engine.renderExternalCanvas(
      canvas: canvas,
      image: images.atlas_icons,
      srcX: 0,
      srcY: 256,
      srcWidth: 64,
      srcHeight: 64,
      dstX: io.getCursorScreenX(),
      dstY: io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void canvasRenderCursorTalk(Canvas canvas){
    engine.renderExternalCanvas(
      canvas: canvas,
      image: images.atlas_icons,
      srcX: 0,
      srcY: 320,
      srcWidth: 64,
      srcHeight: 64,
      dstX: io.getCursorScreenX(),
      dstY: io.getCursorScreenY(),
      scale: 0.5,
    );
  }

  void renderCursor(Canvas canvas) {

    if (!renderCursorEnable)
      return;

    final cooldown = player.weaponCooldown.value;
    final accuracy = player.accuracy.value;
    final distance = ((1.0 - cooldown) + (1.0 - accuracy)) * 10.0 + 5;

    switch (cursorType) {
      case IsometricCursorType.CrossHair_White:
        canvasRenderCursorCrossHair(canvas, distance);
        break;
      case IsometricCursorType.Hand:
        canvasRenderCursorHand(canvas);
        return;
      case IsometricCursorType.Talk:
        canvasRenderCursorTalk(canvas);
        return;
      case IsometricCursorType.CrossHair_Red:
        canvasRenderCursorCrossHairRed(canvas, distance);
        break;
    }
  }

  void renderMouseTargetName() {
    if (!player.mouseTargetAllie.value) return;
    final mouseTargetName = player.mouseTargetName.value;
    if (mouseTargetName == null) return;
    render.renderText(
        value: mouseTargetName,
        x: player.aimTargetPosition.renderX,
        y: player.aimTargetPosition.renderY - 55);
  }

  void renderStarsV3(Position v3) =>
      renderStars(v3.renderX, v3.renderY - 40);

  void renderStars(double x, double y) =>
      engine.renderSprite(
        image: images.sprite_stars,
        srcX: 125.0 * animation.frame16,
        srcY: 0,
        srcWidth: 125,
        srcHeight: 125,
        dstX: x,
        dstY: y,
        scale: 0.4,
      );

  void notifyLoadImagesCompleted() {
    print('isometric.notifyLoadImagesCompleted()');
    compositor.rendererNodes.atlasNodes = images.atlas_nodes;
    compositor.rendererNodes.atlasNodesLoaded = true;
    imagesLoadedCompleted.complete(true);

    mapGameObjectTypeToImage = <int, dartUI.Image> {
      GameObjectType.Weapon: images.atlas_weapons,
      GameObjectType.Object: images.atlas_gameobjects,
      GameObjectType.Head: images.atlas_head,
      GameObjectType.Body: images.atlas_body,
      GameObjectType.Legs: images.atlas_legs,
      GameObjectType.Item: images.atlas_items,
    };
  }

  dartUI.Image getImageForGameObjectType(int type) =>
      mapGameObjectTypeToImage [type] ?? (
          throw Exception(
              'isometric.getImageForGameObjectType(type: ${GameObjectType.getName(type)}})'
          )
      );
}
