
import 'package:amulet_client/classes/amulet.dart';
import 'package:amulet_client/components/render/renderer_characters.dart';
import 'package:amulet_client/components/src.dart';
import 'package:amulet_client/ui/isometric_colors.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'debug/isometric_debug.dart';
import 'editor/src.dart';
import 'isometric_actions.dart';
import 'isometric_animation.dart';
import 'isometric_audio.dart';
import 'isometric_camera.dart';
import 'isometric_compositor.dart';
import 'isometric_environment.dart';
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
import 'isometric_screen.dart';
import 'isometric_server.dart';
import 'isometric_style.dart';
import 'isometric_ui.dart';
import 'render/renderer_editor.dart';
import 'render/renderer_gameobjects.dart';
import 'render/renderer_nodes.dart';
import 'render/renderer_particles.dart';
import 'render/renderer_projectiles.dart';

mixin IsometricComponent implements Component {
  late final LemonEngine engine;
  late final IsometricAnimation animation;
  late final IsometricServer server;
  late final IsometricParticles particles;
  late final IsometricPlayer player;
  late final IsometricScene scene;
  late final IsometricEnvironment environment;
  late final IsometricAudio audio;
  late final RendererCharacters rendererCharacters;
  late final RendererNodes rendererNodes;
  late final RendererParticles rendererParticles;
  late final RendererProjectiles rendererProjectiles;
  late final RendererGameObjects rendererGameObjects;
  late final RendererEditor rendererEditor;
  late final IsometricEditor editor;
  late final IsometricDebug debugger;
  // late final IsometricMinimap minimap;
  late final IsometricCamera camera;
  late final IsometricMouse mouse;
  late final IsometricUI ui;
  late final IsometricRender render;
  late final IsometricActions actions;
  late final IsometricEvents events;
  late final IsometricOptions options;
  late final IsometricParser parser;
  late final Amulet amulet;
  late final IsometricIO io;
  late final IsometricImages images;
  late final IsometricScreen screen;
  late final IsometricLighting lighting;
  late final IsometricColors colors;
  late final IsometricCompositor compositor;
  late final IsometricStyle style;

  /// (save to override)
  Future onComponentInit(SharedPreferences sharedPreferences) async {  }

  /// (save to override)
  void onComponentReady(){  }

  /// (save to override)
  void onComponentError(Object error, StackTrace stack) {}

  /// (save to override)
  void onComponentDispose() {

  }
}