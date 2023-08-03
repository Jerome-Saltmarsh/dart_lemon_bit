
import 'dart:async';

import 'package:flutter/material.dart';
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

import 'classes/src.dart';
import 'components/isometric_options.dart';
import 'components/isometric_render.dart';
import 'components/render/renderer_nodes.dart';
import 'components/render/renderer_projectiles.dart';
import 'components/src.dart';
import 'ui/game_isometric_minimap.dart';


class Isometric {

  var initialized = false;

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
  }

  void update() {
    for (final updatable in updatable) {
      updatable.onComponentUpdate();
    }
  }

  Future init(sharedPreferences) async {
    print('isometric.init()');
    await images.load(this);
    dispatchNotificationImagesLoaded();
  }

  Widget build(BuildContext context) {
    print('isometric.build()');

    if (initialized){
      print('isometric.build() - skipped as already initialized');
      return engine;
    }

    initialized = true;
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

    for (final component in components){
      if (component is IsometricComponent)
        component.engine = engine;
    }
    engine.onUpdate = update;
    dispatchNotificationComponentsReady();
    return engine;
  }

  void onError(Object error, StackTrace stack){
    print('isometric.onError()');
  }

  void dispatchNotificationComponentsReady(){
    print('isometric.dispatchNotificationComponentsReady()');
    for (final component in components) {
      if (component is IsometricComponent)
        component.onComponentReady();
    }
  }

  void dispatchNotificationImagesLoaded() {
    print('isometric.dispatchNotificationImagesLoaded()');
    for (final component in components){
      if (component is IsometricComponent)
        component.onImagesLoaded();
    }
  }
}

