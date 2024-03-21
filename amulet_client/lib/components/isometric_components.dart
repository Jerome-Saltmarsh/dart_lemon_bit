
import 'package:amulet_client/classes/amulet.dart';
import 'package:amulet_client/components/isometric_environment.dart';
import 'package:amulet_client/components/isometric_screen.dart';
import 'package:amulet_client/components/render/renderer_characters.dart';
import 'package:amulet_client/components/render/renderer_gameobjects.dart';
import 'package:amulet_client/components/render/renderer_particles.dart';
import 'package:amulet_client/components.dart';
import 'package:amulet_client/ui/game_isometric_minimap.dart';
import 'package:amulet_client/ui/isometric_colors.dart';
import 'package:lemon_engine/lemon_engine.dart';

import 'debug/isometric_debug.dart';
import 'editor/isometric_editor.dart';
import 'isometric_actions.dart';
import 'isometric_animation.dart';
import 'isometric_audio.dart';
import 'isometric_camera.dart';
import 'isometric_component.dart';
import 'isometric_compositor.dart';
import 'isometric_events.dart';
import 'isometric_images.dart';
import 'isometric_io.dart';
import 'isometric_lighting.dart';
import 'isometric_mouse.dart';
import 'isometric_options.dart';
import 'isometric_parser.dart';
import 'isometric_particles.dart';
import 'isometric_player.dart';
import 'isometric_render.dart';
import 'isometric_scene.dart';
import 'isometric_server.dart';
import 'isometric_style.dart';
import 'isometric_ui.dart';
import 'render/renderer_editor.dart';
import 'render/renderer_nodes.dart';
import 'render/renderer_projectiles.dart';
import 'src.dart';


class IsometricComponents extends ComponentContainer {
  var componentsConnected = false;
  final LemonEngine engine;
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

  IsometricComponents({
    required this.engine,
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
    required this.amulet,
    required this.animation,
    required this.screen,
    required this.lighting,
    required this.colors,
    required this.style,
  }) {
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
    components.add(amulet);
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
    componentsConnected = true;
  }
}

