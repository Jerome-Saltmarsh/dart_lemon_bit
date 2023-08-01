
import 'dart:async';
import 'dart:math';
import 'dart:ui' as dartUI;

import 'package:firestore_client/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/functions/validate_atlas.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/moba/moba.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_environment.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_network.dart';
import 'package:gamestream_flutter/gamestream/game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_gameobjects.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/extensions/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/network/enums/connection_region.dart';
import 'package:gamestream_flutter/gamestream/operation_status.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/loading_page.dart';

import '../network/functions/detect_connection_region.dart';
import 'classes/src.dart';
import 'components/isometric_options.dart';
import 'components/isometric_render.dart';
import 'components/render/renderer_nodes.dart';
import 'components/render/renderer_projectiles.dart';
import 'components/src.dart';
import 'enums/cursor_type.dart';
import 'ui/game_isometric_minimap.dart';
import 'ui/isometric_constants.dart';



class Isometric {

  var componentsReady = false;

  final components = <dynamic>[];

  late final WebsiteGame website;
  late final MmoGame mmo;
  late final Moba moba;
  late final CaptureTheFlagGame captureTheFlag;
  late final IsometricGame isometricEditor;

  late final Engine engine;
  late final IsometricRender render;
  late final IsometricOptions options;
  late final GameAudio audio;
  late final IsometricParticles particles;
  late final IsometricCompositor compositor;
  late final IsometricNetwork network;

  late final IsometricScene scene;
  late final IsometricDebug debug;
  late final IsometricEditor editor;
  late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricPlayer player;
  late final IsometricUI ui;
  late final GameIO io;
  late final IsometricEnvironment environment;
  late final RendererNodes rendererNodes;
  late final RendererCharacters rendererCharacters;
  late final RendererParticles rendererParticles;
  late final RendererProjectiles rendererProjectiles;
  late final RendererGameObjects rendererGameObjects;
  late final IsometricActions action;
  late final IsometricEvents events;
  late final IsometricResponseReader responseReader;
  late final IsometricAnimation animation;
  late final IsometricImages images;

  Isometric() {
    print('Isometric()');
    images = IsometricImages();
    environment = IsometricEnvironment();
    rendererNodes = RendererNodes();
    rendererCharacters = RendererCharacters();
    rendererParticles = RendererParticles();
    rendererProjectiles = RendererProjectiles();
    rendererGameObjects = RendererGameObjects();
    editor = IsometricEditor();
    debug = IsometricDebug();
    minimap = IsometricMinimap();
    mouse = IsometricMouse();
    ui = IsometricUI();
    render = IsometricRender();
    action = IsometricActions();
    events = IsometricEvents();
    responseReader = IsometricResponseReader();
    camera = IsometricCamera();
    player = IsometricPlayer();
    scene = IsometricScene();
    io = GameIO();
    network = IsometricNetwork();
    audio = GameAudio();
    options = IsometricOptions();
    particles = IsometricParticles();
    compositor = IsometricCompositor();
    website = WebsiteGame();
    mmo = MmoGame();
    moba = Moba();
    captureTheFlag = CaptureTheFlagGame();
    isometricEditor = IsometricGame();
    animation = IsometricAnimation();

    components.add(images);
    components.add(scene);
    components.add(environment);
    components.add(rendererNodes);
    components.add(rendererCharacters);
    components.add(rendererParticles);
    components.add(rendererProjectiles);
    components.add(rendererGameObjects);
    components.add(network);
    components.add(player);
    components.add(audio);
    components.add(particles);
    components.add(editor);
    components.add(debug);
    components.add(minimap);
    components.add(camera);
    components.add(mouse);
    components.add(ui);
    components.add(io);
    components.add(render);
    components.add(action);
    components.add(events);
    components.add(responseReader);
    components.add(options);
    components.add(compositor);
    components.add(website);
    components.add(mmo);
    components.add(moba);
    components.add(captureTheFlag);
    components.add(isometricEditor);
    components.add(animation);

    for (final component in components) {
      if (component is! IsometricComponent)
        continue;

      component.isometric = this;
      component.scene = scene;
      component.environment = environment;
      component.rendererNodes = rendererNodes;
      component.rendererParticles = rendererParticles;
      component.rendererCharacters = rendererCharacters;
      component.rendererProjectiles = rendererProjectiles;
      component.rendererGameObjects = rendererGameObjects;
      component.network = network;
      component.player = player;
      component.audio = audio;
      component.particles = particles;
      component.editor = editor;
      component.debug = debug;
      component.minimap = minimap;
      component.camera = camera;
      component.mouse = mouse;
      component.ui = ui;
      component.io = io;
      component.render = render;
      component.action = action;
      component.events = events;
      component.responseReader = responseReader;
      component.website = website;
      component.options = options;
      component.animation = animation;
      component.images = images;
    }
    validateAtlases();
  }


  var totalAmbientOffscreen = 0;
  var totalAmbientOnscreen = 0;
  var renderResponse = true;
  var renderCursorEnable = true;
  var cursorType = IsometricCursorType.Hand;
  var nextLightingUpdate = 0;
  var interpolationPadding = 0.0;
  var nodesRaycast = 0;
  final lighting = Lighting();
  final colors = IsometricColors();
  final imagesLoadedCompleted = Completer();
  final textEditingControllerMessage = TextEditingController();
  final textFieldMessage = FocusNode();
  final panelTypeKey = <int, GlobalKey>{};
  final playerTextStyle = TextStyle(color: Colors.white);
  final windowOpenMenu = WatchBool(false);
  final operationStatus = Watch(OperationStatus.None);
  final region = Watch<ConnectionRegion?>(ConnectionRegion.LocalHost);
  final serverFPS = Watch(0);
  final imagesLoaded = Future.value(false);
  final sceneName = Watch<String?>(null);
  final gameRunning = Watch(true);
  final watchTimePassing = Watch(false);

  late final Map<int, dartUI.Image> mapGameObjectTypeToImage;


  void drawCanvas(Canvas canvas, Size size) {

    if (!componentsReady)
      return;

    if (options.gameType.value == GameType.Website)
      return;

    totalAmbientOffscreen = 0;
    totalAmbientOnscreen = 0;
    camera.update();
    particles.update();
    compositor.render3D();
    renderEditMode();
    renderMouseTargetName();
    debug.drawCanvas();
    options.game.value.drawCanvas(canvas, size);
    options.rendersSinceUpdate.value++;
  }

  void update(){

    if (!componentsReady)
      return;

    if (!network.websocket.connected)
      return;

    if (!gameRunning.value) {
      io.writeByte(ClientRequest.Update);
      io.applyKeyboardInputToUpdateBuffer(this);
      io.sendUpdateBuffer();
      return;
    }

    options.update();
    options.updateClearErrorTimer();
    options.game.value.update();
    scene.update();
    audio.update();
    particles.update();
    animation.update();
    player.update();
    lighting.update();
    readPlayerInputEdit();
    io.applyKeyboardInputToUpdateBuffer(this);
    io.sendUpdateBuffer();

    interpolationPadding = ((scene.interpolationLength + 1) * Node_Size) / engine.zoom;



    if (nextLightingUpdate-- <= 0){
      nextLightingUpdate = IsometricConstants.Frames_Per_Lighting_Update;
      scene.updateAmbientAlphaAccordingToTime();
    }
  }

  void readPlayerInputEdit() {
    if (!options.edit.value)
      return;

    if (engine.keyPressedSpace) {
      engine.panCamera();
    }
    if (engine.keyPressed(KeyCode.Delete)) {
      editor.delete();
    }
    if (io.getInputDirectionKeyboard() != IsometricDirection.None) {
      // actionSetModePlay();
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

  // @override
  void onError(Object error, StackTrace stack) {
    if (error.toString().contains('NotAllowedError')){
      // https://developer.chrome.com/blog/autoplay/
      // This error appears when the game attempts to fullscreen
      // without the user having interacted first
      // TODO dispatch event on fullscreen failed
      // onErrorFullscreenAuto();
      return;
    }
    print(error.toString());
    print(stack);
    website.error.value = error.toString();
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

  void onChangedAccount(Account? account) {

  }

  void doRenderForeground(Canvas canvas, Size size){
    if (!network.websocket.connected)
      return;
    renderCursor(canvas);
    renderPlayerAimTargetNameText();

    if (io.inputModeTouch) {
      io.touchController.render(canvas);
    }

    options.game.value.renderForeground(canvas, size);
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
      buildUI: (context){
        return buildText('loading components');
      },
      buildLoadingScreen: () => LoadingPage(),
    );

    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
    // engine.drawCanvasAfterUpdate = true;
    // engine.drawCanvasAfterUpdate = false;
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

    for (final component in components){
      if (component is IsometricComponent)
        component.engine = engine;
    }
    for (final component in components) {
      if (component is IsometricComponent)
        component.onComponentReady();
    }
    componentsReady = true;
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


  void renderEditMode() {
    if (options.playMode) return;
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
    imagesLoadedCompleted.complete(true);

    for (final component in components){
      if (component is IsometricComponent)
        component.onImagesLoaded();
    }

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

  Game mapGameTypeToGame(GameType gameType) => switch (gameType) {
    GameType.Website => website,
    GameType.Capture_The_Flag => captureTheFlag,
    GameType.Editor => isometricEditor,
    GameType.Moba => moba,
    GameType.Mmo => mmo,
    _ => throw Exception('mapGameTypeToGame($gameType)')
  };
}
