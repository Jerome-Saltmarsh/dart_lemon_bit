
import 'dart:async';

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
import 'package:gamestream_flutter/lemon_ioc/updatable.dart';
import 'package:gamestream_flutter/library.dart';

import 'classes/src.dart';
import 'components/isometric_options.dart';
import 'components/isometric_render.dart';
import 'components/render/renderer_nodes.dart';
import 'components/render/renderer_projectiles.dart';
import 'components/src.dart';
import 'ui/game_isometric_minimap.dart';

class IOCContainer {
  final components = <dynamic>[];
  final updatable = <Updatable>[];

  void update() {
    for (final updatable in updatable) {
      updatable.onComponentUpdate();
    }
  }

  Future init(sharedPreferences) async {
    print('iocContainer.init()');

    for (final component in components){
      if (component is Updatable) {
        updatable.add(component);
      }
    }

    for (final component in components){
      if (component is IsometricComponent)
        await component.initializeComponent(sharedPreferences);
    }

    for (final component in components){
      if (component is IsometricComponent)
        component.onComponentsInitialized();
    }
  }

  void onError(Object error, StackTrace stack){
    for (final component in components){
      if (component is IsometricComponent)
        component.onError(error, stack);
    }
  }
}

class IsometricComponents extends IOCContainer {
  final Engine engine;
  final WebsiteGame website;
  final MmoGame mmo;
  final Moba moba;
  final CaptureTheFlagGame captureTheFlag;
  final IsometricRender render;
  final IsometricOptions options;
  final IsometricAudio audio;
  final IsometricParticles particles;
  final IsometricCompositor compositor;
  final IsometricNetwork network;
  final IsometricScreen screen;
  final IsometricScene scene;
  final IsometricDebug debug;
  final IsometricEditor editor;
  final IsometricMinimap minimap;
  final IsometricCamera camera;
  final IsometricMouse mouse;
  final IsometricPlayer player;
  final IsometricUI ui;
  final IsometricIO io;
  final IsometricEnvironment environment;
  final RendererNodes rendererNodes;
  final RendererCharacters rendererCharacters;
  final RendererParticles rendererParticles;
  final RendererProjectiles rendererProjectiles;
  final RendererGameObjects rendererGameObjects;
  final IsometricActions action;
  final IsometricEvents events;
  final IsometricResponseReader responseReader;
  final IsometricAnimation animation;
  final IsometricImages images;
  final IsometricLighting lighting;
  final IsometricColors colors;
  final IsometricStyle style;

  final IsometricGame isometricEditor = IsometricGame();

  IsometricComponents({
    required this.images,
    required this.environment,
    required this.rendererNodes,
    required this.rendererCharacters,
    required this.rendererParticles,
    required this.rendererProjectiles,
    required this.rendererGameObjects,
    required this.editor,
    required this.debug,
    required this.minimap,
    required this.mouse,
    required this.ui,
    required this.render,
    required this.action,
    required this.events,
    required this.responseReader,
    required this.camera,
    required this.player,
    required this.scene,
    required this.io,
    required this.network,
    required this.audio,
    required this.options,
    required this.particles,
    required this.compositor,
    required this.website,
    required this.mmo,
    required this.moba,
    required this.captureTheFlag,
    required this.animation,
    required this.screen,
    required this.lighting,
    required this.colors,
    required this.style,
    required this.engine,
  }) {
    print('IsometricComponents()');
    engine.onInit = init;
    engine.onUpdate = update;
    engine.onError = onError;

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
      component.engine = engine;
    }
  }
}

