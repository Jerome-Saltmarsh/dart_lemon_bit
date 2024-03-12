
import 'package:amulet_flutter/amulet/amulet.dart';
import 'package:amulet_flutter/amulet_app.dart';
import 'package:amulet_flutter/isometric/classes/isometric_game.dart';
import 'package:amulet_flutter/website/website_game.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_environment.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_screen.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_characters.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_gameobjects.dart';
import 'package:amulet_flutter/gamestream/isometric/components/render/renderer_particles.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/isometric_colors.dart';
import 'package:amulet_flutter/packages/lemon_components.dart';

import 'components/isometric_options.dart';
import 'components/isometric_render.dart';
import 'components/render/renderer_editor.dart';
import 'components/render/renderer_nodes.dart';
import 'components/render/renderer_projectiles.dart';
import 'components/src.dart';
import 'ui/game_isometric_minimap.dart';


class IsometricComponents extends ComponentContainer {
  var ready = false;
  final AmuletApp engine;
  final WebsiteGame website;
  final Amulet amulet;
  final IsometricRender render;
  final IsometricOptions options;
  final IsometricAudio audio;
  final IsometricParticles particles;
  final IsometricCompositor compositor;
  final IsometricServer network;
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
  final RendererEditor rendererEditor;
  final IsometricActions action;
  final IsometricEvents events;
  final IsometricParser responseReader;
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
    required this.rendererEditor,
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
    required this.amulet,
    required this.animation,
    required this.screen,
    required this.lighting,
    required this.colors,
    required this.style,
    required this.engine,
  }) {
    print('IsometricComponents()');
    engine.onError = onError;

    components.add(images);
    components.add(scene);
    components.add(environment);
    components.add(rendererNodes);
    components.add(rendererCharacters);
    components.add(rendererParticles);
    components.add(rendererProjectiles);
    components.add(rendererGameObjects);
    components.add(rendererEditor);
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
    components.add(amulet);
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
      component.rendererEditor = rendererEditor;
      component.server = network;
      component.player = player;
      component.audio = audio;
      component.particles = particles;
      component.editor = editor;
      component.debugger = debug;
      component.minimap = minimap;
      component.camera = camera;
      component.mouse = mouse;
      component.ui = ui;
      component.io = io;
      component.render = render;
      component.actions = action;
      component.events = events;
      component.parser = responseReader;
      component.website = website;
      component.amulet = amulet;
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
    ready = true;
  }
}

