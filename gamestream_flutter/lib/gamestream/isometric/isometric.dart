
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/functions/validate_atlas.dart';
import 'package:gamestream_flutter/gamestream/games/capture_the_flag/capture_the_flag_game.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/games/moba/moba.dart';
import 'package:gamestream_flutter/gamestream/games/website/website_game.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_environment.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_screen.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_gameobjects.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_particles.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_colors.dart';
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
import 'ui/game_isometric_minimap.dart';


class Isometric {

  var initialized = false;
  var componentsReady = false;

  final components = <dynamic>[];
  final updatable = <Updatable>[];

  late final WebsiteGame website;
  late final MmoGame mmo;
  late final Moba moba;
  late final CaptureTheFlagGame captureTheFlag;
  late final IsometricGame isometricEditor;
  late final Engine engine;
  late final IsometricRender render;
  late final IsometricOptions options;
  late final IsometricAudio audio;
  late final IsometricParticles particles;
  late final IsometricCompositor compositor;
  late final IsometricNetwork network;
  late final IsometricScreen screen;
  late final IsometricScene scene;
  late final IsometricDebug debug;
  late final IsometricEditor editor;
  late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricPlayer player;
  late final IsometricUI ui;
  late final IsometricIO io;
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
  late final IsometricLighting lighting;
  late final IsometricColors colors;
  late final IsometricStyle style;

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
    io = IsometricIO();
    network = IsometricNetwork();
    audio = IsometricAudio();
    options = IsometricOptions();
    particles = IsometricParticles();
    compositor = IsometricCompositor();
    website = WebsiteGame();
    mmo = MmoGame();
    moba = Moba();
    captureTheFlag = CaptureTheFlagGame();
    isometricEditor = IsometricGame();
    animation = IsometricAnimation();
    screen = IsometricScreen();
    lighting = IsometricLighting();
    colors = IsometricColors();
    style = IsometricStyle();

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
    components.add(screen);
    components.add(lighting);
    components.add(colors);
    components.add(style);

    for (final component in components) {
      if (component is Updatable) {
        updatable.add(component);
      }
      if (component is! IsometricComponent) {
        continue;
      }

      component.findComponent = findComponent;
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
      component.amulet = mmo;
      component.captureTheFlag = captureTheFlag;
      component.options = options;
      component.animation = animation;
      component.images = images;
      component.screen = screen;
      component.colors = colors;
      component.compositor = compositor;
      component.lighting = lighting;
      component.style = style;
    }
    validateAtlases();
  }

  T findComponent<T>() {
    for (final component in components){
      if (component is T)
        return component;
    }
    throw Exception('{method: "isometric.findComponent(component: $T)", reason: "could not be found"}');
  }

  void drawCanvas(Canvas canvas, Size size) {

    if (options.gameType.value == GameType.Website)
      return;

    camera.update();
    particles.update();
    compositor.render3D();
    render.renderEditMode();
    render.renderMouseTargetName();
    debug.drawCanvas();
    options.game.value.drawCanvas(canvas, size);
    options.rendersSinceUpdate.value++;
  }

  void update() {

    if (!network.websocket.connected)
      return;

    if (!options.gameRunning.value) {
      io.writeByte(ClientRequest.Update);
      io.applyKeyboardInputToUpdateBuffer(this);
      io.sendUpdateBuffer();
      return;
    }

    for (final updatable in updatable) {
      updatable.update();
    }

    readPlayerInputEdit();
    io.applyKeyboardInputToUpdateBuffer(this);
    io.sendUpdateBuffer();

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

  void drawForeground(Canvas canvas, Size size){

    if (!network.websocket.connected)
      return;

    render.renderCursor(canvas);
    render.renderPlayerAimTargetNameText();

    if (io.inputModeTouch) {
      io.touchController.drawCanvas(canvas);
    }

    options.game.value.renderForeground(canvas, size);
  }

  Future init(sharedPreferences) async {
    print('isometric.init()');
    await images.load(this);
    dispatchNotificationImagesLoaded();
  }

  void onMouseEnterCanvas(){
    options.renderCursorEnable = true;
  }

  void onMouseExitCanvas(){
    options.renderCursorEnable = false;
  }

  Widget build(BuildContext context) {
    print('isometric.build()');

    if (initialized){
      print('isometric.build() - skipped as already initialized');
      return engine;
    }

    initialized = true;

    print('uri-base-host: ${Uri.base.host}');
    print('region-detected: ${detectConnectionRegion()}');

    engine = Engine(
      init: init,
      update: () {}, // overridden when components are ready
      render: (canvas, size) {}, // overridden when components are ready
      onDrawForeground: (canvas, size) {}, // overridden when components are ready
      title: 'AMULET',
      themeData: ThemeData(fontFamily: 'VT323-Regular'),
      backgroundColor: colors.black,
      onError: onError,
      buildUI: (context){
        return buildText('loading components');
      },
      buildLoadingScreen: () => LoadingPage(),
    );

    engine.durationPerUpdate.value = convertFramesPerSecondToDuration(20);
    engine.cursorType.value = CursorType.Basic;
    engine.onMouseEnterCanvas = onMouseEnterCanvas;
    engine.onMouseExitCanvas = onMouseExitCanvas;
    onEngineBuilt();
    return engine;
  }

  void onError(Object error, StackTrace stack){
    print('isometric.onError()');
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
    engine.onUpdate = update;
    engine.onDrawCanvas = drawCanvas;
    engine.onDrawForeground = drawForeground;
  }

  void dispatchNotificationImagesLoaded() {
    print('isometric.dispatchNotificationImagesLoaded()');
    for (final component in components){
      if (component is IsometricComponent)
        component.onImagesLoaded();
    }
  }
}

